# ExaCS Module

## Modules summery

The following TF var need to be setup for your account:

```
export TF_VAR_fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
export TF_VAR_private_key_path=/homenfs/<your_OSC_LDAP_ID>/.oci/oci_api_key.pem
export TF_VAR_user_ocid=ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

You will need to set the Project ID (proj_id) and the number database (db_count) sharing the same Oracle home that will be created by editing terrafrom.tfvars in additional to the usual API login info as mention above.