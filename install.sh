#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}

function check_internet() {
  printf "Checking if you are online..."
  wget -q --spider http://github.com
  if [ $? -eq 0 ]; then
    echo "Online. Continuing."
  else
    error "Offline. Go connect to the internet then run the script again."
  fi
}

check_internet

DOCKERDIR=/docker/container/

if [ ! -d $DOCKERDIR ]; then
    mkdir -p $DOCKERDIR
fi
cd /docker
echo "Traefik login username"
read -p 'Username: ' uservar
echo "Traefik login password. Alphanumeric. No special characters"
read -p 'Password: ' passvar
clear
echo "Your CloudFlare email account"
read -p 'Email: ' email
read -p 'Domain: ' domain
read -p 'CloudFlare API KEY: ' cftoken
sudo apt update
sudo apt install apache2-utils git wget docker-compose -y
basicauth=$(echo $(htpasswd -nb $uservar $passvar) | sed -e s/\\$/\\$\\$/g)

mkdir -p $DOCKERDIR/traefik-portainer

if [ ! -f $DOCKERDIR/traefik-portainer/docker-compose.yml ]; then
    sudo wget https://raw.githubusercontent.com/kimostberg/traefik-portainer-ssl/main/docker-compose.yml -P $DOCKERDIR/traefik-portainer
fi
mkdir -p $DOCKERDIR/traefik/data

if [ ! -f $DOCKERDIR/traefik/data/traefik.yml ]; then
    sudo wget https://raw.githubusercontent.com/kimostberg/traefik-portainer-ssl/main/traefik/data/traefik.yml -P $DOCKERDIR/traefik/data
fi

sed -i -e "s/local.example.com/$domain/g" $DOCKERDIR/traefik-portainer/docker-compose.yml
sed -i -e "s/user@example.com/$email/g" $DOCKERDIR/traefik-portainer/docker-compose.yml
sed -i -e "s/YOU_API_KEY/$cftoken/g" $DOCKERDIR/traefik-portainer/docker-compose.yml
sed -i -e "s/BASICAUTH/$basicauth/g" $DOCKERDIR/traefik-portainer/docker-compose.yml
sed -i -e "s/user@example.com/$email/g" $DOCKERDIR/traefik-portainer/traefik/traefik.yml
touch $DOCKERDIR/traefik/data/acme.json
chmod 600 $$DOCKERDIR/traefik/data/acme.json
if [ ! -f $DOCKERDIR/traefik/data/config.yml ]; then
    sudo wget https://raw.githubusercontent.com/kimostberg/traefik-portainer-ssl/main/traefik/data/config.yml -P $DOCKERDIR/traefik/data
fi

sudo docker network create \
  --driver=bridge \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  frontend

sudo docker network create \
  --driver=bridge \
  --subnet=172.21.0.0/16 \
  backend

docker-compose up -d -f $DOCKERDIR/traefik-portainer/docker-compose.yml