#!/bin/bash
#
# The web server soft Nginx install/uninstall tools
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-09-12
#

declare -a _install_help=`
clear
cat<<EOF
\n
Todo:\n
Nginx installation tools\n
------------------------\n\n

Usage:($0 install/help/h/--help/-h/-?/?)\n
----------------------------\n
 If your want install nginx,please run fllowing scripts.\n
-------------------------------------------------------------\n
 $0 install \ \n
 --ngx-ver=1.10.3 \ \n
 --ngx-deps="pcre-devel openssl-devel" \ \n
 --ngx-user=www:33333 \ \n
 --ngx-group=www:33333 \ \n
 --ngx-user-create-mode=Recreate \ \n
 --ngx-confs="--with-http_ssl_module --with-http_stub_status_module" \ \n
 --ngx-tar-get-url="http://nginx.org/download/1.10.3.tar.gz" \ \n
 --ngx-tar-md5-sign="20cb4f0b0c9db746c630d89ff4ea" \ \n
 --ngx-skiped-when-installed="yes" \ \n
 --before-script="echo Starting" \ \n
 --post-script="echo done." \n
---------------------------------------------------------------------------\n
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

cd $dir
if [ ! -f ./common.sh ] ; then
   wget -O ./common.sh \
   https://raw.githubusercontent.com/oceanho/my-shell/master/scripts/nginx/common.sh
fi

#
# Import common functions
. ./common.sh
[ $? -ne 0 ] && echo "Import failed. may be missing ./common.sh" && exit 1

#
# The Application's base dir
APP_BASE_DIR="/application"

#
# This my tools dir( source tar.gz will be download to here)
MY_TOOLS_DIR="/server/tools/"

#
# Set nginx's version
NGX_VERSION="1.10.3"

#
# Set nginx's worker process user & group
# Formater need. user:userid   group:groupid
NGX_USER="www:33333"
NGX_GROUP="www:33333"

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
NGX_USER_CREATE_MODE="Recreate"

#
# Nginx's will be stop installation
# When NGINX has installed.
#
NGX_SKIPED_WHEN_INSTALLED="yes"

#
# Set nginx's dependencies.(yum install to do)
NGX_DEPS="pcre-devel openssl-devel"

#
# The nginx's ./configure parameters
#
NGX_CONF_LIST="--with-http_stub_status_module --with-http_ssl_module"

#
# Local's variables
ngx_tar="nginx-${NGX_VERSION}.tar.gz"

#
# Nginx tar.gz get url & md5 sign
NGX_TAR_GET_URL="http://nginx.org/download/$ngx_tar"
NGX_TAR_MD5_SIGN="204a20cb4f0b0c9db746c630d89ff4ea"

# Store all params
declare -A _args;

# Initial the defualt's value
_args["ngx-ver"]="1.10.3"
_args["ngx-deps"]=$NGX_DEPS
_args["ngx-confs"]=$NGX_CONF_LIST
_args["ngx-base-dir"]=$APP_BASE_DIR
_args["ngx-user"]=$NGX_USER
_args["ngx-group"]=$NGX_GROUP
_args["ngx-user-create-mode"]=$NGX_USER_CREATE_MODE

_args["ngx-tar-get-url"]=$NGX_TAR_GET_URL
_args["ngx-tar-md5-sign"]=$NGX_TAR_MD5_SIGN

_args["ngx-skiped-when-installed"]=$NGX_SKIPED_WHEN_INSTALLED

_args["before-script"]="echo starting."
_args["post-script"]="echo done."

# Process all paramters
until [ $# -eq 0 ]
do
   if egrep "^--.*=.*" <<< "$1" ; then
      k=$(sed -nr 's#--([a-z-]+)=.*#\1#gp' <<<$1)
      v=$(sed -nr 's#--[a-z-]+=(.*)#\1#gp' <<<$1)
      _args[$k]=$v
   fi
   shift
done


#
# Check need stop install if the nginx has installed
#
_s=${_args["ngx-skiped-when-installed"]}
if [ "$_s" == "yes" ]
then
   source /etc/profile
   which nginx >/dev/null 2>&1
   if [ $? -eq 0 ]
   then
      echo "Skiped install. because of the nginx has installed."
      exit 0
   fi
fi


#
# Set the variable's new value
# 
NGX_USER=${_args["ngx-user"]}
NGX_GROUP=${_args["ngx-group"]}
NGX_USER_CREATE_MODE=${_args["ngx-user-create-mode"]}

#
# Recover the nginx's dependencies installed by yum install
NGX_DEPS=${_args["ngx-deps"]}

#
# Recover the nginx's ./configure parameters
NGX_CONF_LIST=${_args["ngx-confs"]}

#
# Recover the nginx's installtion directory
NGX_INSTALL_DIR="${_args['ngx-base-dir']}/$NGX_VERSION"

#
# Recover the nginx's tar.gz download url & finger
NGX_TAR_GET_URL=${_args["ngx-tar-get-url"]}
NGX_TAR_MD5_SIGN=${_args["ngx-tar-md5-sign"]}

#
# Recover the nginx's Base Directory
NGX_BASE_DIR=${_args["ngx-base-dir"]}

#
# Set nginx's installed dir
NGX_INSTALL_DIR="${NGX_BASE_DIR}/nginx-${NGX_VERSION}"


#
# Nginx Install completed execute scripts
post_script=${_args["post-script"]}

#
# Nginx Install before execute scripts
before_script=${_args["before-script"]}

#
#
# The basic check & Process data(Check param is passed) 
#
# 01. Check & Get the Nginx's user(id,name) & group(id,name)
if ! egrep -q "[a-z][0-9a-z_-]+:[1-9][0-9]+" <<<$NGX_USER ; then
   echo "invalid --ngx-user=$NGX_USER"
   exit 1
fi
if ! egrep -q "[a-z][0-9a-z_-]+:[1-9][0-9]+" <<<$NGX_GROUP ; then
   echo "invalid --ngx-group=$NGX_GROUP"
   exit 1
fi

#
# Get nginx user id/name
ngx_user_id=$(sed -nr 's#.*:(.*)#\1#gp' <<<$NGX_USER)
ngx_user_name=$(sed -nr 's#(.*):.*#\1#gp' <<<$NGX_USER)

#
# Get nginx group id/name
ngx_group_id=$(sed -nr 's#.*:(.*)#\1#gp' <<<$NGX_GROUP)
ngx_group_name=$(sed -nr 's#(.*):.*#\1#gp' <<<$NGX_GROUP)

#
# 01. Check ngx-user-creation-mode & soft-delete user if neeedle.
case "$NGX_USER_CREATE_MODE" in
   "Recreate" | "recreate" | "re" | "r" | "R" )

      # Get the nginx's user id maped user name. It's remarks also .
      _ngx_user_id_map_name=`get_user_name "$ngx_user_id"`
      _ngx_group_id_map_name=`get_group_name "$ngx_group_id"`

      # Remarks user(by name)
      sed -ri.$(date +%F_%H%m%S).bak \
      -e "s#(^${ngx_user_name}:.*)#\#\1#g" \
      -e "s#(^${_ngx_user_id_map_name}:.*)#\#\1#g" /etc/passwd

      # Remarks group(by name)
      sed -ri.$(date +%F_%H%m%S).bak \
      -e "s#(^${ngx_group_name}:.*)#\#\1#g" \
      -e "s#(^${_ngx_group_id_map_name}:.*)#\#\1#g" /etc/group
   ;;
esac

if [ ! $? -eq 0 ] ; then
   echo "failed.(basic check did not passed.)"
   exit 1
fi
# Basic check End
#------------------------------------------------------------------

#
#
# Begin install Nginx do
#

# Execute before-scripts
if [ ! -z "$before_script" ] ; then
   echo "Run before script."
   echo "$before_script" | /bin/bash
fi
if [ $? -ne 0 ] ; then
   echo "It's seem to has problem. Execute [ bash -c $before_script ] failed."
   exit 1
fi

# Install the nginx Dependencies
if [ ! -z "$NGX_DEPS" ] ; then
   echo "Installing dependencies."
   yum install -y $NGX_DEPS
fi
if [ $? -ne 0 ] ; then
   echo "It's seem to has proble. [ yum install -y $NGX_DEPS ] failed."
   exit 1
fi

# Init basic directory.
mkdir -p ${MY_TOOLS_DIR} && cd ${MY_TOOLS_DIR}

# Created User & Group of Nginx's Worker runAs user
if ! group_exists "" "$ngx_group_name" ; then
   groupadd -g $ngx_group_id "$ngx_group_name"
   if [ $? -ne 0 ] ; then
      echo "Add group failed."
      exit 1
   fi
fi
if ! user_exists "" "$ngx_user_name" ; then
   useradd -s /sbin/nologin -u $ngx_user_id -g $ngx_group_id -M $ngx_user_name
   if [ $? -ne 0 ] ; then
      echo "Add user failed."
      exit 1
   fi
fi

# Download nginx tar.gz file
cd ${MY_TOOLS_DIR}
if [ ! -f $ngx_tar ] ; then
   echo "Downloading nginx's source code from $NGX_TAR_GET_URL"
   wget -O $ngx_tar -q $NGX_TAR_GET_URL
   if [ $? -ne 0 ] ; then
      echo "Download nginx failed."
      exit 1
   fi
   echo "Download ok."
fi

# Clean up the nginx.tar.gz decompress target dir
decompress_dir=$(sed -nr "s#(.*).tar.gz#\1#gp" <<<$ngx_tar)
[ -d $decompress_dir ] && /bin/rm -rf $decompress_dir

# Check the nginx tar.gz finger
echo "$NGX_TAR_MD5_SIGN  ./$ngx_tar" > oceanho_ngx_tar.md5 && \
md5sum -c ./oceanho_ngx_tar.md5 && \
tar xf $ngx_tar
if [ $? -ne 0 ] ; then
   echo "Delete $ngx_tar ,because of has problem.";
   /bin/rm -f $ngx_tar
   exit 1
fi

#
# Replace --user & --group from NGX_CONF_LIST
if egrep -q "\-\-(user|group|prefix)=\S+" <<<$NGX_CONF_LIST ; then
   NGX_CONF_LIST=$(sed -nr "s#--(user|group|prefix)=\S+##gp" <<<$NGX_CONF_LIST)
fi

#
# Fix nginx's --user & --group & --prefix
NGX_CONF_LIST="$NGX_CONF_LIST --user=$ngx_user_name --group=$ngx_group_name --prefix=$NGX_INSTALL_DIR"

# Change into Nginx's Decompressed dir & ./configure && make && make install
cd $decompress_dir && \
./configure $NGX_CONF_LIST && make && make install
if [ $? -ne 0 ] ; then
   echo "failed."
   exit 1
fi

# Create a symbol-link
/bin/rm -f "${NGX_BASE_DIR}/nginx" &>/dev/null
ln -s $NGX_INSTALL_DIR ${NGX_BASE_DIR}/nginx && \

# Set the Nginx to env PATH
. /etc/profile && which nginx &>/dev/null || \
echo -e "\n
# Configure the Nginx PATH by OceanHo-Nginx-tools \n
export PATH=${NGX_BASE_DIR}/nginx/sbin:\$PATH" >> /etc/profile

if [ $? -ne 0 ] ; then
   echo "failed."
   exit 1
fi

# Reload the /etc/profile & Let Nginx PATH effect.
. /etc/profile
echo "-----------------------------------"
echo "+     Nginx installation info     +"
echo "-----------------------------------"
nginx -V
echo "-------------------------------------------------------------------------------------------"
echo "done."

if [ -z "$post_script" ] ; then
   echo "Run post-script"
   echo "$post_script" | /bin/bash
fi

