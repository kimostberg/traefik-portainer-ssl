#!/bin/bash

DOCKERDIR=/docker/traefik/data

if [ ! -d $DOCKERDIR ]; then
    mkdir -p $DOCKERDIR
fi
cd /docker
read -p 'Username: ' uservar
read -p 'Password: ' passvar
read -p 'Email: ' email
read -p 'Domain: ' domain
read -p 'CloudFlare DNS API TOKEN: ' cftoken 
sudo apt update
sudo apt install apache2-utils git -y
basicauth=`htpasswd -nb $uservar $passvar`

if [ ! -f /docker/docker-compose.yml ]; then
    sudo wget https://raw.githubusercontent.com/kimostberg/traefik-portainer-ssl/main/docker-compose.yml -P /docker
fi

if [ ! -f /docker/traefik/data/traefik.yml ]; then
    sudo wget https://raw.githubusercontent.com/kimostberg/traefik-portainer-ssl/main/traefik/data/traefik.yml -P /docker/traefik/data
fi

sed -i -e "s/local.example.com/$domain/g" /docker/docker-compose.yml
sed -i -e "s/user@example.com/$email/g" /docker/docker-compose.yml
sed -i -e "s/YOU_API_TOKEN/$cftoken/g" /docker/docker-compose.yml
sed -i -e "s/USER:BASIC_AUTH_PASSWORD/$basicauth/g" /docker/docker-compose.yml
sed -i -e "s/user@example.com/$email/g" /docker/traefik/data/traefik.yml
touch /docker/traefik/data/acme.json
chmod 600 /docker/traefik/data/acme.json
touch /docker/traefik/data/config.yml
