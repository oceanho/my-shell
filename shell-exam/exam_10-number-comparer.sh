#!/bin/bash
#
# 19.1.10企业Shell面试题10：比较整数大小经典案例
# 综合实战案例：开发shell脚本分别实现以脚本传参以及read读入的方式比较2个整数大小。
# 用条件表达式（禁止if）进行判断并以屏幕输出的方式提醒用户比较结果。
# 注意：一共是开发2个脚本。当用脚本传参以及read读入的方式需要对变量是否为数字、并且传参个数不对给予提示。
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

# 定义2个变量,保存需要比较的2个数字的值
num1=1
num2=2

#
# 设置num1,num2参数值
[ "$1" != "" ] && num1=$1
[ "$2" != "" ] && num2=$2

#
# 判断第一个数字num1是否为数字
expr 1 + $num1 &>/dev/null
if [ $? -eq 2 ]
then
   echo -e "num1: $num1 不是整数."
   exit 1
fi

#
# 判断第2个数字num2是否为数字
expr 1 + $num2 &>/dev/null
if [ $? -eq 2 ]
then
   echo -e "num2: $num2 不是整数."
   exit 1
fi


#
# 比较大小(相等比较)
if [ $num1 -eq $num2 ]
then
   echo "num1($num1) 等于 num2($num2)"
   exit 0
fi

#
# 比较大小（num1大于num2）
if [ $num1 -gt $num2 ]
then
   echo "num1($num1) 大于 num2($num2)"
   exit 0
fi

# num1小于num2
echo "num1($num1) 小于 num2($num2)"

