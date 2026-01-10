resource "google_project_service" "cloud_run_api" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "compute_engine_api" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "eventarc" {
  service            = "eventarc.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "pubsub" {
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}