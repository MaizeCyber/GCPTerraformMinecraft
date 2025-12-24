resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_disk" "additional_disk" {
  name    = "minecraft-disk"
  type    = "pd-ssd"
  size    = 50 # Disk size in GB
  zone    = "${var.instance_zone}"
}

resource "google_compute_instance" "minecraft_server" {
  name = "${var.instance_name}"
  # RESOURCE properties go here
  zone         = "${var.instance_zone}"
  machine_type = "${var.instance_type}"

  tags = ["minecraft-server"]

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
  attached_disk {
    source      = google_compute_disk.additional_disk.self_link
    mode        = "READ_WRITE"
  }
  metadata_startup_script = file("${path.module}/startup.sh")
  
  metadata = {
    shutdown-script = file("${path.module}/shutdown.sh")
    backup_script_content = file("${path.module}/backup.sh")
  }
}
