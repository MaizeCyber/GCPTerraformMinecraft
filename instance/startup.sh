#!/bin/bash

echo "Waiting for apt locks to be released..."
while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/cache/apt/archives/lock >/dev/null 2>&1; do
    echo "System updates are in progress. Waiting 5 seconds..."
    sleep 5
done
echo "Apt is free. Proceeding with installation."
# Exit immediately if a command fails
set -e

DEVICE_NAME = "google-minecraft-disk"
MOUNT_PATH = "/home/minecraft"
DISK_PATH= "/dev/disk/by-id/$DEVICE_NAME"

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

cd /home/minecraft

echo "Running package updates"
sudo apt-get update
sudo apt-get install wget

sudo apt-get install -y wget ca-certificates

if ! command -v java &> /dev/null; then
  echo "Downloading and installing java"
  wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
  sudo apt-get install -y ./jdk-21_linux-x64_bin.deb
fi

java -version

if [ ! -e "$MOUNT_PATH/server.jar" ]; then
  echo "Downloading Minecraft server"
  sudo wget https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar
  echo "eula=true" > eula.txt
fi

sudo apt-get install -y screen

echo "Running server via screen..."
sudo screen -d -m -S mcs java -Xmx1024M -Xms1024M -jar server.jar nogui

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
  echo "0 0 * * * /home/minecraft/backup.sh" >> mycron
  #install new cron file
  crontab mycron
  rm mycron
fi

echo "Startup script complete"
