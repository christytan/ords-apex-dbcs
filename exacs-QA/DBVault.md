## Introduction


Managed database services run the risk of 'Admin snooping', allowing privileged users access to customer data. Oracle Exadata Cloud Service provides powerful security controls within your database, restricting access to application data by privileged database users, reducing the risk of insider and outsider threats and addressing common compliance requirements.

You can deploy controls to block privileged account access to application data and control sensitive operations inside the database. Trusted paths can be used to add additional security controls to authorized data access and database changes. Through the runtime analysis of privileges and roles, you can increase the security of existing applications by implementing least privileges and reducing the attack profile of your database accounts. IP addresses, usernames, client program names and other factors can be used as part of Oracle Database Vault security controls to increase security.  Oracle Database Vault secures existing database environments transparently, eliminating costly and time consuming application changes.

**For more information, refer to the [Database Vault Administrator’s Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dvadm/introduction-to-oracle-database-vault.html).

To log issues and view the Lab Guide source, go to the [github oracle](https://github.com/oracle/learning-library/issues/new) repository.

## Objectives

As a database security admin,

- Configure and enable Database Vault for your Exadata Cloud Service database instance
- Create a realm to restrict schema access
- Add audit policy to audit Database Vault activities


## Required Artifacts

- An Oracle Cloud Infrastructure account

- A pre-provisioned instance of Oracle Developer Client image in an application subnet. Refer to [Lab 2](?lab=lab-2-provision-exadata-infrastructure)

- A pre-provisioned Autonomous Transaction Processing instance. Refer to [Lab 1](?lab=lab-1-preparing-private-data-center-o)

## Steps

### **STEP 1: Set up Application Schema and Users**

Oracle Database vault comes pre-installed with your Autonomous database on dedicated infrastructure. In this lab we will enable Database Vault (DV), add required user accounts and create a DV realm to secure a set of user tables from privileged user access. 

Our implementation scenario looks as follows,

![](./images/Infra/db_vault/DVarchitecture.png " ")

The HR schema contains multiple tables. The employees table contains sensitive information such as employee names, SSN, pay-scales etc. and needs to be protected from privileged users such as the schema owner (user HR) and sys (DBA).

The table should however be available to the application user (appuser). Note that while the entire HR schema can be added to DV, here we demonstrate more fine grained control by simply adding a single table to the vault.

**Let's start by creating the HR schema and the appuser accounts**

- Connect to your dev client using VNC Viewer. Refer to [Lab 4](?lab=lab-4-configure-development-system-for-use) for reference.

- Open terminal in the dev client instance and ssh into one of the database nodes.
  ```
  <copy>ssh -i /path/to/private/key opc@private-ip-of-db-node</copy>
  ```
- Change to `oracle` user.
  ```
  <copy>sudo su - oracle</copy>
  ```
- List all the files.
  ```
  <copy>ls</copy>
  ```
  You should see `your-database-name.env` file after executing `ls`.
- Configure all the required environment variables into the current session.
  ```
  <copy>source your-database-name.env</copy>
  ```
- To find the pdb name of your database, login as `SYS`.
  ```
  <copy>sqlplus sys as sysdba;</copy>
  ```
  ```
  <copy>show pdbs;</copy>
  ```
- Under `CON_NAME` you will see your `PDB$SEED` and `your-pdb-name` listed as shown in the figure below (in this example, my pdb name is `TFPDB1`). Save this pdb name to be used in later parts of the lab.
  
  ![](./images/Infra/db_vault/find-pdb.png " ")


- Change to your pdb at SQL prompt.
  ```
  <copy>alter session set container=your-pdb-name;</copy>
  ```

- Now, create the schema `hr` and table `employees`:

  ```
  <copy>create user hr identified by WElcome_123#;</copy>
  ```
  ```
  <copy>grant create session, create table to hr;</copy>
  ```
  ```
  <copy>grant unlimited tablespace to hr;</copy>
  ```
  ```
  <copy>create table hr.employees (id number, name varchar2 (20), salary number);</copy>
  ```
  ```
  <copy>insert into hr.employees values (10,'Larry',20000);</copy>
  ```
  ```
  <copy>commit;</copy>
  ```
  ![](./images/Infra/db_vault/create-hr.png " ")

- Next, create the application user `appuser`.

  ```
  <copy>create user appuser identified by WElcome_123#;</copy>
  ```
  ```
  <copy>grant create session, read any table to appuser;</copy>
  ```
  ```
  <copy>exit;</copy>
  ```
  ![](./images/Infra/db_vault/create-appuser.png " ")

### **STEP 2: Configure and enable Database Vault**

We start with creating the two DV user accounts - DV Owner and DV Account Manager. The dv_owner account is mandatory as an owner of DV objects. DV account manager is an optional but recommended role. Once DV is enabled, the user 'SYS' loses its ability to create/drop DB user accounts and that privilege is then with the DV Account Manager role. While DV Owner can also become DV account manager, it is recommended to maintain separation of duties via two different accounts.

In this step, we will need to configure and enable database vault in both CDB and PDB of the database.


- Login to the CDB as `SYS` with sysdba privileges.
  ```
  <copy>sqlplus sys as sysdba;</copy>
  ```
  ![](./images/Infra/db_vault/sys-cdb.png " ")

- Create the common user accounts `c##dv_owner1` and `c##dv_acctmgr1` and assign `dv_owner` and `dv_acctmgr` roles respectively.
  ```
  <copy>create user c##dv_owner1 identified by WElcome_123#;</copy>
  ```
  ```
  <copy>grant dv_owner, create session, set container, audit_admin to c##dv_owner1 container=all;</copy>
  ```
  ```
  <copy>create user c##dv_acctmgr1 identified by WElcome_123#;</copy>
  ```
  ```
  <copy>grant dv_acctmgr, create session, set container to c##dv_acctmgr1 container=all;</copy>
  ```
  ```
  <copy>commit;</copy>
  ```
  ```
  <copy>exit;</copy>
  ```
  ![](./images/Infra/db_vault/create-dvusers.png " ")

- Change to `ORACLE_HOME`.
  ```
  <copy>cd $ORACLE_HOME</copy>
  ```
- Create a sql file `configure_dv.sql`.
  ```
  <copy>vi configure_dv.sql</copy>
  ```
- Press `i` on your keyboard to change to insert mode and copy and paste the following into the vi editor. Press `Esc` and `:wq!` to save and quit.
  
  ```
      <copy>
      BEGIN
        CONFIGURE_DV (
          dvowner_uname         => 'c##dv_owner1',
          dvacctmgr_uname       => 'c##dv_acctmgr1');
      END;
      /
      </copy>
  ```

#############Comment#########
- Open a new terminal tab/window and ssh into the database node.
  
````
<copy>ssh -i <private-key> opc@<private-ip-of-db-node>
sudo su - oracle
source <your-database-name>.env
cd $ORACLE_HOME
vi configure_dv.sql</copy>
  ````
#############Comment#########

- Connect to your CDB as `SYS`.
  ```
  <copy>sqlplus sys as sysdba;</copy>
  ```
- Execute the `configure_dv.sql` script you just created.
  ```
  <copy>@?/configure_dv.sql</copy>
  ```
  ![](./images/Infra/db_vault/configuredv-cdb.png " ")

- Run the `utlrp.sql` script to recompile invalidated objects.
  ```
  <copy>@?/rdbms/admin/utlrp.sql</copy>
  ```
- Now, connect as `c##dv_owner1` and check if the database vault is enabled with the following statement. It should return `False`.
  ```
  <copy>conn c##dv_owner1/WElcome_123#;</copy>
  ```
  ```
  <copy>SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';</copy>
  ```
  ![](./images/Infra/db_vault/cdb-dv-false.png " ")

**********************************


- Enable the database vault. Then, connect as `SYS` and restart the CDB.

  ```
  <copy>exec dbms_macadm.enable_dv;</copy>
  ```
  ```
  <copy>conn sys as sysdba;</copy>
  ```
  ```
  <copy>shutdown immediate;</copy>
  ```
  ```
  <copy>startup</copy>
  ```

  ![](./images/Infra/db_vault/dv-enable-cdb.png " ")

- Now, check if the database vault is enabled in CDB.
  ```
  <copy>SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';</copy>
  ```
  ```
  <copy>SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';</copy>
  ```
  ```
  <copy>SELECT * FROM DVSYS.DBA_DV_STATUS;</copy>
  ```
  ```
  <copy>exit</copy>
  ````

  ![](./images/Infra/db_vault/cdb-dv-true.png " ")


- Now, we need to enable the database vault in the pdb. Log in as `SYS` with sysdba privileges to your pdb.
  ```
  <copy>sqlplus sys@your-pdb-name as sysdba;</copy>
  ```

  ![](./images/Infra/db_vault/sys-pdb.png " ")

- Grant necessary privileges to the common user accounts.
  ```
  <copy>GRANT CREATE SESSION, SET CONTAINER TO c##dv_owner1 CONTAINER = CURRENT;</copy>
  ```
  ```
  <copy>GRANT CREATE SESSION, SET CONTAINER TO c##dv_acctmgr1 CONTAINER = CURRENT;</copy>
  ```
  ```
  <copy>grant select any dictionary to c##dv_owner1;</copy>
  ```
  ```
  <copy>grant select any dictionary to C##DV_ACCTMGR1;</copy>
  ```

  ![](./images/Infra/db_vault/grant-pdb.png " ")

- Configure database vault in the pdb.

  ```
  <copy>@?/configure_dv.sql</copy>
  ```

- Run the `utlrp.sql` script to recompile invalidated objects.
  ```
  <copy>@?/rdbms/admin/utlrp.sql</copy>
  ```
  ![](./images/Infra/db_vault/configuredv-pdb.png " ")

- Now, connect as `c##dv_owner1` and check if the database vault is enabled with the following statement. It should return `False`.
  ```
  <copy>conn c##dv_owner1/WElcome_123#@your-pdb-name;</copy>
  ```
  ```
  <copy>SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';</copy>
  ```
  ```
  <copy>exit</copy>
  ```

  ![](./images/Infra/db_vault/pdb-dv-false.png " ")

- Change to `ORACLE_HOME/rdbms/lib` and execute the following command.
  ```
  <copy>cd $ORACLE_HOME/rdbms/lib</copy>
  ```
  ```
  <copy>make -f ins_rdbms.mk dv_on lbac_on ipc_rds ioracle</copy>
  ```

- Login as `SYS` into your pdb and enable Oracle Label Security.
  ```
  <copy>sqlplus sys@your-pdb-name as sysdba;</copy>
  ```
  ```
  <copy>EXEC LBACSYS.CONFIGURE_OLS;</copy>
  ```
  ```
  <copy>EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;</copy>
  ```
  ![](./images/Infra/db_vault/enable-ols.png " ")

- Verify if Oracle Label Security is successfully enabled. This should return `TRUE`.
  ```
  <copy>SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';</copy>
  ```
  ![](./images/Infra/db_vault/ols-verify-pdb.png " ")
  

- Now, connect as `c##dv_owner1` to your pdb and enable the database vault.
  ```
  <copy>conn c##dv_owner1/WElcome_123#@your-pdb-name;</copy>
  ```
  ```
  <copy>exec dbms_macadm.enable_dv;</copy>
  ```
  ```
  <copy>exit</copy>
  ```
  ![](./images/Infra/db_vault/conn-enable-dv-pdb.png " ")

- Now, log in as `SYS` and restart the pdb.
  ```
  <copy>sqlplus sys as sysdba;</copy>
  ```
  ```
  <copy>alter pluggable database your-pdb-name close immediate;</copy>
  ```
  ```
  <copy>alter pluggable database your-pdb-name open ;</copy>
  ```
  ```
  <copy>exit</copy>
  ```
  ![](./images/Infra/db_vault/alter-pdb.png " ")

- Verify if database vault is successfully enabled.
  ```
  <copy>sqlplus sys@your-pdb-name as sysdba;</copy>
  ```
  ```
  <copy>conn c##dv_owner1/WElcome_123#@your-pdb-name;</copy>
  ```
  ```
  <copy>SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';</copy>
  ```
  ```
  <copy>SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';</copy>
  ```
  ```
  <copy>SELECT * FROM DVSYS.DBA_DV_STATUS;</copy>
  ```
  ```
  <copy>exit</copy>
  ```
  ![](./images/Infra/db_vault/pdb-dv-true.png " ")

- Now that the database vault is successfully configured and enabled in both CDB and PDB, let us go ahead and create security realms and policies.


### **STEP 3: Create security Realms and add schema objects**

Next we create a 'Realm', add objects to it and define access rules for the realm.

Let's create a realm to secure `HR.EMPLOYEES` table from `SYS` and `HR` (table owner) and grant access to `APPUSER` only.

- Open a new terminal window and ssh into the database node.
  ```
  <copy>cd $ORACLE_HOME</copy>
  ```
  ```
  <copy>vi create_realm.sql</copy>
  ```

- Press `i` and copy and paste the following into the vi editor. Press `Esc` and `:wq!` to save and quit.
  
  ```
    <copy>BEGIN
    DBMS_MACADM.CREATE_REALM(
      realm_name    => 'HR App', 
      description   => 'Realm to protect HR tables', 
      enabled       => 'y', 
      audit_options => DBMS_MACUTL.G_REALM_AUDIT_OFF,
      realm_type    => 1);
    END; 
    /
    BEGIN
    DBMS_MACADM.ADD_OBJECT_TO_REALM(
      realm_name   => 'HR App', 
      object_owner => 'HR', 
      object_name  => 'EMPLOYEES', 
      object_type  => 'TABLE'); 
    END;
    /
    BEGIN
    DBMS_MACADM.ADD_AUTH_TO_REALM(
      realm_name   => 'HR App', 
      grantee      => 'APPUSER');
    END;
    /</copy>
  ```
- Connect to the PDB of your database, connect as `c##dv_owner1` and execute the script.
  ```
  <copy>sqlplus sys@your-pdb-name as sysdba;</copy>
  ```
  ```
  <copy>conn c##dv_owner1/WElcome_123#@your-pdb-name;</copy>
  ```
  ```
  <copy>@?/create_realm.sql</copy>
  ```

  ![](./images/Infra/db_vault/create-realm.png " ")


### **STEP 4: Create Audit Policy to Capture Realm Violations**

You may also want to capture an audit trail of unauthorized access attempts to your realm objects. Since the Exadata Cloud Service includes Unified Auditing, we will create a policy to audit database vault activities. For more information on Unified Auditing, refer to the [Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/introduction-to-auditing.html)

- Create an audit policy to capture realm violations.

  ```
  <copy>create audit policy dv_realm_hr actions select, update, delete actions component=DV Realm Violation ON "HR App";</copy>
  ```
  ```
  <copy>audit policy dv_realm_hr;</copy>
  ```
  ```
  <copy>exit;</copy>
  ```

  ![](./images/Infra/db_vault/create-audit-policy.png " ")


- Finally, let's test how this all works. To test the realm, try to access the EMPLOYEES table as HR, SYS and then APPUSER, you can test with a combination of SELECT and DML statements.
- Connect as `SYS` to your pdb and test the access. You should see an error with insufficient privileges.
  ```
  <copy>sqlplus sys@your-pdb-name as sysdba;</copy>
  ```
  ```
  <copy>select * from hr.employees;</copy>
  ```

- Connect as `HR` and test the access. You should see an error with insufficient privileges.
  ```
  <copy>conn hr/WElcome_123#@<your-pdb-name>;</copy>
  ```
  ```
  <copy>select * from hr.employees;</copy>
  ```

- Connect as `APPUSER` and test the access. This should be successful and you should see the data.
  ```
  <copy>conn appuser/WElcome_123#@<your-pdb-name>;</copy>
  ```
  ```
  <copy>select * from appuser.employees;</copy>
  ```

  ![](./images/Infra/db_vault/sys-access-fail.png " ")

  ![](./images/Infra/db_vault/hr-access-fail.png " ")

  ![](./images/Infra/db_vault/appuser-access-success.png " ")



**Note: The default `SYS` account in the database has access to all objects in the database, but realm objects are now protected from `SYS` access. In fact, even the table owner `HR` does not have access to this table. Only `APPUSER` has access.**

### **STEP 5: Review realm violation audit trail**

We can query the audit trail to generate a basic report of realm access violations. 

- Connect as Audit Administrator, in this lab this is the Database Vault owner, and execute the following:

````
<copy>sqlplus c##dv_owner1/WElcome_123#@<your-pdb-name>;
set head off
select os_username, dbusername, event_timestamp, action_name, sql_text from UNIFIED_AUDIT_TRAIL where DV_ACTION_NAME='Realm Violation Audit';</copy>
````

  ![](./images/Infra/db_vault/access-violations.png " ")

  You can see the access attempts from `HR` and `SYS`.

That is it! You have successfully enabled and used database vault in your Exadata cloud database.

If you'd like to reset your database to its original state, follow the steps below -

To remove the components created for this lab and reset the database back to the original configuration. 
As Database Vault owner, execute:

````
<copy>noaudit policy dv_realm_hr;
drop audit policy dv_realm_hr;
EXEC DBMS_MACADM.DELETE_REALM('HR App');
EXEC DBMS_MACADM.DISABLE_DV;
exit;</copy>
````

Restart the CDB and PDB as `SYS`.

````
<copy>sqlplus sys/WElcome_123# as sysdba;
shutdown immediate;
startup;
alter pluggable database <your-pdb-name> close immediate;
alter pluggable database <your-pdb-name> open;</copy>
````

![](./images/Infra/db_vault/restart.png " ")
