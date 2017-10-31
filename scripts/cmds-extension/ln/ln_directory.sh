#
# 递归给目录所有的子文件创建软硬链接
# Created By OceanHo(gzhehai@foxmail.com) AT 2017-10-31
#

function lndirfiles()
{
   echo -e "\033[31m Not Implemetion. \033[0m"
   return 1

   src=
   dest=
   recursive=0
   case "$1" in
      -r|-R|--recursive)
         shift
         recursive=1
      ;;
   esac
   
   src="$1"
   dest="$2"

   #
   # 如果创建链接的源不是一个目录,就创建单个文件的硬链接
   if [ ! -d "$src" ]
   then
      dest_file="$dest"
      if [ -d "$dest" ]
      then
         dest_file="$dest/`basename $src`"
      fi
      ln -f $src $dest_file
      return 0
   fi

   #
   # 如果创建链接的源是目录,需要遍历这个目录下的文件,并且在目标目录创建对应的硬链接
   baseSrcDir=$src
   subStartIndex=
}
