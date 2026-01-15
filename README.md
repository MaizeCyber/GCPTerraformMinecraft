# GCPTerraformMinecraft v1.0
Terraform configuration files to deploy a Minecraft Server in Google Cloud.

## SETUP

### Prerequisites

1. Create a GCP account and claim your $300 in credits: https://docs.cloud.google.com/docs/get-started
2. In GCP, create a project, then note the project ID: https://developers.google.com/workspace/guides/create-project
3. On your local machine, install the Google Cloud CLI: https://docs.cloud.google.com/sdk/docs/install-sdk
4. Login to the Google Cloud CLI with ```gcloud auth login```
5. On your machine, install terraform on your local machine: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

### Setup

First, define the following as environment variables in your terminal:
```
export TF_VAR_project_id=<your project id> # The full project id, i.e. server-123456
export TF_VAR_project_region=<your selected region> # The region of the project. Choose one near you that also supports e2-medium Instances: https://cloud.google.com/about/locations
export TF_VAR_project_zone=<your selected region> # The zone of the project. The format is the region followed by a, b, c, or d, ie us-east4-a. Choose any available zone.
export TF_VAR_backup_bucket_name=<your selected region> # The name of the bucket which will store your world backups. Must be global unique, so chose a long name.
```

Next, you are going to create a bucket in your project to store the terraform state:
```
gcloud config set project $TF_VAR_project_id
gcloud storage buckets create --location $TF_VAR_project_region gs://${TF_VAR_project_id}-tfstate
gcloud storage buckets update gs://${TF_VAR_project_id}-tfstate --versioning
```

Edit line 9 of provider.tf with the full name of your newly created bucket. 
> bucket  = "testminecraft-483804-tfstate"

Finally run these terraform commands in order:
```
terraform init
```
```
terraform validate
```
```
terraform plan
```
```
terraform apply
```

If you encounter an error during apply similar to "googleapi: Error 403:", just wait a few minutes then run plan and apply again. Sometimes it takes a few minutes for the APIs to enable in the project.

Once apply is complete, terraform will output out three values:
```
cloud_run_url = "https://<sevice_string>.a.run.app"
server_ipv4_address = "<your ipv4 here>"
server_ipv6_address = "<your ipv6 here>"
```

### Use

The server blocks all client connections by default. To join, visit the cloud run url provided to whitelist your IP address. Give this same url to any other users of the server. The URL should display the following once loaded:

> Your IP address has been whitelisted. 
> For 'Server Address' please enter this address:
> -> SERVER_IP <- 
> Server Starting!

The URL will display the IPv4 or IPv6 address of the server depending on what the visitor connected with. Both will work for connecting. These addresses are static and should not change even if the server is stopped and restarted. Backups should be handled automatically by the startup.sh, backup.sh, and shutdown.sh scripts. You can manually review these backups in the Cloud Storage Bucket created under the TF_VAR_backup_bucket_name variable.

The instance will suspend itself upon the server have no connected players. Users will need to visit the join link against to resume the server.

### Cost

The current estimated cost is ~$40 a month. Future work on this project will focus on lowering associated costs, primarily by stopping the server during inactivity or the use of preemptible machines.

## Specs
Storage: 50 GB SSD Persistent Disk
Machine Type: e2-medium
Encryption: Google Managed Encryptions

### Networking
Static External IPv4 and IPv6 Address
Automatic firewall rule creation for user IPs which allows 25565 traffic

### Backups
backup.sh script into Cloud Storage buck
Cronjob for the backup script
Object Lifecycle Management for 60 days of backups, up to three version saves per day

### Other To Dos
Use domain or subdomain with Cloud DNS to cut down on static IP cost
Check on Cloud Run costs and find alternatives if high.
Password authentication for the join link
Automated review and removal of firewall rules

