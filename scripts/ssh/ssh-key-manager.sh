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

if [ $# -eq 0 ]
then
echo -e `
clear
cat <<EOF
\n
Todo: \n
Distrubte ssh key to remote servers. \n
------------------------------------ \n
\n
Usage: \n
------------------------------------ \n
Distrib-SSH_Key \ \n
--keyid="~/.ssh/id_rsa.pub" \ \n
--hosts="172.16.1.{1..100}" \ \n
--mutual-trust=yes \ \n
--ssh-user=admin \ \n
--ssh-port=22222 \ \n
--ssh-passwd=ocean123 \ \n
--from-file=/tmp/disb-web.conf \n\n

Remark for option --from-file \n
Your can use the --from-file option to specify \n
the configuration file of Distrubte-SSH_Key needle. \n\n
Example of the file \n
# This is a comment.\n
#keyid = ~/.ssh/conn_web_id_rsa \n\n
keyid = ~/.ssh/conn_web_id_rsa \n
hosts = 172.16.1.{1..100} \n
mutual-trust = yes\n
ssh-user = admin\n
ssh-port = 12555 \n
ssh-passwd = ocean123 \n \n

\033[33m \n
Warning !! \n
When --form-file and other options together appeared \n
The --XXXX option value will be used by default.\033[0m \n
---------------------------------------------------- \n
EOF
`
return 0
fi   
   #
   # Target hosts
   hosts=""
   
   #
   # The distribute public key or identity file
   keyid="~/.ssh/id_rsa.pub"
   
   #
   # If need trust with ssh's key amoung the machines
   # Set the variable mutual_trust=yes
   mutual_trust="no"         
   
   #
   # The SSH's conn configuration
   ssh_port="22"
   ssh_user="root"
   ssh_passwd=""

   #
   # Distribute the ssh's key successed Host IPs
   declare -a suss_ips
   declare -i cur_suss_ip_index=0
   
   #
   # If used --from-file . Should be read the configure file
   from_file=`sed -nr 's#.*--from-file=([A-Za-z0-9_-/.]+).*#\1#gp' <<<"$*"`
   if [ ! -z "$from_file" ] ; then
      #
      # Return 1 & exit if the --from-file not exists.
      if [ ! -f "$from_file" ] ; then
         echo -e "\033[31m Not found file \033[0m. [ $from_file ]"
         return 1
      fi
      #
      # Read the file & get configure value
      hosts=`sed -nr 's#^hosts = (.*)#\1#gp' $from_file`
      keyid=`sed -nr 's#^keyid = (.*)#\1#gp' $from_file`
      ssh_port=`sed -nr 's#^ssh-port = (.*)#\1#gp' $from_file`
      ssh_user=`sed -nr 's#^ssh-user = (.*)#\1#gp' $from_file`
      ssh_passwd=`sed -nr 's#^ssh-passwd = (.*)#\1#gp' $from_file`
      if [ -z "$ssh_passwd" ]
      then
         ssh_passwd=`sed -nr 's#^ssh-password = (.*)#\1#gp' $from_file`
      fi
      mutual_trust=`sed -nr 's#^mutual_trust = (.*)#\1#gp' $from_file`
   fi

   #
   # Process all options to replaced variable
   # From the specified options with Shell's Command line
   until [ $# -eq 0 ]
   do
      if egrep -q "^--.*=.*" <<<"$1" ; then
         key=`sed -nr 's#^--(.*)=.*#\1#gp' <<<"$1"`
         value=`sed -nr 's#^--.*=(.*)#\1#gp' <<<"$1"`
         case "$key" in
            "pub" | "keyid" | "key" )
               keyid="$value"
            ;;
            "hosts" )
               hosts="$value"
            ;;
            "mutual-trust" )
               mutual_trust="yes"
            ;;
            "ssh-user" )
               ssh_user="$value"
            ;;
            "ssh-port" )
               ssh_port="$value"
            ;;
            "ssh_passwd" )
               ssh_trust="$value"
            ;;
         esac
      fi
      shift
   done

   #
   # Process Shell's enviroment value
   keyid=$(echo "echo $keyid" | /bin/bash)

   # Check keyid file exists
   if [ ! -f "$keyid" ] ; then
      echo -e "\033[31m Not found public key file \033[0m [ $keyid ] "
      echo -e " Ensure or Generate key file by Create-SSH_Key --key-id=~/.ssh/id_rsa if needed."
      return 1
   fi

   #
   # Check hosts is not empty
   if [ -z "$hosts" ] ; then
      echo "Missing hosts."
      return 1
   fi

   #
   # Check ssh's settings.
   if [ -z "$ssh_user" ]
   then
      echo -e "\033[31m Missing SSH's user.\033[0m Your can be specified with --ssh-user"
      return 1
   fi
   if [ -z "$ssh_port" ]
   then
      echo -e "\033[31m Missing SSH's port.\033[0m Your can be specified with --ssh-user"
      return 1
   fi
   if [ -z "$ssh_passwd" ]
   then
      echo -e "\033[31m Missing SSH's password.\033[0m Your can be specified with --ssh-passwd"
      return 1
   fi
   
   #
   # Needle ssh's password plugin. No-interactive
   which sshpass >/dev/null 2>&1
   if [ $? -ne 0 ]
   then
      echo "Missing sshpass. Please install sshpass then try again."
      return 1
   fi

   #
   # Distribute SSH's key to remote hosts
   for ip in `echo "echo $hosts"| /bin/bash`
   do
      echo -e "\033[33m Send ssh's key to $ip \033[0m"
      sshpass -p"$ssh_passwd" ssh-copy-id -i "$keyid" \
      "$ssh_user@$ip -p $ssh_port -oStrictHostKeyChecking=no" \
      > /tmp/ssh_copy_id.msg 2>&1
      if [ $? -eq 0 ] ; then
         echo -e " Test $ip,`ssh $ssh_user@$ip -p $ssh_port "hostname"`.\t[ \033[32m OK \033[0m ]"
         suss_ips[$cur_suss_ip_index]=$ip
         cur_suss_ip_index=$cur_suss_ip_index+1
      else
         echo -e "\033[31m ssh-copy-id failed \033[0m.\n messages: `cat /tmp/ssh_copy_id.msg`\n--------------------------------"
      fi
   done

   #
   # Mutual-trust among machines
   f="/tmp/oceanho-ssh-pub-key-dis_$(date +%s).pubs"
   [ -f $f ] && /bin/rm -f $f
   
   #
   # SSH's identity file name
   _keyid=$keyid
   if egrep "*.pub$" <<<$keyid
   then
      _keyid=`sed -nr 's#(.*).pub#\1#gp' <<<"$keyid"`
   fi

   #
   # remote host's user HOME dir
   remote_home_dir="/root"
   if [ "$ssh_user" != "root" ]
   then
      remote_home_dir="/home/$ssh_user"
   fi


   case "$mutual_trust" in
      "Y" | "y" | "yes" | "Yes" )
         #
         # Scaning remote server SSH's public key
         echo " Scaning all host SSH's Public key"
         for ip in ${suss_ips[@]}
         do
            ssh-keyscan $ip >>$f 2>/dev/null
         done
         echo -e " Scan done. Total hosts: `wc -l $f`"
         
         #
         # Copy the SSH's key & public key to remote hosts
         for ip in ${suss_ips[@]}
         do
            echo -e "\033[33m adding $ip mutual-trust. \033[0m"
            scp -qrp -P $ssh_port $_keyid{,pub} \
               $ssh_user@$ip:"$remote_home_dir/.ssh/" >/dev/null && \
            cat $f | ssh -p $ssh_port $ssh_user@$ip \
            "exec sh -c 'cd; umask 077; test -d .ssh || mkdir .ssh ; \
             cat >> .ssh/known_hosts && (test -x /sbin/restorecon && \
             /sbin/restorecon .ssh .ssh/known_hosts >/dev/null 2>&1 || true)'" >/dev/null
            if [ $? -eq 0 ]
            then
               echo -e " $ip [ \033[32m Trusted OK \033[0m ]"
            else
               echo -e " $ip [ \033[31m Trusted failed \033[0m ]"
            fi
         done
         #
         # Clear
         #/bin/rm -f $f
      ;;
   esac
}



# Register a SSH's private key to /etc/ssh/ssh_config
Register-SSH_Key()
{

echo "Register ssh's identity file to /etc/ssh/ssh_config."
echo -e `
clear
cat <<EOF
\n
Usage: \n
--------------------------------- \n
Distrib-SSH_Key \ \n
--keyid="~/.ssh/id_rsa.pub" \ \n
--hosts="172.16.1.{1..100}" \ \n
--mutual-trust=yes \ \n
--ssh-user=admin \ \n
--ssh-port=22222 \ \n
--ssh-passwd=ocean123 \ \n
---------------------------------------------------- \n
EOF
`

   keyid="~/.ssh/id_rsa.pub"
}

# UnRegister a SSH's private key from /etc/ssh/ssh_config
UnRegister-SSH_Key()
{
   echo "UnRegister ssh's key ."
}

# Check & Install SSH's password Plugin sshpass
Install-Soft_WhenUninstalled()
{
   echo "Install-Soft-WhenUnInstalled ."
}
