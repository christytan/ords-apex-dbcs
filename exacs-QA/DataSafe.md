## Introduction

Data Safe is a unified control center for your Oracle Databases which helps you understand the sensitivity of your data, evaluate risks to data, mask sensitive data, implement and monitor security controls, assess user security, monitor user activity, and address data security compliance requirements. Whether you’re using Oracle Autonomous Database or Oracle Database Cloud Service (Exadata, Virtual Machine, or Bare Metal), Data Safe delivers essential data security capabilities as a service on Oracle Cloud Infrastructure.

This lab walks you through the steps to get started using Oracle Data Safe with ExaCS on Oracle Cloud Infrastructure. 

To **log issues**, click [here](https://github.com/oracle/learning-library/issues/new) to go to the github oracle repository issue submission form.

## Requirements

- Login credentials for your tenancy in Oracle Cloud Infrastructure
- An Oracle Database Service enabled in a region in your tenancy
- A registered target database in Oracle Data Safe with sample audit data and the password for the SYS user account. This lab refers to an Exadata Cloud Service (ExaCS) database.

## Before You Begin

[Register a Target Database using a Private Endpoint](DataSafePE.md)

## Sections

### Security and User Assessment
- [Assessment Lab 1](DataSafeAssessment.md) - Assess Database Configurations with Oracle Data Safe
- [Assessment Lab 2](DataSafeAssessment2.md) - Assess Users with Oracle Data Safe

### Sensitive Data Discovery
- [Discovery Lab 1](DataSafeSDD.md) - Discover Sensitive Data with Oracle Data Safe
- [Discovery Lab 2](DataSafeSDD2.md) - Verify a Sensitive Data Model with Oracle Data Safe
- [Discovery Lab 3](DataSafeSDD3.md) - Update a Sensitive Data Model with Oracle Data Safe
- [Discovery Lab 4](DataSafeSDD4.md) - Create a Sensitive Type and Sensitive Category with Oracle Data Safe

### Data Masking
- [Masking Lab 1](DataSafeDM.md) - Discover and Mask Sensitive Data by Using Default Masking Formats in Oracle Data Safe
- [Masking Lab 2](DataSafeDM2.md) - Explore Data Masking Results and Reports in Oracle Data Safe
- [Masking Lab 3](DataSafeDM3.md) - Create a Masking Format in Oracle Data Safe
- [Masking Lab 4](DataSafeDM4.md) - Configure a Variety of Masking Formats with Oracle Data Safe

### Auditing and Reporting
- [Auditing Lab 1](DataSafeAudit.md) - Provision Audit and Alert Policies and Configure an Audit Trail in Oracle Data Safe
- [Auditing Lab 2](DataSafeAudit2.md) - Analyze Audit Data with Reports and Alerts in Oracle Data Safe
- [Auditing Lab 3](DataSafeAudit3.md) - Create and Provision a Custom Audit Policy and View Audit Data in Oracle Data Safe
