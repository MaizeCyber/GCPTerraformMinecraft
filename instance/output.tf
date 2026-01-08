output "external_ip" {
  description = "The external IP address of the compute instance"
  value       = google_compute_address.static.address
}