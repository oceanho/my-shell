#!/bin/bash
#
# Use Rsync push data to server in client side
# Created by OceanHo(gzhehai@foxmail.com) at 2017-09-07
#

# Rsync Dir
Rsync_Dir=$1

# Rsync Server Info. Example rsyc@backup::backup/data
Rsync_SvrInfo=$2

# Rsync Server Password. It's Can be a file or text
Rsync_Password=$3

# Rsync to Client RATE limit. defualts 20MB/s.
Rsync_BWlimit=20

# Basic Check
if [ -z $Rsync_Dir ] ; then
   echo "invalid Rsync dir."
   exit 1
fi

if [ $Rsync_Dir == "help" ] ; then
   echo "Usage: $0 /data rsync@172.16.1.41::backup rsync_password 20"
   exit 200
fi

if [ ! -f $Rsync_Dir -a ! -d $Rsync_Dir ] ; then
   echo "invalid Path: $Rsync_Dir"
   exit 1
fi

if [ -z $Rsync_SvrInfo ] ; then
   echo "invalid Rsync Info."
   exit 1
fi

if [ -z $Rsync_Password ] ; then
   echo "invalid Rsync's Password."
   exit 1
fi

# If configured the Number of 4 Parameter. Check and set bwlimit if passed.
if [ ! -z "$4" ] ; then
   if egrep "^[1-9][0-9]{0,}$" <<< "$4" >/dev/null 2>&1 ; then
      Rsync_BWlimit=$4
   fi
fi

# If the password is a file. Read that text as Password.
if [ -f $Rsync_Password ] ; then
   Rsync_Password=$(cat $Rsync_Password)
fi

# Configure Rsync's Password
export RSYNC_PASSWORD=$Rsync_Password

# Execute rsync process
rsync -az --bwlimit $Rsync_BWlimit $4 $Rsync_Dir $Rsync_SvrInfo
