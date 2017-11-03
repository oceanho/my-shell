#!/bin/bash
##############################################################
# File Name: oldboyedu_fun.sh
# Version: V1.0
# Author: yao zhang
# Organization: www.zyops.com
# Created Time : 2016-09-12 16:58:28
# Description:
##############################################################

# 脚本初始化
function scripts_init(){
  prog=`basename $0 .sh`
  LockFile=/var/lock/subsys/${prog}.lock  # 使用锁文件
  LogFile=/var/log/${prog}.log  # 脚本记录日志
  PidFile=/var/run/${prog}.pid  # 记录进程号，可以管理脚本

  [ -f $LockFile ] && echo "There $LockFile is exist!!" && exit 1 ||touch $LockFile
  [ ! -f $LogFile ] && touch $LogFile
  [ -f $PidFile ] && echo "There $PidFile is exist!!" && exit 2|| echo $$ > $PidFile
}

# 记录日志
function writelog(){
  Date=$(date "+%F_%T")
  ShellName=`basename $0`
  Info=$1
  echo "$Date : ${ShellName} : ${Info}" >> ${LogFile}
}

# 脚本退出扫尾
function closeout(){
  [ -f $LockFile ] && rm -f $LockFile 
  [ -f $PidFile ]&& rm -f $PidFile
}

# 判断输入是整数
function int_judge(){
  fun_a=$1
  expr $fun_a + 1 &>/dev/null
  RETVAL=$?
  return $RETVAL
}

# 判断输入非空
function input_judge(){
  RETVAL=0
  fun_a=$1
  [ ${#fun_a} -eq 0 ]&& RETVAL=1
  return $RETVAL
}

