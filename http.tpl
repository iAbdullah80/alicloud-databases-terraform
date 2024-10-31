#!/bin/sh

sudo apt-get update -yy

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

wget https://raw.githubusercontent.com/iAbdullah80/capstone-project/refs/heads/deployment/compose.yml
printf "REDIS_HOST=${redis_host}\nDB_HOST=${db_host}\nDB_USER=user\nDB_PASSWORD=${db_password}\nDB_NAME=mydatabase\n" >> .env
until nc -vzw 2 ${db_host} 3306; do sleep 30; done
docker compose up web -d