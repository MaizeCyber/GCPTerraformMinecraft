resource "google_project_service" "cloud_build_api" {
  project = var.project_name
  service   = "cloudbuild.googleapis.com"
}