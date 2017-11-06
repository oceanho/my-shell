#!/bin/bash
#
# 随机选择考试题目 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

#
# 显示菜单
function menu()
{
   echo ""
}

function get_unique_rand_nums()
{
   maxIndex=$1
   nums=(`seq 1 $((maxIndex))`)
   
   local i=0
   declare -a randomNums
   
   for num in ${nums[@]}
   do
      randomInx=`get_random_num 0 ${#nums[@]}`
      randomNum=${nums[$randomInx]}
      randomNums[((i++))]=${nums[randomNum]}
      unset nums[$randomNum]
   done
   echo "Random Nums: "${randomNums[@]}
}

function get_random_num()
{
   local min=$1
   local max=$2
   echo $((RANDOM%max+min))
}

main()
{
   get_unique_rand_nums "$@"
}

main "$@"
