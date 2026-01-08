# GCPTerraformMinecraft
Terraform configuration riles to deploy a Minecraft Server in Google Cloud.

## Specs
Storage: 50 GB SSD Persistent Disk
Zone: us-east4
Machine Type: e2-medium
Encryption: Google Managed Encryptions

## Networking
Static External IP Address
Default Network interface
Automatic firewall rule creation for user IPs which allows 25565 traffic

## Security
Storage: RW

## Backups
Create Bucket
backup.sh script
Set cronjob for backup script
Configure Object Lifecycle Management 

