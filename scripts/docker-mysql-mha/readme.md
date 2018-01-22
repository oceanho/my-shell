
# 说明
基于 docker 实现 mysql MHA（实验）

## libs
mysql mha 需要用到的软件包

## mha-manager
mysql mha manager 节点的 docker 镜像构建内容(Dockerfile)

## mha-node
mysql mha node，每个MySQL Server节点都需要安装 docker 镜像构建内容(Dockerfile)

## build images
sh ./build.sh

## run a MHA-node container
docker run -it --rm -e MYSQL_ROOT_PASSWORD=123456 -p 1022:22 -p 13306:3306 oceanho/mysql-mha-node:5.6

## run a MHA-manager container
docker run -it --rm -p 2022:22 oceanho/mysql-mha-manager:ubuntu1604

## what's password for root ?
root login password  is : passW0rd