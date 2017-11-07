#!/bin/bash
#
# LVS Client Manager Tools
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-07
#

Interface="lo"
VIPs=(
10.0.0.3
)

#
# 配置ARP
# 抑制/取消抑制ARP响应
function Conf_ARP()
{
   echo "${1:-1}" > /proc/sys/net/ipv4/conf/lo/arp_ignore
   echo "${1:-2}" > /proc/sys/net/ipv4/conf/lo/arp_announce
   echo "${1:-1}" > /proc/sys/net/ipv4/conf/all/arp_ignore
   echo "${1:-2}" > /proc/sys/net/ipv4/conf/all/arp_announce
}

#
# 添加虚拟IP
function Add_VIP()
{
   for p in ${VIPs[*]}
   do
     ip addr show | grep -q "$p" >/dev/null
     if [ $? -ne 0 ]
     then
       Conf_VIP "add" "$p" "to"
     fi
   done
   Conf_ARP
}

#
# 移除虚拟IP
function Remove_VIP()
{
   for p in ${VIPs[*]}
   do
     ip addr show | grep -q "$p" >/dev/null
     if [ $? -eq 0 ]
     then
       Conf_VIP "del" "$p" "from"
     fi
   done
   Conf_ARP 0
}

#
# Add/Remove VIP 
function Conf_VIP()
{
   ip addr $1 $2/32 dev $Interface
   Msg "${1}ing VIP:$2 $3 Interface:$Interface" 2
}

#
# Show VIP configures
function Show_VIP()
{
   clear
   echo "-----------------------------------------"
   echo "VIPs:                                    "
   ip addr show | egrep "`Get_VIP_RegexPattern`"
   echo
   echo "-----------------------------------------"
}

function Get_VIP_RegexPattern()
{
   vips=""
   maxIndex=`expr ${#VIPs[@]} - 1`
   for((i=0;i<=maxIndex;i++))
   do
      vips+="${VIPs[i]}"
      if ((i<maxIndex))
      then
         vips+="|"
      fi
   done
   echo $vips
}

#
# Select Menu
function Select()
{
   local action="$1"
   shift
   [ $# -eq 0 ] || {
      index=0
      until [ $# -eq 0 ]
      do
         VIPs[index++]=$1
         shift
      done
   }
   case "$action" in
      add-vip | start ) Add_VIP ;;
      del-vip | stop ) Remove_VIP ;;
      show-vip | show | status ) Show_VIP ;;
      * ) echo "Usage: /bin/sh $0 start|add-vip|stop|del-vip|show-vip|show|status" ;;
   esac
}

#
# Show Messages
function Msg()
{
   local color="\033[32m"
   if [ $2 -eq 1 ]
   then
      color="\033[31m"
   elif [ $2 -eq 2 ]
   then
      color="\033[37m"
   fi
   echo -e "$color $1 \033[0m"
}

#
#
function Script_Init()
{
   if [ $UID -ne 0 ]
   then
      Msg "only allow runAs root." 1
      return 1
   fi
}

#
#
function Script_Post()
{
   :
}

main()
{
   Script_Init
   [ $? -ne 0 ] && { 
      Script_Post
      exit $?
   }
   Select "$@"
   Script_Post
}


main "$@"
