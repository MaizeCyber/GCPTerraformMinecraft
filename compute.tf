module "minecraft-server-vm" {
  source              = "./instance"
  instance_name       = "minecraft-server-1"
  project_region      = var.project_region
  instance_zone       = var.project_zone
  instance_type       = "e2-medium"
  instance_network    = google_compute_network.mynetwork.self_link
  instance_subnetwork = google_compute_subnetwork.dual_stack_subnetwork.self_link
  sa_email            = google_service_account.minecraft_sa.email
}

module "join-url-service" {
  source          = "./cloud_run"
  run_name        = "join-url-1"
  run_region      = var.project_region
  sa_email        = google_service_account.cloud_run_sa.email
  container_name  = "docker.io/maizecyber/mc-server-join:v3"
  instance_name   = "minecraft-server-1"
  network_name    = "mynetwork"
  project_id      = var.project_id
  project_zone    = var.project_zone
  server_ip       = module.minecraft-server-vm.external_ip
  server_ip_v6    = module.minecraft-server-vm.external_ipv6
  version_trigger = var.version_trigger
}




