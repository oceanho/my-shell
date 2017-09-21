#!/bin/bash
#
# MySQL installtion tools
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-09-16
#


declare -a _install_help=`
clear
cat<<EOF
\n
Todo:\n
MySQL installation tools\n
------------------------\n\n

Usage:($0 install/help/h/--help/-h/-?/?)\n
----------------------------\n
 If your want install nginx,please run fllowing scripts.\n
-------------------------------------------------------------\n
 $0 install \ \n
 --mysql-user=mysql:33333 \ \n
 --mysql-group=mysql:33333 \ \n
 --mysql-user-create-mode=Recreate \ \n
 --mysql-skiped-when-installed="yes" \ \n
 --before-script="echo Starting" \ \n
 --post-script="echo done." \n
---------------------------------------------------------------------------\n
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

if [ -f "/application/mysql/bin/mysql" ]
then
   source /etc/profile
   echo -e "MySQL seem to has installed at `which mysql`"
   exit 0
fi

id mysql &>/dev/null || useradd -s /sbin/nologin -M mysql

cd /server/tools && \
tar xf mysql-5.6.34-linux-glibc2.5-x86_64.tar.gz && \

mkdir -p /application/ && \
mv -f /server/tools/mysql-5.6.34-*-x86_64 /application/mysql-5.6.34 && \
ln -s /application/mysql-5.6.34/ /application/mysql && \

chown -R mysql.mysql /application/mysql/data && \

cp /application/mysql/support-files/mysql.server  /etc/init.d/mysqld && \
chmod +x /etc/init.d/mysqld && \

sed -i 's#/usr/local/mysql#/application/mysql#g' \
/application/mysql/bin/mysqld_safe /etc/init.d/mysqld && \

\cp -f /application/mysql/support-files/my-default.cnf /etc/my.cnf && \

/application/mysql/scripts/mysql_install_db \
   --basedir=/application/mysql \
   --datadir=/application/mysql/data --user=mysql && \
/etc/init.d/mysqld start && \
/application/mysql/bin/mysqladmin -u root password 'oldboy123' && \

chkconfig --add mysqld && \
chkconfig mysqld off && chkconfig mysqld --level 35 on && \

exit 0 || exit 1
