#!/bin/bash

cd $(dirname $0)

. ../conf/settings.sh

if [ "$CONFIG" -ne 1 ]
	then
	echo some issue
	exit 1
	fi


if [ -z "$1" ]
	then
	echo ERROR: First parameters needs to be apache server name
	echo File: ../conf/apache_servers.csv
	echo
	cat ../conf/apache_servers.csv | grep -v ^# 
	exit 1
	fi

SERVER=$1

POM=$( grep $SERVER ../conf/apache_servers.csv )
if [ -z "$POM" ]
	then
	echo ERROR: Server is not found in list!
	echo File: ../conf/apache_servers.csv
	echo
        cat ../conf/apache_servers.csv | grep -v ^#
	exit 2
	fi

POM=$( ls /etc/"$SERVER"/ 2>/dev/null )
if [ -z "$POM" ]
        then
        echo ERROR: Server is not found on this machine!
	ls /etc/apache2*
        exit 3 
        fi

S_USER=$(grep $SERVER';' ../conf/apache_servers.csv | cut -d';' -f2)
chmod -R 777 /var/www/cert/ 

SERVICE_EXT=$( echo $SERVER | sed 's/apache2//' )
if ! [ -z "$SERVICE_EXT" ]
	then
	SERVER_EXT="@"$SERVICE_EXT
	fi

a2dissite$SERVICE_EXT $CERTBOT_VHOST_NAME 1>/dev/null 

systemctl restart apache2$SERVER_EXT
RC=$?
if [ "$RC" -ne 0 ]
	then
        exit 4
        fi

for FILE in $( ls /etc/"$SERVER"/sites-enabled/ | grep "ssl" )
	do
	FILE=$( echo $FILE | sed 's/-le-ssl.conf/\.conf/' )
	a2dissite$SERVICE_EXT $FILE 1>/dev/null
	a2dissite$SERVICE_EXT $( echo $FILE | sed 's/\.conf/-le-ssl.conf/' ) 1>/dev/null 2>&1

	echo "################ "/etc/"$SERVER"/sites-available/$FILE
	POM=$(cat /etc/"$SERVER"/sites-available/$FILE | grep ServerAlias )
	if ! [ -z "$( echo $POM | grep \* )" ] 
		then
		echo WARNING: Wildcard found, skipping! 
	 	break	
		fi
	ALIAS=$( echo $POM | awk '{ print $2 }' )
	echo "################ "$ALIAS
	mkdir -p /var/www/cert/$ALIAS/
	echo $ALIAS" " > /var/www/cert/$ALIAS/test.html
	echo $(date) >> /var/www/cert/$ALIAS/test.html
	echo '
<VirtualHost *:80>
  ServerAlias '$ALIAS' 
  ServerName '$ALIAS' 

  DocumentRoot /var/www/cert/'$ALIAS'/

  ErrorLog /var/www/cert/'$ALIAS'/error.log
  CustomLog /var/www/cert/'$ALIAS'/access.log combined
</VirtualHost>' > /etc/"$SERVER"/sites-available/""$CERTBOT_VHOST_NAME
	a2ensite$SERVICE_EXT $CERTBOT_VHOST_NAME 1>/dev/null
	systemctl restart apache2$SERVER_EXT
	RC=$?
	if [ "$RC" -ne 0 ]
		then
		exit 5
		fi
	
	sleep 1
	wget -O - http://$ALIAS/test.html 2>/dev/null
	certbot certonly -d $ALIAS --non-interactive --agree-tos --webroot -w /var/www/cert/$ALIAS/
	RC=$?
	if [ "$RC" -ne 0 ]
                then
                exit 6
                fi

	a2ensite$SERVICE_EXT $FILE 1>/dev/null
	a2ensite$SERVICE_EXT $( echo $FILE | sed 's/\.conf/-le-ssl.conf/' ) 1>/dev/null 


	a2dissite$SERVICE_EXT $CERTBOT_VHOST_NAME 1>/dev/null
	systemctl restart apache2
        RC=$?
        if [ "$RC" -ne 0 ]
                then
                exit 7
                fi


	sleep 3
	
	done 



chmod -R 700 /var/www/cert/
chown -R $S_USER:$S_USER /etc/$SERVER/
chmod -R 770 /etc/$SERVER/


if [ "$RESTART_MAIL_SERVER" -eq 1 ]
	then	
	echo INFO: Restarting mail server
	sudo systemctl restart postfix.service 
	sudo systemctl restart dovecot.service 
	fi
