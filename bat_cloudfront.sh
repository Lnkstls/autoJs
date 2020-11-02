#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if (( $#!=0 )) ;then
if [[ -e $1 ]] ;then
while read line ;do
python3 cloudfront.py $line $2
if (( $?=0 )) ;then
echo "${line}完成 !"
else
break
fi
done <$1
else
echo "文件不存在 !" && exit 1
fi
else
echo "参数: 文件 线程数" && exit 1
fi
