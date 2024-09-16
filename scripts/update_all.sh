#!/bin/bash

cd $(dirname $0)

if [ -z "$CONF_DIR" ]
	then
	cd $(dirname $0)
	cd ..
	CONF_DIR=$(pwd)"/conf/"
	fi

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

mkdir -p $CONF_DIR'../logs/'
rm -f $CONF_DIR'../logs/'$SERVER'.log'

for SERVER in $(grep -v ^# $CONF_DIR"apache_servers.csv" | cut -d';' -f1)
        do
        sudo /bin/su - root -c "$(pwd)/scripts/main.sh $SERVER" | tee -a $CONF_DIR'../logs/'$SERVER'.log'
        done
