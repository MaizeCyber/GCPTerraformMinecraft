resource "google_compute_firewall" "allow_client_traffic" {
  name = "all_client_traffic_ssh"
  # RESOURCE properties go here
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22", "25565"]
    }
  allow {
    protocol = "icmp"
    }
  source_ranges = ["0.0.0.0/0"]
}
