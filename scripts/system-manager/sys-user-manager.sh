#!/bin/bash
#
# A tool scripts for user manager
# Added By OceanHo(gzhehai@foxmail.com) at 2017-08-12
#

# delete users
function del_user
{
    while [ $# != 0 ];
    do
      user=$1
      groupdel $user  >/dev/null 2>&1
      userdel -r $user >/dev/null 2>&1
      /bin/rm -rf /var/mail/$user >/dev/null 2>&1
      /bin/rm -rf /var/spool/mail/$user >/dev/null 2>&1
      /bin/rm -rf /home/$user >/dev/null 2>&1
      if [ ! -d "/home/$user" ]; then
         echo "delete user $user ok."
      fi
      shift
   done
}

# get and show system's all users
function get_users
{
    echo "total users:`cat /etc/passwd | wc -l`"
    awk -F ":" '{print $1}' /etc/passwd # | xargs -n1
}

# private function of get_users
function _get_users
{
    echo "_get_users"
}

# delete users from a file
function del_user_from_file
{
    echo -n "Input want delete username file: "
    read str_file_name
    if [ ! -f $str_file_name ]; then
       echo "No file：$str_file_name."
       return
    fi
    echo "It will be delete fllowing users."
    cat $str_file_name
    echo -n "Are you sure? Y/N "
    read confirm_delete_result
    if [ "$confirm_delete_result" != "Y" ]; then
       echo "Cancel."
       return
    fi
    del_user $(cat $str_file_name |xargs)
}

# Create user if not exists
function create_user_if_not_exists()
{
   _id=$1
   _passwd=$2
   ! id $_id &>/dev/null && useradd $_id >/dev/null || return 1
   echo $_passwd | passwd --stdin $_id >/dev/null
}

#
# 创建用户
function create_user()
{
   pass="$2"
   passLen=20
   [ expr 1 + "$3" &>/dev/null ] && passLen=$3
   [ "$pass" == "" ] && pass=` uuidgen | tr [0-9-] [a-z] | cut -c -$passLen`
   create_user_if_not_exists $1 $pass && echo $pass || return 1
}

#
# 批量创建用户
function create_users()
{
   pattern="$1"
   userListDb="/tmp/userListDb-$(date +%s)"
   if ! egrep -q -i "[0-9a-z]+\{[0-9a-z]+\.\.[0-9a-z]+\}" <<< $pattern
   then
      echo -e "\033[31m Pattern Empty or Invalid. $pattern \033[0m"
      return 1
   fi
   
   mkdir -p `dirname $userListDb`
   
   for user in `echo "echo $pattern" | bash`
   do
      pass=`create_user $user`
      if [ $? -eq 0 ]
      then
         echo $user:$pass >> $userListDb
      fi
   done
   echo -e "\033[32m User Created Done.\033[0m user pass file: $userListDb"
}
