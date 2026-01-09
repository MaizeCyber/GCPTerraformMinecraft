output "cloud_run_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.join-url-service.service_url
}

output "server_ipv4_address" {
  description = "The IPv4 address of your minecraft server"
  value       = module.minecraft-server-vm.external_ip
}

output "server_ipv6_address" {
  description = "The IPv6 address of your minecraft server"
  value       = module.minecraft-server-vm.external_ipv6
}