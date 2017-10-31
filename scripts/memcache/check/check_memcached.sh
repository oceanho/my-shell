#!/bin/bash
#
# 检查Memcached服务的可用状态 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-31
key="ocean-mem-check-keyid-0011"
host=127.0.0.1
port=11211
healthly_output="\033[32m Memcached Service is Healthly. \033[0m"

if [ "$1" == "--security" ]
then
   if [ ! -f "$2" ]
   then
      echo -e "\033[31m use the options --security. missing memcached configure file: $2 \033[0m"
      exit 1
   fi
   source $2
else
   [ "$1" != "" ] && host=$1
   [ "$2" != "" ] && port=$2
   [ "$3" != "" ] && healthly_output=$3
fi

. /etc/profile

check_memcached_service()
{
   #
   # 尝试写入,读取memcache缓存
   value="`uuidgen`"
   printf "set $key 0 0 ${#value}\r\n$value\r\n" | nc $host $port >/dev/null || return 1
   
   #
   # 尝试从Mmecached读取写入的缓存数据,用于相同比较,如果读取到的值和定义的变量相同,则memcache服务正常
   geted_val=$(printf "get $key\r\n" | nc $host $port | awk 'NR==2')
   
   #
   # 从 memcached 读取到的数据,存在编码问题,这里直接获取前36位的字符.
   geted_val=`echo ${geted_val:0:36}`
   [ "$geted_val" == "$value" ] && return 0
   return 1
}

check_memcached_service || {
   echo -e "\033[31m Memecached Service is UnHealthly. \033[0m"
   exit 1
}

echo -e "$healthly_output"
