#!/bin/bash


if [ -z "$CONF_DIR" ]
	then
	cd $(dirname $0)
	cd ..
	CONF_DIR=$(pwd)"/conf/"
	fi

cd $(dirname $0)

if ! [ -a $CONF_DIR"settings.sh" ]
	then
	echo ERROR: Settings file not found!
	echo $CONF_DIR"settings.sh"
	exit 1
	fi

. $CONF_DIR"settings.sh"

if ! [ -a $CONF_DIR"apache_servers.csv" ]
        then
        echo ERROR: File with server list not found!
        exit 1
        fi

for SERVER in $(grep -v ^# $CONF_DIR"apache_servers.csv" | cut -d';' -f1)
        do
        sudo /bin/su - root -c "$(pwd)/main.sh $SERVER" > $CONF_DIR'../logs/'$SERVER'.log'
        done
