variable "project_id" {
  type    = string
  description = "The full project id, i.e. server-123456"
}

variable "project_region" {
  type    = string
  description = "The region of the project. Choose one near you that also supports e2-medium Instances: https://cloud.google.com/about/locations"
}

variable "project_zone" {
  type    = string
  description = "The zone of the project. The format is the region followed by a, b, c, or d, ie us-east4-a. Choose any available zone."
}

variable "backup_bucket_name" {
  type    = string
  description = "The name of the bucket which will store your world backups. Must be global unique, so chose a long name."
}

variable "version_trigger" {
  type    = string
  default = "1"
}