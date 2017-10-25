#!/bin/bash
#
# Zabbix's Java gateway Control Tools
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-25

zabbix_java_gateway_docker_id="ocean-zabbix-java-gateway"
zabbix_server_docker_id="ocean-zabbix-server"
zabbix_java_gateway_docker_image="zabbix/zabbix-java-gateway:ubuntu-3.0.9"


zabbix_java_gateway_data_dir="/data/zabbix/zabbix-java-gateway"

#
# Zabbix Server dir volume
#zabbix_java_gateway_docker_params="-v $zabbix_java_gateway_data_dir:/etc/zabbix"

zabbix_java_gateway_docker_params="-p 10052:10052"

function init()
{
   [ "`docker ps -a --filter name="$zabbix_java_gateway_docker_id" -q`" == "" ] && \
   docker run --name $zabbix_java_gateway_docker_id \
     --link $zabbix_server_docker_id:zabbix-server \
     $zabbix_java_gateway_docker_params -d zabbix/zabbix-java-gateway:ubuntu-3.0.9
}

function start()
{
   init
   docker start $zabbix_java_gateway_docker_id >/dev/null && echo -e "\033[32m Done. \033[0m" || echo -e "\033[31m Failed. \033[0m"
}

function stop()
{
   docker stop $zabbix_java_gateway_docker_id   
}

function restart()
{
   stop;
   start;
}

function delete()
{
   docker stop $zabbix_java_gateway_docker_id
   docker rm -f $zabbix_java_gateway_docker_id
}

function info()
{
   echo -e " \033[36m
`
clear
cat <<EOF
Info:
docker-id: $zabbix_java_gateway_docker_id
zabbix-data-dir: $zabbix_java_gateway_data_dir
docker-container-status: 
EOF
`
\033[0m"
}


case "$1" in
   start | stop | info | restart | delete ) $1 ;;
   * ) echo -e "Usage: $0 start|stop|info|restart" ;;
esac


