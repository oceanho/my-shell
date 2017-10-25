#!/bin/bash
#
# KVM Manager tools
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-26

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



