#!/bin/bash
  
red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

# 检查SSH服务
SSHD=`systemctl status sshd | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`
if [ "$SSHD" == "running" ]; then
	echo -e "$green sshd服务 正在运行！$none"
else
	systemctl start sshd
	SSHD=`systemctl status sshd | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`
	if [ "$SSHD" == "running" ]; then
		echo -e "$green sshd服务 启动！$none"
	else
		echo -e "$red sshd服务 启动失败！$none" && exit 1
	fi
fi

# 自定义SSH端口
read -p "$(echo -e "$cyan 是否需要修改SSH端口号(y/N):$none ")" chpo;chpo=${chpo:-n};
until [[ $chpo =~ ^([y]|[n]|[Y]|[N])$ ]]; do
	read -p "$(echo -e "$cyan 是否需要修改SSH端口号(y/N):$none ")" chpo;chpo=${chpo:-n};
done

if [[ $chpo == y || $chpo == Y ]]; then
	read -p "$(echo -e "$cyan 请指定自定义SSH端口号(默认:24509):$none ")" Port;Port=${Port:-24509};
	until  [[ $Port =~ ^([0-9]{1,4}|[1-5][0-9]{4}|6[0-5]{2}[0-3][0-5])$ ]];do
		read -p "$(echo -e "$cyan 请重新键入SSH自定义端口号(默认:24509):$none ")" Port;Port=${Port:-24509};
	done
fi

# 修改SSH端口
if [[ $chpo == y || $chpo == Y ]]; then
	if [ -e "/etc/ssh/sshd_config" ]; then
		sed -i "s/Port .*/Port $Port/" /etc/ssh/sshd_config
	else
		echo -e "$red 未找到/etc/ssh/sshd_config，无法修改SSH端口$none"
		read -p "$(echo -e "$cyan 是否尝试安装SSH服务端？(y/N):$none ")" ins_sshd;ins_sshd=${ins_sshd:-n}
		until [[ $ins_sshd =~ ^([y]|[n]|[Y]|[N])$ ]]; do
			read -p "$(echo -e "$cyan 是否尝试安装SSH服务端？(y/N):$none ")" ins_sshd;ins_sshd=${ins_sshd:-n}
		done
	fi
else
	Port=22
fi

if [[ $ins_sshd == y || $ins_sshd == Y ]]; then
	# 尝试安装SSH服务端
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
	echo -e "$green 安装SSH服务端$none"
	eval $cmd install openssh-server
	echo
	echo -e "$green 启动SSHD服务 $none"
	service sshd start
	echo
	
fi

# 登陆安全
read -p "$(echo -e "$cyan 是否设置密钥登陆(Y/n):$none ")" chpo;chpo=${chpo:-y};

if [[ $chpo == y || $chpo == Y ]]; then
	read -p "$(echo -e "$cyan 请输入用户邮箱地址:$none ")" mailaddr
	if [ -z "${mailaddr}" ];then
		mailaddr=$USER@$HOSTNAME
	else
		until  [[ $mailaddr =~ ^([a-zA-Z0-9_\-\.\+]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$ ]];do
			read -p "$(echo -e "$cyan 请输入用户邮箱地址:$none ")" mailaddr
			if [ -z "${mailaddr}" ];then
				mailaddr=$USER@$HOSTNAME
				break
			fi
		done
	fi
	# 选择密钥算法
	echo -e "$cyan 选择密钥生成算法 $none"
	echo
	echo -e "$yellow 1. $none RSA"
	echo
	echo -e "$yellow 2. $none Ed25519"
	echo
	read -p "$(echo -e "请选择 [${magenta}1,2$none](默认:2): ")" _opt;_opt=${_opt:-2};
	until  [[ $_opt =~ ^[1-9]\d*$ ]];do
		read -p "$(echo -e "请选择 [${magenta}1,2$none](默认:2): ")" _opt;_opt=${_opt:-2};
	done
	case $_opt in
	1)
		# 创建 RSA key
		echo "为用户$mailaddr创建RSA密钥"
		ssh-keygen -o -t rsa -b 4096 -f ~/.ssh/id_rsa -C "$mailaddr"
		pri_key='id_rsa'
		pub_key='id_rsa.pub'
		;;
		
	2)
		# 创建 Ed25519 key
		echo "为用户$mailaddr创建Ed25519密钥"
		ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "$mailaddr"
		pri_key='id_ed25519'
		pub_key='id_ed25519.pub'
		;;
	*)
		echo -e "error" && exit 1
		;;
	esac

	echo -e "安装公钥"
	cd ~/.ssh
	eval cat $pub_key >> authorized_keys
	echo
	echo -e "公钥访问权限"
	chmod 600 authorized_keys
	chmod 700 ~/.ssh
	echo
	echo -e "使密钥生效"
	eval "$(ssh-agent -s)"
	eval "ssh-add ~/.ssh/$pri_key"
	echo

	service sshd restart
	if [[ $Port == 22 ]]; then
		echo -e "$green SSH已重启，未改变端口号$none"
	else
		echo -e "$green SSH已重启，新的SSH端口为$Port $none"
	fi
	echo
	echo -e "请下载并删除私钥 ~/.ssh/$pri_key"

	cat << EOF 手动操作参考：
service sshd restart
vim /etc/ssh/sshd_config
  PasswordAuthentication no
  RSAAuthentication yes
  PubkeyAuthentication yes
EOF
	
fi

echo 
echo -e "$green Done.$none"

