resource "google_storage_bucket" "gcs_backup_bucket" {
  name                        = var.backup_bucket_name
  location                    = "US"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      age = 60
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
}

data "archive_file" "function_file" {
  type        = "zip"
  output_path = "/tmp/function-source.zip"
  source_dir  = "cloud_functions/instance_stop"
}

resource "google_storage_bucket" "function_bucket" {
  name                        = "function-source-bucket-${var.project_id}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "function_object" {
  name   = "source.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_file.output_path
}