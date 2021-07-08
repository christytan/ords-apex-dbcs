# Deploy Oracle GoldenGate Cloud Service

## Introduction

Data Replication is a essential part of your efforts and tasks when you are migrating your Oracle databases. While data migration can be acheived in many ways, there are fewer options when downtime tolerance is low and live, trickle feed replication may be the only way. Oracle Cloud Infrastructure Marketplace provides a goldengate microservice that can easily be setup for logical data replication between a variety of databases. In this hands-on lab we will setup goldengate to replicate data from a 19c Oracle database comparable to an 'on-prem' source database to an 19c  database in OCI. This approach is recommended while migrating most production or business critical application to DBCS .

Why Golden Gate?

- Oracle Golden Gate is an enterprise grade tool which can provide near real time data replication from one database to another. 
- Oracle GoldenGate offers a real-time, log-based change data capture (CDC) and replication software platform to meet the needs of today’s transaction-driven applications. It provides capture, routing, transformation, and delivery of transactional data across heterogeneous environments in real time can be acheived using Golden Gate. 
- Oracle GoldenGate only captures and moves committed database transactions to insure that transactional integrity is maintained at all times. The application carefully ensures the integrity of data as it is moved from the source database or messaging system, and is applied to any number of target databases or messaging systems.

[Learn More](http://www.oracle.com/us/products/middleware/data-integration/oracle-goldengate-realtime-access-2031152.pdf)

To **log issues**, click [here](https://github.com/oracle/learning-library/issues/new) to go to the github oracle repository issue submission form.

## Objectives

- Setup real time data replication from on-premise database to database cloud service.

## Required Artifacts

- Access to an Oracle Cloud Infrastructure tenancy.
- Access to an Oracle 19c database configured as source database.
- An database cloud service 19c as target database.
- Access to cloud virtual network.


## Background and Architecture

- There are three components to this lab. The **source database** that you are planning to migrate to database cloud service, the **target database cloud service** in OCI and an instance of **Oracle GoldenGate** server with access to both source and target databases.

- The source database can be any Oracle database version 19c or higher with at least one application schema that you wish to replicate to an database in OCI. For the purpose of this lab, you may provision a 19c DBCS instance in your compartment in OCI and configure it as source. 


- The Golden Gate cloud service is going to be deployed on OCI in a public network which has access to both the source database and the target database via the Goldengate instance in OCI.

- Let us understand the architecture of the setup we have here:
    - We have a source database on a VM on OCI(DBCS) which will act as an on-premise database.
    - We have a target database on an database cloud service VM on OCI.
    - We have a Goldengate instance with access to both the source database and target database.

   

## Steps
### **STEP 1: Provision a Goldengate Cloud Service from OCI**



### **STEP 2: Configure the source database**

### **STEP 3: Configure the target database**

### **STEP 4: Configure Goldengate Cloud Service**

