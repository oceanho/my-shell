#!/bin/bash
# chkconfig:35 30 90
#
# 轻量级的Nginx启动,重启管理脚本,支持chkconfig管理自启动 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-31
#

#
# Nginx管理脚本思路：
#    1、动作：启动/重启/平滑重启/停止,为此,我们可定义以下几个函数
#       start:    启动Nginx
#       restart:  重启Nginx
#       reload:   平滑重启Nginx
#       stop:     关闭Nginx
#    2、所有的动作,都是通过Nginx的二进制程序 nginx 完成的.
#       2.1、启动Nginx,直接执行nginx命令就可以了,但nginx二进制文件目录必须配置到PATH环境变量中
#       2.2、关闭/停止Nginx,通过命令 nginx -s stop 就可以关闭nginx了
#       2.3、重启Nginx,可以先关闭nginx,然后再启动nginx就可以了
#       2.2、平滑重启Nginx,执行 nginx -s reload 就可以了
#    3、根据第2条,我们可以知道一点,所有操作,都需要nginx这个命令.所以可以得出以下2点
#       3.1、nginx 如果已经配置到PATH环境变量中,直接通过执行命令 nginx 就可以了
#       3.2、nginx 如果没有配置到PATH环境变量中,不能直接执行 nginx 命令,因为找不到命令
#            所以,这种情况,需要通过 find / -type f | grep -FzZ "sbin/nginx" 查找nginx命令的位置.
#            为了下一次可以直接使用nginx命令,我们最好把nginx命令的目录路径配置到PATH环境变量中
#

#
# 只有root用户可以管理Nginxif [ $UUID -ne 0 ]
if [ $UID -ne 0 ]
then
   echo -e "\033[31m 此功能只允许root用户运行. \033[0m"
   exit 128
fi

#
# 加载环境变量配置,系统的Shell函数库
. /etc/profile
. /etc/init.d/functions

#
# nginx命令路径
ngx_bin=`which nginx 2>/dev/null`
is_in_path=1

#
# Nginx 不在环境变量PATH中,尝试用find查找 nginx 二进制程序所在目录位置
if [ "$ngx_bin" == "" ]
then
   ngx_bin=`find / -type f | grep -FzZ "sbin/nginx"`
   is_in_path=0
fi

#
# 再执行一次判断,如果还是没有找到 nginx 命令,说明Nginx可能没有安装.
# 不能执行任何nginx的动作
if [ "$ngx_bin" == "" ]
then
   action "好像没有Nginx服务,若您已安装Nginx,请先在/etc/profile配置nginx的PATH环境变量,再重试." /bin/false
   exit 127
elif [ $is_in_path -ne 1 ]
then
   sed -i "/$ngx_bin/d" /etc/profile
   sed -i "\$aexport PATH=\$PATH:`dirname $ngx_bin`" /etc/profile
fi

#
# 启动Nginx的函数
start()
{
   $ngx_bin
   [ $? -eq 0 ] || {
      action "启动" /bin/false
      return 1
   }
   action "启动" /bin/true
}


#
# 关闭Nginx的函数
stop()
{
   $ngx_bin -s stop
   [ $? -eq 0 ] || {
      action "关闭" /bin/false
      return 1
   }
   action "关闭" /bin/true
}

#
# 重启的Nginx函数
restart()
{
   stop
   sleep 1
   start
}

#
# 平滑重启Nginx的函数
reload()
{
   $ngx_bin -s reload
   [ $? -eq 0 ] || {
      action "平滑重启" /bin/false
      return 1
   }
   action "平滑重启" /bin/true
}

#
# 脚本使用帮助
help()
{
   echo -e "Usage: $0 start|stop|restart|reload"
   return 1
}

case "$1" in
   start|restart|stop|reload ) $1 ;;
   *) help;
esac
