# Create the mynetwork network
resource "google_compute_network" "mynetwork" {
  name = "mynetwork"
  # RESOURCE properties go here
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "dual_stack_subnetwork" {
  name                     = "minecraft-subnet"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.project_region
  network                  = google_compute_network.mynetwork.id

  # Enable Dual-Stack
  stack_type               = "IPV4_IPV6"
  ipv6_access_type         = "EXTERNAL"
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
