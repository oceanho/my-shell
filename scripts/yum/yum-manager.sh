#!/bin/bash
#
# A tool scripts for yum manager
# Added By OceanHo(gzhehai@foxmail.com) at 2017-10-01
#

OS_VERSION=`cat /etc/redhat-release | sed -r 's#.*(5|6|7).*#\1#g'`

repoEpelFileUrl_Aliyun=http://mirrors.aliyun.com/repo/epel-${OS_VERSION}.repo
repoBaseFileUrl_Aliyun=http://mirrors.aliyun.com/repo/Centos-${OS_VERSION}.repo


function change_yum_to_aliyun()
{
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-${ver}.repo
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-${ver}.repo
}

function configure_base_epel_repos()
{
   echo "asda"
}

download()
{   
   rpm -qa wget &>/dev/null || yum -y install wget || {
      echo -e "\033[31m Missing the command wget . \033[0m"
      exit 127
   }
   [ $# -ge 2 ] && dest_params="-O $2"
   wget $dest_params $1
}

function set_repos()
{
   repoOrg="$1"
   repoName="$2"
   if [ "$repoName" ]
   then
      echo "ssss"
   fi
}

function add_repos()
{
   echo "add"
}

function del_repos()
{
   echo "del"
}

function list_repos()
{
   echo "list"
}

#
# help Menu
help()
{
   echo -e \
"`
clear
cat <<EOF
\033[36m
Todo:
Yum Repos Manager Tools
---------------------------------------------------
\033[0m
Usage:
yumreposctl <ACTIONS> [OPTIONS]

ACTIONS:
set-repos   Set the yum\'s repostories
get-repos   Get the yum\'s repostories
add-repos   Add the yum\'s repostories
del-repos   Delete the yum\'s repostories
list-repos  List the yum\'s repostories

ACTION USAGE:
\033[36mset-repos <Repostories> [ReposTarget] [ReposFileUrl] \033[0m
 Repostories
  base: /etc/yum.repos.d/CentOS-Base.repo
  epel: /etc/yum.repos.d/epel.repo
  webtaic: /etc/yum.repos.d/webtatic.repo
  zabbix: /etc/yum.repos.d/zabbix-release.repo
  oceanho: /etc/yum.repos.d/oceanho.repo
 It can be other value if not found your wanted.

***************************************************
|      Created By OceanHo(aha@oceanho.com)        |
|                  At 2016-11-01                  |
***************************************************
EOF
`"
}

#
# Yum仓库管理函数,用于 source 加载方式管理 yum 用.
function yumreposctl()
{
   action="$1"
   case "$action" in
      set-repos ) set_repos "$2" "$3" ;;
      get-repos ) get_repos "$2" ;;
      add-repos ) add_repos "$2" "$3" ;;
      del-repos ) del_repos "$2" "$3" ;;
      list-repos ) list_repos "$2" ;;
      * ) help ;;
   esac
}
