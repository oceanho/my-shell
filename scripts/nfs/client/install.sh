#!/bin/bash
#
# Install nfs's client
# Created by OceanHo(gzhehai@foxmail.com) at 2017-09-10
#

Nfs_Version="nfs-tools"
Rpc_Version="rpcbind"
Install_Execute_Log="/tmp/oceanho_install_nfs_rpc_client.log"

# 01. Check & install nfs-tools
if ! rpm -qa $Nfs_Version &>>$Install_Execute_Log ; then
   echo "Installing $Nfs_Version ."
   yum install -y $Nfs_Version
   if [ $? -ne 0 ] ; then
      echo "Install $Nfs_Version failed. "
      exit 1
   fi
fi

# 01. Check & install rcpbind
if ! rpm -qa $Rpc_Version &>>$Install_Execute_Log ; then
   echo "Installing $Rpc_Version ."
   yum install -y $Rpc_Version
   if [ $? -ne 0 ] ; then
      echo "Install $Rpc_Version failed. "
      exit 1
   fi
fi

echo "done."
exit 0
