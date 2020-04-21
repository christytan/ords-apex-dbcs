## Introduction

Data Safe is a unified control center for your Oracle Databases which helps you understand the sensitivity of your data, evaluate risks to data, mask sensitive data, implement and monitor security controls, assess user security, monitor user activity, and address data security compliance requirements. Whether you’re using Oracle Autonomous Database or Oracle Database Cloud Service (Exadata, Virtual Machine, or Bare Metal), Data Safe delivers essential data security capabilities as a service on Oracle Cloud Infrastructure.

This lab walks you through the steps to get started using Oracle Data Safe with ExaCS on Oracle Cloud Infrastructure. 

To **log issues**, click [here](https://github.com/oracle/learning-library/issues/new) to go to the github oracle repository issue submission form.

## Requirements

- Login credentials for your tenancy in Oracle Cloud Infrastructure
- An Oracle Database Service enabled in a region in your tenancy
- A registered target database in Oracle Data Safe with sample audit data and the password for the SYS user account. This lab refers to an Exadata Cloud Service (ExaCS) database.

## Before You Begin

[Register a Target Database using a Private Endpoint](?lab=lab-7-1-register-target-database-using-private)

## Sections

### Security and User Assessment
- [Assessment Lab 1](?lab=lab-7-2-assess-database-configurations) - Assess Database Configurations with Oracle Data Safe
- [Assessment Lab 2](?lab=lab-7-3-assess-users-oracle-data-safe) - Assess Users with Oracle Data Safe

### Sensitive Data Discovery
- [Discovery Lab 1](?lab=lab-7-4-discover-sensitive-data-oracle-data) - Discover Sensitive Data with Oracle Data Safe
- [Discovery Lab 2](?lab=lab-7-5-verify-sensitive-data-model) - Verify a Sensitive Data Model with Oracle Data Safe
- [Discovery Lab 3](?lab=lab-7-6-update-sensitive-data-model) - Update a Sensitive Data Model with Oracle Data Safe
- [Discovery Lab 4](?lab=lab-7-7-create-sensitive-type-sensitive) - Create a Sensitive Type and Sensitive Category with Oracle Data Safe

### Data Masking
- [Masking Lab 1](?lab=lab-7-8-discover-mask-sensitive-data-by) - Discover and Mask Sensitive Data by Using Default Masking Formats in Oracle Data Safe
- [Masking Lab 2](?lab=lab-7-9-explore-data-masking-results-reports) - Explore Data Masking Results and Reports in Oracle Data Safe
- [Masking Lab 3](?lab=lab-7-10-create-masking-format-oracle-data) - Create a Masking Format in Oracle Data Safe
- [Masking Lab 4](?lab=lab-7-11-configure-variety-masking-formats) - Configure a Variety of Masking Formats with Oracle Data Safe

### Auditing and Reporting
- [Auditing Lab 1](?lab=lab-7-12-provision-audit-alert-policies) - Provision Audit and Alert Policies and Configure an Audit Trail in Oracle Data Safe
- [Auditing Lab 2](?lab=lab-7-13-analyze-audit-data-reports-aler) - Analyze Audit Data with Reports and Alerts in Oracle Data Safe
- [Auditing Lab 3](?lab=lab-7-14-create-provision-custom-audit) - Create and Provision a Custom Audit Policy and View Audit Data in Oracle Data Safe
