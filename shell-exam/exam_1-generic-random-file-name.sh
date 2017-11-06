#!/bin/bash
#
# 19.1.1 企业Shell面试题1：批量生成随机字符文件名案例
# 使用for循环在/oldboy目录下批量创建10个html文件，其中
# 每个文件需要包含10个随机小写字母加固定字符串oldboy，名称示例如下：
# [root@oldgirl C19]# ls /oldboy
# apquvdpqbk_oldboy.html  mpyogpsmwj_oldboy.html  txynzwofgg_oldboy.html
# bmqiwhfpgv_oldboy.html  mtrzobsprf_oldboy.html  vjxmlflawa_oldboy.html
# jhjdcjnjxc_oldboy.html  qeztkkmewn_oldboy.html
# jpvirsnjld_oldboy.html  ruscyxwxai_oldboy.html
#
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

dir="/tmp/oldboy/"
[ -p dir ] || mkdir -p dir || { 
   echo "权限错误"
   exit 1
}

num=10
fileCount=20

rm -f $dir*
for n in `eval echo {1..$fileCount}`
do
   fileName="`openssl rand -hex 5`.html"
   touch $dir$fileName
done

ls -lh $dir
