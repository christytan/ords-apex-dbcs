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
  default = "us-phoenix-1"
}

variable "db_count" {
  description = "Number of database share the same Oracle Home"
}

variable "proj_id" {
}

variable "dbsysid" {
  default = "ocid1.dbsystem.oc1.iad.abuwcljtgtdbuh4xs2r4gfedt6rhhazezin4v32am5lysqzxlvmnzrwrnqka"
}