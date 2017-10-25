#!/bin/bash
#
# KVM Manager tools
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-26
#

#
# The kvm manager is only allowed root do.
[ $UID -ne 0 ] && {
   echo -e "\033[31m This features only allowed root user. \033[0m"
   exit 1
}

ScriptRootDir="/server/scripts"
EtcScriptRootDir="$ScriptRootDir/etc"

#
# Common functions for echo
# More INFO to https://www.github.com/oceanho/my-shell
#
my_shell_base="https://raw.githubusercontent.com/oceanho/my-shell"
my_shell_echo_lib_url="$my_shell_base/master/scripts/etc/lib/oceanho-echo-lib.sh"
if [ ! -f $EtcScriptRootDir/lib/oceanho-echo-lib.sh  ];then
   mkdir -p $EtcScriptRootDir/lib/
   which wget >/dev/null 2>&1 || yum -y install wget &>/dev/null
   wget -O $EtcScriptRootDir/lib/oceanho-echo-lib.sh $my_shell_echo_lib_url >/dev/null 2>&1
   [ $? -ne 0 ] && {
      echo -e "\033[31m Get common lib failed from ${my_shell_echo_lib_url}. \033[0m"
      exit 1
   }
fi
source $EtcScriptRootDir/lib/oceanho-echo-lib.sh

#
# Show help text
function help()
{
   echoInfo "`
   clear
   cat <<EOF
   Todo:\n
   The kvm Manager tools
   \n\n
   Usage:\n
   /bin/sh $0 create|update|clone|start|stop|delete|status
   EOF
   `"
}


#
# Show KVM machine's status
function list()
{
   virsh list --all
}


#
# Clone a KVM machine
# $1: 指定从哪个kvm虚机克隆
# $2: 指定克隆的kvm新虚拟机的名称
function clone()
{
   [ "$1" == "" ] && {
      echoError "缺少克隆主机名,可以通过第1个参数指定,比如：c72-moban"
      return 1
   }
   [ "$2" == "" ] && {
      echoError "缺少克隆目标主机名,可以通过第2个参数指定,比如：c72-clone"
      return 1
   }

   src_vir_disk="`virsh dumpxml $1 | sed -nr 's#.*<source file=.(.*).{3}#\1#gp'`"
   dest_vir_disk="${2}.`basename $src_vir_disk`"
   dest_vir_xmlconf="`dirname $src_vir_disk`/${2}.xml"

   # 基础检查
   if [ -f $dest_vir_disk ]
   then
      echoWarn "目标主机好像已经存在,请确认重试.磁盘:$dest_vir_disk"
      return 1
   fi
   if [ -f $dest_vir_xmlconf ]
   then
      echoWarn "目标主机好像已经存在,请确认重试.配置:$dest_vir_xmlconf"
      return 1
   fi

   # 复制虚拟磁盘
   /bin/cp -a $src_vir_disk $dest_vir_disk
   # 复制虚拟机配置文件
   virsh dumpxml "$1" > $dest_vir_xmlconf

   # 更新虚拟机的配置文件
   new_kvm_conf "$dest_vir_xmlconf" "$2" "$dest_vir_disk"
}


#
# 更新指定配置文件的UUID,Name,磁盘文件,网卡MAC地址等参数
# $1：指定需要修改的xml的配置文件
# $2：指定主机的新名称
# $3：指定主机的新磁盘文件
function new_kvm_conf()
{
   xml="$1"
   new_name="$2"
   new_disk="$3"
   new_mac_addr=`openssl rand -hex 6 | sed -r 's/(..)/\1:/g;s/.$//g'`

   # 1.替换虚拟机的名字
   sed -ri "s#(.*)<name>.*</name>#\1<name>$new_name</name>#g" $xml
   
   # 2.替换虚拟机的UUID
   sed -ri "s#(.*)<uuid>.*</uuid>#\1<uuid>`uuidgen`</uuid>#g" $xml
   
   # 3.替换虚拟机的磁盘文件
   sed -ri "s#(.*<source file=).*#\1\'$new_disk\' />#g" $xml
   
   # 4.替换虚拟机的网卡的Mac地址
   sed -ri "s#(.*<mac address=).*#\1\'${new_mac_addr}\' />#g" $xml
}



