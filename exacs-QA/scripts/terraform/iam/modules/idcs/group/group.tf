variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "activityNumber" {}
resource "oci_identity_group" "viewOnlyGroup" {
  name           = "OSC${var.activityNumber}ViewOnly"
  description    = "group created by terraform"
  compartment_id = var.tenancy_ocid
}
resource "oci_identity_policy" "policyViewOnly" {
  name           = "OSC${var.activityNumber}PolicyViewOnly"
  description    = "policy created by terraform"
  compartment_id = var.tenancy_ocid

  statements = [
    "Allow group id ${oci_identity_group.viewOnlyGroup.id} to read all-resources in compartment id ${var.compartment_ocid}",
    "Allow group id ${oci_identity_group.viewOnlyGroup.id} to manage objects in compartment id ${var.compartment_ocid} where all {request.permission='OBJECT_CREATE'}",
    # The following 3 statement is to allow viewonly lab 1 and 2 for lesson 5: security and access control
    "Allow group id ${oci_identity_group.viewOnlyGroup.id} to read users in tenancy",
    "Allow group id ${oci_identity_group.viewOnlyGroup.id} to read groups in tenancy",
    "Allow group id ${oci_identity_group.viewOnlyGroup.id} to read policies in tenancy"
  ]
}
output "viewOnlyGroupId" {
  depends_on = [
    oci_identity_policy.policyViewOnly,
    oci_identity_group.adminGroup,
    oci_identity_policy.policyAdmin,
    ]
  value     = oci_identity_group.viewOnlyGroup.id
}
resource "oci_identity_group" "dbaGroup" {
  name           = "OSC${var.activityNumber}dba"
  description    = "group created by terraform"
  compartment_id = var.tenancy_ocid
}

resource "oci_identity_policy" "policydba" {
  name           = "OSC${var.activityNumber}Policydba"
  description    = "policy created by terraform"
  compartment_id = var.tenancy_ocid

  statements = [
    "Allow group id ${oci_identity_group.dbaGroup.id} to use database-family in compartment id ${var.compartment_ocid}",
    "Allow group id ${oci_identity_group.dbaGroup.id} to manage db-homes in compartment id ${var.compartment_ocid}",
    "Allow group id ${oci_identity_group.dbaGroup.id} to manage databases in compartment id ${var.compartment_ocid}",
  ]
}

output "dbaGroupId" {
  depends_on = [
    oci_identity_policy.policydba,
    oci_identity_group.adminGroup,
    oci_identity_policy.policyAdmin,
  ]
  value = oci_identity_group.dbaGroup.id
}
resource "oci_identity_group" "adminGroup" {
  name           = "OSC${var.activityNumber}Admin"
  description    = "group created by terraform"
  compartment_id = var.tenancy_ocid
}
resource "oci_identity_policy" "policyAdmin" {
  name           = "OSC${var.activityNumber}PolicyAdmin"
  description    = "policy created by terraform"
  compartment_id = var.tenancy_ocid

  statements = ["Allow group id ${oci_identity_group.adminGroup.id} to manage all-resources in compartment id ${var.compartment_ocid}",
  ]
}
output "adminGroupId" {
  value     = oci_identity_group.adminGroup.id
}