# Discovery Lab 2 - Verify a Sensitive Data Model with Oracle Data Safe

## Objectives
In this lab, you learn how to do the following:
- Perform an incremental update to a sensitive data model by using the Data Discovery wizard

## Challenge
Suppose your ExaCS database has a new column added to it and you want to update your sensitive data model to include that column.

Follow these general steps:
1. Connect to your ExaCS database as the SYS user with SQL Developer.
2. In SQL Developer, add an AGE column to the HCM1.EMPLOYEES table in your ExaCS database. Gather schema statistics on your database.
3. Sign in to the Oracle Data Safe Console in your region.
4. In the Oracle Data Safe Console, update your sensitive data model against your target database by using the update option in the Data Discovery wizard. What does the update test find?

## Step-by-Step Instructions

### Part 1: Connect to your ExaCS database as the SYS user with SQL Developer

Please visit [Lab 4: Configuring a development system for use with your EXACS database](ConfigureDevClient.md) for instructions to securely configure ExaCS to connect using Oracle SQL Developer, SQLXL and SQL*Plus.
### Part 2: In SQL Developer, add an `AGE` column to the `HCM1.EMPLOYEES` table in your ExaCS database

- In SQL Developer, run the following command to connect to PDB1 pluggable database:

```
ALTER SESSION SET CONTAINER=PDB1;
```
- Expand the `EMPLOYEES` table to view the current columns.
On the SQL Worksheet, run the following commands to add an `AGE` column to the `EMPLOYEES` table.

```
ALTER TABLE HCM1.EMPLOYEES ADD AGE NUMBER;
```
- On the Navigator tab, click the Refresh button.<br>
`AGE` is added to the bottom of the list in the `EMPLOYEES` table.
- Run the following command to gather schema statistics.

```
EXEC DBMS_STATS.GATHER_SCHEMA_STATS('HCM1');
```
### Part 3: Sign in to the Oracle Data Safe Console in your region

- From the navigation menu, click **Data Safe**

![](./images/dbsec/datasafe/login/navigation.png)

- You are taken to the **Registered Databases** Page.
- Click on **Service Console**

![](./images/dbsec/datasafe/login/service-console.png)

- You are taken to the Data Safe login page. Sign into Data Safe using your credentials.

![](./images/dbsec/datasafe/login/sign-in.png)

### Part 4: Update your sensitive data model against your database by using the update option in the Data Masking wizard

- In the Oracle Data Safe Console, click the **Home** tab, and then click Data Discovery. The Select Target for **Data Discovery** page is displayed.

![](./images/dbsec/datasafe/discovery/discovery-nav.png)
- Select your target database, and then click **Continue**. The **Select Sensitive Data Model** page is displayed.

![](./images/dbsec/datasafe/discovery/discovery-target2.png)
- For Sensitive Data Model, click **Pick from Library**.

![](./images/dbsec/datasafe/discovery/library-pick.png)
- Click **Continue**.
The **Select Sensitive Data Model** page is displayed.
- Select your sensitive data model (**<username> SDM1**).

![](./images/dbsec/datasafe/discovery/select-target2.png)

- Leave **Update the SDM with the target** selected.
- Click **Continue**.
The wizard launches a data discovery job.
- When the job is finished, notice that the **Detail** column reads **Data discovery job finished successfully**.
- Click **Continue**. The **Sensitive Data Model: <username> SDM1** page is displayed.
- Notice that you have the newly discovered sensitive column, `AGE`. Only newly discovered columns are displayed at the moment.
- **Expand all** of the nodes.
- To view all of the sensitive columns in the sensitive data model, click **View all sensitive columns**.
  - You can toggle the view back and forth between displaying all of the sensitive columns or just the newly discovered ones.
- Click **Exit**.

### All Done!
