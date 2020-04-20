<table class="tbl-heading"><tr><td class="td-logo">

![](./images/obe_tag.png)

Sept 1, 2019
</td>
<td class="td-banner">
# Lab 11: Protect your data with Database Vault
</td></tr><table>

To **log issues**, click [here](https://github.com/oracle/learning-library/issues/new) to go to the github oracle repository issue submission form.

## Introduction


Managed database services run the risk of 'Admin snooping', allowing privileged users access to customer data. Oracle Exadata Cloud Service provides powerful security controls within your database, restricting access to application data by privileged database users, reducing the risk of insider and outsider threats and addressing common compliance requirements.

You can deploy controls to block privileged account access to application data and control sensitive operations inside the database. Trusted paths can be used to add additional security controls to authorized data access and database changes. Through the runtime analysis of privileges and roles, you can increase the security of existing applications by implementing least privileges and reducing the attack profile of your database accounts. IP addresses, usernames, client program names and other factors can be used as part of Oracle Database Vault security controls to increase security.  Oracle Database Vault secures existing database environments transparently, eliminating costly and time consuming application changes.

**For more information, refer to the [Database Vault Administrator’s Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dvadm/introduction-to-oracle-database-vault.html).

## Objectives

As a database security admin,

- Configure and enable Database Vault for your Exadata Cloud Service database instance
- Create a realm to restrict schema access
- Add audit policy to audit Database Vault activities


## Required Artifacts

- An Oracle Cloud Infrastructure account

- A pre-provisioned instance of Oracle Developer Client image in an application subnet. Refer to [Lab2](20DeployImage.md)

- A pre-provisioned Autonomous Transaction Processing instance. Refer to [Lab 1](./10ProvisionAnATPDatabase.md)

## Steps

### **STEP 1: Set up Application Schema and Users**

Oracle Database vault comes pre-installed with your Autonomous database on dedicated infrastructure. In this lab we will enable Database Vault (DV), add required user accounts and create a DV realm to secure a set of user tables from priviledged user access. 

Our implementation scenario looks as follow,

![](./images/Infra/db_vault/DVarchitecture.png)

The HR schema contains multiple tables. The employees table contains sensitive information such as employee names, SSN, pay-scales etc. and needs to be protected from priviledged users such as the schema owner (user HR) and sys (DBA).

The table should however be available to the application user (appuser). Note that while the entire HR schema can be added to DV, here we demonstrate more fine grained control by simply adding a single table to the vault.

**Let's start by creating the HR schema and the appuser accounts**


- Connect to your ExaCS database pdb as user `sys`. Open terminal in the dev client instance and ssh into one of the database nodes.
  ````
  $ ssh -i <private-key> opc@<private-ip-of-db-node>
  $ sudo su - oracle
  $ ls
  ````
  You should see `<your-database-name>.env` file after executing `ls`.
- Enter `$ source <your-database-name>.env` to configure all the required environment variables into the current session.
  ````
  $ source <your-database-name>.env
  ````
- Find your pdb name with the following command.
  ```
  $ cd $ORACLE_HOME/network/admin
  $ ls
  $ cd <your-database-folder>
  $ cat tnsnames.ora
  ```
  ![](./images/Infra/db_vault/find-pdb.png)

- Login to your pdb as `SYS` with `SYSDBA` privileges `$ sqlplus sys@<your-pdb-name> as sysdba;` and enter password for the `SYS` user.

  ![](./images/Infra/db_vault/sys-pdb.png)

- Now, create the schema `hr` and table `employees`:

  ````
  SQL> create user hr identified by WElcome_123#;
  SQL> grant create session, create table to hr;
  SQL> grant unlimited tablespace to hr;
  SQL> create table hr.employees (id number, name varchar2 (20), salary number);
  SQL> insert into hr.employees values (10,'Larry',20000);
  SQL> commit;
  ````
  ![](./images/Infra/db_vault/create-hr.png)

- Next, create the application user `appuser`.

  ````
  SQL> create user appuser identified by WElcome_123#;
  SQL> grant create session, read any table to appuser;
  SQL> exit;
  ````
  ![](./images/Infra/db_vault/create-appuser.png)

### **STEP 2: Configure and enable Database Vault**

We start with creating the two DV user accounts - DV Owner and DV Account Manager. The dv_owner account is mandatory as an owner of DV objects. DV account manager is an optional but recommended role. Once DV is enabled, the user 'SYS' loses its ability to create/drop DB user accounts and that privilege is then with the DV Account Manager role. While DV Owner can also become DV account manager, it is recommended to maintain separation of duties via two different accounts.

- Login to the database CDB as `SYS` with sysdba privileges.
  ````
  $ sqlplus sys as sysdba;
  SQL> show con_name;
  ````
  ![](./images/Infra/db_vault/sys-cdb.png)
- Create the common user accounts `c##dv_owner1` and `c##dv_acctmgr1` and assign `dv_owner` and `dv_acctmgr` roles respectively.
  ````
  SQL> create user c##dv_owner1 identified by WElcome_123#;

  SQL> grant dv_owner, create session, set container, audit_admin to c##dv_owner1 container=all;

  SQL> create user c##dv_acctmgr1 identified by WElcome_123#;

  SQL> grant dv_acctmgr, create session, set container to c##dv_acctmgr1 container=all;

  SQL> commit;
  ````
  ![](./images/Infra/db_vault/create-dvusers.png)
- Open a new terminal tab/window and ssh into the database node.
  ````
    $ ssh -i <private-key> opc@<private-ip-of-db-node>
    $ sudo su - oracle
    $ source <your-database-name>.env
    $ cd $ORACLE_HOME
    $ vi configure_dv.sql
  ````
  Copy and paste the following into the vi editor. Press `Esc` and `:wq!` to save and quit.
  ````
    BEGIN
      CONFIGURE_DV (
        dvowner_uname         => 'c##dv_owner1',
        dvacctmgr_uname       => 'c##dv_acctmgr1');
    END;
    /
  ````

- Come back to the first terminal where you have SQL prompt still connected to the CDB of your database and execute the following.
  ````
  SQL> @?/configure_dv.sql
  SQL> @?/rdbms/admin/utlrp.sql
  ````
  ![](./images/Infra/db_vault/configuredv-cdb.png)

- Now, connect as `c##dv_owner1` and check if the database vault is enabled with the following statement. It should return `False`.
  ````
  SQL> conn c##dv_owner1;
  SQL> SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';
  ````
  ![](./images/Infra/db_vault/cdb-dv-false.png)


- Enable the database vault. Then, connect as `SYS` and restart the CDB.
  ````
  SQL> exec dbms_macadm.enable_dv;
  SQL> conn sys as sysdba;
  SQL> shutdown immediate;
  SQL> startup
  ````
  ![](./images/Infra/db_vault/dv-enable-cdb.png)

- Now, check if the database vault is enabled in CDB.
  ````
  SQL> SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';
  SQL> SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';
  SQL> SELECT * FROM DVSYS.DBA_DV_STATUS;
  SQL> exit
  ````
  ![](./images/Infra/db_vault/cdb-dv-true.png)



- Now, we need to enable the database vault in the pdb. In this example, my pdb name is `vltpdb2`. Log in as `SYS` with sysdba privileges to your pdb.
  ````
  $ sqlplus sys@<your-pdb-name> as sysdba;
  ````
  ![](./images/Infra/db_vault/sys-pdb.png)

- Grant necessary privileges to the common user accounts.
  ````
  SQL> GRANT CREATE SESSION, SET CONTAINER TO c##dv_owner1 CONTAINER = CURRENT;
 
  SQL> GRANT CREATE SESSION, SET CONTAINER TO c##dv_acctmgr1 CONTAINER = CURRENT;
 
  SQL> grant select any dictionary to c##dv_owner1;

  SQL> grant select any dictionary to C##DV_ACCTMGR1;
  ````
  ![](./images/Infra/db_vault/grant-pdb.png)
- Configure and enable database vault in the pdb.
  ````
  SQL> @?/configure_dv.sql
  SQL> @?/rdbms/admin/utlrp.sql
  ````
  ![](./images/Infra/db_vault/configuredv-pdb.png)

- Now, connect as `c##dv_owner1` and check if the database vault is enabled with the following statement. It should return `False`.
  ````
  SQL> conn c##dv_owner1@<your-pdb-name>;
  SQL> SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';
  SQL> exit
  ````
  ![](./images/Infra/db_vault/pdb-dv-false.png)

***********
- Open a new terminal window and ssh into the database node.
  ````
    $ ssh -i <private-key> opc@<private-ip-of-db-node>
    $ sudo su - oracle
    $ source <your-database-name>.env
    $ cd $ORACLE_HOME/rdbms/lib
    $ make –f ins_rdbms.mk dv_on lbac_on ipc_rds ioracle
  ````
- Come back to the previous terminal and connect as `SYS` to your pdb and enable Oracle Label Security. to your pdb. 
  ```
  $ sqlplus sys@<your-pdb-name> as sysdba;
  SQL> EXEC LBACSYS.CONFIGURE_OLS;
  SQL> EXEC LBACSYS.OLS_ENFORCEMENT.ENABLE_OLS;
  ```
  ![](./images/Infra/db_vault/enable-ols.png)

- Login as `SYS` with `SYSOPER` privilege and restart the database.
  ```
  $ sqlplus sys@<your-pdb-name> as sysoper;
  SQL> shutdown immediate
  SQL> startup
  SQL> SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';
  SQL> conn c##dv_owner1
  SQL> exec dbms_macadm.enable_dv;
  ```
  ![](./images/Infra/db_vault/restart-enable-dv.png)

- Now, check if the database vault is enabled in PDB.
  ````
  SQL> SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Database Vault';

  SQL> SELECT VALUE FROM V$OPTION WHERE PARAMETER = 'Oracle Label Security';

  SQL> SELECT * FROM DVSYS.DBA_DV_STATUS;
  ````
  ![](./images/Infra/db_vault/cdb-dv-true.png)
- Now that the database vault is successfully configured and enabled in both CDB and PDB, let us go ahead and create security realms and policies.

### **STEP 3: Create security Realms and add schema objects**

Next we create a 'Realm', add objects to it and define access rules for the realm.

Let's create a realm to secure HR.EMPLOYEES table from SYS and HR (table owner) and grant access to APPUSER only.

- Open a new terminal window and ssh into the database node.
  ````
    $ ssh -i <private-key> opc@<private-ip-of-db-node>
    $ sudo su - oracle
    $ source <your-database-name>.env
    $ cd $ORACLE_HOME
    $ vi create_realm.sql
  ````
- Copy and paste the following into the vi editor. Press `Esc` and `:wq!` to save and quit.
  ````
  BEGIN
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
  / 
  ````
- Come back to the first terminal where you have SQL prompt still connected to the PDB of your database, connect as `c##dv_owner1` and execute the script.
  ````
  SQL> conn c##dv_owner1@<your-pdb-name>;
  SQL> @?/create_realm.sql
  ````
  ![](./images/Infra/db_vault/create-realm.png)


### **STEP 4: Create Audit Policy to Capture Realm Violations**

You may also want to capture an audit trail of unauthorized access attempts to your realm objects. Since the Exadata Cloud Service includes Unified Auditing, we will create a policy to audit database vault activities. For more information on Unified Auditing, refer to the [Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/introduction-to-auditing.html)

- Create an audit policy to capture realm violations.

  ````
  SQL> create audit policy dv_realm_hr actions select, update, delete actions component=DV Realm Violation ON "HR App";
  SQL> audit policy dv_realm_hr;
  SQL> exit;
  ````

  ![](./images/Infra/db_vault/create-audit-policy.png)


- Finally, let's test how this all works. To test the realm, try to access the EMPLOYEES table as HR, SYS and then APPUSER, you can test with a combination of SELECT and DML statements.
- Connect as `SYS` to your pdb and test the access.
  ````
  $ sqlplus sys@vltpdb2 as sysdba;
  SQL> select * from hr.employees;
  SQL> exit

  SQL> sqlplus hr/WElcome_123#@<your-pdb-name>;
  SQL> select user from dual;
  SQL> select * from hr.employees;
  SQL> exit

  SQL> sqlplus appuser/WElcome_123#@<your-pdb-name>;
  SQL> select user from dual;
  SQL> select * from hr.employees;
  ````
  ![](./images/Infra/db_vault/sys-access-fail.png)

  ![](./images/Infra/db_vault/hr-access-fail.png)

  ![](./images/Infra/db_vault/appuser-access-success.png)



**Note: The default `SYS` account in the database has access to all objects in the database, but realm objects are now protected from `SYS` access. In fact, even the table owner `HR` does not have access to this table. Only `APPUSER` has access.**

### **STEP 5: Review realm violation audit trail**

We can query the audit trail to generate a basic report of realm access violations. 

- Connect as Audit Administrator, in this lab this is the Database Vault owner, and execute the following:

  ````
  $ sqlplus c##dv_owner1/WElcome_123#@<your-pdb-name>;
  SQL> set head off
  SQL> select os_username, dbusername, event_timestamp, action_name, sql_text from UNIFIED_AUDIT_TRAIL where DV_ACTION_NAME='Realm Violation Audit';
  ````
  ![](./images/Infra/db_vault/access-violations.png)

  You can see the access attempts from `HR` and `SYS`.

That is it! You have successfully enabled and used database vault in your Exadata cloud database.

If you'd like to reset your database to its original state, follow the steps below -

To remove the components created for this lab and reset the database back to the original configuration. 
As Database Vault owner, execute:

````
SQL> noaudit policy dv_realm_hr;
SQL> drop audit policy dv_realm_hr;
SQL> EXEC DBMS_MACADM.DELETE_REALM('HR App');
SQL> EXEC DBMS_MACADM.DISABLE_DV;
SQL> exit;
````

Restart the CDB and PDB as `SYS`.
````
$ sqlplus sys/WElcome_123# as sysdba;
SQL> shutdown immediate;
SQL> startup;
SQL> alter pluggable database <your-pdb-name> close immediate;
SQL> alter pluggable database <your-pdb-name> open;

````
![](./images/Infra/db_vault/restart.png)

<table>
<tr><td class="td-logo">

[![](images/obe_tag.png)](#)</td>
<td class="td-banner">
### Congratulations! You successfully learnt to use database vault in your Exadata Cloud Service database.




</td>
</tr>
<table>