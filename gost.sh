#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="0.07"

font_color_up="\033[32m" && font_color_end="\033[0m" && error_color_up="\033[31m" && error_color_end="\033[0m"
info="${font_color_up}[提示]: ${font_color_end}"
error="${error_color_up}[错误]: ${error_color_end}"
note="\033[33m[警告]: \033[0m"
lnkstls_link="https://js.clapse.com"

if (($EUID != 0)); then
  echo -e "${error}仅在root环境下测试 !" && exit 1
fi

Release=$(cat /etc/os-release | grep "VERSION_ID" | awk -F '=' '{print $2}' | sed "s/\"//g")
if [ "$arch" = "x86_64" ]; then
  echo -e "${error}暂不支持 x86_64 以外系统 !" && exit 1
fi
if [[ -f /etc/redhat-release ]]; then
  Distributor="CentOS"
  Commad="yum"
elif cat /etc/issue | grep -Eqi "debian"; then
  Distributor="Debian"
  Commad="apt"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
  Distributor="Ubuntu"
  Commad="apt"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
  Distributor="CentOS"
  Commad="yum"
elif cat /proc/version | grep -Eqi "debian"; then
  Distributor="Debian"
  Commad="apt"
elif cat /proc/version | grep -Eqi "ubuntu"; then
  Distributor="Ubuntu"
  Commad="apt"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
  Distributor="CentOS"
  Commad="yum"
else
  echo -e "${error}未检测到系统版本！" && exit 1
fi

update_sh() {
  uname="gost.sh"
  echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
  local sh_new_ver=$(wget -qO- "${lnkstls_link}/${uname}" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
  [[ -z ${sh_new_ver} ]] && echo -e "${error}检测最新版本失败 !" && sleep 3s && start_menu
  if [[ ${sh_new_ver} != ${sh_ver} ]]; then
    echo -e "${info}发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
    read -p "(默认: y): " yn
    [[ -z "${yn}" ]] && yn="y"
    if [[ ${yn} == [Yy] ]]; then
      wget "${lnkstls_link}/${uname}" && chmod +x ${uname}
      echo -e "${info}脚本已更新为最新版本[ ${sh_new_ver} ] !" && exit 0
    else
      echo && echo "${info}已取消..." && echo
    fi
  else
    echo -e "${info}当前已是最新版本[ ${sh_new_ver} ] !"
    sleep 5s
    start_menu
  fi
}

ginuerzh_gost() {
  if [[ -n $num ]]; then
    if [ -e /etc/docker/deamon.json ]; then
      echo -e "${note}deamon.json文件存在 !"
    else
      read -p "加速地址(不需要则回车): " num
      if [[ -n $num ]]; then
        echo "{\"registry-mirrors\": [\"${num}\"]}" >/etc/docker/deamon.json
        systemctl daemon-reload
        systemctl restart docker
      fi
    fi
  fi
  docker pull ginuerzh/gost
}

add_docker() {
  if [[ ! $(command -v docker) ]]; then
    echo -e "${error}Docker未安装 !" && exit 1
  fi
  if (($(docker images -a | grep -Ei "ginuerzh/gost" | wc -l) == 0)); then
    echo -e "${info}拉取镜像"
    ginuerzh_gost
    if [[ $? != 0 ]]; then
      echo -e "${error}拉取失败 !" && exit 1
    fi
  fi
  read -p "端口: " name
  read -p "操作(-L and -F): " content
  docker run -d --name="gost${name}" --net=host --log-opt max-size=100m --restart=always ginuerzh/gost:latest ${content} &&
    echo -e "${info}创建成功 !"
}

status_docker() {
  docker ps -a --no-trunc | grep ginuerzh/gost
}

delete_docker() {
  read -p "端口: " port
  docker rm -f $(docker kill gost${port}) 1>/dev/null && echo -e "${info}删除成功 !"
}

start_menu() {
  echo && echo -e "Author: @Lnkstls
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end} 升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end} 创建隧道(Docker)
${font_color_up}2.${font_color_end} 查看隧道(Docker)
${font_color_up}3.${font_color_end} 删除端口(Docker)
——————————————————————————————
Ctrl+C 退出" && echo
  read -p "请输入数字: " num
  case "$num" in
  0)
    update_sh
    ;;
  1)
    add_docker
    ;;
  2)
    status_docker
    ;;
  3)
    delete_docker
    ;;
  esac
}
start_menu
