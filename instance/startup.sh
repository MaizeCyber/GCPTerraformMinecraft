#!/bin/bash

echo "Waiting for apt locks to be released..."
while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/cache/apt/archives/lock >/dev/null 2>&1; do
    echo "System updates are in progress. Waiting 5 seconds..."
    sleep 5
done
echo "Apt is free. Proceeding with installation."

DEVICE_NAME="google-minecraft-disk"
MOUNT_PATH="/home/minecraft"
DISK_PATH="/dev/disk/by-id/$DEVICE_NAME"

if [ ! -d "$MOUNT_PATH" ]; then
  sudo mkdir -p "$MOUNT_PATH"
fi

while [ ! -b "$DISK_PATH" ]; do
  echo "Waiting for persistent disk to attach..."
  sleep 2
done

if mountpoint -q "$MOUNT_PATH"; then
  echo "Disk is already mounted to $MOUNT_PATH. Skipping setup."
else

  # Format the disk only if it doesn't have a filesystem yet
  if ! blkid "$DISK_PATH" > /dev/null; then
    echo "New disk detected. Formatting with ext4..."
    sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard "$DISK_PATH"
  fi

  echo "Mounting disk"
  sudo mount -o discard,defaults /dev/disk/by-id/google-minecraft-disk /home/minecraft

  # Ensure it mounts automatically on reboots
  if ! grep -qs "$MOUNT_PATH" /etc/fstab; then
    echo "$DISK_PATH $MOUNT_PATH ext4 discard,defaults,nofail 0 2" >> /etc/fstab
  fi

  echo "Persistent disk mounted successfully to $MOUNT_PATH"

fi

# Install Ops Agent
if [ ! -f "add-google-cloud-ops-agent-repo.sh" ]; then
  echo "Downloading ops agent"
  wget -nc https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
fi

if [ ! -f "/etc/google-cloud-ops-agent/config.yaml" ]; then
  echo "Installing ops agent"
  sudo bash add-google-cloud-ops-agent-repo.sh --also-install
fi

# Add mincraft config to ops agent
if [ ! -f "config.yaml" ]; then
  echo "Downloading ops config file"
  curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/ops_config_file" \
      -H "Metadata-Flavor: Google" > /home/minecraft/config.yaml
fi

echo "Adding config.yaml file to ops agent..."
sudo rm /etc/google-cloud-ops-agent/config.yaml
sudo cp /home/minecraft/config.yaml /etc/google-cloud-ops-agent/
sudo systemctl restart google-cloud-ops-agent

# Check if the world folder exists. If not, try to restore from backup.
if [ ! -d "$MOUNT_PATH/world" ]; then
  echo "World folder not found. Attempting to restore from Cloud Storage..."

  # Get the most recent backup folder name from the bucket
  LATEST_BACKUP=$(gcloud storage ls gs://potato-swirl-landbridge-deaf/ | sort | tail -n 1)

  if [ -z "$LATEST_BACKUP" ]; then
    echo "No backups found in bucket. A new world will be generated."
  else
    echo "Restoring from $LATEST_BACKUP"
    gcloud storage cp -R "${LATEST_BACKUP}world" "$MOUNT_PATH/"
    echo "Restore complete."
  fi
fi

cd /home/minecraft

echo "Running package updates"
sudo apt-get update
sudo apt-get install wget

sudo apt-get install -y wget ca-certificates

if ! command -v java &> /dev/null; then
  echo "Java is not installed. Checking for local installer..."

  # Check if the installer is already on the persistent disk
  if [ ! -f "jdk-21_linux-x64_bin.deb" ]; then
    echo "Installer not found. Downloading..."
    wget -nc https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
  else
    echo "Found existing installer on disk. Skipping download."
  fi

  echo "Installing Java from local file..."
  sudo apt-get install -y ./jdk-21_linux-x64_bin.deb
fi

java -version

if [ ! -f "server.jar" ]; then
  echo "Downloading Minecraft server..."
  # -nc prevents duplicates like server.jar.1
  wget -nc https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar
fi

echo "eula=true" > eula.txt

sudo apt-get install -y screen

echo "Running server via screen..."
sudo screen -d -m -S mcs java -Xmx2G -Xms1024M -jar server.jar nogui

if [ ! -e "$MOUNT_PATH/backup.sh" ]; then
  echo "Downloading backup script"
  curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/backup_script_content" \
    -H "Metadata-Flavor: Google" > /home/minecraft/backup.sh
fi

sudo chmod 755 /home/minecraft/backup.sh

if crontab -l 2>/dev/null | grep -Fq "/home/minecraft/backup.sh"; then
    echo "Cron job already exists. Skipping."
else
  echo "Setting backup cron job"
  #write out current crontab
  crontab -l > mycron 2>/dev/null || touch mycron
  #echo new cron into cron file
  echo "0 */4 * * * /home/minecraft/backup.sh" >> mycron
  #install new cron file
  crontab mycron
  rm mycron
fi

echo "Startup script complete"
