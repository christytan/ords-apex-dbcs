variable "dbaOCIDs" {
  type = list(string)
}
//variable "compartment_id" {}
variable "group_id" {}
resource "oci_identity_user_group_membership" "dba-group-mem1" {
  count               = length(var.dbaOCIDs)
//compartment_id = var.compartment_id
  user_id        = var.dbaOCIDs[count.index]
  group_id       = var.group_id
}