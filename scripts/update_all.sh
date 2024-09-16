#!/bin/bash

cd $(dirname $0)


if ! [ -a "../conf/settings.sh" ]
	then
	echo ERROR: Settings file not found!
	exit 1
	fi

if ! [ -a "../conf/apache_servers.csv" ]
        then
        echo ERROR: File with server list not found!
        exit 2
        fi

.  "../conf/settings.sh"
FILEN="_"$( date '+%Y.%m.%d_%H:%M:%S' )".log"

mkdir -p "../logs/"

for SERVER in $(grep -v ^# "../conf/apache_servers.csv" | cut -d';' -f1)
        do
        sudo /bin/su - root -c "$(pwd)/main.sh $SERVER" | tee -a $SEVER"_"$FILEN
        done
