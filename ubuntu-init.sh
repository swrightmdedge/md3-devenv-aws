#!/bin/bash
PASSWD=${PASSWORD:?specify the password in PASSWORD envar}
DDTOKEN=${TOKEN:?duckdns token}
DDHOST=${HOST:?duckdns host}
LEEMAIL=${EMAIL:?letsencrypt email}
# Install Docker
apt-get update -y && apt-get install -y docker.io && apt install docker-compose -y
# Build the Docker image
# set app directory
mkdir /app
if test -b /dev/sdb
then if  file -sL /dev/sdb | grep "/dev/sdb: data"
     then mkfs.ext4 /dev/sdb
     fi
     echo "/dev/sdb /app ext4 defaults 0 0" >>/etc/fstab
     mount -a
fi
groupadd -g 1001 app
useradd -g 1001 -u 1001 -d /app app
cp /etc/skel/.* /app
echo "app ALL=(ALL)	NOPASSWD: ALL" >>/etc/sudoers
echo "app:${PASSWD}" | chpasswd
chown -Rvf app:app /app
# prepare ssh access
sed  -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
# assign duckdns hostname
echo "curl http://www.duckdns.org/update?domains=${DDHOST}\&token=${DDTOKEN}\&ip=" >>/etc/rc.d/rc.local
bash /etc/rc.d/rc.local
# restore a backup of letsencrypt if provided
if test -n "$LETGZ"
then wget -O- "$LETGZ" | tar xzf - -C /
fi
# generate a certificate with letsencrypt
if ! test -d /app/letsencrypt/live
then
  mkdir -p /app/letsencrypt
  chmod 0755 /app /app/letsencrypt
  docker run --rm \
    -p 80:80 -p 443:443 \
    --name letsencrypt \
    -v "/app/letsencrypt:/etc/letsencrypt" \
    -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
    -e "LETSENCRYPT_EMAIL=${LEEMAIL:?email}" \
    -e "LETSENCRYPT_DOMAIN1=${DDHOST}.duckdns.org" \
    quay.io/letsencrypt/letsencrypt:non-interactive auth \
     --email ${LEEMAIL:?email} -d ${DDHOST}.duckdns.org --agree-tos
fi
# fallback to selfsigned if it did not work
if ! test -e /app/letsencrypt/live/${DDHOST}.duckdns.org/fullchain.pem
then
  mkdir -p /app/letsencrypt/live/${HOST}.duckdns.org
  printf "\\n\\n\\n\\n\\n\\n\\n" |\
  openssl req -x509 -newkey rsa:2048 \
  -keyout  /app/letsencrypt/live/${HOST}.duckdns.org/privkey.pem \
  -out /app/letsencrypt/live/${HOST}.duckdns.org/fullchain.pem \
  -days 30000 -nodes
fi
chown -Rvf app:app /app
