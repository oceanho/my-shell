#!/bin/bash
#
# 随机抓取前3名最幸运的儿童去参加项目实践 
# Created By OceanHo(aha@oceanho.com) AT 2017-11-02
#

trap 'echo "请使用菜单退出."' SIGINT

datadir="/tmp/zy-random-select-student"
randomPool="$datadir/random-pool.txt"
selectedUsers="$datadir/input-users.txt"

#
# 准备数据目录与随机数池/输入用户信息存储文件
[ ! -d $datadir ] && mkdir -p $datadir
[ ! -f $selectedUsers ] && >$selectedUsers
[ ! -f $randomPool ] && seq 1 1 99 >$randomPool

#
# 显示可以去参加项目实践的学生
show()
{
   clear
   echo "以下是可以参加项目实践的学生信息"
   echo "--------------------------------"
   if [ -f $selectedUsers ]
   then
      #
      # 第二列,按照数字比较模式进行倒叙排列显示
      sort -n -r -k 2 $selectedUsers | column -t -c 25 | head -3
   fi
   echo "--------------------------------"
   read -p "回车继续..."
}

#
# 抓阄
zhuajiu()
{
   while true
   do
      clear
      read -p "请输入大名(只能是小写英文)：" name
      if ! egrep -q "^[a-z]{2,10}$" <<< "$name"
      then
         echo -ne "\033[31m大名无效.请重新输入.回车键继续... \033[0m"
         read
         continue
      fi
      break
   done

   if egrep -q "^$name [0-9]+$" $selectedUsers
   then
      read -p "嘿,$name,你已经抓过阄了."
      return
   fi
   
   maxIndex=`wc -l $randomPool| awk '{print $1}'`   
   numIndex=`expr $((RANDOM%maxIndex + 1))`   
   randPoolNum=`sed -n "${numIndex}p"` $randomPool

   #
   # 从随机数池文件中删除即将被使用的随机数
   sed -i "${numIndex}d" $randomPool

   #
   # 写入用户抽选到到数字映射信息
   echo "$name $randNum" >> $selectedUsers
   show
}

#
# 菜单
menu()
{
echo -e \
"
`
clear
cat <<EOF
1. 显示
2. 抓阄
3. 退出
EOF
`"
}

#
# 菜单
while true
do
   menu
   read -p "请选菜单(1/2/3)：" choice
   case "$choice" in
      1 ) show ;;
      2 ) zhuajiu ;;
      3 ) break ;;
      * )
         echo -ne "\033[31m 无效的输入,回车继续.. \033[0m";read >/dev/null
      ;;
   esac
done
