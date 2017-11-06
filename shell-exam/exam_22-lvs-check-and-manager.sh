#!/bin/bash
#
# 19.1.22 企业Shell面试题22：LVS节点健康检查及管理脚本案例
# 请在LVS负载均衡主节点上，模拟keepalived健康检查功能管理LVS节点，
# 当节点挂掉从服务器池中剔除，好了再加到服务器池中来。
#
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#

lvs_server="10.0.0.3:80"

lvs_nodes=(
10.0.0.6
10.0.0.7
)

#
# 执行健康检查
function check()
{
   for node in ${lvs_nodes[@]}
   do
     if ! ping -c 1 -W 1 $node &>/dev/null
     then
      remove_node
      continue
     fi
     add_node
   done
}

#
# 移除不健康的节点
function remove_node()
{
   local ip="$1"
   ipvsadm -ln | grep -q "$1" && {
      ipvsadm -d -t $lvs_server -r "$ip"
   }
}

#
# 添加健康节点到LVS节点中
function add_node()
{
   local ip="$1"
   ipvsadm -ln | grep -q "$1" || {
      ipvsadm -a -t $lvs_server -r "$ip" -g -w 1
   }
}


check
