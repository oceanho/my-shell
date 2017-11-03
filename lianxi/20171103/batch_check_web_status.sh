#!/bin/bash
#
#  
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-03
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

