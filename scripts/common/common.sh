#!/bin/bash
#
# common functions for shell
# author ocean(gzhehai@foxmail.com)
#

# The test extension
function my_test
{
   str=$*
   if [ -z "$str" ]; then
      echo "Test failed(Empty)."
      return
   fi
   if [ $(expr match "$str" '\[.*\]') -ne 0 ]; then
      eval "$str"
   else
      test $str
   fi
   if [ $? -eq 0 ]; then
      echo "Test ok."
   else
      echo "Test failed."
   fi
}

# 


# The parameter parse as a Associate arrary.
function parse_params()
{
   k="_DEFAULT"
   declare -A _args
   until [ $# -eq 0 ]
   do
      p=$1
      if egrep -qo "^--" <<< $p; then
         k=$(sed -nr 's#^--(.*)=.*#\1#gp' <<< $p)
         _args[$k]=$(sed -nr 's#.*=(.*)#\1#gp' <<< $p)
      fi
      shift
   done
   return $_args
}

