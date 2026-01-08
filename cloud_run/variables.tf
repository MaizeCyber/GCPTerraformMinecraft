variable "sa_email" {}
variable "run_name" {}
variable "container_name" {}
variable "run_region" {}

variable "server_ip" {
  type        = string
  description = "IP of the minecraft server instance"
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

variable "network_name" {
  type        = string
  description = "Name of the VPC network the minecraft server lives on"
}
