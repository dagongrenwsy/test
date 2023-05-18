#!/bin/sh
ping_ip=192.168.40.50
interface=cellular0

usage(){
	echo "##########################################"
	echo "# usage: ./ping.sh start thread_count    #"
	echo "# usage: ./ping.sh stop                  #"
	echo "##########################################"
	exit
}

if [ -n $2 -a $1 == start ]
then
	for a in `seq $2`
	do
		ping $ping_ip -I $interface -s 1472 >> /dev/null &
	done
elif [ $1 == stop ]
	then
	killall ping
else
	usage
fi
