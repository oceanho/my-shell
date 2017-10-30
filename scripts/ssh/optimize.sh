#!/bin/bash
#
# Optimize sshd service configure 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-30
#


#
# Disable UseDNS
if egrep "^UseDNS" /etc/ssh/sshd_config
then
   sed -i 's#^UseDNS#UseDNS=no#g' /etc/ssh/sshd_config
else
   if egrep "^#UseDNS" /etc/ssh/sshd_config
   then
      sed -i '/^#UseDNS/aUseDNS=no' /etc/ssh/sshd_config
   fi
fi

