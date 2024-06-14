#!/bin/sh

count=1
test_flie=/tmp/emmc_test
log_file=./log/emmc_test.log
mkdir ./log

function log()
{
	content="$(date '+%Y-%m-%d %H:%M:%S') $@"
	echo $content | tee -a $log_file
}

log " "
log "==========eMMC test begin =========="

#Determine if a file exists from a previous script run, and if so, delete the file
if [ -e /data/emmc_test ];then
	rm -rf /data/emmc_test
	log "Exist /data/emmc_test, Delete /data/emmc_test successfully"
fi

while [ 1 ]
do
	log "==========write ${count} =========="
	#Need to clear the cache before reading and writing data, otherwise the rate returned by the dd command is incorrect
	sync && echo 3 > /proc/sys/vm/drop_caches
	#Write to a 1GB size file
	dd if=/dev/zero of=/data/test_write bs=16k count=65536
	if [ $# -eq 0 ];then
		log "emmc write ${count} succesful"
	else
		log "emmc write ${count} failure "
		kill -9 $$
	fi
	sleep 5
	log "==========read  ${count} =========="
	sync && echo 3 > /proc/sys/vm/drop_caches
	dd if=/data/test_write of=/dev/null bs=16k count=65536	
	if [ $# -eq 0 ];then
		log "emmc read ${count} succesful"
	else
		log "emmc read ${count} failure "
		kill -9 $$
	fi
	sleep 5
	df -h
	let count=count+1

done
