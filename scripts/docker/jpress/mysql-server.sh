#!/bin/bash
#
# JPress's mysql db docker-container
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-25

jpress_mysql_docker_id="ocean-jpress-server-db"
jpress_mysql_docker_image="mysql/mysql-server:5.6"


jpress_mysql_data_dir="/data/mysql/jpress"

#
# MySQL data dir volume
jpress_mysql_docker_params="-v $jpress_mysql_data_dir:/var/lib/mysql"

#
# MySQL root password
jpress_mysql_docker_params="$jpress_mysql_docker_params -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_ROOT_HOST='%'"
jpress_mysql_docker_params="$jpress_mysql_docker_params -p 3306:3306"

#
# Zabbix account and database init scripts
jpress_db_initial_scripts="create database if not exists jpress default charset utf8 COLLATE utf8_general_ci;"
jpress_db_initial_scripts="$jpress_db_initial_scripts grant all on jpress.* to jpress@'%' identified by 'jpress';"
jpress_db_initial_scripts="$jpress_db_initial_scripts flush privileges;"

function init()
{
   [ "`docker ps -a --filter name="$jpress_mysql_docker_id" -q`" == "" ] && \
   docker run --name $jpress_mysql_docker_id $jpress_mysql_docker_params -d $jpress_mysql_docker_image
}

function start()
{
   init
   docker start $jpress_mysql_docker_id >/dev/null && echo -e "\033[32m Done. \033[0m" || echo -e "\033[31m Failed. \033[0m"
}

function stop()
{
   docker stop $jpress_mysql_docker_id   
}

function restart()
{
   stop;
   start;
}

function delete()
{
   docker stop $jpress_mysql_docker_id
   docker rm -f $jpress_mysql_docker_id
}

function info()
{
   echo -e " \033[36m
`
clear
cat <<EOF
Info:
docker-id: $jpress_mysql_docker_id
mysql-data-dir: $jpress_mysql_data_dir
docker-container-status: 
EOF
`
\033[0m"
}


case "$1" in
   start | stop | info | restart | delete ) $1 ;;
   * ) echo -e "Usage: $0 start|stop|info|restart" ;;
esac


