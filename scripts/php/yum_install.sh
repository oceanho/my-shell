#!/bin/bash
#
# Install the php by yum -y install php-fpm
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-30
#

rpm -q php-fpm php-mysql &>/dev/null && exit 0
yum -y install php-mysql php-fpm
