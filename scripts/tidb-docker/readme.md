# deploy-tidb-by-docker.sh

参考官方文档：https://pingcap.com/docs-cn/op-guide/docker-deployment/

在单个docker主机上部署一套Tidb的实验环境、

## 执行脚本会发生什么事情？
1、创建一个 192.168.1.0/24 的私有docker网络
2、从 docker 官方拉取 pingcap/tidb:latest 等镜像
3、部署一个 实验环境的 tidb 数据库集群

说明：使用前，最好根据情况修改脚本以满足你的需求。
