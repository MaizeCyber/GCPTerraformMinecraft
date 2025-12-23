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
    ports    = ["22", "25565"]
    }
  allow {
    protocol = "icmp"
    }
  source_ranges = ["0.0.0.0/0"]
}

# Create the mynet-vm-1 instance
module "minecraft-server-vm" {
  source           = "./instance"
  instance_name    = "mynet-vm-1"
  instance_zone    = "Zone"
  instance_type     = "e2-micro"
  instance_network = google_compute_network.mynetwork.self_link
}
