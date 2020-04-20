# ExaCS Module

## Modules summery

The following TF var need to be setup for your account:

```
export TF_VAR_fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
export TF_VAR_private_key_path=/homenfs/<your_OSC_LDAP_ID>/.oci/oci_api_key.pem
export TF_VAR_user_ocid=ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

You will need to set the Project ID (proj_id) by editing terrafrom.tfvars in additional to the usual API login info as described above.

1. Create 3 groups, admin, DBA, and ViewOnly.
    * source = "./modules/idcs/group"
    * The viewOnly group also allows upload of file to object storage so that we don't need to assign DBA admin group for lift and shift database.
2. Give DBA or admin authority to list of users to the compartment
    * source = "./modules/idcs/dbaGroup"
    * source = "./modules/idcs/adminGroup"
3. Create a list of user.
    * source = "./modules/idcs/user"
    * *Note:* the user will be assigned to viewOnly group for the compartment.

## Examples:

See main.tf for examples.

The following is the recommended practice to grant/upgrade authority of user:

1. ID will only have viewonly access to the compartment initially.
2. Once the ID owner confirm that they have login and change the initial password, you can add them to groups with more authority, e.g. DBA, by copy/pasting the OCID of the ID to the group OCIDs list, e.g. dbaOCIDs in terraform.tfvars, then run terraform apply.
3. You will probably only need to grant admin authority for person need to create other instance such as VCN, compute, Data Safe Private Endpoint, etc.