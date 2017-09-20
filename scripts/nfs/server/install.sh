#!/bin/bash
#
# Nfs shared store server side installation tools
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-09-20
#

dir=`dirname $0`
if [ ! -d "$dir" ] ; then
   echo "invalid path,please use [sh AbsolutePath] to run script."
   exit 1
fi
cd $dir

yum install -y nfs-utils rpcbind && \
/bin/cp -f ./nfs/exports /etc/exports && \
/bin/cp -f ./sersync/rsync.passwd /etc/rsync.passwd && \
chmod 600 /etc/rsync.passwd && \
tar xf ./sersync/sersync-64bit.tar.gz -C /usr/local/ && \
chmod +x /usr/local/sersync/bin/sersync && \
/bin/cp -f ./sersync/sersync-conf.xml /usr/local/sersync/conf/confxml.xml && \

for a in `cat ./nfs/exports`
do
   if egrep -q "^/" <<<$a
   then
      mkdir -p $a
      chown nfsnobody.nfsnobody $a
   fi
done

/etc/init.d/rpcbind restart
/etc/init.d/nfs restart
/usr/local/sersync/bin/sersync -d -r -o /usr/local/sersync/conf/confxml.xml
