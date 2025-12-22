resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.default.id
  instance = google_compute_instance.default.id
}

resource "google_compute_instance" "minecraft_server" {
  name = "${var.instance_name}"
  # RESOURCE properties go here
  zone         = "${var.instance_zone}"
  machine_type = "${var.instance_type}"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      }
  }
  network_interface {
    network = "${var.instance_network}"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  lifecycle {
    ignore_changes = google_compute_attached_disk.static.self_link
  }
}
