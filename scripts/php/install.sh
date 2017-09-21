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
 --php-user=www:33333 \ \n
 --php-group=www:33333 \ \n
 --php-user-create-mode=Recreate \ \n
 --before-script="echo Starting" \ \n
 --post-script="echo done." \n
---------------------------------------------------------------------------
\n
EOF
`

if [ -f "/application/php/sbin/php-fpm" ]
then
   echo "PHP installed. nothing to do."
   exit 0
fi

#
# Select command's & execute .
#  if [ $# -eq 0 ] ; then
#     echo -e $_install_help
#     exit 0
#  fi
#  
#  if [ $# -eq 1 ] ; then
#     case  "$1" in
#        "help" | "h" | "--help" | "-h" | "-help" | "?" | "-?" )
#           echo -e $_install_help;
#           exit 0
#        ;;
#     esac
#  fi
#  
#  dir=`dirname $0`
#  if [ ! -d "$dir" ] ; then
#     echo "invalid path,please use [sh AbsolutePath] to run script."
#     exit 1
#  fi

cd /server/tools && \

yum install \
zlib-devel \
libxml2-devel \
libjpeg-devel \
libjpeg-turbo-devel \
freetype-devel \
libpng-devel \
gd-devel \
libcurl-devel \
libxslt-devel \
libxslt-devel -y && \

tar -xf ./libiconv-1.14.tar.gz && \
cd libiconv-1.14 && ./configure --prefix=/usr/local/libiconv && \
make && make install && \

cd /server/tools/ && \

wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo && \

yum -y install libmcrypt-devel mhash mcrypt && \

tar -xf ./php-5.5.32.tar.gz && \

cd ./php-5.5.32 && \

./configure \
--prefix=/application/php-5.5.32 \
--with-mysql=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir=/usr/local/libiconv \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-fpm \
--enable-mbstring \
--with-mcrypt \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-soap \
--enable-short-tags \
--enable-static \
--with-xsl \
--with-fpm-user=www \
--with-fpm-group=www \
--enable-ftp \
--enable-opcache=no && \

make && make install

if [ $? -ne 0 ]
then
   echo -e "\033[31m Install PHP failed.\033[0m"
   exit 1
fi

/bin/rm -f /application/php &>/dev/null
ln -s /application/php-5.5.32 /application/php

echo -e "\033[32m Done. \033[0m"
exit 0


