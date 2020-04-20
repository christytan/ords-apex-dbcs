variable "tenancy_ocid" {}
variable "uidList" {
  type = list(string)
}
variable "groupId" {}
variable "activityNumber" {}

resource "oci_identity_user" "user1" {
  count               = length(var.uidList)
  name           = var.uidList[count.index]
  description    = "user for PoC activity ${var.activityNumber}"
  compartment_id = var.tenancy_ocid
}
resource "oci_identity_ui_password" "password1" {
  count               = length(var.uidList)
  user_id        = oci_identity_user.user1.*.id[count.index]
}

output "allUserInitialPasswords" {
  sensitive = false
  value     = oci_identity_ui_password.password1.*.password
}
output "allUserOCIDs" {
  sensitive = false
  value     = oci_identity_user.user1.*.id
}

resource "oci_identity_user_group_membership" "user-group-mem1" {
  count               = length(var.uidList)
  compartment_id = oci_identity_user.user1.*.compartment_id[count.index]
  user_id        = oci_identity_user.user1.*.id[count.index]
  group_id       = var.groupId
}