# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
  name = "mynetwork"
  # RESOURCE properties go here
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "allow-client-traffic" {
  name = "allow-client-traffic"
  # RESOURCE properties go here
  network = google_compute_network.mynetwork.self_link
  target_tags = ["minecraft-server"]
  allow {
    protocol = "tcp"
    ports    = ["25565"]
    }
  allow {
    protocol = "icmp"
    }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-ssh-traffic" {
  name = "allow-ssh-traffic"
  # RESOURCE properties go here
  network = google_compute_network.mynetwork.self_link
  target_tags = ["minecraft-server"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
    }
  allow {
    protocol = "icmp"
    }
  source_ranges = ["35.235.240.0/20"]
}

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
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
}

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


