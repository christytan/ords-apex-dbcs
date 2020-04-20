# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {
}

variable "user_ocid" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}

variable "compartment_ocid" {
}

variable "region" {
}

variable "proj_id" {
}

variable "uidList" {
  type    = list(string)
  default = [
  ]
}

variable "dbaOCIDs" {
  type    = list(string)
  default = [
  ]
}

variable "adminOCIDs" {
  type    = list(string)
  default = [
  ]
}
