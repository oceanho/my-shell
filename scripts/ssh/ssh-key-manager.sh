#!/bin/bash
#
# SSH key Manager tools
# Created by OceanHo(gzhehai@foxmail.com) at 2017-09-11
#

_MENU_TEXT="
`cat <<EOF
1.
2.
3.
4.
EOF`"

# Create SSH's Key pair
Create-SSH_Key()
{
   #
   # Usage
   #  Create-SSH_Key -f --key-id=~/.ssh/my_conn_all_id_rsa
   #
 
   force=0
   verbose="0"
   key_id=""
   key_type=rsa
   key_size=2048
   key_password=""
   key_comment="$USER@`hostname`"
   _help_text=`cat <<EOF
Usage: Create-SSH_Key -f -v \ \n
--key-id=~/.ssh/my_conn_all_id_rsa \ \n
--key-type=rsa \ \n
--key-size=2048 \ \n
--key-password=123456 \ \n
--key-comment="my test key pair."
EOF`
   # Check has parameter & request is show help.
   if [ $# -eq 0 ] ; then
      echo -e $_help_text
      return
   fi

   # Show help
   case "$1" in
      "help" | "h" | "--help" | "-h" | "-help" | "?" | "-?" )
         echo -e $_help_text
         return
      ;;
   esac

   until [ $# -eq 0 ]
   do
      if [ $1 == "-f" ] ; then
         shift
         force=1
         continue
      fi
      if [ $1 == "-v" ] ; then
         shift
         verbose=1
         continue
      fi
      k=$(sed -nr 's#--(.*)=.*#\1#gp' <<<$1)
      v=$(sed -nr 's#--.*=(.*)#\1#gp' <<<$1)
      case "$k" in
         "key-id" )
            key_id=$v
         ;;
         "key-type" )
            key_type=$v
         ;;
         "key-size" )
            key_size=$v
         ;;
         "key-password" )
            key_password=$v
         ;;
         "key-comment" )
            key_comment=$v
         ;;
         "force" )
            force=1
         ;;
         * )
            if [ $1 != "-v" ] ; then
               echo "Warning. Unsupoort paramters: $1 "
            fi
         ;;
      esac
      shift
   done
   
   # Check the key-id parameter required.
   if [ -z "$key_id" ] ; then
      echo "Missing parameter,key-id. Your can use --key-id= options to specify."
      return
   fi
   
   key_id=$(echo "echo $key_id" | /bin/bash)
   
   # Move the keys If exists & Generate with force.
   if [ -f $key_id -a $force -eq 1 ] ; then
      bakid=".bak-$(date +%F_%s)"
      /bin/mv ${key_id}{,$bakid}
      /bin/mv ${key_id}.pub{,$bakid}
   fi

   # Check the key pair are exists.
   if [ -f $key_id ] ; then
      echo "Key ID has exists. Your can use -f or remove file $key_id and try again."
      return
   fi

   # Concat ssh-keygen Command Script text.
   cmd="ssh-keygen -t $key_type -b $key_size -f $key_id -N \"$key_password\" -C \"$key_comment\""
 
   # Set -q options to cmd if not need show verbose info.
   if [ $verbose == "0" ] ; then
      cmd=$cmd -q 
   fi

   echo "Excute command:[ $cmd ]."
   if echo $cmd | /bin/bash ; then
      echo "done."
      return
   fi
   echo "failed."
}


# Dispatch-SSH key to service nodes
Distrib-SSH_Key()
{
   pub="~/.ssh/id_rsa.pub"
   #hosts="172.16.1.{1..10}"
   hosts="172.16.1.{1..10}"
   mutual_trust="no"          # Machines mutual trust ?
   until [ $# -eq 0 ]
   do
      if egrep -q "^--.*=.*" <<<"$1" ; then
         key=`sed -nr 's#^--(.*)=.*#\1#gp' <<<"$1"`
         value=`sed -nr 's#^--.*=(.*)#\1#gp' <<<"$1"`
         case "$key" in
            "pub" )
               pub="$value"
            ;;
            "hosts" )
               hosts="$value"
            ;;
            "mutual-trust" )
               mutual_trust="yes"
            ;;
         esac
      fi
      shift
   done
   pub=$(echo "echo $pub" | /bin/bash)
   if [ ! -f "$pub" ] ; then
      echo "Not found. [ $pub ].please ensure Or generate ssh's key with Create-SSH_Key --key-id=~/.ssh/id_rsa"
      return 1
   fi

   if [ -z "$hosts" ] ; then
      echo "invalid hosts."
      return 1
   fi
   
   for ip in `echo "echo $hosts"| /bin/bash`
   do
      echo "ip:" $ip
   done
}

# Register a SSH's private key to /etc/ssh/ssh_config
Register-SSH_Key()
{
   echo "Register SSH's key ."
}

# UnRegister a SSH's private key from /etc/ssh/ssh_config
UnRegister-SSH_Key()
{
   echo "UnRegister SSH's key ."
}

# Check & Install SSH's password Plugin sshpass
Install-Soft_WhenUninstalled()
{
   echo "Install-Soft-WhenUnInstalled ."
}
