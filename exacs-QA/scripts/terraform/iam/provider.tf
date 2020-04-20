#Provider for current region and home region that is needed to create users and groups
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data oci_identity_regions regions {
}

locals {
  region_map = {
    for r in data.oci_identity_regions.regions.regions :
    r.key => r.name
  }
  home_region = lookup(
    local.region_map, 
    data.oci_identity_tenancy.tenancy.home_region_key
  )
}

provider "oci" {
  alias            = "home"
  #region           = "us-ashburn-1"
  region           = local.home_region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
//retry_duration_seconds = 3600
}