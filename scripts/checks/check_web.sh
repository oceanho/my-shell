#!/bin/bash
#
# 精确监测Web程序是否正常 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-31
#

check_url=$1
expect_http_status=200
expect_http_response="ok"

which curl &>/dev/null || yum -y install curl &>/dev/null || {
   echo -e "\033[31m Missing curl . \033[0m"
   exit 1
}

result=`curl -s -w %{http_code} $check_url`
result=`sed -r 's#\n##g'<<<$result`

[ "$result" == "$expect_http_response $expect_http_status" ] && \
echo -e "\033[32m Web status is healthly \033[0m" && exit 1

echo -e "\033[31m Web status is Unhealthly \033[0m"
