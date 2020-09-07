#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="0.01"

font_color_up="\033[32m" && font_color_end="\033[0m" && error_color_up="\033[31m" && error_color_end="\033[0m"
info="${font_color_up}[提示]: ${font_color_end}"
error="${error_color_up}[错误]: ${error_color_end}"
note="\033[33m[警告]: \033[0m"

update_sh() {
  local github="https://raw.githubusercontent.com/Lnkstls/autoJs/master/"
  echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
  local sh_new_ver=$(wget -qO- "${github}/haproxy.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
  [[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && sleep 3s && start_menu
  if [[ ${sh_new_ver} != ${sh_ver} ]]; then
    echo -e "${info}发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
    read -p "(默认: y):" yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ ${yn} == [Yy] ]]; then
      wget -O poseidon.sh "${github}/poseidon.sh" && chmod +x poseidon.sh
      echo -e "${info}脚本已更新为最新版本[ ${sh_new_ver} ]!"
    else
      echo && echo "${info}已取消..." && echo
    fi
  else
    echo -e "${info}当前已是最新版本[ ${sh_new_ver} ]!"
    sleep 5s
    start_menu
  fi
}

if (($EUID != 0)); then
  echo -e "${error}仅在root环境下测试 !" && exit 1
fi

if [ ! $(command -v lsb_release) ]; then
  yum install -y redhat-lsb
fi
arch='uname -m'
Distributor=$(lsb_release -a 2>/dev/null | grep "Distributor" | awk '{print $NF}')
Release=$(lsb_release -a 2>/dev/null | grep "Release" | awk '{print $NF}')
# Codename=$(lsb_release -a 2>/dev/null | grep "Codename" | awk '{print $NF}')
if [ "$arch" = "x86_64" ]; then
  echo -e "${error}暂不支持 x86_64 以外系统 !" && exit 1
fi
if [ "${Distributor}" = "Debian" ] || [ "${Distributor}" = "Ubuntu" ]; then
  commad="apt"
elif [ "${Distributor}" = "CentOS" ]; then
  commad="yum"
else
  echo -e "${info}不支持的系统 !"
  commad="apt"
fi

install() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    if [ "$Release" = "9" ]; then
      curl https://haproxy.debian.net/bernat.debian.org.gpg | apt-key add -
      echo deb http://haproxy.debian.net stretch-backports-2.2 main | tee /etc/apt/sources.list.d/haproxy.list
      apt update
      apt install -y haproxy=2.2.\* && echo -e "${info}安装完成(2.2)"
    elif [ "$Release" = "10" ]; then
      curl https://haproxy.debian.net/bernat.debian.org.gpg | apt-key add -
      echo deb http://haproxy.debian.net buster-backports-2.2 main | tee /etc/apt/sources.list.d/haproxy.list
      apt update
      apt install -y haproxy=2.2.\* && echo -e "${info}安装完成(2.2)"
    fi
  elif [ "$Distributor" = "CentOS" ]; then
    echo -e "${error}暂不提供 !"
  else
    echo -e "${error}不支持的系统 !" && exit 1
  fi
}

uninstall() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    apt purge -y haproxy
  # elif [ "$Distributor" = "CentOS" ]; then
  #     echo -e "${error}暂不提供 !"
  else
    echo -e "${error}不支持的系统 !" && exit 1
  fi
}

reboot() {
  systemctl restart haproxy
}

status() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    systemctl status haproxy
  # elif [ "$Distributor" = "CentOS" ]; then
  #     echo -e "${error}暂不提供 !"
  else
    echo -e "${error}不支持的系统 !" && exit 1
  fi
}

edit_etc() {
  vim /etc/haproxy/haproxy.cfg
}

qk_edit() {

}

start_menu() {
  echo -e "Author: by @Lnkstls
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end} 升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end} 安装Haproxy
${font_color_up}2.${font_color_end} 卸载Haproxy
${font_color_up}3.${font_color_end} 重启Haproxy
${font_color_up}4.${font_color_end} 查看状态
${font_color_up}5.${font_color_end} 编辑配置
${font_color_up}6.${font_color_end} 快速配置
——————————————————————————————
Ctrl+c 退出" && echo
  read -p "请输入数字: " num
  case "$num" in
  0)
    update_sh
    ;;
  1)
    install
    ;;
  2)
    uninstall
    ;;
  2)
    reboot
    ;;
  4)
    status
    ;;
  5)
    edit_etc
    ;;
  6)
    echo -e "${error}暂不支持 !"
    sleep 3s
    start_menu
    ;;
  *)
    echo -e "${error}输入错误 !"
    sleep 3s
    start_menu
    ;;
  esac

}

if [ $(command -v vim) ]; then
  echo -e "${info}安装依赖 vim"
  ${commad} install -y vim
fi
if [ $(command -v curl) ]; then
  echo -e "${info}安装依赖 curl"
  ${commad} install -y curl
fi
