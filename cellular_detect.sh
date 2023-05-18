#!/bin/sh
log_file="./log/cellular_detect.log"
cellular_ping=114.114.114.114 #ping地址

mkdir ./log

function log()
{
	content="$(date '+%Y-%m-%d %H:%M:%S') $@"
	echo $content | tee -a $log_file
}


while [ 1 ]
do
	ttyUSB_get=`ls /dev |grep ttyUSB |wc -l`
	if [ "$ttyUSB_get" == "4" ]
	then
		log "ttyUSB Get OK!"
		echo -e "enable\ncon t\ncellular send at AT+QCFG=\"band\",ff,200000000080000df,0" | vtysh  >> /etc/null #EG95-AUX做特殊处理
		cellular_ip_get=`ip addr | grep cellular | grep inet | wc -l`
		if [ "$cellular_ip_get" == "1" ]
		then
			log "Cellular IP Get OK!"
			break
		fi
	fi
	sleep 5
done

sleep 10
ping -c 10 $cellular_ping -I cellular0 >> $log_file
