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

declare help_text=`
clear
cat <<EOF
\n
Todo:\n
Rsync client tools.
\n\n

Usage: \n
sh $0 "YOUR RSYNC_DIR" "YOUR RSYNC SERVER INFO" \ \n
"RSYNC's PASSWORD or password file PATH" "RSYNC's Paramters" \n\n

Example:\n
1. /bin/sh $0 "/backup" "back@172.16.1.31::backup/$(hostname -i)/" "ocean123" "--bwlimit=2" \n
2. /bin/sh $0 "/backup" "back@172.16.1.31::backup/$(hostname -i)/" "ocean123" "--bwlimit=2 --delete" \n
EOF
`

if [ $# -eq 0 -o "$1" == "help" ]
then
   echo -e $help_text
   exit 0
fi

# Basic Check
if [ -z $Rsync_Dir ] ; then
   echo "invalid Rsync dir."
   exit 1
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

# If the password is a file. Read that text as Password.
if [ -f $Rsync_Password ] ; then
   Rsync_Password=$(cat $Rsync_Password)
fi

# Configure Rsync's Password
export RSYNC_PASSWORD=$Rsync_Password

# Execute rsync process
rsync -az $4 $Rsync_Dir $Rsync_SvrInfo && exit 0 || exit 1
