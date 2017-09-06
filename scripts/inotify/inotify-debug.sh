#!/bin/bash
#
# Script for inotifywait test
# Created by OceanHo(gzhehai@foxmail.com) at 2017-09-05
#

Watch_Dir=$1
Watch_Events="create,delete,move,close_write"

if [ -z $Watch_Dir ] ; then
   echo "invalid Watch_Dir."
   exit 1
fi

if [ ! -f $Watch_Dir -a ! -d $Watch_Dir ] ; then
   echo "invalid Watch_Dir. Path [$Watch_Dir] Not exists."
   exit 1
fi

if [ ! -z "$2" ] ; then
   Watch_Events=$2
fi

inotifywait -rm --timefmt "%F %T" --format "%T ,Trigger Events: %e" $Watch_Dir --event "$Watch_Events"
