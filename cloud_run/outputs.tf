output "service_url" {
  description = "The URL of the service to join the server"
  value       = google_cloud_run_v2_service.mc_join_service.uri
}