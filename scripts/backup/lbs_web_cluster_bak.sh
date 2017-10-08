#!/bin/bash
#
# LBS for Web cluster backup
#

bakdt=`date -d "-1 days"`
bakid="lbs-web-cluster-`date -d '-1 days' +%Y%m%d_wk%w`.tar.gz"
bakdest="/backup"
mkdir -p $bakdest

my_data_dir=""

#
# www
if [ -d $web_root_dir/www ]
then
   my_data_dir="$my_data_dir $web_root_dir2/www"
fi

#
# No need backup dir .
# This is may be not a web server
if [ -z "$my_data_dir" ]
then
   echo -e "\033[31m Not found [$my_data_dir]. Ensure your run this scripts is at LBS Web clusters server \033[0m"
   exit 1
fi

cd / && \
tar -zcf $bakdest/$bakid $my_data_dir
if [ $? -ne 0 ]
then
   echo "command [tar -zcf $bakdest/$bakid $my_data_dir] failed"
   exit 1
fi

#
# nginx's configures
if [ -d /application/nginx/conf ]
then
   my_data_dir="application/nginx/conf"
   bakip=`echo $bakip | sed -nr 's#web-(.*)#web-ngx-confs-\1#g'`
   cd / && \
   tar -zcf $bakdest/$bakip $my_data_dir
fi

if [ $? -ne 0 ]
then
   echo "command [tar -zcf $bakdest/$bakid $my_data_dir] failed"
   exit 1
fi
exit

