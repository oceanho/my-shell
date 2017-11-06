#!/bin/bash
#
# 19.1.7企业Shell面试题7：MySQL数据库分库分表备份
# 如何实现对MySQL数据库进行分库加分表备份，请用脚本实现。
#
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-06
#


backupdir="/backup/db"
backupid="bak-`date "+%Y%M%d-%h%m%s"`"
backupParam="--master-data=2 --single-transaction"

mysqlLoginParam="-uroot -p123456"
mysqlBinExecutor="/usr/bin/mysql $mysqlLoginParam"
mysqldumpBinExecutor="/usr/bin/mysqldump $mysqlLoginParam $backupParam"

mkdir -p $backupdir

for db in `$mysqlBinExecutor -e "show databases;" | awk 'NR>=2'`
do
   $mysqldumpBinExecutor $db 2>/dev/null | gzip > $backupdir/${db}-${backupid}.sql.gz
   for table in `$mysqlBinExecutor -e "show tables from $db;" | awk 'NR>=2'`
   do
      $mysqldumpBinExecutor $db $table 2>/dev/null | gzip > $backupdir/${db}-${table}-${backupid}.sql.gz
   done
done

