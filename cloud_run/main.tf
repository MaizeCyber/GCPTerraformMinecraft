resource "google_cloud_run_v2_service" "mc_join_service" {
  name                 = var.run_name
  location             = var.run_region
  ingress              = "INGRESS_TRAFFIC_ALL"
  invoker_iam_disabled = true
  deletion_protection  = false # set to "true" in production

  template {
    service_account = var.sa_email
    labels = {
      "deployment_version" = var.version_trigger
    }
    containers {
      image = var.container_name
      ports {
        container_port = 8080
      }
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
      env {
        name  = "SERVER_IP"
        value = var.server_ip
      }
      env {
        name  = "SERVER_IP_V6"
        value = var.server_ip_v6
      }
      env {
        name  = "PROJECT_NAME"
        value = var.project_id
      }
      env {
        name  = "PROJECT_ZONE"
        value = var.project_zone
      }
      env {
        name  = "INSTANCE_NAME"
        value = var.instance_name
      }
      env {
        name  = "NETWORK_NAME"
        value = var.network_name
      }
    }
  }
}