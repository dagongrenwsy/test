#!/bin/sh
log_file=./log/test.log
lan_ping=192.168.1.1
#wan_ping=`ubus call yruo_wan get '{"base":"yruo_wan"}' | grep gateway | awk -F '"' '{print $4}'`
wan_ping=192.168.47.1
cellular_ping=www.baidu.com
dev_ip=$1

#log函数
function log()
{
	content="$(date '+%Y-%m-%d %H:%M:%S') $@"
	echo $content
	echo $content >> $log_file
}

if [ ! -e $log_file ]
then
	touch $log_file
	log "Touch log file successfully"
fi

CHECK_MODULE_TEMP()
{
	#Openwrt框架设备读取模组温度
	temp=`mipc_wan_cli --at_cmd at+qtemp | grep md_5g | awk -F '"' '{print $4}'`
	#斑驴框架设备读取模组温度
	#echo -e "enable\ncon t\ncellular send at AT+QTEMP" | vtysh
	#temp=`tail -n 3 /etc/urlog/cellular.log | grep "+QTEMP:" | awk -F ' ' '{print $5}'`
	log "module_temp $temp"
}

CHECK_CPU_TEMP()
{
	cpu_temp=`mipc_wan_cli --at_cmd at+qtemp |grep cpu_little0 |awk -F '"' '{print $4}'`
	#cpu_temp=`cat /sys/devices/virtual/thermal/thermal_zone0/temp`
	log "cpu_temp $cpu_temp"
}

CHECK_CELLULAR()
{
	#检查蜂窝接口是否正常
	#cellular_interface=`ls /dev |grep ttyUSB |wc -l`
	cellular_interface=`cat /sys/kernel/ccci/boot |grep "md1:4 | md2:n/a | md3:n/a | md4:n/a | md5:n/a" |wc -l`
	if [ "$cellular_interface" = "1" ]
	then
		ping_result=`ping -c 10 $cellular_ping |grep "100% packet loss" |wc -l `
		ping_result_2=`ping -c 10 $cellular_ping |grep "packets transmitted" |wc -l`
		if [ "$ping_result" = "0" -a "$ping_result_2" = "1" ]
		then
			log "cellular0 ping success"
			cellular_success_number=`expr $cellular_success_number + 1`
		else
			log "cellular0 ping error"
			curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
				-H 'Content-Type: application/json' \
				-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  cellular0 ping error \"}}"	
		fi	
	else
		log "cellular0 interface error"
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
				-H 'Content-Type: application/json' \
				-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip cellular0 interface error\"}}"	
	fi	
}

CHECK_LAN()
{
	ping_result=`ping -c 10 $lan_ping |grep "10 packets received" |wc -l`
	if [ "$ping_result" = "1" ]
	then 
		log "ping lan success"
		lan_success_number=`expr $lan_success_number + 1`
	else 
		log "ping lan error"
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip ping lan dev error \"}}"	
	fi	
}

CHECK_WAN()
{
	ping_result=`ping -c 10 $wan_ping -I eth1 |grep "10 packets received" |wc -l`
	if [ "$ping_result" = "1" ]
	then 
		log "check_wan success"
	else 
		log "check_wan error"
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip ping wan(eth1) error \"}}"	
	fi	
}

CHECK_WIFI()
{
	wifi_result=`ifconfig |grep ra0 |wc -l`
	wifi5G_result=`ifconfig |grep rai0 |wc -l`		
	#检查2.4Gwifi接口
	if [ "$wifi_result" = "1" ]
	then
		log "wifi-2.4G success"
	else
		log "wifi2.4G error"
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
				-H 'Content-Type: application/json' \
				-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  wifi2.4G error \"}}"
	fi
	#检查wifi-5G接口
	if [ "$wifi5G_result" = "1" ]
	then
		log "wifi-5G success"
	else
		log "wifi-5G error"
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
				-H 'Content-Type: application/json' \
				-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  wifi-5G error \"}}"
	fi
	#检查进程
	ps_wapp_result=`ps | grep wapp | wc -l`
	if [ "$ps_wapp_result" = "3" ]
	then
		log "check wapp success"
	else
		log "check wapp error"
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
				-H 'Content-Type: application/json' \
				-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  wapp error \"}}"
	fi
}

CHECK_SERIAL()
{
	RS232_serial_result=`ls /dev/ |grep ttyS1 |wc -l`
	if [ "$RS232_serial_result" = "1" ]
	then
		log "ttyS1 success"
		RS232_success_number=`expr $RS232_success_number + 1`
	else
		log "ttyS1 error"
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
				-H 'Content-Type: application/json' \
				-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  ttyS1 error \"}}"
	fi
	# RS485_serial_result=`ls /dev/ |grep ttymxc2 |wc -l`
	# if [ "$RS485_serial_result" = "1" ]
	# then
	# 	log "ttymxc2 success"
	# 	RS485_success_number=`expr $RS485_success_number + 1`
	# else
	# 	log "ttymxc2 error"
	# 	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
	# 			-H 'Content-Type: application/json' \
	# 			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  ttymxc2 error \"}}"
	# fi
	DIDO_serial_result=`ls /dev/ |grep urgpio |wc -l`
	if [ "$DIDO_serial_result" = "1" ]
	then
		log "urgpio success"
		GPIO_success_number=`expr $GPIO_success_number + 1`
	else
		log "urgpio error"
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
				-H 'Content-Type: application/json' \
				-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  urgpio error \"}}"
	fi
}

check_number=1
cellular_success_number=0
lan_success_number=0
RS232_success_number=0
# RS485_success_number=0
GPIO_success_number=0
log "############test begin############"
while  [ 1 ]
do
	log "############################"
	log "No $check_number check start"
	log "############################"
	CHECK_MODULE_TEMP
	CHECK_CPU_TEMP
	CHECK_CELLULAR
	CHECK_WAN
	CHECK_WIFI
	CHECK_SERIAL
	#log "check number $check_number cellular success $cellular_success_number lan success $lan_success_number RS232 success $RS232_success_number RS485 success $RS485_success_number GPIO success $GPIO_success_number"
	sleep 60
	check_number=`expr $check_number + 1`
done
