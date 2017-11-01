#!/bin/bash
#
# Zabbix官方的 yum repository 爬虫同步
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-09-01
#

. /etc/init.d/functions

savedBaseDir="/data/yum-repos/zabbix"

tempFileDir="/tmp/oceanho/zabbix-spider"
tempFileDirHtmls="$tempFileDir/html-files"
failedUrlList="$tempFileDir/failed-url-$(date +%s).txt"
failedFilesList="$tempFileDir/failed-files-$(date +%s).txt"

b="$0"

help()
{
   echo -e \
"
`
clear
cat <<EOF
用途：
\033[36m Zabbix软件包爬虫同步脚本工具 \033[0m

使用方法：
1. 指定从拥有zabbix软件仓库的远程地址开始爬虫同步到本地的/data/yum-repos/zabbix/
   /bin/sh $b sync http://repo.zabbix.com/  /data/yum-repos/zabbix/
   /bin/sh $b sync https://mirrors.aliyun.com/zabbix/  /data/yum-repos/zabbix/

2. 指定爬虫同步的远程 http://repo.zabbix.com/zabbix/3.4/ 到本地 /data/yum-repos/zabbix/zabbix/3.4/
   /bin/sh $b sync http://repo.zabbix.com/zabbix/3.4/  /data/yum-repos/zabbix/zabbix/3.4/
EOF
`
"
}

start_sync()
{
   #
   # $1
   #   https://mirrors.aliyun.com/zabbix/
   #   https://mirrors.aliyun.com/zabbix/zabbix/
   #   https://mirrors.aliyun.com/zabbix/zabbix/3.0/
   #   https://mirrors.aliyun.com/zabbix/non-supported/
   #
   # $2
   #   /data/yum-repos/zabbix/
   #   /data/yum-repos/zabbix/zabbix/
   #   /data/yum-repos/zabbix/non-supported/
   #
   
   if ! isEndWithSlash "$1"
   then
      action "源目录:($1)无效,应以/结尾.比如:http://repos.zabbix.com/zabbix/3.0/" /bin/false
      return 1
   fi
   if ! isEndWithSlash "$2"
   then
      action "目标目录:($2)无效,应以/结尾.如:/data/yum-repos/zabbix/3.0/" /bin/false
      return 1
   fi

   mkdir -p $tempFileDirHtmls || {
      action "初始化临时目录[$tempFileDirHtmls]失败." /bin/false
      return 1
   }

   #
   # 数据存储根目录
   savedBaseDir="$2" 
   
   # 清理异常文件
   find $2 -type f -size 0 -exec rm -f {} \; &>/dev/null

   #
   # 开始读取文件夹,并同步
   syncDirFiles "$1" ""
}

syncDirFiles()
{
   #
   #
   # $1
   #   http://repos.zabbix.com/
   #   http://repos.zabbix.com/zabbix/
   #   http://repos.zabbix.com/zabbix/3.0/
   #
   # $2
   #   /
   #   zabbix/
   #   zabbix/3.0/
   #   zabbix-data/3.0/
   #

   local objUrl=""
   local objLocalFile=""

   local objectId="$tempFileDir/objectid-`uuidgen`"
   get_files_from_url "$1" "$objectId" || {
      echo "$1" >> $failedUrlList
      return 1
   }

   #
   # 循环读取文件内容
   while read object;
   do
      objUrl="$1$object"
      objLocalFile="$2$object"
      #
      # 以斜线结尾的对象,是目录,需递归遍历远程目录获取下载文件
      if isEndWithSlash "$object"
      then
         syncDirFiles "$objUrl" "$objLocalFile"
         continue
      fi
      downloadFileTo "${savedBaseDir}${objLocalFile}" "$objUrl" --skip-exists
   done <$objectId
   #
   # 清理文件
   rm -f $objectId
}

isEndWithSlash()
{
   a="$1"
   lastedStr="${a:((${#a}-1))}"
   [ "$lastedStr" == "/" ] || return 1
}

get_files_from_url()
{
   local htmlId="$tempFileDirHtmls/`echo $1 | md5sum | awk '{print $1}'`"
   if [ ! -f $htmlId ]
   then
      printf "\033[36m获取远程目录/文件列表,URL:$1\033[0m\n"
      /usr/bin/curl -L -s -o "$htmlId" "$1" || {
         action "网络异常,获取列表失败." /bin/false
         #
         # 保存拉取列表失败的Url,需要支持重试功能
         echo "$htmlId $1" >>$failedUrlList
         return 128
      }
   else
      echo -e "\033[33m [ Use Cached ]\033[0m $htmlId"
   fi
   
   #
   # To output result to specified file
   sed -nr '/href=\"\.\.\/\"/d;/http[s]?:/d;/Parent Directory/d;s#.*<a href=\"(.*)\".*#\1#gp' $htmlId >$2
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

   if [ -f "$1" -a "$3" == "--skip-exists" ]
   then
      echo -e "\033[33m [ Skipped ] \033[0m $1 "
      return 0
   fi

   printf "\033[34m [ GET FILE ]\033[0m $2 \n"
   printf "         -> $1 \t"
   /usr/bin/curl -L -s -o "$1" "$2" &>/dev/null && {
      printf "\033[32m [ OK ] \033[0m \n"
   } || {
      printf "\033[31m [ Failed ] \033[0m \n"
      # 保存失败的请求文件列表,再所有拉取操作完成后,可以实现重试功能
      echo "$2 $1" >> $failedFilesList
   }
}

#
# 只有传递三个参数且第一个参数是 sync 才执行同步操作,其它的显示帮助菜单
if [ "$1" == "sync" ]
then
   if [ $# -eq 3 ]
   then
      start_sync "$2" "$3"
      exit 0
   fi
fi

help
