#!/bin/bash
#
# Zabbix's Server MySQL Control Tools
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-25

zabbix_mysql_docker_id="ocean-zabbix-server-db"
zabbix_mysql_docker_image="mysql/mysql-server:5.6"


zabbix_mysql_data_dir="/data/mysql/zabbix"

#
# MySQL data dir volume
zabbix_mysql_docker_params="-v $zabbix_mysql_data_dir:/var/lib/mysql"

#
# MySQL root password
zabbix_mysql_docker_params="$zabbix_mysql_docker_params -e MYSQL_ROOT_PASSWORD=oceanho123456"

#
# Zabbix account and database init scripts
zabbix_db_initial_scripts="create database if not exists zabbix default charset utf8 COLLATE utf8_general_ci;"
zabbix_db_initial_scripts="$zabbix_db_initial_scripts grant all on zabbix.* to zabbix@'%' identified by 'zabbix';"
zabbix_db_initial_scripts="$zabbix_db_initial_scripts flush privileges;"

function init()
{
   [ "`docker ps -a --filter name="$zabbix_mysql_docker_id" -q`" == "" ] && \
   docker run --name $zabbix_mysql_docker_id $zabbix_mysql_docker_params -d $zabbix_mysql_docker_image
}

function start()
{
   init
   docker start $zabbix_mysql_docker_id >/dev/null && echo -e "\033[32m Done. \033[0m" || echo -e "\033[31m Failed. \033[0m"
}

function stop()
{
   docker stop $zabbix_mysql_docker_id   
}

function restart()
{
   stop;
   start;
}

function delete()
{
   docker stop $zabbix_mysql_docker_id
   docker rm -f $zabbix_mysql_docker_id
}

function info()
{
   echo -e " \033[36m
`
clear
cat <<EOF
Info:
docker-id: $zabbix_mysql_docker_id
mysql-data-dir: $zabbix_mysql_data_dir
docker-container-status: 
EOF
`
\033[0m"
}


case "$1" in
   start | stop | info | restart | delete ) $1 ;;
   * ) echo -e "Usage: $0 start|stop|info|restart" ;;
esac


