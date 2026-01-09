output "external_ip" {
  description = "The external IP address of the compute instance"
  value       = google_compute_address.static.address
}

output "external_ipv6" {
  description = "The external IPv6 address of the compute instance"
  value       = google_compute_address.static_ipv6.address
}