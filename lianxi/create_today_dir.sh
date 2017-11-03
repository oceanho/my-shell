#!/bin/bash
#
# Created directory 
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-11-02
#

#
# more info
# http://blog.csdn.net/woshizhangliang999/article/details/53996280
SOURCE="$0"
while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

dir=$DIR/`date "+%Y%m%d"`
[ -d $dir ] || mkdir -p $dir
cd $dir
