provider "google" {
  project     = var.project_name
  region      = var.project_region
  zone        = var.project_zone
}

terraform {
  backend "gcs" {
    bucket  = "soup-burrata-cool-summer"
    prefix  = "terraform/state"
  }
}

resource "google_project_service" "cloud_build_api" {
  project = var.project_name
  service   = "cloudbuild.googleapis.com"
}