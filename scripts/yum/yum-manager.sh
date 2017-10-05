#!/bin/bash
#
# A tool scripts for yum manager
# Added By OceanHo(gzhehai@foxmail.com) at 2017-10-01
#

function change_yum_to_aliyun()
{
    ver=`uname -r | sed -nr 's#.*el([0-9]).*#\1#gp'`
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-${ver}.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-${ver}.repo
}

