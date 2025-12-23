#!/bin/bash 
sudo mkdir -p /home/minecraft
sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/google-minecraft-disk
mount /dev/disk/by-id/google-minecraft-disk /home/minecraft
cd /home/minecraft
sudo wget https://launcher.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar
sudo java -Xmx1024M -Xms1024M -jar server.jar nogui
sed -i '$c\eula=true' eula.txt
sudo screen -d -m -S mcs java -Xmx1024M -Xms1024M -jar server.jar nogui
