#!/bin/bash
#
# Install & Configure Rsync's Client side
# Created by OceanHo(gzhehai@foxmail.com) at 2017-09-07
#

Auth_PasswordFile="/etc/rsync.password"
Process_LogFile="/tmp/oceanh_yum-install-rsync.log"

# Basic check
if [ ! -f "./rsync.password" ] ; then
   echo "missing file rsync.password in `pwd`"
   exit 1
fi

# Check & install rsync if need do.
rpm -q rsync >/dev/null 2>&1
if [ ! $? -eq 0 ] ; then
   echo "installing rsync."
   yum install rsync -y >$Process_LogFile 2>&1
   if [ ! $? -eq 1 ] ; then
      echo "Install rsync failed. Messages: `cat $Process_LogFile`"
      exit 1
   else
      echo "done."
   fi
fi

# 01. Create Rsync's Password file
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
