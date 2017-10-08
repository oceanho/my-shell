#!/bin/bash
#
# Db data backup
#

bakdt=`date -d "-1 days" +%Y%m%d_wk%w`
bakid="dbs-`date -d '-1 days' +%Y%m%d_wk%w`.tar.gz"
bakdest="/backup"

mkdir -p $bakdest

mysqldump_options=" -uroot -poldboy123 --databases "
mysqldump_db_options=""
mysqldump_command="/application/mysql/bin/mysqldump"

if [ ! -f $mysqldump_command ]
then
   echo -e "\033[31m Not found file:[$mysqldump_command].Ensure Your run this script is at Db server. \033[0m"
   exit 1
fi

#
# Backup www's Db: dedecms
$mysqldump_command  $mysqldump_options "dedecms" $mysqldump_db_options > $bakdest/"dedecms-${bakdt}-bak.sql" && \

#
# Backup bbs's Db: discuz
$mysqldump_command  $mysqldump_options "Discuz" $mysqldump_db_options > $bakdest/"discuz-${bakdt}-bak.sql" && \

#
# Backup blog's Db: wordpress
$mysqldump_command  $mysqldump_options "wordpress" $mysqldump_db_options > $bakdest/"wordpress-${bakdt}-bak.sql" && \

#
# Backup MySQL's kernel db: mysql
$mysqldump_command  $mysqldump_options "mysql" $mysqldump_db_options > $bakdest/"mysql-${bakdt}-bak.sql" && \

tar -zcf $bakdest/$bakid $bakdest/{dedecms,discuz,wordpress,mysql}-$bakdt-bak.sql && \

/bin/rm -f $bakdest/*.sql && exit 0 || exit 1
