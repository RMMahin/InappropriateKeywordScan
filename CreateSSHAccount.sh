#!/bin/bash

DOMAIN="soft.rest"
PASS="S0ft828"

DOMAIN_DIR="${DOMAIN//./_}"

sudo adduser $DOMAIN_DIR 2>> error.csv

sudo usermod -G www-data $DOMAIN_DIR 2>> error.csv
sudo mkdir -p /var/public/$DOMAIN_DIR/$DOMAIN/www 2>> error.csv
sudo chown -R $DOMAIN_DIR:www-data /var/public/$DOMAIN_DIR/$DOMAIN/ 2>> error.csv
sudo chmod -R 755 /var/public/$DOMAIN_DIR/$DOMAIN/ 2>> error.csv

sudo bash -c echo "

Match User $DOMAIN_DIR

    ChrootDirectory /var/public/$DOMAIN_DIR
#    ForceCommand internal-sftp
    X11Forwarding no
    AllowTcpForwarding no
" >> /etc/ssh/sshd_config 2>> error.csv

sudo systemctl restart ssh 2>> error.csv
