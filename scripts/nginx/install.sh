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
   #
   # Set nginx's version
   NGX_VERSION="1.10.3"

   #
   # Set nginx's worker process user & group
   # Formater need. user:userid   group:groupid
   NGX_WORKUSER="www:33333"
   NGX_WORKGROUP="www:33333"

   #
   # Definde the Nginx's virtual user creation mode
   # Can be used values: Default Recreate , The default value is Recreate
   #
   #-------------------------
   # About Default & Recreate
   #------------------------------------------------------------------------
   # Default
   #   Use default user as nginx's user if the specify user exists.
   #   Create a new user as nginx's user if the specify user does not exists
   #      
   # Recreate
   #   01. Delete user if the specify user exists.
   #   02. Create a new user as Nginx's virtual user.
   #------------------------------------------------------------------------
   #
   NGX_USER_CREATION_MODE="Recreate"

   #
   # Set nginx's dependencies.(yum install to do)
   NGX_DEPS="pcre-devel openssl-devel"

   #
   # Local's variables
   nginx_tar="nginx-${NGX_VERSION}.tar.gz"
   nginx_down_url="http://nginx.org/download/$nginx_tar"

   # To store all params
   declare -A _args;

   # Initial the defualt's value
   _args["ngx-deps"]=$NGX_DEPS
   _args["ngx-configures"]=$NGX_CONF_LIST
   _args["ngx-install-dir"]=$NGX_INSTALL_DIR
   _args["ngx-worker-user"]=$NGX_WORKUSER
   _args["ngx-worker-group"]=$NGX_WORKGROUP
   _args["ngx-user-creation-mode"]=$NGX_WORKGROUP

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
   NGX_WORKUSER=${_args["ngx-worker-user"]}
   NGX_WORKGROUP=${_args["ngx-worker-group"]}
   NGX_WORKUSER=${_args["ngx-worker-user"]}

   #
   # The nginx's dependencies installed by yum install
   NGX_DEPS=${_args["ngx-deps"]}

   #
   # The nginx's ./configure parameters
   NGX_CONF_LIST=${_args["ngx-configures"]}

   #
   # The nginx's installtion directory
   NGX_INSTALL_DIR=${_args["ngx-install-dir"]}
    
   #
   # Set nginx's installed dir
   NGX_INSTALL_DIR="${APP_BASE_DIR}/nginx-${NGX_VERSION}"

   #
   # The nginx's ./configure parameters
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
      echo "It's seem to has problem. yum install $NGX_DEPS failed."
      return
   fi
  
   # Init basic directory.
   mkdir -p ${MY_TOOLS_DIR} && cd ${MY_TOOLS_DIR}

   # Created User & Group of Nginx's Worker runAs user
   ! id $NGX_WORKUSER &>/dev/null && useradd -s /sbin/nologin -M $NGX_WORKUSER

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

   # Clean up the nginx.tar.gz decompress target dir
   decompress_dir=$(sed -nr "s#(.*).tar.gz#\1#gp" <<<$nginx_tar)
   [ -d $decompress_dir ] && /bin/rm -rf $decompress_dir

   # Decompress the nginx.tar.gz
   tar xf $nginx_tar
   if [ $? -ne 0 ] ; then
      echo "Delete $nginx_tar ,because of has problem.";
      /bin/rm -f $nginx_tar
      return
   fi
   
   # Change into Nginx's Decompressed dir & ./configure && make && make install
   cd $decompress_dir && \
   ./configure $NGX_CONF_LIST && make && make install
   if [ $? -ne 0 ] ; then
      echo "failed."
      return
   fi

   # Create a symbol-link
   /bin/rm -f "${APP_BASE_DIR}/nginx" &>/dev/null
   ln -s $NGX_INSTALL_DIR ${APP_BASE_DIR}/nginx && \

   # Set the Nginx to env PATH
   . /etc/profile && which nginx &>/dev/null || \
   echo -e "\n
# Configure the Nginx PATH by OceanHo-Nginx-tools \n
export PATH=${APP_BASE_DIR}/nginx/sbin:\$PATH" >> /etc/profile

   if [ $? -ne 0 ] ; then
      echo "failed."
      return
   fi

   # Reload the /etc/profile & Let Nginx PATH effect.
   . /etc/profile
   echo "-----------------------------------"
   echo "+     Nginx installation info     +"
   echo "-----------------------------------"
   nginx -V
   echo "-------------------------------------------------------------------------------------------"
   echo "done."
}

# UnInstall Nginx
uninstall()
{
   echo "UnInstall. not implemention."
}


#
# Common functions
# Check user has exists by ID or Name
#------------------------------------
#
# The first param is UID if want checked by id.
# The second param is Name if want checked by name.
# Notice: If only want checked by Name, the first param set as ""
#----------------------------------------------------------------
#
# Return 0 if the user has not exists
# Return 1 if the user has exists.
#
#----------------------------------------------------------------
function user_exists()
{
    id=$1
    name=$2
    if [ ! -z "$id" ] ; then
      p=`awk -F":" -vid=$id '$3==id{print 1}' /etc/passwd`
      if [ "$p" == "1" ] ; then
         return 0 
      fi
    fi
    if [ ! -z "$name" ] ; then   
      p=`awk -F":" -vname=$name '$1==name{print 1}' /etc/passwd`
      if [ "$p" == "1" ] ; then
         return 0 
      fi
    fi
    return 1
}


#
# Common functions
# Check group has exists by ID or Name
#------------------------------------
#
# The first param is UID if want checked by id.
# The second param is Name if want checked by name.
# Notice: If only want checked by Name, the first param set as ""
#----------------------------------------------------------------
#
# Return 0 if the group has not exists
# Return 1 if the group has exists.
#
#----------------------------------------------------------------
function group_exists()
{
    id=$1
    name=$2
    if [ ! -z "$id" ] ; then
      p=`awk -F":" -vid=$id '$3==id{print 1}' /etc/group`
      if [ "$p" == "1" ] ; then
         return 0 
      fi
    fi
    if [ ! -z "$name" ] ; then   
      p=`awk -F":" -vname=$name '$1==name{print 1}' /etc/group`
      if [ "$p" == "1" ] ; then
         return 0 
      fi
    fi
    return 1
}

#
#
#
#

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

action=$1

if [ "$action" == "install" ] ; then
   install $*
   exit 0
fi
