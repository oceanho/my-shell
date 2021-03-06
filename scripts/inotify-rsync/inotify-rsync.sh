#!/bin/bash
#
# Use inotify-tools to watch files and rsync data
# Created by OceanHo(gzhehai@foxmail.com) at 2017-09-04
#

# Watch Dir
Watch_Dir=$1

# Rsync Server Info. Example rsyc@backup::backup/data
Rsync_SvrInfo=$2

# Rsync Server Password. It's Can be a file or text
Rsync_Password=$3

# Rsync to Client RATE limit. defualts 20MB/s.
Rsync_BWlimit=20

# Basic Check
if [ -z $Watch_Dir ] ; then
   echo "invalid Watch dir."
   exit 1
fi

if [ $Watch_Dir == "help" ] ; then
   echo "Usage: $0 /watch_dir rsync@172.16.1.41::backup rsync_password [bwlimit_value]"
   exit 200
fi

if [ ! -f $Watch_Dir -a ! -d $Watch_Dir ] ; then
   echo "invalid Path: $Watch_Dir"
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

# test rsync result
#rsync ${Rsync_SvrInfo%%/*}
#if [ ! $? -eq 0 ] ; then
#   echo "Rsync test failed. "
#   exit 1
#fi

# watch dir & execute rsync process
inotifywait -qrm --format "%w" -e create,delete,close_write,move $Watch_Dir|\
while read line
do
   rsync -az --bwlimit $Rsync_BWlimit --delete $Watch_Dir $Rsync_SvrInfo
done
