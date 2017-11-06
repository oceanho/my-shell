#!/bin/bash
#
# 19.1.3 企业Shell面试题3：批量创建特殊要求用户案例
# 批量创建10个系统帐号oldboy01-oldboy10并设置密码（密码为随机数，要求字符和数字等混合）。
# 不用for循环的实现思路：http://user.qzone.qq.com/49000448/blog/1422183723
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

userData="/tmp/user-data.txt"
>$userData

for user in oldboy{01..10}
do
   if ! id $user &>/dev/null
   then
      password=`uuidgen | sed 's#-##g'`
      echo "$user:$password" >> $userData
      useradd $user;
      echo $password | passwd --stdin $user
   fi
done

if [ "$1"=="clean" ]
then
   for i in oldboy{01..10};do sudo userdel -r $i ;done
fi
