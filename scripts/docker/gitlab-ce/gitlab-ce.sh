#!/bin/bash
#
# gitlab-ce's tools
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-25

gitlab_gitlab_docker_id="ocean-gitlab-server"
gitlab_mysql_docker_id="ocean-gitlab-server-db"
gitlab_gitlab_docker_image="gitlab/gitlab-ce"

#
# gitlab-ce volumes
gitlab_gitlab_docker_params=" -v /etc/gitlab:/etc/gitlab "
gitlab_gitlab_docker_params+=" -v /var/opt/gitlab:/var/opt/gitlab "
gitlab_gitlab_docker_params+=" -v /var/log/gitlab:/var/log/gitlab "

#
# Expose port
gitlab_gitlab_docker_params+=" -p 8080:80 -p 8443:443 -p 1122:22 "

function init()
{
   [ "`docker ps -a --filter name="$gitlab_gitlab_docker_id" -q`" == "" ] && \
   docker run --name $gitlab_gitlab_docker_id \
          $gitlab_gitlab_docker_params -d $gitlab_gitlab_docker_image
}

function start()
{
   init
   docker start $gitlab_gitlab_docker_id >/dev/null && echo -e "\033[32m Done. \033[0m" || echo -e "\033[31m Failed. \033[0m"
}

function stop()
{
   docker stop $gitlab_gitlab_docker_id   
}

function restart()
{
   stop ;
   sleep 3 ;
   start ;
}

function delete()
{
   docker stop $gitlab_gitlab_docker_id
   docker rm -f $gitlab_gitlab_docker_id
}

function info()
{
   echo -e " \033[36m
`
clear
cat <<EOF
Info:
docker-id: $gitlab_gitlab_docker_id
gitlab-data-dir: $gitlab_gitlab_data_dir
docker-container-status: 
EOF
`
\033[0m"
}


case "$1" in
   start | stop | info | restart | delete ) $1 ;;
   * ) echo -e "Usage: $0 start|stop|info|restart" ;;
esac
