variable "dbsysid" {
  default = "ocid1.dbsystem.oc1.iad.abuwcljtgtdbuh4xs2r4gfedt6rhhazezin4v32am5lysqzxlvmnzrwrnqka"
}
// The creation of an oci_database_db_system requires that it be created with exactly one oci_database_db_home. Therefore the first db home will have to be a property of the db system resource and any further db homes to be added to the db system will have to be added as first class resources using "oci_database_db_home".
resource "oci_database_db_home" "tf_db_home" {
  //count = 1
  db_system_id = var.dbsysid
  database {
    admin_password = "BEstr0ng1--"
    db_name        = "tfDb"
    /*
    admin_password = "BEstrO0ng--${count.index}"
    db_name        = "tfDb${count.index}"
    character_set  = "AL32UTF8"
    ncharacter_set = "AL16UTF16"
    db_workload    = "OLTP"
    pdb_name       = "tfPdb${count.index}"
    */
  }
  source       = "NONE"
  db_version   = "19.0.0.0"
  //display_name = "${count.index+1} of 1 DB for project ID ${var.proj_id}"
  display_name = "DB home for project ID ${var.proj_id}"
}

// Work around to remember to adjust the timeout 60 min/new DB.
resource "oci_database_database" "test_database" {
  count = var.db_count
  #Required
  database {
    admin_password = "BEstr0ng--${count.index}"
    db_name        = "tfDb${count.index}"
    character_set  = "AL32UTF8"
    ncharacter_set = "AL16UTF16"
    db_workload    = "OLTP"
    pdb_name       = "tfPdb${count.index}"

    db_backup_config {
      auto_backup_enabled = false
    }
  }
  //It takes about 40 min to create 1 DB so make it simple to give an hour per DB
  timeouts {
      create = "${var.db_count}h"
 }

  db_home_id = oci_database_db_home.tf_db_home.id
  source     = "NONE"
}