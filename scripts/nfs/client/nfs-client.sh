#!/bin/bash
#
# Nfs client Manager tools
# Created by OceanHo(gzhehai@foxmail.com) at 2017-09-10
#

# Bash's version should be Ganther Than 4.X
if [ $(bash --version | sed -nr '1s#.*version ([0-9]+).*#\1#gp') -lt 4 ] ; then
   echo "This tool only support Bash's version 4.0 +"
   exit 1
fi

function nfs_mount()
{
   declare -A _mounts
   _mounts["src"]=""
   _mounts["path"]=""
   _mounts["opts"]=""
   
   k="src"
   v=""
   until [ $# -eq 0 ]
   do
      p=$1
      if egrep -qo "^--" <<< $p; then
         k=$(sed -nr 's#^--(.*)=.*#\1#gp' <<< $p)
         _mounts[$k]=$(sed -nr 's#.*=(.*)#\1#gp' <<< $p)
      fi
      shift
   done
   for key in ${!_mounts[*]}
   do
      echo "Key:$key ,Value:${_mounts[$key]} ."
   done
}

nfs_mount $*
