#!/bin/bash
#
# Initial Zabbix's Server MySQL Database
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-25

zabbix_mysql_docker_id="ocean-zabbix-server-db"

#
# Zabbix account and database init scripts
zabbix_db_initial_scripts="create database if not exists zabbix default charset utf8 COLLATE utf8_general_ci;"
zabbix_db_initial_scripts="$zabbix_db_initial_scripts grant all on zabbix.* to zabbix@'%' identified by 'zabbix';"
zabbix_db_initial_scripts="$zabbix_db_initial_scripts flush privileges;"

function init()
{
   docker exec $zabbix_mysql_docker_id bash -c "echo \"$zabbix_db_initial_scripts\" | mysql -uroot -poceanho123456"
}

case "$1" in
   init ) $1 ;;
   * ) echo -e "Usage: $0 init" ;;
esac


