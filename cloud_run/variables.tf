variable "sa_email" {}
variable "run_name" {}
variable "container_name" {}
variable "run_region" {}

variable "server_ip" {
  type        = string
  description = "IP of the minecraft server instance"
}

variable "server_ip_v6" {
  type        = string
  description = "IPv6 of the minecraft server instance"
}

variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "project_zone" {
  type        = string
  description = "Zone of the project"
}

variable "instance_name" {
  type        = string
  description = "Name of the minecraft server instance"
}

variable "version_trigger" {
  type        = string
  description = "Passed from GitHub Run ID to force secret updates"
}

variable "network_name" {
  type        = string
  description = "Name of the VPC network the minecraft server lives on"
}
