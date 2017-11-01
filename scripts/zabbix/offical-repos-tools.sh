#!/bin/bash
#
# Zabbix官方的 yum repository 爬虫同步
# Created By OceanHo(gzhehai@foxmail.com) AT 2016-10-31
#

repoUrl="http://repo.zabbix.com/"
repoSaveToDir="/data/yum-repos/zabbix/"

htmlTempFileDir="/tmp/oceanho-zabbix-repos-tmp-htmls/"

help()
{
   echo -e \
"
`
clear
cat <<EOF
用途：
Zabbix官方yum仓库爬虫同步脚本工具

使用方法：
1. 指定从zabbix官方的远程根目录开始爬虫同步到本地的/data/yum-repos/zabbix/
   /bin/sh $0 sync /  /data/yum-repos/zabbix/

2. 指定爬虫同步的远程目录为 zabbix/3.4/ 到本地 /data/yum-repos/zabbix/zabbix/3.4/
   /bin/sh $0 sync zabbix/3.4/  /data/yum-repos/zabbix/zabbix/3.4/
EOF
`
"
}

action()
{
   local color="\033[32m"
   local result="OK"
   "$2" || {
      color="\033[31m"
      result="Failed"
   }
   echo -e "$1 \t\t $color [ $result ] \033[0m"
}

start_sync()
{
   # $1
   #   /
   #   zabbix/
   #   non-supported/
   # $2
   #   /data/yum-repos/zabbix/
   #   /data/yum-repos/zabbix/zabbix/
   #   /data/yum-repos/zabbix/non-supported/
   
   if ! is_dir "$1"
   then
      action "源目录:($1)无效,应以/结尾.比如:zabbix/3.0/" /bin/false
      return 1
   fi
   if ! is_dir "$2"
   then
      action "目标目录:($2)无效,应以/结尾.如:/data/yum-repos/zabbix/3.0/" /bin/false
      return 1
   fi

   local urlPath="$1"
   repoSaveToDir="$2"
   mkdir -p $htmlTempFileDir || {
      action "创建目标目录[$2]失败." /bin/false
      return 1
   }

   [ "$urlPath" == "/" ] && urlPath=""
   syncDirFiles "${repoUrl}${urlPath}" ""
}

syncDirFiles()
{
   #
   #
   # $1
   #   http://repos.zabbix.com/
   #   http://repos.zabbix.com/zabbix/
   #   http://repos.zabbix.com/zabbix/3.0/
   # $2
   #   zabbix/
   #   zabbix/3.0/
   #   zabbix-data/3.0/
   #

   local objUrl=""
   local objLocalFile=""

   echo -e "\033[36m正在读取远程目录/文件列表,URL:$1 \033[0m"
   for object in `get_files_from_url "$1"`
   do
      echo -e "$object"
      continue
      [ "$object" == "" ] && exit 127      
      objUrl="$1$object"
      objLocalFile="$2$object"
      if is_dir "$object"
      then
         syncDirFiles "$objUrl" "$objLocalFile"
         continue
      fi
      downloadFileTo "${repoSaveToDir}${objLocalFile}" $objUrl
   done
}

is_dir()
{
   a="$1"
   lastedStr="${a:((${#a}-1))}"
   [ "$lastedStr" == "/" ] || return 1
}

get_files_from_url()
{
   local htmlFileId="$htmlTempFileDir`uuidgen`"
   /usr/bin/curl -s -o "$htmlFileId" "$1" || {
      action "网络异常,获取目录/文件列表失败." /bin/false
      return 128
   }
   echo -e "`sed -nr '/http[s]?:/d;/Parent Directory/d;s#.*<a href=\"(.*)\".*#\1#gp' $htmlFileId`"
   rm -f $htmlFileId
}

downloadFileTo()
{
   #
   # $1
   #   /data/yum-repos/zabbix/zabbix-official-repo.key
   # $2
   #   http://repo.zabbix.com/zabbix-official-repo.key
   #
   destdir="`dirname $1`"
   [ -d $destdir ] || mkdir -p $destdir || {
      action "创建目录($destdir)失败." /bin/false
      exit 127
   }

   printf "URL:$2 \n"
   printf "SaveTo:$1 \t"
   /usr/bin/curl -s -o "$1" "$2" &>/dev/null && {      
      printf "\033[32m [ OK ] \033[0m \n"
   } || {
      printf "\033[31m [ Failed ] \033[0m \n"
   }
}

#
# 只有传递三个参数且第一个参数是 sync 才执行同步操作,其它的显示帮助菜单
if [ "$1" == "sync" -a $# -eq 3 ]
then
   start_sync "$2" "$3"
   exit 0
fi

help
