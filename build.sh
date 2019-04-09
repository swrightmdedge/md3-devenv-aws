#!/bin/bash
if ! test $(id -u)  == "1001"
then echo "Please run this script as 'app' user" ; exit 1
fi
if ! test -e devenv/_password 
then echo "Please type password for devenv"
     read PASSWORD
     echo $PASSWORD >devenv/_password
fi
test -e base-ssh/id_rsa ||  ssh-keygen -t rsa -f base-ssh/id_rsa -N '' 
cp base-ssh/id_* devenv
for i in \
    devenv
do docker build -t md3/$i $i || exit 1
done
if ! grep docker-compose /etc/rc.d/rc.local >/dev/null
then echo "Build complete. You can start with 'docker-compose up' or reboot to start automatically"
     sudo cp "$(dirname $0)/docker-compose.yml" /etc/docker-compose.yml
     echo "/usr/bin/docker-compose -f /etc/docker-compose.yml up -d" | sudo tee -a /etc/rc.d/rc.local >/dev/null
fi
