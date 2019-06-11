#!/bin/bash

# 自定义SSH端口
read -p "是否需要修改SSH端口号（y/n）：" chpo
	until [[ $chpo =~ ^([y]|[n])$ ]]; do
		read -p "请重新键入是否需要修改SSH端口号（y/n）：" chpo;
	done
  
	if [[ $chpo == y ]]; then
	read -p "请指定自定义SSH端口号（可用范围为0-65535 推荐使用大端口号）：" Port;Port=${Port:-22233}
		until  [[ $Port =~ ^([0-9]{1,4}|[1-5][0-9]{4}|6[0-5]{2}[0-3][0-5])$ ]];do
			read -p "请重新键入SSH自定义端口号：" Port;Port=${Port:-22233};
		done
	fi

# 修改SSH端口
	if [[ $chpo == y ]]; then
		echo 更改SSH端口号为$Port
		sed -i "s/Port .*/Port $Port/" /etc/ssh/sshd_config
	fi
  echo 新的SSH端口为$Port
  
# 登陆安全
  read -p "请输入用户邮箱地址：" mailaddr
# 创建Ed25519key
  echo 为用户$mailaddr创建密钥
  ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "$mailaddr"
  echo 安装公钥
  cd ~/.ssh
  cat id_ed25519.pub >> authorized_keys
  chmod 600 authorized_keys
  chmod 700 ~/.ssh
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
  
  cat << EOF
  请下载并删除id_ed25519
  参考操作：
  service sshd restart
  vim /etc/ssh/sshd_config
    PasswordAuthentication no
    RSAAuthentication yes
    PubkeyAuthentication yes
    
  EOF
  
  
