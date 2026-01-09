resource "google_storage_bucket" "gcs_backup_bucket" {
  name           = var.backup_bucket_name
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