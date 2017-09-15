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
# Return user's name by uid
function get_user_name()
{
   awk -F ":" -vid="$1" '($1 ~ /^[^#]/ && $3==id){print $1}' /etc/passwd
}

#
# Return group's name by gid
function get_group_name()
{
   awk -F ":" -vid="$1" '($1 ~ /^[^#]/ && $3==id){print $1}' /etc/group
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
