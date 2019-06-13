#!/bin/bash
  
red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

if [[ -f /usr/bin/yum ]]; then
	cmd="yum"
elif [[ -f /usr/bin/apt-get ]]; then
	cmd="apt-get"
else
	echo -e "$red 本脚本不支持当前操作系统$none" && exit 1
fi

echo -e "$green 更新包管理器列表$none"
eval $cmd update
echo

# 检查安装screen
if [ `command -v screen`  ];then
	echo -e "$green screen 已安装！$none"
else
	echo -e "$green 尝试安装screen$none"
	eval $cmd install screen
	echo
	if [ `command -v screen`  ];then
		echo -e "$green screen 安装完毕！$none"
	else 
		echo -e "$red screen 安装失败！$none"
	fi
fi

echo 
echo -e "$green Done.$none"
