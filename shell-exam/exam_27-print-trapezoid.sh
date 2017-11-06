#!/bin/bash
#
# 19.1.27 企业Shell面试题27：编写直角梯形图形字符案例
# 请用shell或Python编写一个画直角梯形程序，接收用户输入的参数n（n>2）
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

while true
do
   read -p "输入一个大于2的整数："
   if egrep -q "[2-9][0-9]?" <<<$REPLY
   then
      n=$REPLY
      break
   fi
done

for i in `seq 2 $n`
do
   for j in `seq 1 $i`
   do
      echo -n "#-"
   done
   echo
done
