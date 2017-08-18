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
