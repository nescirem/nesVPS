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


echo -e "$green 下载脚本reload_zsh.sh$none"
wget -c https://raw.githubusercontent.com/nescirem/nesVPS/master/reload_zsh.sh -O ~/reload_zsh.sh
cd ~
chmod +x reload_zsh.sh

echo -e "$green 当前Shell列表$none"
sudo cat /etc/shells
sleep 1
echo
sleep 1

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
eval $cmd install zsh -y
echo
echo -e "$green 将用户Shell切换到ZSH$none"
sudo usermod -s /bin/zsh $USER
echo


# 安装或升级git
echo -e "$green 安装/升级GIT$none"
eval $cmd install git
echo


# 检测oh-my-zsh以及插件安装状态
if [[ -d ~/.oh-my-zsh  ]]; then
	omz_insd=true
	if [[ -d ~/.oh-my-zsh/custom/plugins/autojump  ]]; then
		aj_insd=true
	fi
	if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions  ]]; then
		za_insd=true
	fi
	if [[ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting  ]]; then
		zshl_insd=true
	fi
fi

# 选择安装oh-my-zsh
if [[ "$omz_insd" = true ]]; then
	read -p "$(echo -e "$cyan 是否重新安装oh-my-zsh(y/N):$none ")" chpo;chpo=${chpo:-n};
	until [[ $chpo =~ ^([y]|[n]|[Y]|[N])$ ]]; do
		read -p "$(echo -e "$cyan 是否重新安装oh-my-zsh(y/N):$none ")" chpo;chpo=${chpo:-n};
	done
	
	if [[ $chpo == y || $chpo == Y ]]; then
		sudo rm -rf ~/.oh-my-zsh
		za_insd=false
		zsh_insd=false
		git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh 
		sudo cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
		ZSH_CUSTOM="~/.oh-my-zsh/custom"
	fi
else
	read -p "$(echo -e "$cyan 是否安装oh-my-zsh(Y/n):$none ")" chpo;chpo=${chpo:-y};
	if [[ $chpo == y || $chpo == Y ]]; then
		git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh 
		sudo cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
		omz_insd=true
		ZSH_CUSTOM="~/.oh-my-zsh/custom"
	fi
fi

if [[ "$omz_insd" = true ]]; then
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
	echo
	if [[ "$aj_insd" = true ]]; then
		read -p "$(echo -e "$cyan 是否重新安装插件autojump(y/N):$none ")" chpo;chpo=${chpo:-n};
		until [[ $chpo =~ ^([y]|[n]|[Y]|[N])$ ]]; do
			read -p "$(echo -e "$cyan 是否重新安装插件autojump(y/N):$none ")" chpo;chpo=${chpo:-n};
		done
		if [[ $chpo == y || $chpo == Y ]]; then
			sudo rm -rf ${ZSH_CUSTOM}/plugins/autojump
			git clone git://github.com/wting/autojump.git ${ZSH_CUSTOM}/plugins/autojump
			cd ${ZSH_CUSTOM}/plugins/autojump
			python ./install.py >/dev/null
			cd ~
			sed -i '/autojump/d' ~/.zshrc
			sed -i '/compinit/d' ~/.zshrc
			#sed -i '/BG_NICE/d' ~/.zshrc
			if [[ $USER == root ]]; then
				echo "[[ -s /root/.autojump/etc/profile.d/autojump.sh ]] && source /root/.autojump/etc/profile.d/autojump.sh">>~/.zshrc
			else
				echo "[[ -s /home/$USER/.autojump/etc/profile.d/autojump.sh ]] && source /home/$USER/.autojump/etc/profile.d/autojump.sh">>~/.zshrc
			fi
			echo 'autoload -U compinit && compinit -u'>>~/.zshrc
			#echo 'unsetopt BG_NICE'>>~/.zshrc
		fi
	else
		git clone git://github.com/wting/autojump.git ${ZSH_CUSTOM}/plugins/autojump
		cd ${ZSH_CUSTOM}/plugins/autojump
		python ./install.py >/dev/null
		cd ~
		sed -i '/autojump/d' ~/.zshrc
		sed -i '/compinit/d' ~/.zshrc
		#sed -i '/BG_NICE/d' ~/.zshrc
		if [[ $USER == root ]]; then
			echo "[[ -s /root/.autojump/etc/profile.d/autojump.sh ]] && source /root/.autojump/etc/profile.d/autojump.sh">>~/.zshrc
		else
			echo "[[ -s /home/$USER/.autojump/etc/profile.d/autojump.sh ]] && source /home/$USER/.autojump/etc/profile.d/autojump.sh">>~/.zshrc
		fi
		echo 'autoload -U compinit && compinit -u'>>~/.zshrc
		#echo 'unsetopt BG_NICE'>>~/.zshrc
	fi
	echo -e "$green 已添加插件 autojump$none"
	echo
	
	if [[ "$za_insd" = true ]]; then
		read -p "$(echo -e "$cyan 是否重新安装插件zsh-autosuggestions(y/N):$none ")" chpo;chpo=${chpo:-n};
		until [[ $chpo =~ ^([y]|[n]|[Y]|[N])$ ]]; do
			read -p "$(echo -e "$cyan 是否重新安装插件zsh-autosuggestions(y/N):$none ")" chpo;chpo=${chpo:-n};
		done
		if [[ $chpo == y || $chpo == Y ]]; then
			sudo rm -rf ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
			git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
		fi
	else
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	fi
	echo -e "$green 已添加插件 zsh-autosuggestions$none"
	echo
	
	if [[ "$zshl_insd" = true ]]; then
		read -p "$(echo -e "$cyan 是否重新安装插件zsh-syntax-highlighting(y/N):$none ")" chpo;chpo=${chpo:-n};
		until [[ $chpo =~ ^([y]|[n]|[Y]|[N])$ ]]; do
			read -p "$(echo -e "$cyan 是否重新安装插件zsh-syntax-highlighting(y/N):$none ")" chpo;chpo=${chpo:-n};
		done
		if [[ $chpo == y || $chpo == Y ]]; then
			sudo rm -rf ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
			git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
		fi
	else
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	fi
	echo -e "$green 已添加插件 zsh-syntax-highlighting$none"
	echo
	
	var="plugins=(git extract autojump history zsh-autosuggestions zsh-syntax-highlighting)"
	eval sed -i "/^plugins=/c'$var'" ~/.zshrc
	
	# 开启新的Z Shell继续执行
	exec ~/reload_zsh.sh
	
fi

echo 
echo -e "$green Done.$none"

