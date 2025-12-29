#!/bin/bash

echo "Waiting for apt locks to be released..."
while fuser /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock /var/cache/apt/archives/lock >/dev/null 2>&1; do
    echo "System updates are in progress. Waiting 5 seconds..."
    sleep 5
done
echo "Apt is free. Proceeding with installation."
# Exit immediately if a command fails
set -e

#!/bin/bash
set -e

sudo mkdir -p /home/minecraft

while [ ! -b "/dev/disk/by-id/google-minecraft-disk" ]; do
  echo "Waiting for persistent disk to attach..."
  sleep 2
done

echo "Formatting disk"
if [ -z "$(blkid /dev/disk/by-id/google-minecraft-disk)" ]; then
  sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-minecraft-disk
fi

echo "Mounting disk"
sudo mount -o discard,defaults /dev/disk/by-id/google-minecraft-disk /home/minecraft
cd /home/minecraft

echo "Running package updates"
sudo apt-get update
sudo apt-get install wget

sudo apt-get install -y wget ca-certificates

echo "Downloading and installing java"
wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
sudo apt-get install -y ./jdk-21_linux-x64_bin.deb

java -version

echo "Downloading Minecraft server"
sudo wget https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar
echo "eula=true" > eula.txt
sudo apt-get install -y screen

echo "Running server via screen..."
sudo screen -d -m -S mcs java -Xmx1024M -Xms1024M -jar server.jar nogui

echo "Downloading backup script"
curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/backup_script_content" \
  -H "Metadata-Flavor: Google" > /home/minecraft/backup.sh

sudo chmod 755 /home/minecraft/backup.sh

echo "Setting backup cron job"
#write out current crontab
crontab -l > mycron 2>/dev/null || touch mycron
#echo new cron into cron file
echo "0 0 * * * /home/minecraft/backup.sh" >> mycron
#install new cron file
crontab mycron
rm mycron

echo "Startup script complete"
