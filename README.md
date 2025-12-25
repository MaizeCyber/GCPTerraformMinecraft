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
Firewall Rule which allows 25565 traffic

## Security
Storage: RW

## Backups
Create Bucket
backup.sh script
Set cronjob for backup script
Configure Object Lifecycle Management 

## Startup Script
1. Create a new directory
2. Format a disk
3. Mount the disk to the directory
4. Using apt to update and install a JRE
5. Download and object with wget
6. Run java against the downloaded object
7. Edit a text file
