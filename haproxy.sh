#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="0.06"

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
      wget -O haproxy.sh "${github}/haproxy.sh" && chmod +x haproxy.sh
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

arch='uname -m'
# Distributor=$(lsb_release -a 2>/dev/null | grep "Distributor" | awk '{print $NF}')
# Release=$(lsb_release -a 2>/dev/null | grep "Release" | awk '{print $NF}')
if [ "$arch" = "x86_64" ]; then
  echo -e "${error}暂不支持 x86_64 以外系统 !" && exit 1
fi
if [[ -f /etc/redhat-release ]]; then
  Distributor="CentOS"
  commad="yum"
elif cat /etc/issue | grep -Eqi "debian"; then
  Distributor="Debian"
  commad="apt"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
  Distributor="Ubuntu"
  commad="apt"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
  Distributor="CentOS"
  commad="yum"
elif cat /proc/version | grep -Eqi "debian"; then
  Distributor="Debian"
  commad="apt"
elif cat /proc/version | grep -Eqi "ubuntu"; then
  release="Ubuntu"
  commad="apt"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
  Distributor="CentOS"
  commad="yum"
else
  echo -e "${error}未检测到系统版本！" && exit 1
fi

Release=$(cat /etc/os-release | grep "VERSION_ID" | awk -F '=' '{print $2}' | sed "s/\"//g")

install() {
  echo -e "
\033[2A
——————————————————————————————
${font_color_up}1.${font_color_end} 仓库安装
${font_color_up}2.${font_color_end} 编译安装
${font_color_up}3.${font_color_end} docker安装
——————————————————————————————
${font_color_up}0.${font_color_end}返回上一步
    "
  read -p "请输入数字: " num
  case "$num" in
  0)
    start_menu
    ;;
  1)
    sev_install
    ;;
  2)
    echo -e "${info}开发中..."
    sleep 3s
    install
    ;;
  3)
    echo -e "${info}开发中..."
    sleep 3s
    install
    ;;
  *)
    echo -e "${error}输入错误 !"
    sleep 3s
    install
    ;;
  esac
}

sev_install() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    if [ "$Release" = "9" ]; then
      curl https://haproxy.debian.net/bernat.debian.org.gpg | apt-key add - &&
        echo deb http://haproxy.debian.net stretch-backports-2.2 main | tee /etc/apt/sources.list.d/haproxy.list &&
        apt update &&
        apt install -y haproxy=2.2.\* &&
        echo -e "${info}安装完成(2.2)"
    elif [ "$Release" = "10" ]; then
      curl https://haproxy.debian.net/bernat.debian.org.gpg | apt-key add - &&
        echo deb http://haproxy.debian.net buster-backports-2.2 main | tee /etc/apt/sources.list.d/haproxy.list &&
        apt update &&
        apt install -y haproxy=2.2.\* && curl && echo -e "${info}安装完成(2.2)"
    fi
  elif [ "$Distributor" = "CentOS" ]; then
    echo -e "${error}暂不提供 !"
  else
    echo -e "${error}不支持的系统 !" && exit 1
  fi
}

uninstall() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    apt purge -y haproxy && ehco -e "${info}卸载完成 !"
  # elif [ "$Distributor" = "CentOS" ]; then
  #     echo -e "${error}暂不提供 !"
  else
    echo -e "${error}不支持的系统 !" && exit 1
  fi
}

reboot() {
  haproxy -f /etc/haproxy/haproxy.cfg
  if [ $? -eq 0 ]; then
    systemctl restart haproxy && echo -e "${info}重启成功 !"
  else
    echo -e "${error}配置错误 !"
  fi
}
reboot() {
  haproxy -f /etc/haproxy/haproxy.cfg
  if [ $? -eq 0 ]; then
    systemctl reload haproxy && echo -e "${info}重载成功 !"
  else
    echo -e "${error}配置错误 !"
  fi
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

# qk_edit() {
#
# }

start_menu() {
  echo && echo -e "Author: by @Lnkstls
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end} 升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end} 安装Haproxy
${font_color_up}2.${font_color_end} 卸载Haproxy
${font_color_up}3.${font_color_end} 重启Haproxy
${font_color_up}4.${font_color_end} 重载Haproxy
${font_color_up}5.${font_color_end} 查看状态
${font_color_up}6.${font_color_end} 编辑配置
${font_color_up}7.${font_color_end} 快速配置
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
  3)
    reboot
    ;;
  4)
    reload
    ;;
  5)
    status
    ;;
  6)
    edit_etc
    ;;
  7)
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

ARGS=$(getopt -a -o :rs -l reboot,reload,status,help -- "$@")
eval set -- "$ARGS"
for opt in $@; do
  case $opt in
  -s | --status | status)
    status
    break
    ;;
  -r | --reload | reload)
    reload
    break
    ;;
  --reboot | reboot)
    reboot
    break
    ;;
  -h | --help)
    echo -e "参数列表:
  -s  --status  状态
  -r  --reload  重载
  -h  --help    帮助
  
  --reboot  重启"
    exit 1
    ;;
  esac
done

# 安装支持依赖
if [ ! $(command -v vim) ]; then
  echo -e "${info}安装依赖 vim"
  ${commad} install -y vim
fi
if [ ! $(command -v curl) ]; then
  echo -e "${info}安装依赖 curl"
  ${commad} install -y curl
fi

start_menu
