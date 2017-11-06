#!/bin/bash
#
# 企业Shell面试题14：开发脚本入侵检测与报警案例
# 面试及实战考试题：监控web站点目录（/var/html/www）
# 下所有文件是否被恶意篡改（文件内容被改了），如果有就打印改动的文件名（发邮件），定时任务每3分钟执行一次。
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

. /etc/init.d/functions

watchDir="/var/html/www"
md5sumFile="/data/security/var_html_www_files.md5"
md5sumCheckTempFile="/data/security/var_html_www_files-chk-tmp.md5"

[ -d /data/security ] || mkdir -p "/data/security" || {
   echo -e "\033[31m 权限拒绝 \033[0m"
   exit 1
}

ScriptName="`basename $0 .sh`"
LogFileName="/var/log/${ScriptName}.log"
PidFileName="/var/run/${ScriptName}.pid"

#
# 初始化脚本时自动执行函数
function Script_Init()
{
   if [ -f $PidFileName ]
   then
      action "任务已经运行.PidFile: $PidFileName" /bin/false
      exit 1
   fi 
 
   echo "$$" > $PidFileName || {
      action "写入权限拒绝.PidFile:$PidFileName" /bin/false
      return 1
   }

   echo "Init: `date "+%F %T"`" >> $LogFileName || {
      action "写入权限拒绝.LogFile:$LogFileName" /bin/false
      return 1
   }   
}

#
# 脚本执行完成时自动执行的函数
function Script_Post()
{
   echo "Post: `date "+%F %T"`" >> $PidFileName
   rm -f $PidFileName && \
   action "done" /bin/true
}

#
# 正常更新文件,需要生成和更新文件指纹库
function updateMd5Finger()
{
   mv $md5sumFile
   for file in `find $watchDir -type f | sort`
   do
      md5sum $file >>$md5sumFile
   done
}

#
# 执行校验,并且获取发生变更的文件列表
function checkAndGetChangedFiles()
{
   echo "checkAndGetChangedFiles"
}

#
# Ctrl + C 进程信号捕获
trap Script_Post SIGINT

function main()
{
   Script_Init "$@"
   if [ $? -eq 0 ]
   then
      case "$1" in
         update ) updateMd5Finger "$@" ;;
         check ) checkAndGetChangeFiles "$@" ;;
      esac
   fi
   Script_Post "$@"
}

main "$@"

