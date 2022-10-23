#!/bin/bash

DOCROOT="/var/www/cert/"

if [ -z "$1" ]
	then
	echo ERROR: Enter apache2 instance name!	
	exit 1
	fi
INSTANCE=$1
SERVICE_EXT=$( echo $INSTANCE | sed 's/apache2//' )
if ! [ -z "$SERVICE_EXT" ]
	then
	SERVER_EXT="@"$SERVICE_EXT
	fi

if [ -z "$2" ]
        then
        echo ERROR: Enter the new domain name!
        exit 2 
        fi
DOMAIN=$2

mkdir -p $DOCROOT
mkdir -p $DOCROOT""$DOMAIN 
mkdir -p $DOCROOT""$DOMAIN/web/ 
mkdir -p $DOCROOT""$DOMAIN/log/ 

echo "<VirtualHost *:80>
  ServerAlias $DOMAIN 
  ServerName $DOMAIN 

  DocumentRoot $DOCROOT""$DOMAIN/web/

  ErrorLog /var/www/cert/$DOMAIN/log/error.log
  CustomLog /var/www/cert/$DOMAIN/log/access.log combined
</VirtualHost>" > /etc/$INSTANCE/sites-available/000-certbot-new_domain.conf

echo Generated new config:
echo =========================
cat /etc/$INSTANCE/sites-available/000-certbot-new_domain.conf
echo =========================

a2ensite$SERVICE_EXT 000-certbot-new_domain.conf >/dev/null
systemctl reload apache2$SERVER_EXT

certbot certonly -d $DOMAIN --non-interactive --agree-tos --webroot -w /var/www/cert/$DOMAIN/web/

dissite$SERVICE_EXT 000-certbot-new_domain.conf 2>/dev/null
rm /etc/$INSTANCE/sites-available/000-certbot-new_domain.conf

#ls -l /etc/letsencrypt/live/$DOMAIN/
