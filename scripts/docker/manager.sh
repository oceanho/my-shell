#!/bin/bash
#

appdir=`dirname "$0"`

source $appdir/vars.sh

function init()
{
    mkdir -p /data/mysql/zabbix/
    mkdir -p /data/zabbix/
}

function start()
{
    /bin/sh $appdir/zabbix-mysql.sh start
    /bin/sh $appdir/zabbix-db-init.sh init
    /bin/sh $appdir/zabbix-server.sh start
    /bin/sh $appdir/zabbix-java-gateway.sh start
    /bin/sh $appdir/zabbix-web-nginx.sh start
}

function restart()
{
    stop;
    start;
}

function status()
{
   echo "status"
   docker ps -a --filter name="zabbix-*"
}

function stop()
{
    /bin/sh $appdir/zabbix-java-gateway.sh stop
    /bin/sh $appdir/zabbix-web-nginx.sh stop
    /bin/sh $appdir/zabbix-server.sh stop
    /bin/sh $appdir/zabbix-mysql.sh stop
}

case "$1" in
   start | restart | stop | status ) $1 ;;
   * ) echo -e "Usage: $0 start|stop|restart|status " ;;
esac
