resource "google_storage_bucket" "gcs_backup_bucket" {
  name           = "potato-swirl-landbridge-deaf"
  location       = "US"
  storage_class  = "STANDARD"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      age = 60
    }
    action {
      type = "Delete"
    }
  }
}


terraform {
  backend "gcs" {
    bucket  = "soup-burrata-cool-summer"
    prefix  = "terraform/state"
  }
}