# Install APEX on DBCS and Deploy ORDS

## Introduction

Oracle Application Express (Oracle APEX) is a rapid web application development tool for the Oracle database. Using only a web browser and limited programming experience, you can develop and deploy professional applications that are both fast and secure. Oracle APEX is a fully supported, no cost option of the Oracle database.

Why would you use Oracle APEX?

Oracle Application Express (APEX) is a low-code development platform that enables you to build scalable, secure enterprise apps, with world-class features, that can be deployed anywhere.

Low Code Development

With Oracle APEX and low code, your organization can be more agile - by developing solutions faster, for less cost, and with greater consistency. You can adapt to changing requirements with ease. Empower professional developers and everyone else in your organization to be a part of the solution.

**For more information, refer to the [APEX Documentation](https://apex.oracle.com/en/platform/low-code/)

To **log issues**, click [here](https://github.com/oracle/learning-library/issues/new) to go to the github oracle repository issue submission form.

## Objectives

- Set up Oracle REST Data Services(ORDS) and Application Express (APEX) for the database cloud service database.
- Create a REST Service using APEX and deploy ORDS in standalone mode.


## Required Artifacts

- An Oracle Cloud Infrastructure account

- A pre-provisioned instance of Oracle Database Cloud Service.

- A pre-provisioned Virtual Cloud Network.

- A pre-provisioned instance of Oracle Compute Linux.



**You are all set, let's begin!**

## Steps

### **STEP 1: Set up APEX on Oracle Database Cloud Service**

- Removing the existing APEX from the Container Database(CDB)
```
$ sudo su - oracle
$ cd $ORACLE_HOME/apex
$ sqlplus / as sysdba
SQL > @apxremov_con.sql
PL/SQL procedure successfully completed.
```

- Download and install APEX on PDB
    * Connect to Oracle Database Cloud Service and download the latest apex on [Link](https://www.oracle.com/tools/downloads/apex-downloads.html).


```
$ sudo su -
$ cd /tmp
$ cd wget https://download.oracle.com/otn/java/appexpress/apex_19.1_en.zip?AuthParam=1552035503_zxxxx
```

- Unzip the file in a new folder as root user, change directory into it and then switch to ORACLE user

```
$ unzip apex_zip_folder.zip?xxxxx /u01/app/ -d /u01/app/
$ cd /u01/app
$ chown -R oracle:oinstall apex/
$ cd apex
$ cd su oracle
```

- Connect to PDB
```
$ sqlplus / as sysdba
sql > alter session set container=pdb_name;

session altered.
```

- Create Tablespace for APEX

```
sql > CREATE TABLESPACE apex DATAFILE SIZE 100M AUTOEXTEND ON NEXT 1M;
Tablespace created.
```
- Install APEX on PDB

```
sql > @apexins.sql APEX APEX TEMP /i/
```

- Change ADMIN password for the INTERNAL workspace with @apxchpwd.sql. Leave username unchanged.

```
sql > alter session set container=pdb_name;
sql > @apxchpwd.sql
...set_appun.sql
================================================================================
This script can be used to change the password of an Application Express
instance administrator. If the user does not yet exist, a user record will be
created.
================================================================================
Enter the administrator's username [ADMIN 
User "ADMIN" does not yet exist and will be created.
Enter ADMIN's email [ADMIN]
Enter ADMIN's password []
Created instance administrator ADMIN.m
```

- Create the APEX\_LISTENER and APEX\_REST\_PUBLIC\_USER users by running @apex\_rest\_config.sql

```
sql > @apex_rest_config.sql
Enter a password for the APEX_LISTENER user              []
Enter a password for the APEX_REST_PUBLIC_USER user              []
...set_appun.sql
...create APEX_LISTENER and APEX\_REST\_PUBLIC\_USER users
```
- Set password for the APEX\_PUBLIC\_USER and unlock the account.
```
sql > alter profile DEFAULT limit PASSWORD_REUSE_TIME unlimited;
sql > alter profile DEFAULT limit PASSWORD_LIFE_TIME  unlimited;
sql > alter user apex_public_user IDENTIFIED BY <password>;
sql > alter user apex_public_user profile DEFAULT;
sql > exit
```



### **STEP 2: Set up Oracle REST Data Service on Oracle Compute Linux**

- Install Oracle REST Data Service software in Oracle Linux server. Default installation directory is /opt/oracle/ords
```
$ sudo su -
$ yum install ords

```

- Create ORDS configuration folder

```
$ mkdir -p opt/oracle/ords/conf
```

- Edit the configuration file 
```
$ vi /opt/oracle/ords/params/ords_params.properties

db.hostname=150.xxx.xxx.126
db.port=1521
db.servicename=pdb.sub031xxxxx220.odiinstancevcn.oraclevcn.com
db.sid=
db.username=APEX_PUBLIC_USER
migrate.apex.rest=false
rest.services.apex.add=
rest.services.ords.add=true
schema.tablespace.default=APEX
schema.tablespace.temp=TEMP
standalone.http.port=8080
standalone.static.images=/opt/oracle/ords/images
user.tablespace.default=APEX
user.tablespace.temp=TEMP
```
- parameters:
```
db.hostname: hostname of database
db.port: 1521 is the default database cloud service port
db.servicename: pdb_name.databse_hostname, you can find database hostname in the OCI console
schema.tablespace.default:tablespace created for apex
user.tablespace.default: tablespace created for apex user
```

- Copy apex image folder to ORDS directory
```
$ mkdir /opt/oracle/ords/images
$ cp -R /u01/app/apex/images/* /opt/oracle/ords/images
```

- Switch to ROOT user and specify the configuration directory
```
$ sudo su -
$ /usr/bin/java -jar ords.war configdir /opt/oracle/ords/conf
```

- Edit standalone properties file
```
$ vi /opt/oracle/ords/conf/ords/standalone/standalone.properties

#Mon May 03 15:26:45 GMT 2021
jetty.port=8080
standalone.context.path=/ords
standalone.doc.root=/opt/oracle/ords/conf/ords/standalone/doc_root
standalone.scheme.do.not.prompt=true
standalone.static.context.path=/i
standalone.static.path=/opt/oracle/ords/images
```
- parameters: 
```
standalone.static.path: directory for apex images folder
standalone.doc.root: directory of doc_root folder in ORDS  
```


- Install ORDS. Type in **sys as sysdba** as the administrator username. Provide password for *ORDS_PUBLIC_USER*,     APEX\_PUBLIC\_USER, APEX\_LISTENER, and APEX\_REST\_PUBLIC\_USER.

```
Enter the database password for ORDS_PUBLIC_USER:
Confirm password:
Requires to login with administrator privileges to verify Oracle REST Data Services schema.
Enter the administrator username: sys as sysdba
Enter the database password for sys as sysdba:
Confirm password:
Retrieving information.
Enter 1 if you want to use PL/SQL Gateway or 2 to skip this step.
If using Oracle Application Express or migrating from mod_plsql then you must enter 1 [1]:1
Enter the database password for APEX_PUBLIC_USER:
Confirm password:
Enter 1 to specify passwords for Application Express RESTful Services database users (APEX_LISTENER, APEX_REST_PUBLIC_USER) or 2 to skip this step [1]:1
Enter the database password for APEX_LISTENER:
Confirm password:
Enter the database password for APEX_REST_PUBLIC_USER:
Confirm password:
Oct 10, 2019 9:12:29 PM
INFO: reloaded pools: []
Installing Oracle REST Data Services version 19.2.0.r1991647
... Log file written to /root/ords_install_core_2019-10-10_211229_00775.log
... Verified database prerequisites
... Created Oracle REST Data Services proxy user
... Created Oracle REST Data Services schema
... Granted privileges to Oracle REST Data Services
... Created Oracle REST Data Services database objects
... Log file written to /root/ords_install_datamodel_2019-10-10_211257_00956.log
... Log file written to /root/ords_install_apex_2019-10-10_211259_00706.log
Completed installation for Oracle REST Data Services version 19.2.0.r1991647. Elapsed time: 00:00:31.657
Enter 1 if you wish to start in standalone mode or 2 to exit [1]:2

```
- Add the ingress rule for port 8080 in Oracle Cloud Network
- Open Compute Linux Server Firewall port 8080. Switch to ROOT user

```
$ sudo su -
$ firewall-cmd --zone=public --add-port=8080/tcp —permanent
$ firewall-cmd --list-all
$ firewall-cmd --reload
```

### **STEP 3: Deploy ORDS with APEX on Database Cloud Service.**

- Run ORDS in standalone mode
```
$ java -jar ords.war standalone
```

- Login into Oracle Apex - http://129.xxx.xxx.xxxx:8080/ords

```
WORKSPACE: INTERNAL
USERNAME: ADMIN
PASSWORD: ADMIN_PASSWORD
```
