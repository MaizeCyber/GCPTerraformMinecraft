# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
  name = "mynetwork"
  # RESOURCE properties go here
  auto_create_subnetworks = "true"
}

# resource "google_compute_firewall" "allow-client-traffic" {
#   name = "allow-client-traffic"
#   # RESOURCE properties go here
#   network = google_compute_network.mynetwork.self_link
#   target_tags = ["minecraft-server"]
#   allow {
#     protocol = "tcp"
#     ports    = ["25565"]
#     }
#   allow {
#     protocol = "icmp"
#     }
#   source_ranges = ["0.0.0.0/0"]
# }

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
      age = 60
    }
    action {
      type = "Delete"
    }
  }
}

