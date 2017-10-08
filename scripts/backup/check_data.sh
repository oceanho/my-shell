#!/bin/bash
#
# Rsync backup server check figger & mail to administrator
#

bakdest="/data/backup/"
admin_mail="gzhehai@foxmail.com"

chk_result_file="/tmp/$(date +%s).result"
#
# find figger file & check md5 sum
for figger in `find $bakdest -type f -name "figger.md5"`
do
   dir=`dirname $figger`
   pushd $dir &>/dev/null
      md5sum -c ./figger.md5 >>$chk_result_file 2>&1
   popd &>/dev/null
done

if [ ! -f "$chk_result_file" ]
then
   echo "Not found figger.md5 file.Ensure your backup is worked." >> $chk_result_file
fi

#
# send mail to administrator
/bin/mail -s "Your Backup Data Check Result" ${admin_mail} <$chk_result_file && \

/bin/rm -f $chk_result_file && exit 0 || exit 1

