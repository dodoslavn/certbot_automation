#!/bin/bash


APACHE_LIST_F="../conf/apache_servers.csv"



renew()
	{
	POM=$1	
	FILE_SSL=$(ls -l "/etc/"$SERVER"/sites-available/"$POM* | rev | awk '{ print $1 }' | rev | grep "\-le-ssl.conf" | grep -v ".tmp" )
	FILE_NONSSL=$(ls -l "/etc/"$SERVER"/sites-available/"$POM* | rev | awk '{ print $1 }' | rev | grep -v "\-le-ssl.conf" | grep -v ".tmp" )

	SN_SSL=$( cat $FILE_SSL | grep ServerName | awk '{ print $2 }' )
	SN_NONSSL=$( cat $FILE_NONSSL | grep ServerName | awk '{ print $2 }' )

        SA_SSL=$( cat $FILE_SSL | grep ServerAlias | awk '{ print $2 }' )
        SA_NONSSL=$( cat $FILE_NONSSL | grep ServerAlias | awk '{ print $2 }' )

	DR="/var/www/cert/"$SA_SSL

	cp $FILE_NONSSL $FILE_NONSSL".tmp"
        cp $FILE_SSL $FILE_SSL".tmp"

	mkdir -p $DR

	echo '

<VirtualHost *:80>
  ServerName '$SN_NONSSL' 
  ServerAlias '$SA_NONSSL'

  DocumentRoot '$DR'/

  RewriteEngine on
  RewriteRule ^ https://'$SA_NONSSL'%{REQUEST_URI} [END,QSA,R=permanent]
  RewriteCond %{SERVER_NAME} ='$SA_NONSSL'
  RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

' > $FILE_NONSSL

	echo '

<IfModule mod_ssl.c>
  <VirtualHost *:443>
    ServerName '$SN_SSL' 
    ServerAlias '$SA_SSL'

    DocumentRoot '$DR'/ 

    Include /etc/letsencrypt/options-ssl-apache.conf
    SSLCertificateFile /etc/letsencrypt/live/'$SA_SSL'/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/'$SA_SSL'/privkey.pem
  </VirtualHost>
</IfModule>

' > $FILE_SSL

	systemctl reload $SERVER

	echo "  ############# $SA_NONSSL ############"
	certbot certonly -d $SA_NONSSL --non-interactive --agree-tos --webroot -w /var/www/cert/$SA_NONSSL/
	echo "  ############# $SA_NONSSL ############"
	
	rm $FILE_NONSSL $FILE_SSL
	mv $FILE_NONSSL".tmp" $FILE_NONSSL
	mv $FILE_SSL".tmp" $FILE_SSL

	systemctl reload $SERVER
	sleep 3
	}



for SERVER in $( cat $APACHE_LIST_F )
	do
	echo Working on server \"$SERVER\"

	for SITE in $(ls -l "/etc/"$SERVER"/sites-enabled/" | rev | awk '{ print $3 }' | rev | cut -d"-" -f1 | uniq ) 
		do
		#echo $SITE	
		if ! [ -z "$(ls -l "/etc/"$SERVER"/sites-enabled/"$SITE* | grep -v '.tmp' | rev | awk '{ print $3 }' | rev | grep "\-le-ssl.conf" )" ]
			then
			echo Certificate found for web $( ls -l "/etc/"$SERVER"/sites-enabled/"$SITE* | rev | awk '{ print $3 }' | rev | grep -v "\-le-ssl.conf" ) 
			renew $SITE
		else
			echo Skipping $( ls -l "/etc/"$SERVER"/sites-enabled/"$SITE* | rev | awk '{ print $3 }' | rev ) 
			fi 
		done
	chown www-data:www-data /etc/"$SERVER"/sites-enabled/*
	chmod 770 /etc/"$SERVER"/sites-enabled/*

	done



