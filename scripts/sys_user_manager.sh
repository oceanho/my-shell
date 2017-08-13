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
