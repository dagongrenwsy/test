#!/bin/sh

usage () {
	echo "# usage: ./set_ip.sh [dev_ip]"
	exit 1
}

if [ -z $1 ]; then
	usage
else 
	