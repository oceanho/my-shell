#!/bin/bash
#
# Zabbix's Server Control Tools
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-25

zabbix_zabbix_docker_id="ocean-zabbix-server"
zabbix_mysql_docker_id="ocean-zabbix-server-db"
zabbix_zabbix_docker_image="zabbix/zabbix-web-nginx-mysql:ubuntu-3.0.9"


zabbix_zabbix_data_dir="/data/zabbix/zabbix-server"

#
# Zabbix Server dir volume
zabbix_zabbix_docker_params="-v $zabbix_zabbix_data_dir:/etc/zabbix"

#
# Expose port
zabbix_zabbix_docker_params="-p 10051:10051"


function init()
{
   [ "`docker ps -a --filter name="$zabbix_zabbix_docker_id" -q`" == "" ] && \
   docker run --name $zabbix_zabbix_docker_id \
     -e MYSQL_PASSWORD="zabbix" \
     -e MYSQL_USER="zabbix" \
     --link $zabbix_mysql_docker_id:mysql-server $zabbix_zabbix_docker_params -d zabbix/zabbix-server-mysql:ubuntu-3.0.9
}

function start()
{
   init
   docker start $zabbix_zabbix_docker_id >/dev/null && echo -e "\033[32m Done. \033[0m" || echo -e "\033[31m Failed. \033[0m"
}

function stop()
{
   docker stop $zabbix_zabbix_docker_id   
}

function restart()
{
   stop;
   start;
}

function delete()
{
   docker stop $zabbix_zabbix_docker_id
   docker rm -f $zabbix_zabbix_docker_id
}

function info()
{
   echo -e " \033[36m
`
clear
cat <<EOF
Info:
docker-id: $zabbix_zabbix_docker_id
zabbix-data-dir: $zabbix_zabbix_data_dir
docker-container-status: 
EOF
`
\033[0m"
}


case "$1" in
   start | stop | info | restart | delete ) $1 ;;
   * ) echo -e "Usage: $0 start|stop|info|restart" ;;
esac


