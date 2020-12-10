#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="0.3"

font_color_up="\033[32m" && font_color_end="\033[0m" && error_color_up="\033[31m" && error_color_end="\033[0m"
info="${font_color_up}[提示]: ${font_color_end}"
error="${error_color_up}[错误]: ${error_color_end}"
note="\033[33m[警告]: \033[0m"
lnkstls_link="https://js.clapse.com"

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
      wget "${lnkstls_link}/${uname}.sh" && chmod +x ${uname}.sh
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

install_docker() {
  echo -e "${info}开始安装docker..."
  curl -fsSL https://get.docker.com | bash
  curl -L -S "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod a+x /usr/local/bin/docker-compose
  rm -f $(which dc) && ln -s /usr/local/bin/docker-compose /usr/bin/dc >/dev/null
  systemctl start docker >/dev/null && echo -e "${info}docker安装完成 !"
}

ginuerzh_gost() {
  if [[ -n $num ]]; then
    if [ -e /etc/docker/deamon.json ]; then
      echo -e "${note}deamon.json文件存在 !"
    else
      read -p "加速地址(不需要则回车): " num
      if [[ -n $num ]]; then
        echo "{\"registry-mirrors\": [\"${num}\"]}" >/etc/docker/deamon.json
        systemctl restart docker
      fi
    fi
  fi
  docker pull ginuerzh/gost
}

add_docker() {
  if [[ ! $(command -v docker) ]]; then
    echo -e "${error}Docker未安装, 即将开始安装, 按Ctr+C取消"
    sleep 3s
    install_docker
  fi
  if (($(docker images -a | grep -Ei "ginuerzh/gost" | wc -l) == 0)); then
    echo -e "${info}拉取镜像"
    ginuerzh_gost
  fi
  read -p "昵称: " name
  read -p "操作(-L and -F): " content
  docker run -d --name="gost${name}" --net=host --log-opt max-size=100m --restart=always ginuerzh/gost:latest ${content} &&
    echo -e "${info}创建成功 !"
}

start_menu() {
  echo && echo -e "Author: by @Lnkstls
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end} 升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end} 创建隧道(Docker)
——————————————————————————————
Ctrl+c 退出" && echo
  read -p "请输入数字: " num
  case "$num" in
  0)
    update_sh
    ;;
  1)
    add_docker
    ;;
  esac
}
start_menu
