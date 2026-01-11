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

resource "google_cloudfunctions2_function" "instance_stop_function" {
  name        = "instance-stop-function"
  location    = "us-east4"
  description = "Stops instance on CPU alert"

  build_config {
    runtime     = "python310"
    entry_point = "handle_eventarc_trigger" # Must match your Python function name
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }

  # THIS block creates the Eventarc trigger automatically
  event_trigger {
    trigger_region = "us-east4" # Keep this the same as the function location
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.server_cpu_topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}



