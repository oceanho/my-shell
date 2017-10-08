#!/bin/bash
#

script_dir="/server/scripts/backup"

myip=`ifconfig eth1 | awk -F".*dr:|[ ]+" 'NR==2{print $2}'`
rsync_dir="/backup/"
rsync_info="backup@172.16.1.41::backup/$myip"
rsync_password="123456"
rsync_options="--bwlimit=200"

#
# System backup
if [ -f $script_dir/sys_bak.sh ]
then
   /bin/sh $script_dir/sys_bak.sh
fi
if [ $? -ne 0 ]
then
   exit 1
fi

#
# Web backup
if [ -f $script_dir/web_bak.sh ]
then
   /bin/sh $script_dir/web_bak.sh
fi
if [ $? -ne 0 ]
then
   exit 1
fi

#
# Db backup
if [ -f $script_dir/db_bak.sh ]
then
   /bin/sh $script_dir/db_bak.sh
fi
if [ $? -ne 0 ]
then
   exit 1
fi

#
# Clean 7 days before data
echo -e "\033[035 Cleaning 7 days before data \033[0m"
find $rsync_dir -mtime +7 -exec /bin/rm -rf {} \;

#
# Generic the md5sum for .tar.gz
cd $rsync_dir && \
echo -e "\033[035 Generic md5 fingger for .tar.gz files \033[0m"
md5sum ./*.tar.gz > figger.md5 && \

echo -e "\033[035 Rsync data  to backup server \033[0m" && \
#
# Rsync data to backup server
/bin/sh $script_dir/rsync_client.sh \
"$rsync_dir" "$rsync_info" "$rsync_password" "$rsync_options" && \
exit 0 || exit 1


