#!/bin/bash
# chkconfig:35 90 99
#
#------------------------------------------------------
#
# Nginx service manager tools
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-09-13
#

. /etc/profile

#
# Start nginx.
start()
{
   ngx=$(which nginx 2>/dev/null)
   ngx_pathed=1
   if [ -z $ngx ] ; then
      ngx=`find / -type f -name "nginx" | egrep -o ".*/sbin/nginx$"`
      ngx_pathed=0
   fi
   if [ -z "$ngx" ] ; then
      echo "Not found nginx server."
      return
   fi
   if [ $ngx_pathed -eq 0 ] ; then
      if [ set_ngx_to_PATH $ngx -ne 0 ] ; then
         return
      fi
   fi

   c=`ps -ef | egrep "nginx: (master|worker)" | wc -l`
   if [ $c -eq 0 ] ; then
      echo "Starting nginx." && nginx && echo "done."
      return
   fi
   echo "Nginx already started. Nothing to do."
}

#
# Set the Nginx's sbin to PATH
set_ngx_to_PATH()
{
   if [ ! -f "$1" ] ; then
      echo "Error. invalid nginx's binary file."
      return 1
   fi
   echo "Configure the Nginx PATH by OceanHo-Nginx-tools" >> /etc/profile && \
   echo "export PATH=`dirname $1`:\$PATH" >> /etc/profile && \
   source /etc/profile
   return 0
}

#
# Stop nginx.
stop()
{
   c=`ps -ef | egrep "nginx: (master|worker)" | wc -l`
   if [ $c -eq 0 ] ; then
      echo "Nginx not running. Nothing to do."
      return
   fi
   ngx=$(which nginx 2>/dev/null)
   ngx_pathed=1
   if [ -z $ngx ] ; then
      ngx=`find / -type f -name "nginx" | egrep -o ".*/sbin/nginx$"`
      ngx_pathed=0
   fi
   if [ -z "$ngx" ] ; then
      echo "Not found nginx server."
      return
   fi
   if [ $ngx_pathed -eq 0 ] ; then      
      if [ set_ngx_to_PATH $ngx -ne 0 ] ; then
         return
      fi
   fi
   echo "Stoping nginx."
   nginx -s stop && echo "done." && return
   echo "failed."
}

#
# Restart nginx service
# It's will be stop then start
restart()
{
   stop;
   sleep 1;
   start;
}

#
# Reload nginx's configure
reload()
{
   echo "Reload Nginx."
   c=`ps -ef | egrep "nginx: (master|worker)" | wc -l`  
   if [ $c -eq 0 ] ; then
      echo "Nginx not running.Please execute [ $0 start ] to Start the nginx service first."
      return
   fi
   nginx -s reload && echo "done." && return
   echo "failed."
}

#
# Show nginx running status
status()
{
   c=`ps -ef | egrep "nginx: (master|worker)" | wc -l`
   if [ $c -eq 0 ] ; then
      echo "Nginx not running."
      return
   fi

   clear
   echo
   echo "-------------------------------------------"
   echo "+  The nginx is running, processes info   +"
   echo "-------------------------------------------"
   ps -ef | egrep "nginx: (master|worker)"
   echo "------------------------------------------------------------------------------"
}

#
# Show Nginx installed version info
info()
{
   ngx=$(which nginx 2>/dev/null)
   if [ -z $ngx ] ; then
      ngx=`find / -type f -name "nginx" | egrep "*/sbin/nginx$"`
   fi
   if [ -z "$ngx" ] ; then
      echo "Not found nginx server."
      return
   fi
 
   clear
   echo
   echo "-----------------------------------"
   echo "+  The Nginx's Installation info  +"
   echo "-----------------------------------"
   nginx -V
   echo "--------------------------------------------------------------------------------------"
}

#
# Show help messages
help_text="Usage: $0 start/stop/restart/reload/status/info"
help()
{
   echo $help_text
}

#
# Chooice & Execute commands.
case "$1" in
   "start" )
      start
    ;;
    "restart" )
      restart ;;
    "stop" )
      stop
    ;;
    "reload" )
      reload
    ;;
    "status" )
      status
    ;;
    "info" )
      info
    ;;
    * )
      help
    ;;
esac
exit 0
