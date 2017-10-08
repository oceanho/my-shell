#!/bin/bash
# rotate nginx's access log
/usr/sbin/logrotate -f$1 /etc/logrotate.d/nginx_access
