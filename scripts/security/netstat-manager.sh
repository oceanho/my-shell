#!/bin/bash
#
# 检测DOS攻击 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-02
#

#
#
# 获取网络的连接状态信息
function getNetworkConnections(){
   to_file_cmd=
   if [ "$1" != "" ]
   then
      to_file_cmd=" >$1"
   fi
   netstat -ant | awk -F "([ ]+)|:+" '(NR>=2 && $NF!=LISTEN){print $(NF-2),$NF}' $to_file_cmd
}

function getClientConnectionInfo()
{
   listClientConnectionInfo | egrep "$1"
}

function listClientConnectionInfo()
{
   getNetworkConnections | awk -F "[ ]+" '{print $1}' | uniq -c
}
