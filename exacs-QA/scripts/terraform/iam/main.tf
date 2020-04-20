#Create Group of users to the compartment for the activity
module "create_group" {
  source = "./modules/idcs/group"
  providers = {
    oci = oci.home
  }
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  activityNumber   = var.proj_id
}
module "admin-group-mem1" {
  source = "./modules/idcs/adminGroup"
  providers = {
    oci = oci.home
  }
  adminOCIDs        = var.adminOCIDs
  group_id       = module.create_group.adminGroupId
}
module "dba-group-mem1" {
  source = "./modules/idcs/dbaGroup"
  providers = {
    oci = oci.home
  }
  dbaOCIDs        = var.dbaOCIDs
  group_id       = module.create_group.dbaGroupId
}
module "create_users" {
  source = "./modules/idcs/user"
  providers = {
    oci = oci.home
  }

  tenancy_ocid   = var.tenancy_ocid
  uidList        = var.uidList
  groupId        = module.create_group.viewOnlyGroupId
  activityNumber = var.proj_id
}

output "allUsers" {
  sensitive = false
  value     = var.uidList
}

output "accessCredentials" {
  sensitive = false
  value     = module.create_users.allUserInitialPasswords
}

output "allUserOCIDs" {
  sensitive = false
  value     = module.create_users.allUserOCIDs
}