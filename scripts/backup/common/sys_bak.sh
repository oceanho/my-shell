#!/bin/bash
#
# System's file backup
#

bakdt=`date -d "-1 days"`
bakid="sysbak-`date -d '-1 days' +%Y%m%d_wk%w`.tar.gz"
bakdest="/backup"
mkdir -p $bakdest

my_data_dir=""

if [ -d /server/scripts ]
then
   my_data_dir="$my_data_dir server/scripts/"
fi

#
# Keepalived.conf
if [ -f /etc/keepalived/keepalived.conf ]
then
   my_data_dir="$my_data_dir etc/keepalived/keepalived.conf"
fi

cd / && \
tar -zcf $bakdest/$bakid \
etc/hosts \
etc/services \
etc/sysconfig/iptables \
$my_data_dir && exit 0 || exit 1
