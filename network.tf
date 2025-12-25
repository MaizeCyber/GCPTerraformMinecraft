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
  allow {
    protocol = "tcp"
    ports    = ["25565"]
    }
  allow {
    protocol = "icmp"
    }
  source_ranges = ["0.0.0.0/0"]
}

# Create the mynet-vm-1 instance
module "minecraft-server-vm" {
  source           = "./instance"
  instance_name    = "minecraft-server-1"
  instance_zone    = "us-east4-a"
  instance_type     = "e2-medium"
  instance_network = google_compute_network.mynetwork.self_link
}

resource "google_storage_bucket" "gcs_backup_bucket" {
  name           = "potato-swirl-landbridge-deaf"
  location       = "US"
  storage_class  = "STANDARD"
  versioning {
    enabled = true
  }
}
