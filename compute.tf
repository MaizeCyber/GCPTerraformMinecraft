resource "google_service_account" "minecraft_sa" {
  account_id   = "minecraft-server-sa"
  display_name = "Minecraft Server Service Account"
}

resource "google_project_iam_member" "logging_writer" {
  project = "minecraftserver-482021"
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
  instance_zone    = "us-east4-a"
  instance_type     = "e2-medium"
  instance_network = google_compute_network.mynetwork.self_link
  sa_email = google_service_account.minecraft_sa.email
}


