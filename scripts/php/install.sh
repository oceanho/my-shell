#!/bin/bash
#
# PHP installation tools
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-09-19
#
declare -a _install_help=`
clear
cat<<EOF
\n
Todo:\n
PHP installation tools\n
------------------------\n\n

Usage:($0 install/help/h/--help/-h/-?/?)\n
----------------------------\n
 If your want install php,please run fllowing scripts.\n
-------------------------------------------------------------\n
 $0 install \ \n
 --php-ver=1.10.3 \ \n
 --php-deps="pcre-devel openssl-devel" \ \n
 --php-user=www:33333 \ \n
 --php-group=www:33333 \ \n
 --php-user-create-mode=Recreate \ \n
 --php-confs="--with-http_ssl_module --with-http_stub_status_module" \ \n
 --php-tar-get-url="http://nginx.org/download/1.10.3.tar.gz" \ \n
 --php-tar-md5-sign="20cb4f0b0c9db746c630d89ff4ea" \ \n
 --before-script="echo Starting" \ \n
 --post-script="echo done." \n
---------------------------------------------------------------------------
\n
EOF
`

#
# Select command's & execute .
if [ $# -eq 0 ] ; then
   echo -e $_install_help
   exit 0
fi

if [ $# -eq 1 ] ; then
   case  "$1" in
      "help" | "h" | "--help" | "-h" | "-help" | "?" | "-?" )
         echo -e $_install_help;
         exit 0
      ;;
   esac
fi

dir=`dirname $0`
if [ ! -d "$dir" ] ; then
   echo "invalid path,please use [sh AbsolutePath] to run script."
   exit 1
fi

