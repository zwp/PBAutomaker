#!/bin/bash

# shellcheck disable=SC2236
if [ ! -n "$1" ];then
  echo "--- ❌ 分支名没有输入，需要重传 ----"
  echo "示例: auto_proto.sh develop release/debug"
  exit
else
  echo "--- 分支名为: $1  ----"
  echo "--- 環境为: $2  ----"
fi

env=0
if [ "$2" = "release" ];then
	env=1
else
  env=0
fi

Branch=$1

#仓库地址
RepoPath=''
#输出工程的oc文件路径
GEN_DIR=../demo/pb

#1. clone proto 仓库,并做清理
rm -rf proto
git clone $RepoPath proto

#2. checkout 需要的分支
cd proto
git checkout -b ${Branch} origin/${Branch}

#返回上一級目錄
cd ..

#3. 移除keywords
echo "移除keywords"
if [ $env -eq 1 ];then
    echo "Release Mode"
    python clean_pb.py Release
else
    echo "Debug Mode"
    python clean_pb.py
fi
echo "移除keywords完成"

cd proto

for file in `ls ./`

do

#_common.proto
if [[ `echo $file | awk -F'.' '$0~/_common.*proto/{print $2}'` = "proto" ]];then
    protoc --objc_out=${GEN_DIR}\
    $file
fi
#.ext.proto
if [[ `echo $file | awk -F'.' '$0~/.*ext.*proto/{print $3}'` = "proto" ]];then
    protoc --objc_out=${GEN_DIR}\
    $file
fi

done

cd ..

echo "开始将pb转化为oc接口..."

python pb_extract.py

echo "转化完成!"
