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
- Create a REST Service using APEX and deploy it using ORDS.


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

- Create the APEX_LISTENER and APEX_REST_PUBLIC_USER users by running @apex_rest_config.sql 

```
sql > @apex_rest_config.sql
Enter a password for the APEX_LISTENER user              []
Enter a password for the APEX_REST_PUBLIC_USER user              []
...set_appun.sql
...create APEX_LISTENER and APEX_REST_PUBLIC_USER users
```
- Set password for the APEX_PUBLIC_USER and unlock the account.
```
sql > alter profile DEFAULT limit PASSWORD_REUSE_TIME unlimited;
sql > alter profile DEFAULT limit PASSWORD_LIFE_TIME  unlimited;
sql > alter user apex_public_user IDENTIFIED BY <password>;
sql > alter user apex_public_user profile DEFAULT;
sql > exit
```



### **STEP 2: Set up Oracle Data Service on Oracle compute Linux**


### **STEP 3: Deploy ORDS with APEX on Database Cloud Service.**

