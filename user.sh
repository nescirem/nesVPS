#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

value=$( grep -ic "lain" /etc/passwd )
if [[ $value == 1 ]]; then
  echo -e "$red 用户 lain 已存在$none" && exit 1
fi

if [[ $UID == 0 ]] then

	addgroup admin
	useradd -d /home/lain -s /bin/bash -m lain
	passwd lain
	usermod -a -G admin lain

else

	echo -e "$red $USER为非root权限用户，请以root权限用户执行脚本$none" && exit 1

fi

# 安装zsh
if [[ -f /usr/bin/yum ]]; then
	pkm="yum"
	ipk=${pkm}' install'
elif [[ -f /usr/bin/apt-get ]]; then
	pkm="apt-get"
	ipk=${pkm}' install'
elif [[ -f /usr/bin/pacman ]]; then
	pkm="pacman"
	ipk=${pkm}' -S'
else
	echo -e "$red 本脚本不支持当前操作系统$none" && exit 1
fi

if [ `command -v sudo`  ];then
	# do nothing
else
	eval $ipk sudo
fi
echo -e "$green sudo已安装$none"
echo

var="lain    ALL=(ALL:ALL) ALL"
sed -i '/^root/a\'$var'' /etc/sudoers

echo 
echo -e "$green Done.$none"
