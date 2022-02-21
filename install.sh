#!/bin/bash

DOCKERDIR=/docker

if [ ! -d $DOCKERDIR ]; then
    mkdir -p $DOCKERDIR
fi
cd /docker
read -p 'Username: ' uservar
read -sp 'Password: ' passvar
read -p 'Email: ' email
read -p 'Domain: ' domain
read -p 'CloudFlare DNS API TOKEN: ' cftoken 
sudo apt update
sudo apt install apache2-utils git -y
basicauth=`htpasswd -nb $uservar $passvar`
git clone https://github.com/kimostberg/traefik-portainer-ssl
sed -i -e 's/local.example.com/$domain/g' /docker/docker-compose.yml
sed -i -e 's/user@example.com/$email/g' /docker/docker-compose.yml
sed -i -e 's/YOU_API_TOKEN/$cftoken/g' /docker/docker-compose.yml
sed -i -e 's/USER:BASIC_AUTH_PASSWORD/$basicauth/g' /docker/docker-compose.yml
sed -i -e 's/user@example.com/$email/g' /docker/traefik/data/traefik.yml
