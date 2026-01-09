# GCPTerraformMinecraft v1.0
Terraform configuration files to deploy a Minecraft Server in Google Cloud.

## Specs
Storage: 50 GB SSD Persistent Disk
Zone: us-east4
Machine Type: e2-medium
Encryption: Google Managed Encryptions

## Networking
Static External IPv4 and IPv6 Address
Automatic firewall rule creation for user IPs which allows 25565 traffic

## Security
Storage: RW

## Backups
backup.sh script into Cloud Storage buck
Cronjob for the backup script
Object Lifecycle Management for 60 days of backups

## Other To Dos
Use domain or subdomain with Cloud DNS to cut down on static IP cost
Install Ops Agent on Instance
Implement logging alerts to catch cloud run failure, instance bottle necking, etc.