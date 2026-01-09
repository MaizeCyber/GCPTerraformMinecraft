resource "google_service_account" "minecraft_sa" {
  account_id   = "minecraft-server-sa"
  display_name = "Minecraft Server Service Account"
}

resource "google_project_iam_member" "logging_writer" {
  project = var.project_name
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.minecraft_sa.email}"
}

resource "google_storage_bucket_iam_member" "backup_writer" {
  bucket = google_storage_bucket.gcs_backup_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft_sa.email}"
}

module "minecraft-server-vm" {
  source           = "./instance"
  instance_name    = "minecraft-server-1"
  project_region   = var.project_region
  instance_zone    = var.project_zone
  instance_type     = "e2-medium"
  instance_network = google_compute_network.mynetwork.self_link
  instance_subnetwork = google_compute_subnetwork.dual_stack_subnetwork.self_link
  sa_email = google_service_account.minecraft_sa.email
}

module "join-url-service" {
  source           = "./cloud_run"
  run_name         = "join-url-1"
  run_region       = var.project_region
  sa_email         = google_service_account.cloud_run_sa.email
  container_name   = "docker.io/maizecyber/mc-server-join:gcp"
  instance_name    = "minecraft-server-1"
  network_name     = "mynetwork"
  project_id       = var.project_name
  project_zone     = var.project_zone
  server_ip        = module.minecraft-server-vm.external_ip
  server_ip_v6     = module.minecraft-server-vm.external_ipv6
  version_trigger  = var.version_trigger
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "service-join-sa"
  display_name = "MC Server Join Service"
}

resource "google_project_iam_member" "cloud_sa_run_admin" {
  project = var.project_name
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_sa_get_instance" {
  project = var.project_name
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloud_sa_create_firewall" {
  project = var.project_name
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}


