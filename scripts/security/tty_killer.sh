#!/bin/bash
#
# 强制断开除,当前登录用户的其它所有终端. 
# Created By OceanHo(gzhehai@foxmail.com) AT 2018-02-01
#
#
# 参考资料
#    1. Shell 字符串操作: https://www.cnblogs.com/gaochsh/p/6901809.html
#    2. Linux断开某个用户的终端连接:http://woshixiguapi.blog.163.com/blog/static/192499692011114658091/
#

process()
{
   _tty="`who am i | awk -F '[ ]+' '{print $2}'`"
   if [ $? -eq 0 -a "$_tty"!="" ] ; then
      for tty in `who | awk -v self=$_tty -F '[ ]+' '$2!=self{print $2}'`
      do
          #skill -9 -t $tty
          #fuser -k /dev/tty/${tty##*/}
          fuser -k /dev/$tty
          echo "kill $tty ok."
      done
   else
      echo "invalid who am i | awk -F '[ ]+' '{print $2}'"
   fi
}

if [ $UID -eq 0 ]; then
   process
else
   echo "The operation only allowed run as root."
fi
