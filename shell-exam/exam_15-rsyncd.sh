#!/bin/bash
#chkconfig:35 90 88
#
# 19.1.15 企业Shell面试题15：开发Rsync服务启动脚本案例
# 写网络服务独立进程模式下Rsync的系统启动脚本，例如：/etc/init.d/rsyncd {start|stop|restart}。
# 要求：
# 1.要使用系统函数库技巧。
# 2.要用函数，不能一坨SHI的方式。
# 3.可被chkconfig管理。
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

. /etc/init.d/functions

Pidfile="/var/run/rsyncd.pid"

function start()
{
   [ ! -f $Pidfile ] && {
      rsync --daemon && \
      echo "`ps -ef | egrep "[r]sync --daemon"`" >$Pidfile && \
      action "done." /bin/true
   }
}

function stop()
{
   [ -f $Pidfile ] && kill `cat $Pidfile` && rm -f $Pidfile
}

function restart()
{
   stop
   sleep 2
   start
}

function help()
{
  echo -e \
"
`
cat <<EOF
Useage: /bin/sh $0 start|stop|restart
EOF
`
"
}

case "$1" in
   start | stop | restart ) $1;;
   * ) help;;
esac

