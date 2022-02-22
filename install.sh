#!/bin/bash

DOCKERDIR=/docker/container/traefik/data

if [ ! -d $DOCKERDIR ]; then
    mkdir -p $DOCKERDIR
fi
cd /docker
read -p 'Username: ' uservar
read -p 'Password: ' passvar
read -p 'Email: ' email
read -p 'Domain: ' domain
read -p 'CloudFlare API KEY: ' cftoken
sudo apt update
sudo apt install apache2-utils git -y
basicauth=$(echo $(htpasswd -nb $uservar $passvar) | sed -e s/\\$/\\$\\$/g)

if [ ! -f /docker/docker-compose.yml ]; then
    sudo wget https://raw.githubusercontent.com/kimostberg/traefik-portainer-ssl/main/docker-compose.yml -P /docker
fi

if [ ! -f /docker/traefik/data/traefik.yml ]; then
    sudo wget https://raw.githubusercontent.com/kimostberg/traefik-portainer-ssl/main/traefik/data/traefik.yml -P $DOCKERDIR
fi

sed -i -e "s/local.example.com/$domain/g" /docker/docker-compose.yml
sed -i -e "s/user@example.com/$email/g" /docker/docker-compose.yml
sed -i -e "s/YOU_API_KEY/$cftoken/g" /docker/docker-compose.yml
sed -i -e "s/BASICAUTH/$basicauth/g" /docker/docker-compose.yml
sed -i -e "s/user@example.com/$email/g" $DOCKERDIR/traefik.yml
touch $DOCKERDIR/acme.json
chmod 600 $DOCKERDIR/acme.json
touch $DOCKERDIR/config.yml