#!/bin/bash
#
# 检查MySQL的可用状态 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-31
#

user=root
pass=123456
host=localhost
port=3306
healthly_output="\033[32m MySQL Service is Healthly. \033[0m"

if [ "$1" == "--security" ]
then
   if [ ! -f "$2" ]
   then
      echo -e "\033[31m use the options --security. missing mysql auth file: $2 \033[0m"
      exit 1
   fi
   source $2
else
   [ "$1" != "" ] && user=$1
   [ "$2" != "" ] && pass=$2
   [ "$3" != "" ] && host=$3
   [ "$4" != "" ] && port=$4
   [ "$5" != "" ] && healthly_output=$5
fi

. /etc/profile

mysql -u$user -p$pass -h$host -P$port -e "select version();" >/dev/null || {
   echo -e "\033[31m MySQL Service is UnHealthly. \033[0m"
   exit 1
}

echo -e "$healthly_output"
