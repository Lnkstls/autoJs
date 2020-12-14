#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="0.02"

font_color_up="\033[32m" && font_color_end="\033[0m" && error_color_up="\033[31m" && error_color_end="\033[0m"
info="${font_color_up}[提示]: ${font_color_end}"
error="${error_color_up}[错误]: ${error_color_end}"
note="\033[33m[警告]: \033[0m"
fder="./JsSet"

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
  uname="poseidon.sh"
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
  if [ ! $(command -v docker) ]; then
    echo -e "${info}开始安装docker..."
    curl -fsSL https://get.docker.com | bash
    curl -L -S "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod a+x /usr/local/bin/docker-compose
    rm -f $(which dc) && ln -s /usr/local/bin/docker-compose /usr/bin/dc >/dev/null
    systemctl start docker >/dev/null && echo -e "${info}docker安装完成"
  else
    echo -e "${info}Docker已安装 !"
  fi
}

set_tcp_config() {
  local tcp_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/tcp/config.json"
  local docker_tcp_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/tcp/docker-compose.yml"
  read -p "节点id(默认1): " node_id
  node_id=${node_id:-1}
  read -p "webapi(http or https): " webapi
  read -p "token: " token
  read -p "节点限速(默认0): " node_speed
  node_speed=${node_speed:-0}
  read -p "用户ip限制(默认0): " user_ip
  user_ip=${user_ip:-0}
  read -p "用户限速(默认0): " user_speed
  user_speed=${user_speed:-0}

  read -p "容器名称(默认v2ray-tcp): " dc_name
  dc_name=${dc_name:-v2ray-tcp}
  read -p "服务端口(80:80): " dc_port
  dc_port=${dc_port:-80:80}

  if [ -d "$dc_name" ]; then
    echo -e "${error}容器名称重复 !"
    sleep 3s
    set_tcp_config
  fi

  mkdir $dc_name
  cd $dc_name
  if [ -n "$webapi" -a -n "$token" ]; then
    curl -sSL $tcp_config | sed "4s/1/${node_id}/g" | sed "6s|http or https://YOUR V2BOARD DOMAIN|${webapi}|g" | sed "7s/v2board token/${token}/g" | sed "9s/0/${node_speed}/g" | sed "11s/0/${user_ip}/g" | sed "12s/0/${user_speed}/g" >config.json
    curl -sSL $docker_tcp_config | sed "s/v2ray-tcp/${dc_name}/g" | sed "s/服务端口:服务端口/${dc_port}/g" | sed "s/2g/100m/g" >docker-compose.yml && echo -e "${info}配置文件完成"
    docker-compose up -d && echo $dc_name && docker-compose logs -f
  else
    echo -e "${error}输入错误 !"
    sleep 3s
    set_ws_config
  fi
}

set_ws_config() {
  local ws_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/ws/config.json"
  local docker_ws_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/ws/docker-compose.yml"

  read -p "节点id(默认1): " node_id
  node_id=${node_id:-1}
  read -p "webapi(http or https): " webapi
  read -p "token: " token
  read -p "节点限速(默认0): " node_speed
  node_speed=${node_speed:-0}
  read -p "用户ip限制(默认0): " user_ip
  user_ip=${user_ip:-0}
  read -p "用户限速(默认0): " user_speed
  user_speed=${user_speed:-0}

  read -p "容器名称(默认v2ray-ws): " dc_name
  dc_name=${dc_name:-v2ray-ws}
  read -p "连接端口(80:10086): " dc_port
  dc_port=${dc_port:-80:10086}

  if [ -d "$dc_name" ]; then
    echo -e "${error}容器名称重复 !"
    sleep 3s
    set_ws_config
  fi

  mkdir $dc_name
  cd $dc_name

  if [ -n "$webapi" -a -n "$token" ]; then
    curl -sSL $ws_config | sed "4s/1/${node_id}/g" | sed "6s|http or https://YOUR V2BOARD DOMAIN|${webapi}|g" | sed "7s/v2board token/${token}/g" | sed "9s/0/${node_speed}/g" | sed "11s/0/${user_ip}/g" | sed "12s/0/${user_speed}/g" >config.json
    curl -sSL $docker_ws_config | sed "s/v2ray-ws/${dc_name}/g" | sed "s/80:10086/${dc_port}/g" | sed "s/2g/100m/g" >docker-compose.yml && echo -e "${info}配置文件完成"
    docker-compose up -d && echo $dc_name && docker-compose logs -f
  else
    echo -e "${error}输入错误 !"
    sleep 3s
    set_ws_config
  fi
}

add_docker() {
  if [ ! -e "v2" ]; then
    mkdir v2
  fi
  cd v2
  echo -e "
——————————————————————————————
${font_color_up}1.${font_color_end} TCP模式
${font_color_up}2.${font_color_end} WS模式
${font_color_up}3.${font_color_end} TLS模式
——————————————————————————————
${font_color_up}0.${font_color_end} 返回上一步
"
  read -p "请输入数字: " num
  case "$num" in
  0)
    start_menu
    ;;
  1)
    set_tcp_config
    ;;
  2)
    set_ws_config
    ;;
  *)
    echo -e "${error}输入错误 !"
    sleep 3s
    install_poseidon
    ;;
  esac
}

update_poseidon() {
  if [[ $(docker pull v2cc/poseidon:latest) == *"Image is up to date"* ]]; then
    docker images --digests
    echo -e "${info}已是最新版本 !"
  else
    docker restart $(docker ps -aq) && echo -e "${info}更新完成 !"
  fi
}

start_menu() {
  echo && echo -e "Author: @Lnkstls
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end} 升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end} 创建poseidon(docker版)
${font_color_up}2.${font_color_end} 更新poseidon(docker版)
——————————————————————————————
Ctrl+C 退出" && echo
  read -p "请输入数字: " num
  case "$num" in
  0)
    update_sh
    ;;
  1)
    install_docker &&
      add_docker
    ;;
  1)
    update_poseidon
    ;;
  esac
}
start_menu
