#!/bin/bash 
sudo mkdir -p /home/minecraft
if [ -z "$(blkid /dev/disk/by-id/google-minecraft-disk)" ]; then
  sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-minecraft-disk
fi
sudo mount -o discard,defaults /dev/disk/by-id/google-minecraft-disk /home/minecraft
cd /home/minecraft
sudo apt-get update
sudo apt-get install -y default-jre-headless
sudo apt-get install wget
sudo wget https://launcher.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar
echo "eula=true" > eula.txt
sudo apt-get install -y screen
sudo screen -d -m -S mcs java -Xmx1024M -Xms1024M -jar server.jar nogui
sudo screen -r mcs

curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/backup_script_content" \
  -H "Metadata-Flavor: Google" > /home/minecraft/backup.sh

sudo chmod 755 /home/minecraft/backup.sh
. /home/minecraft/backup.sh
# Source - https://stackoverflow.com/a
# Posted by dogbane, modified by community. See post 'Timeline' for change history
# Retrieved 2025-12-24, License - CC BY-SA 3.0

#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "0 0 * * * /home/minecraft/backup.sh" >> mycron
#install new cron file
crontab mycron
rm mycron

# Install the Google Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# Create a configuration to watch the Minecraft log file
sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null <<EOF
logging:
  receivers:
    minecraft_logs:
      type: files
      include_paths:
        - /home/minecraft/logs/latest.log
  service:
    pipelines:
      default_pipeline:
        receivers: [minecraft_logs]
EOF

# Restart the agent to apply changes
sudo service google-cloud-ops-agent restart

