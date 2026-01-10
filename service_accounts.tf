resource "google_service_account" "minecraft_sa" {
  account_id   = "minecraft-server-sa"
  display_name = "Minecraft Server Service Account"
}

resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.minecraft_sa.email}"
}

resource "google_storage_bucket_iam_member" "backup_writer" {
  bucket = google_storage_bucket.gcs_backup_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft_sa.email}"
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "service-join-sa"
  display_name = "MC Server Join Service"
}

resource "google_project_iam_member" "cloud_sa_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_sa_get_instance" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_sa_create_firewall" {
  project = var.project_id
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_service_account" "eventarc" {
  account_id   = "eventarc-trigger-sa"
  display_name = "Eventarc Trigger Service Account"
}

resource "google_project_iam_member" "eventreceiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}

resource "google_project_iam_member" "runinvoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}

# data "google_project" "project" {}
#
# resource "google_project_service_identity" "monitoring_notification_sa" {
#   provider = google-beta
#   project  = data.google_project.project.project_id
#   service  = "monitoring.googleapis.com"
# }
#
# resource "google_pubsub_topic_iam_member" "monitoring_publisher" {
#   topic  = google_pubsub_topic.server-cpu-topic.name
#   role   = "roles/pubsub.publisher"
#   member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-monitoring.iam.gserviceaccount.com"
# }