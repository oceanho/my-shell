#!/bin/bash
#
# Install & Configure Rsync's Server side
# Created by OceanHo(gzhehai@foxmail.com) at 2017-09-07
#

Auth_PasswordFile="/etc/rsync.password"
Process_LogFile="/tmp/oceanh_yum-install-rsync.log"

Process_ConfigureMode="force"

Rsync_Server_UID="rsync"
Rsync_Server_GID="rsync"

# Basic check
if [ ! -f "./rsync.password" ] ; then
   echo "missing file rsync.password in `pwd`"
   exit 1
fi

if [ ! -f "./rsyncd.conf" ] ; then
   echo "missing file rsyncd.conf in `pwd`"
   exit 1
fi

# Check & install rsync if need do.
rpm -q rsyncd >/dev/null 2>&1
if [ ! $? -eq 0 ] ; then
   echo "installing rsync."
   yum install rsync -y >$Process_LogFile 2>&1
   if [ ! $? -eq 1 ] ; then
      echo "Install rsync failed. Messages: `cat $Process_LogFile`"
      exit 1
   else
      echo "done."
   fi
then

# 01. Create run rsync's User & Group
id $Rsync_Server_UID >/dev/null 2>&1
if [ ! $? -eq 0 ] ; then
   useradd -s /sbin/nologin -M $Rsync_Server_UID
   if [ $? -eq 0 ];then
      echo "Create User ok."
   else
      echo "Create User failed."
      exit 1
   fi
fi

# 02. Create Rsync's Password file
if [ ! -f $Auth_PasswordFile ] ; then
   cp ./rsync.password /etc/ -f
else
   if [ $Process_ConfigureMode == "force" ] ; then
      cp ./rsync.password /etc/ -f
   fi
fi
if [ -f $Auth_PasswordFile ] ; then
   chmod 600 $Auth_PasswordFile && chown root.root $Auth_PasswordFile
   if [ ! $? -eq 0 ] ; then
      echo "Rsync's Password process failed."
      exit 0
   fi
fi

# 03. Create Rsync's daemon configure file
if [ -f "/etc/rsyncd.conf" ] ; then
   if [ $Process_ConfigureMode == "force" ] ; then
      cp ./rsyncd.conf /etc/ -f
   fi
else
   cp ./rsyncd.conf /etc/ -f
fi

# 04. Create All module's directory by /etc/rsyncd.conf
if [ -f "/etc/rsyncd.conf" ] ; then
   for dir in `sed -nr 's#^path = (.*)#\1#gp' /etc/rsyncd.conf`
   do
      echo "Create dir:[$dir]"
      mkdir -p $dir
      chown rsync.rsync $dir
      echo "Created. $dir"
   done
else
   echo "/etc/rsyncd.conf not found."
   exit 1
fi

# 05. Create Rsyncd Manager Scripts
if [ ! -f ./rsyncd ] ; then
   echo "Missing file rsyncd in `pwd` ."
   exit 1
fi
cp -f ./rsyncd /etc/init.d/rsyncd && chmod +x /etc/init.d/rsyncd
if [ ! $? -eq 0 ] ; then
   echo "Process /etc/init.d/rsyncd failed."
   exit 1
fi

# 06. Add to automatic start when system poweron
chkconfig --list rsyncd >/dev/null || chkconfig --add rsyncd 
chkconfig --levels 35 rsyncd on

# 07. Start Rsync daemon
/etc/init.d/rsyncd restart

