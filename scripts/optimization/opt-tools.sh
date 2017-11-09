#!/bin/bash
#
# [CentOS 6.x] Optimize System tools 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-10
#

#
# Optimize service SSHD
function opt_sshd()
{
   sed -i '/UseDNS=yes/d' /etc/ssh/sshd_config
   sed -i '$aUseDNS=yes' /etc/ssh/sshd_config
}

default_minimal_services="network sshd rsyslog crond sysstat"

#
# Optimize services
function opt_services()
{
   local services="$1"
   [ "$services" == "" ] && services="$default_minimal_services"
   services=`echo "$default_minimal_services" | sed 's# #|#g'`
   for service in `chkconfig --list | awk -F "[ ]+" '{print $1}'`
   do
      chkconfig $service off
   done
   for service in `chkconfig --list | awk -F "[ ]+" '{print $1}' | awk "/$services/{print \$1}"`
   do
      chkconfig $service on --levels 35
   done
}

#
# Expose Control functions
function OptCtl()
{
   local action="$1"; shift
   case "$action" in
      opt-ssh | opt-sshd ) opt_sshd "$@" ;;
      opt-services | opt-service ) opt_services "$@" ;;
   esac
}

#
# main
function main()
{
   if [ $# -ne 0 ]
   then
      OptCtl "$@"
      return 0
   fi
   echo -e "Usage: OptCtl opt-ssh opt-services ."
}

main "$@"
