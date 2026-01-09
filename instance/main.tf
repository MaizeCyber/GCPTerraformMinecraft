resource "google_compute_address" "static" {
  name = "ipv4-address"
  address_type = "EXTERNAL"
  region       = var.project_region
}


resource "google_compute_address" "static_ipv6" {
  name               = "minecraft-ipv6"
  address_type       = "EXTERNAL"
  ip_version         = "IPV6"
  region             = var.project_region
  ipv6_endpoint_type = "VM"
  subnetwork         = var.instance_subnetwork
  network_tier       = "PREMIUM"
}

resource "google_compute_disk" "additional_disk" {
  name    = "minecraft-disk"
  type    = "pd-ssd"
  size    = 50 # Disk size in GB
  zone    = var.instance_zone
}

resource "google_compute_instance" "minecraft_server" {
  name = var.instance_name
  # RESOURCE properties go here
  zone         = var.instance_zone
  machine_type = var.instance_type

  tags = ["minecraft-server"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      }
  }
  network_interface {
    network = var.instance_network
    subnetwork = var.instance_subnetwork # Link to the dual-stack subnet
    stack_type = "IPV4_IPV6"
    access_config {
      nat_ip = google_compute_address.static.address
    }
    ipv6_access_config {
      external_ipv6 = google_compute_address.static_ipv6.address
      network_tier = "PREMIUM"
    }
  }

  attached_disk {
    source      = google_compute_disk.additional_disk.self_link
    device_name = google_compute_disk.additional_disk.name
    mode        = "READ_WRITE"
  }
  metadata_startup_script = file("${path.module}/startup.sh")

  service_account {
    email  = var.sa_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    shutdown-script = file("${path.module}/shutdown.sh")
    backup_script_content = file("${path.module}/backup.sh")
  }
}
