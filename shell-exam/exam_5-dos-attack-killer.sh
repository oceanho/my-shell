#!/bin/bash
#
# 19.1.5 企业Shell面试题5：解决DOS攻击生产案例
# 写一个Shell脚本解决DOS攻击生产案例。
# 请根据web日志或者或者网络连接数，监控当某个IP
# 并发连接数或者短时内PV达到100（读者根据实际情况设定）
# 即调用防火墙命令封掉对应的IP。防火墙命令为：iptables-I INPUT -s IP地址 -j DROP。
#
# more info: http://oldboy.blog.51cto.com/2561410/1867160
# 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

maxAllowNum=100
[ "$1" != "" ] && maxAllowNum=$1

#
# 解除某个IP的访问限制
# $1 -> revert
# #2 -> 需要接触限制的IP地址
#
if [ "$1" == "revert" ]
then
   iptables -D INPUT -s $2 -j DROP
   iptables flush
   exit 0
fi

#
# 每5秒监测一次
while true
do
   netstat -ant | grep "ESTABLISHED" | awk -F "[ ]+|:" '{print $(NF-2)}' | sort -k 2 | uniq -c >/tmp/netstat-data.txt
   while read line;
   do
      ip=`awk -F "[ ]+" '{print $NF}' <<<$line`
      count=`awk -F "[ ]+" '{print $1}' <<<$line`
      if [ $count -gt $maxAllowNum ]
      then
         iptables -I INPUT -s $ip -j DROP
      fi
   done </tmp/netstat-data.txt
   sleep 5
done
