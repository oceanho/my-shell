#!/bin/bash
# chkconfig:35 90 99
#
#------------------------------------------------------
#
# Nginx service manager tools
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-09-13
#

. /etc/profile
. /etc/init.d/functions


#
# Get the nginx binary path
get_NGINX_bin()
{
   bin=$(find / -type f -print0 | grep -FzZ "sbin/nginx")
   if [ -z $bin ]; then return 1; fi
   echo "$bin"
}

#
# Start nginx.
start()
{
   ngx=$(which nginx 2>/dev/null)
   ngx_pathed=1
   if [ -z $ngx ] ; then
      ngx=$(get_NGINX_bin)
      ngx_pathed=0
   fi
   if [ -z "$ngx" ] ; then
      echo -e "\033[31m Not found nginx service. \033[0m"
      return 1
   fi
   if [ $ngx_pathed -eq 0 ] ; then
      if [ set_ngx_to_PATH $ngx -ne 0 ] ; then
         echo -e "\033[31m Configure Nginx PATH failed. \033[0m"
         return 1
      fi
   fi
   nginx -t &>/dev/null || {
      echo -e "\033[31m invalid configure options.\033[0m"
      return 1
   }
   c=`ps -ef | egrep "nginx: (master|worker)" | wc -l`
   if [ $c -eq 0 ] ; then
      echo "Starting nginx." && nginx && action "Done." /bin/true
      return 1
   fi
   echo -e "\033[36m Nginx already started. Nothing to do. \033[0m"
}

#
# Set the Nginx's sbin to PATH
set_ngx_to_PATH()
{
   if [ ! -f "$1" ] ; then
      echo -e "\033[31m Error. invalid nginx's binary file path. \033[0m"
      return 1
   fi
   echo "# Configure the Nginx PATH by OceanHo-Nginx-tools" >> /etc/profile && \
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
      echo "\033[36m Nginx not running. Nothing to do. \033[0m"
      return 1
   fi
   ngx=$(which nginx 2>/dev/null)
   ngx_pathed=1
   if [ -z $ngx ] ; then
      ngx=`find / -type f -name "nginx" | egrep -o ".*/sbin/nginx$"`
      ngx_pathed=0
   fi
   if [ -z "$ngx" ] ; then
      echo "Not found nginx service."
      return 1
   fi
   if [ $ngx_pathed -eq 0 ] ; then      
      if [ set_ngx_to_PATH $ngx -ne 0 ] ; then
         return 1
      fi
   fi
   echo "Stoping nginx."
   nginx -s stop && action "Done." /bin/true && return 1
   action "Failed." /bin/false
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
      return 1
   fi
   nginx -s reload && action "Done." /bin/true && return 1
   action "Failed." /bin/false
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
   echo "---------------------------------------------------------------------------------"
}

#
# Show Nginx installed version info
info()
{
   ngx=$(which nginx 2>/dev/null)
   if [ -z $ngx ] ; then
      ngx=`get_NGINX_bin`
   fi
   if [ -z "$ngx" ] ; then
      echo -e "\033[31m Not found nginx service. \033[0m"
      return 1
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
   start|stop|reload|restart|status|info) $1 ;;
   help|h|--help|-h) help;;
esac
