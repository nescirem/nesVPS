#!/bin/bash
  
red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

cat << EOF 
=========================================
|    本脚本用于快速安装配置 Z Shell     |
|     nescirem@2019.06.12               |
=========================================
EOF

echo -e "$green 当前Shell列表$none"
sudo cat /etc/shells
echo

# 安装zsh
if [[ -f /usr/bin/yum ]]; then
	cmd="sudo yum"
elif [[ -f /usr/bin/apt-get ]]; then
	cmd="sudo apt-get"
elif [[ -f /usr/bin/brew ]]; then
	cmd="sudo brew"
else
	echo -e "$red 本脚本不支持当前操作系统$none" && exit 1
fi

echo -e "$green 更新包管理器列表$none"
eval $cmd update
echo
echo -e "$green 安装ZSH$none"
eval $cmd install zsh
echo
echo -e "$green 切换到ZSH$none"
sudo usermod -s /bin/zsh $USER
echo


# 安装或升级git
echo -e "$green 安装/升级GIT$none"
eval $cmd install git
echo


# 选择安装oh-my-zsh
read -p "$(echo -e "$cyan 是否安装oh-my-zsh(Y/n):$none ")" chpo;chpo=${chpo:-y};
if [[ $chpo == y || $chpo == Y ]]; then

	git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh 
	sudo cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
	
	read -p "$(echo -e "$cyan 是否恢复配置(y/N):$none ")" chre;chre=${chre:-n};
	if [[ $chre == y || $chre == Y ]]; then
		if [ `command -v wget`  ];then
			wget --no-check-certificate https://nesic.site/ftp/Linux/myzshrc -O ~/.zshrc
		elif [ `command -v curl`  ];then
			curl https://nesic.site/ftp/Linux/myzshrc > ~/.zshrc 
		fi
	fi
	# 添加插件
	echo -e "$green 添加插件: autojump, zsh-autosuggestions, zsh-syntax-highlighting$none"
	eval $cmd install autojump
	echo -e "$green 已添加插件 autojump"
	git clone git://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	echo -e "$green 已添加插件 zsh-autosuggestions$none"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	echo -e "$green 已添加插件 zsh-syntax-highlighting$none"
	plugins=(git extract autojump history zsh-autosuggestions zsh-syntax-highlighting)
	
	# 重载配置
	echo -e "$green 重载ZSH配置$none"
	source ~/.zshrc
	
fi

echo 
echo -e "$green Done.$none"

