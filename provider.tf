provider "google" {
  project = var.project_id
  region  = var.project_region
  zone    = var.project_zone
}

terraform {
  backend "gcs" {
    bucket = "soup-burrata-cool-summer"
    prefix = "terraform/state"
  }
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
  }
}