
# ˵��
���� docker ʵ�� mysql MHA��ʵ�飩

## libs
mysql mha ��Ҫ�õ��������

## mha-manager
mysql mha manager �ڵ�� docker ���񹹽�����(Dockerfile)

## mha-node
mysql mha node��ÿ��MySQL Server�ڵ㶼��Ҫ��װ docker ���񹹽�����(Dockerfile)

## build images
sh ./build.sh

## run a MHA-node container
docker run -it --rm -e MYSQL_ROOT_PASSWORD=123456 -p 1022:22 -p 13306:3306 oceanho/mysql-mha-node:5.6

## run a MHA-manager container
docker run -it --rm -p 2022:22 oceanho/mysql-mha-manager:ubuntu1604

## what's password for root ?
root login password  is : passW0rd