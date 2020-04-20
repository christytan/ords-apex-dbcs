variable "adminOCIDs" {
  type = list(string)
}
//variable "compartment_id" {}
variable "group_id" {}
resource "oci_identity_user_group_membership" "admin-group-mem1" {
  count               = length(var.adminOCIDs)
//compartment_id = var.compartment_id
  user_id        = var.adminOCIDs[count.index]
  group_id       = var.group_id
}