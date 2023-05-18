#!/bin/sh
logpath="./check.log"
lan_ping=192.168.40.1
wan_ping=192.168.40.1
cellular_ping=www.baidu.com #ping地址
#设定提示语错误
#eth1_gw=192.168.47.1
#dev_ip=`ifconfig eth1 | grep "inet addr" | awk -F ' ' '{print $2}' | awk -F ':' '{print $2}'`
#lan_dev_ip=`arp | grep "Bridge0" | awk -F ' ' '{print $1}'`
#UR41 设备IP用Bridge0区分
dev_ip=`ifconfig Bridge0 | grep "inet addr" | awk -F ' ' '{print $2}' | awk -F ':' '{print $2}'`
separator="######################################################"
set_time=10:00
set_time2=16:00

check_wan()
{
ping_result=`ping -c 10 $wan_ping -I eth1 |grep "10 packets received" |wc -l`
if [ "$ping_result" = "1" ]
then 
	echo "check_wan success" | tee -a $logpath
else 
	echo "check_wan error" | tee -a $logpath
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
		-H 'Content-Type: application/json' \
		-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip ping wan(eth1) error \"}}"	
fi	
}

check_lan()
{
ping_result=`ping -c 10 $lan_ping |grep "10 packets received" |wc -l`
if [ "$ping_result" = "1" ]
then 
	echo "ping lan success" | tee -a $logpath
	lan_success_number=`expr $lan_success_number + 1`
else 
	echo "ping lan error" | tee -a $logpath
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
		-H 'Content-Type: application/json' \
		-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip ping lan dev error \"}}"	
fi	
}

check_temperature()
{
	#Openwrt框架设备读取模组温度
	#temp=`mipc_wan_cli --at_cmd at+qtemp`
	#斑驴框架设备读取模组温度
	echo -e "enable\ncon t\ncellular send at AT+QTEMP" | vtysh
	temp=`tail -n 3 /etc/urlog/cellular.log | grep "+QTEMP:" | awk -F ' ' '{print $5}'`
	echo "module_temp $temp" | tee -a $logpath
}

check_cpu_temperature()
{
	cpu_temp=`cat /sys/devices/virtual/thermal/thermal_zone0/temp`
	echo "cpu_temp $cpu_temp" | tee -a $logpath
}

check_cellular()
{
#检查蜂窝接口是否正常
cellular_interface=`ls /dev |grep ttyUSB |wc -l`
if [ "$cellular_interface" = "4" ]
then
	ping_result=`ping -c 10 $cellular_ping |grep "100% packet loss" |wc -l `
	ping_result_2=`ping -c 10 $cellular_ping |grep "packets transmitted" |wc -l`
    if [ "$ping_result" = "0" -a "$ping_result_2" = "1" ]
	then
		echo "cellular0 ping success" | tee -a $logpath
		cellular_success_number=`expr $cellular_success_number + 1`
	else
		echo "cellular0 ping error" | tee -a $logpath
		curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  cellular0 ping error \"}}"	
	fi	
else
	echo "cellular0 interface error" | tee -a $logpath
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip cellular0 interface error\"}}"	
	fi	
}

check_wifi()
{
wifi_result=`ifconfig |grep ra0 |wc -l`
wifi5G_result=`ifconfig |grep rai0 |wc -l`		
#检查2.4Gwifi接口
if [ "$wifi_result" = "1" ]
then
	echo "wifi-2.4G success" | tee -a $logpath
else
	echo "wifi2.4G error" | tee -a $logpath
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  wifi2.4G error \"}}"
fi
#检查wifi-5G接口
if [ "$wifi5G_result" = "1" ]
then
	echo "wifi-5G success" | tee -a $logpath
else
	echo "wifi-5G error" | tee -a $logpath
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  wifi-5G error \"}}"
fi
#进程暂不检查
}

check_serial()#检查串口
{
RS232_serial_result=`ls /dev/ |grep ttymxc1 |wc -l`
if [ "$RS232_serial_result" = "1" ]
then
	echo "ttymxc1 success" | tee -a $logpath
	RS232_success_number=`expr $RS232_success_number + 1`
else
	echo "ttymxc1 error" | tee -a $logpath
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  ttymxc1 error \"}}"
fi
RS485_serial_result=`ls /dev/ |grep ttymxc2 |wc -l`
if [ "$RS485_serial_result" = "1" ]
then
	echo "ttymxc2 success" | tee -a $logpath
	RS485_success_number=`expr $RS485_success_number + 1`
else
	echo "ttymxc2 error" | tee -a $logpath
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  ttymxc2 error \"}}"
fi
DIDO_serial_result=`ls /dev/ |grep urgpio |wc -l`
if [ "$DIDO_serial_result" = "1" ]
then
	echo "urgpio success" | tee -a $logpath
	GPIO_success_number=`expr $GPIO_success_number + 1`
else
	echo "urgpio error" | tee -a $logpath
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
			-H 'Content-Type: application/json' \
			-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$dev_ip  urgpio error \"}}"
fi
}

time_alarm()
{
#判断时间，满足一定的时间可上传状态，如果规定时间没有上报，默认出现异常
time_result=`date |grep $set_time |wc -l `
time_result_2=`date |grep $set_time2 |wc -l `
if [ "$time_result" = "1" -o "$time_result_2" = "1" ]
then 
	alarm_messagt=`tail -n 3 $logpath`
	curl 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=86d150db-9508-49d3-bd38-08613817e043' \
		-H 'Content-Type: application/json' \
		-d "{\"msgtype\": \"text\",\"text\": {\"content\": \"$alarm_messagt\"}}"	
fi

}

check_number=1
cellular_success_number=0
lan_success_number=0
RS232_success_number=0
RS485_success_number=0
GPIO_success_number=0
while  [ 1 ]
do
	echo $separator | tee -a $logpath
	date | tee -a $logpath
	echo "No $check_number check start" | tee -a $logpath
	echo $separator | tee -a $logpath
	check_cellular
	check_lan
	#check_wan
	#check_wifi
	check_serial
	check_cpu_temperature
	check_temperature
	echo "check number $check_number cellular success $cellular_success_number lan success $lan_success_number RS232 success $RS232_success_number RS485 success $RS485_success_number GPIO success $GPIO_success_number" | tee -a $logpath
	time_alarm
	sleep 50
	check_number=`expr $check_number + 1`
done
