#!/bin/bash
#
# Zabbix官方的 yum repository 爬虫同步
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-09-01
#

. /etc/init.d/functions

savedBaseDir="/data/yum-repos/zabbix"

tempFileDir="/tmp/oceanho/zabbix-spider"
tempFileDirHtmls="$tempFileDir/html-files"
tempFileDirUrlList="$tempFileDir/url-lists"

failedUrlList="$tempFileDir/failed-url-$(date +%s).txt"
failedFilesList="$tempFileDir/failed-files-$(date +%s).txt"
latedGetFileObject="$tempFileDir/lated-get-file-$(date +%s).txt"

actionCtl_UseCachedList=1
actionCtl_SkipedExistsFile=1

actionVar_ExitMode="\033[32m 正常 \033[0m"

b="$0"

#
# 显示帮助
function help()
{
   echo -e \
"
`
clear
cat <<EOF
用途：
\033[36m Yum软件包爬虫同步脚本 \033[0m

使用方法：
1. 指定从拥有zabbix软件仓库的远程地址开始爬虫同步到本地的/data/yum-repos/zabbix/
   /bin/sh $b sync http://repo.zabbix.com/  /data/yum-repos/zabbix/
   /bin/sh $b sync https://mirrors.aliyun.com/zabbix/  /data/yum-repos/zabbix/

2. 指定爬虫同步的远程 http://repo.zabbix.com/zabbix/3.4/ 到本地 /data/yum-repos/zabbix/zabbix/3.4/
   /bin/sh $b sync http://repo.zabbix.com/zabbix/3.4/  /data/yum-repos/zabbix/zabbix/3.4/
EOF
`
"
exit 0
}

#
# 执行脚本前的执行函数
function Script_before()
{
   [ -d $tempFileDirHtmls ] || mkdir -p $tempFileDirHtmls
   [ -d $tempFileDirUrlList ] || mkdir -p $tempFileDirUrlList
}

#
# 执行脚本后的执行函数
function Script_post()
{
   printf "\n\n
`
cat <<EOF
退出情况: $actionVar_ExitMode
获取Url失败信息文件 -> $failedUrlList
下载软件失败信息文件 -> $failedFilesList
最新下载内容所在文件 -> $latedGetFileObject
EOF
`"
   echo -e "\n\n"
}

#
# 同步入口函数
function start_sync()
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
   
   #
   # 清理异常文件
   find $2 -type f -size 0 -exec rm -f {} \; &>/dev/null

   #
   # 开始读取文件夹,并同步
   syncDirFiles "$1" ""
}

#
# 重试同步入口函数
function retry_sync()
{
   echo "Unsupport."
}

#
# 通过http协议
# 抓取远程目录的可用目录/文件列表并同步
function syncDirFiles()
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

   local objectId="$tempFileDirUrlList/`uuidgen`"
   
   #
   # 获取指定Url的文件/目录链接地址
   get_files_from_url "$1" "$objectId" || {
      echo "$1" >> $failedUrlList
      return 1
   }

   #
   # 循环读取文件内容
   while read object
   do
      objUrl="$1$object"
      objLocalFile="$2$object"
      
      #
      # Url 解码处理
      objLocalFile=`echo "$objLocalFile" | python -c \
         "import sys, urllib as ul; print ul.unquote(sys.stdin.read());"`

      #
      # 以斜线结尾的对象,是目录,需递归遍历远程目录获取下载文件
      if isEndWithSlash "$object"
      then
         syncDirFiles "$objUrl" "$objLocalFile"
         continue
      fi
      downloadFileTo "${savedBaseDir}${objLocalFile}" "$objUrl"
   done <$objectId

   #
   # 清理文件
   rm -f $objectId
}

#
# 判断字符串是否以 / 结尾
function isEndWithSlash()
{
   a="$1"
   subStart=`expr ${#a}-1`
   lastedStr="${a:$subStart}"
   [ "$lastedStr" == "/" ] || return 1
}

#
# 获取指定url目录/文件列表
function get_files_from_url()
{
   local htmlId="$tempFileDirHtmls/`echo $1 | md5sum | awk '{print $1}'`"
   if [ -f $htmlId -a $actionCtl_UseCachedList -eq 1 ]
   then
      echo -e "\033[33m [ Use Cached ]\033[0m $htmlId"
   else
      printf "\033[36m Get Remote Dir Files,URL:$1\033[0m\n"
      /usr/bin/curl --retry 3 -L -s -o "$htmlId" "$1" || {
         action " 网络异常,获取列表失败." /bin/false
         #
         # 保存拉取列表失败的Url,需要支持重试功能
         echo "$htmlId $1" >>$failedUrlList
         return 128
      }
   fi
   
   #
   # To output result to specified file
   sed -nr '/href=\"\.\.\/\"/d;/http[s]?:/d;/Parent Directory/d;s#.*<a href=\"(.*)\".*#\1#gp' $htmlId >$2
}

#
# 下载指定Url的文件到指定目录
function downloadFileTo()
{
   #
   # $1
   #   /data/yum-repos/zabbix/zabbix-official-repo.key
   # $2
   #   http://repo.zabbix.com/zabbix-official-repo.key
   #
   destdir="`dirname $1`"
   [ -d $destdir ] || mkdir -p $destdir || {
      action " 创建目录($destdir)失败." /bin/false
      exit 127
   }

   if [ -f "$1" -a $actionCtl_SkipedExistsFile -eq 1 ]
   then
      echo -e "\033[33m [ Skipped ] \033[0m $1 "
      return 0
   fi

   printf "\033[34m [ GET FILE ]\033[0m $2 \n"
   printf "         -> $1 \t"

   #
   # 更新最后一个下载的文件,因为,下载的这个文件.可能会被异常终止,导致下载的文件是错误的
   # 需要在开始执行该脚本任务的时候,删除该文件.
   echo "[ `date '+ %T %x'` ] $1 $2" > $latedGetFileObject
   /usr/bin/curl --retry 3 -L -s -o "$1" "$2" &>/dev/null && {      
      # 文件下载成功后
      # 删除最后一个下载的文件记录
      >$latedGetFileObject
      printf "\033[32m [ OK ] \033[0m \n"
   } || {
      printf "\033[31m [ Failed ] \033[0m \n"
      # 保存失败的请求文件列表,再所有拉取操作完成后,可以实现重试功能
      echo "$2 $1" >> $failedFilesList
   }
}

#
# The Menu Selection
main()
{
   Script_before
   case "$1" in
      sync ) start_sync "$2" "$3" ;;
      retry ) retry_sync ;; 
      * ) help ;;
   esac
   Script_post
}

#
# Ctrl + c 强制退出
force_exit()
{
   actionVar_ExitMode="\033[31m 强制终止 \033[0m"
   Script_post
   exit 1
}
#
# Trap the keypress：ctrl + c
trap force_exit SIGINT

main "$@"

