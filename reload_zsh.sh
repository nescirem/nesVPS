#!/bin/zsh

green='\e[92m'
yellow='\e[93m'
none='\e[0m'

echo
# 重载配置
echo -e "$green 重载ZSH配置$none"
loaded=`source ~/.zshrc`
za=$(echo "$loaded" | grep -ic "zsh-autosuggestions")
zshl=$(echo "$loaded" | grep -ic "zsh-syntax-highlighting")

if [[ "$za" = 1 ]]; then
	echo -e "$yellow 插件zsh-autosuggestions加载失败，$none重新下载"
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi
if [[ "$zshl" = 1 ]]; then
	echo -e "$yellow 插件zsh-syntax-highlighting加载失败，$none重新下载"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

echo
echo -e "$green ZSH配置已重载$none"
echo
