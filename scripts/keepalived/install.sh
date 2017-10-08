#!/bin/bash
#
# Keepalived installation tools
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-09-20
#
declare -a _install_help=`
clear
cat<<EOF
\n
Todo:\n
Keepalived installation tools\n
-----------------------------\n\n

Usage:($0 install/help/h/--help/-h/-?/?)\n
----------------------------\n
 If your want install Keepalived,please run fllowing scripts.\n
-------------------------------------------------------------\n
 $0 install \ \n
 --Keepalived-user=www:33333 \ \n
 --Keepalived-group=www:33333 \ \n
 --Keepalived-user-create-mode=Recreate \ \n
 --before-script="echo Starting" \ \n
 --post-script="echo Done." \n
---------------------------------------------------------------------------
\n
EOF
`
#
# Select command's & execute .
if [ $# -eq 0 ] ; then
   echo -e $_install_help
   exit 0
fi

if [ $# -eq 1 ] ; then
   case  "$1" in
      "help" | "h" | "--help" | "-h" | "-help" | "?" | "-?" )
         echo -e $_install_help;
         exit 0
      ;;
   esac
fi

dir=`dirname $0`
if [ ! -d "$dir" ] ; then
   echo "invalid path,please use [sh AbsolutePath] to run script."
   exit 1
fi

cd $dir && \

yum install keepalived -y && \

/bin/cp -f ./keepalived-`hostname`.conf /etc/keepalived/keepalived.conf

if [ $? -ne 0 ]
then
   echo -e "failed."
   exit 1
fi

chkconfig keepalived || chkconfig --add keepalived
chkconfig keepalived off
chkconfig keepalived --level 35 on

/etc/init.d/keepalived restart
exit 0
