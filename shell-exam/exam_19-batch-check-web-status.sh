#!/bin/bash
#
# 
# 19.1.19 企业Shell面试题19：批量检查多个网站地址是否正常
# 企业面试题：批量检查多个网站地址是否正常
# 要求：
# 1、使用shell数组方法实现，检测策略尽量模拟用户访问。
# 2、每10秒钟做一次所有的检测，无法访问的输出报警。
# 3、待检测的地址如下
# http://blog.oldboyedu.com
# http://blog.etiantian.org
# http://oldboy.blog.51cto.com
# http://10.0.0.7
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

urls=(
http://blog.oldboyedu.com
http://blog.etiantian.org
http://oldboy.blog.51cto.com
http://10.0.0.7
)
for url in `echo ${urls[@]}`;
do
   http_code=`curl -s -I -o /dev/null -w %{http_code} $url` 
   
   if [ $? -eq 0 ]
   then
      code_flag=$((http_code/100))

      #
      # 2xx / 3xx 站点都正常
      if [ $code_flag -eq 2 -o $code_flag -eq 3 ]
      then
         echo -e "\033[36m $url \033[0m -> \033[32m [ √ ] \033[0m"
         continue
      fi
   fi
   echo -e "\033[33m $url \033[0m -> \033[31m [ × ] \033[0m"
done

