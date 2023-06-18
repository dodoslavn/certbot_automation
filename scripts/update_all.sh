#!/bin/bash


cd $(dirname $0)

. ../conf/settings.sh

if ! [ -a "../conf/apache_servers.csv" ]
	then
	echo ERROR: File with server list not found!
	exit 1
	fi

for SERVER in $(grep -v ^# "../conf/apache_servers.csv" | cut -d';' -f1)
	do
	$(pwd)/main.sh $SERVER > ../logs/$SERVER".log"
	done
