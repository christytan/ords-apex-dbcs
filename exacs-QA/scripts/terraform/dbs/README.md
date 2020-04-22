# ExaCS Module

## Modules summery

The following TF var need to be setup for your account:

```
export TF_VAR_fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
export TF_VAR_private_key_path=/homenfs/<your_OSC_LDAP_ID>/.oci/oci_api_key.pem
export TF_VAR_user_ocid=ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

You will need to set the Project ID (proj_id) and the number database (db_count) sharing the same Oracle home that will be created by editing terraform.tfvars in additional to the usual API login info as mention above.

## Instructor/Administrator
For the instructor or admin person who setup the environment intially, you will also need to get the OCID of the following in terraform.tfvars:
* tenancy_ocid
* compartment_ocid
* region
* dbsysid
    1. Login to OCI UI/console.
    2. Select hamburger manual on the left top.
    3. Select "Bare Metal, VM, and Exadata"
    4. Click on the link the the DB System.
    5. Select Copy of the OCID in the General Information section.
    6. Edit terraform.tfvars and paste and replace the OCID, then save. The OCID should look something like ocid1.dbsystem.oc1.iad.xxx where xxx is a long hex string.

You will also need to run the following and share the tfstate file with the participants or setup remote state by updating provider.tf.