#!/bin/bash
#
# The web server soft Nginx install/uninstall tools
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-09-12
#


#
# The Application's base dir
APP_BASE_DIR="/application"

#
# This my tools dir( source tar.gz will be download to here)
MY_TOOLS_DIR="/server/tools/"

declare -a _install_help=`
clear
cat<<EOF
\n
Usage:($0 install/uninstall)\n
--------------------------------------------\n
1. If your want uninstall nginx,please run: \n
--------------------------------------------\n
 $0 uninstall \ \n
 --ngx-install-dir=/application/nginx-1.10.3 \ \n
 --ngx-delete-worker-user=yes \ \n
 --ngx-delete-worker-group=yes \ \n
-------------------------------------------\n
\n\n
-------------------------------------------------------------\n
2. If your want install nginx,please run fllowing scripts.\n
-------------------------------------------------------------\n
 $0 install \ \n
 --ngx-deps="pcre-devel openssl-devel" \ \n
 --ngx-worker-user=www \ \n
 --ngx-worker-group=www \ \n
 --ngx-configures="--prefix=/application --user=wwww --with-http_ssl_module" \n
---------------------------------------------------------------------------\n
EOF
`

#
# Install Nginx
install()
{
   
   NGX_VERSION="1.10.3"
   NGX_WORKUSER="www"
   NGX_WORKGROUP="www"
   
   # 
   # Set nginx's dependencies.(yum install to do)
   NGX_DEPS="pcre-devel openssl-devel"

   #
   # Local's var
   nginx_tar="nginx-${NGX_VERSION}.tar.gz"
   nginx_down_url="http://nginx.org/download/$nginx_tar"

   # To store all params
   declare -A _args;

   # Initial the defualt's value
   _args["ngx-deps"]=$NGX_DEPS
   _args["ngx-configures"]=$NGX_CONF_LIST
   _args["ngx-install-dir"]=$NGX_INSTALL_DIR

   # Process all paramters
   until [ $# -eq 0 ]
   do
      if egrep "^--.*=.*" <<< "$1" ; then
         k=$(sed -nr 's#--(.*)=.*#\1#gp' <<<$1)
         v=$(sed -nr 's#--.*=(.*)#\1#gp' <<<$1)
         _args[$k]=$v
      fi
      shift
   done
   
   #
   # Set the variable's new value
   # 
   NGX_DEPS=${_args["ngx-deps-dir"]}
   NGX_CONF_LIST=${_args["ngx-configures"]}
   NGX_INSTALL_DIR=${_args["ngx-install-dir"]}
   
   #
   # Set nginx's installed dir
   NGX_INSTALL_DIR="${APP_BASE_DIR}/nginx-${NGX_VERSION}"

   #
   # The nginx's ./configure Parameters
   #
   NGX_CONF_LIST="--prefix=${NGX_INSTALL_DIR} \
   --user=${NGX_WORKUSER} --group=${NGX_WORKGROUP} \
   --with-http_stub_status_module \
   --with-http_ssl_module
   "
  
   # Install the nginx Dependencies
   if [ ! -z "$NGX_DEPS" ] ; then
      yum install $NGX_DEPS -y
   fi
   if [ $? -ne 0 ] ; then
      echo "It's seem to has problem."
      return
   fi
  
   # Init basic directory.
   mkdir -p ${MY_TOOLS_DIR} && cd ${MY_TOOLS_DIR}

   # Created User & Group of Nginx's Worker runAs user
   [ ! id $NGX_WORKUSER &>/dev/null ] && useradd -s /sbin/nologin -M $NGX_WORKUSER

   # Download nginx tar.gz file
   cd ${MY_TOOLS_DIR}
   if [ ! -f $nginx_tar ] ; then
      echo "Downloading nginx's source code from $nginx_down_url"
      wget -O $nginx_tar -q $nginx_down_url
      if [ $? -ne 0 ] ; then
         echo "Download nginx failed."
         return
      fi
      echo "Download ok."
   fi

   # tar xf nginx.tar.gz & execute ./configure && make && make install
   tar xf $nginx_tar && \
   cd $(sed -nr "s#(.*).tar.gz#\1#gp" <<<$nginx_tar) && \
   ./configure $NGX_CONF_LIST && make && make install
   if [ $? -ne 0 ] ; then
      echo "failed."
      return
   fi

   # Create a symbol-link
   /bin/rm -f "${APP_BASE_DIR}/nginx" &>/dev/null
   ln -s $NGX_INSTALL_DIR ${APP_BASE_DIR}/nginx && \

   # Configure the Nginx to env PATH
   which nginx &>/dev/null || echo "export PATH=${APP_BASE_DIR}/nginx/sbin:\$PATH" >> /etc/profile

   if [ $? -ne 0 ] ; then
      echo "failed."
      return
   fi

   # Make configuration effect.
   source /etc/profile
   echo "-------------------------------------------------------------------------------"
   nginx -V
   echo "-------------------------------------------------------------------------------"
   echo "done."
}

# UnInstall Nginx
uninstall()
{
   echo "UnInstall. not implemention."
}



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

action=$1

if [ "$action" == "install" ] ; then
   install $*
   exit 0
fi


