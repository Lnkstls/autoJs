#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="0.2"

font_color_up="\033[32m" && font_color_end="\033[0m" && github="https://raw.githubusercontent.com/Lnkstls/autoJs/master/" && bbrrss="https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && ifdown="按任意键继续...(按Ctrl+c退出)" && btlink="http://download.bt.cn/install/install_panel.sh" && rmbtlink="http://download.bt.cn/install/bt-uninstall.sh"

update_sh() {
    echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	sh_new_ver=$(wget -qO- "${github}/poseidon.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && start_menu
    if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
		read -p "(默认: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N "${github}/poseidon.sh" && chmod +x poseidon.sh
			echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !"
		else
			echo && echo "	已取消..." && echo
		fi
	else
		echo -e "当前已是最新版本[ ${sh_new_ver} ] !"
		sleep 5s
	fi
}

wget_bbr() {
    if [ -e "./tcp.sh" ]; then
        ./tcp.sh
    else
        wget --no-check-certificate -d "${bbrrss}" && chmod +x tcp.sh && ./tcp.sh
    fi
}

docker_install() {
    if [ ! $(command -v docker) ]; then
        echo "即将安装docker环境"
        curl -fsSL https://get.docker.com | bash && curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod a+x /usr/local/bin/docker-compose && echo "环境安装完成"
        rm -f $(which dc) && ln -s /usr/local/bin/docker-compose /usr/bin/dc && echo "软链添加完成"
        systemctl start docker && echo "docker启动成功"
    fi
    echo "docker install OK"
    if [ ! -e "v2" ]; then
        mkdir v2
    fi
    cd v2
}

tcp_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/tcp/config.json"
docker_tcp_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/tcp/docker-compose.yml"
set_tcp_config() {
    docker_install

    read -p "节点id(默认1):" node_id
    node_id=${node_id:-1}
    read -p "webapi(必填):" webapi
    read -p "token(必填):" token
    read -p "节点限速(默认0):" node_speed
    node_speed=${node_speed:-0}
    read -p "用户ip限制(默认0):" user_ip
    user_ip=${user_ip:-0}
    read -p "用户限速(默认0):" user_speed
    user_speed=${user_speed:-0}

    read -p "容器名称(默认v2ray-tcp):" dc_name
    dc_name=${dc_name:-v2ray-tcp}
    read -p "连接端口(默认80):" dc_port
    dc_port=${dc_port:-80}

    if [ -d "$dc_name" ]; then
        echo "容器名称重复！"
        sleep 3s
        set_tcp_config
    fi
    
    mkdir $dc_name
    cd $dc_name
    if [ -n "$webapi" -a -n "$token" ]; then
        wget -O config.json $tcp_config
        cat config.json | sed "4s/1/${node_id}/g" | sed "6s|http or https://YOUR V2BOARD DOMAIN|${webapi}|g" | sed "7s/v2board token/${token}/g" | sed "9s/0/${node_speed}/g" | sed "11s/0/${user_ip}/g" | sed "12s/0/${user_speed}/g" >config.json.$$ && mv config.json.$$ config.json && echo "config.json OK"
        wget -O docker-compose.yml $docker_tcp_config
        cat docker-compose.yml | sed "s/v2ray-tcp/${dc_name}/g" | sed "s/服务端口/${dc_port}/g" >docker-compose.yml.$$ && mv docker-compose.yml.$$ docker-compose.yml && echo "docker-compose OK"
        docker-compose up -d && echo $dc_name >>../update && echo "set update OK" && docker-compose logs -f
    else
        echo "输入错误！"
        sleep 3s
        set_ws_config
    fi
}

ws_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/ws/config.json"
docker_ws_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/ws/docker-compose.yml"
set_ws_config() {
    docker_install

    read -p "节点id(默认1):" node_id
    node_id=${node_id:-1}
    read -p "webapi(必填):" webapi
    read -p "token(必填):" token
    read -p "节点限速(默认0):" node_speed
    node_speed=${node_speed:-0}
    read -p "用户ip限制(默认0):" user_ip
    user_ip=${user_ip:-0}
    read -p "用户限速(默认0):" user_speed
    user_speed=${user_speed:-0}

    read -p "容器名称(默认v2ray-ws):" dc_name
    dc_name=${dc_name:-v2ray-ws}
    read -p "连接端口(默认80):" dc_port
    dc_port=${dc_port:-80}

    if [ -d "$dc_name" ]; then
        echo "容器名称重复！"
        sleep 3s
        set_ws_config
    fi
    
    mkdir $dc_name
    cd $dc_name
    
    if [ -n "$webapi" -a -n "$token" ]; then
        wget -O config.json $ws_config
        cat config.json | sed "4s/1/${node_id}/g" | sed "6s|http or https://YOUR V2BOARD DOMAIN|${webapi}|g" | sed "7s/v2board token/${token}/g" | sed "9s/0/${node_speed}/g" | sed "11s/0/${user_ip}/g" | sed "12s/0/${user_speed}/g" >config.json.$$ && mv config.json.$$ config.json && echo "config.json OK"
        wget -O docker-compose.yml $docker_ws_config
        cat docker-compose.yml | sed "s/v2ray-ws/${dc_name}/g" | sed "s/80/${dc_port}/g" >docker-compose.yml.$$ && mv docker-compose.yml.$$ docker-compose.yml && echo "docker-compose OK"
        docker-compose up -d && echo $dc_name >>../update && echo "set update OK" && docker-compose logs -f
    else
        echo "输入错误！"
        sleep 3s
        set_ws_config
    fi
}

install_poseidon() {
    echo -e "
${font_color_up}1.${font_color_end}tcp
${font_color_up}2.${font_color_end}ws
${font_color_up}3.${font_color_end}tls
-----------------------------------------
${font_color_up}0.${font_color_end}返回上一步
    "
    read -p "请输入数字:" num
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
    3)
        echo "暂不支持！"
        ;;
    *)
        echo "输入错误！"
        sleep 3s
        install_poseidon
        ;;
    esac

}

install_bt() {
    curl -sSO "${btlink}" && bash install_panel.sh
}
rm_bt() {
    wget --no-check-certificate -d "${rmbtlink}" && bash install_panel.sh
}
install_hot() {
    wget --no-check-certificate -d https://raw.githubusercontent.com/CokeMine/ServerStatus-Hotaru/master/status.sh && chmod +x status.sh && ./status.sh c
}
dis_ufw() {
    ufw disable && ufw reset && echo "关闭完成"
}
update_poseidon() {
    docker pull v2cc/poseidon && echo "${font_color_up}pull OK${font_color_end}"
    docker ps -a | grep "-" | awk '{print $NF}' | docker restart && echo "update Yes"
}
de_routing() {
    if [ ! -e "besttrace.sh" ]; then
        wget -qO- -O besttrace.sh git.io/besttrace && chmod +x besttrace.sh && ./besttrace.sh
    fi
    ./besttrace.sh
}
ddserver() {
    if [ -e "dd-gd.sh" ]; then
        wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/dd/master/dd-gd.sh && chmod +x dd-gd.sh && ./dd-gd.sh
    fi
    ./dd-gd.sh
}
time_up() {
    timedatectl set-timezone 'Asia/Shanghai' && ntpdate -u pool.ntp.org && hwclock -w
    timedatectl
}
start_menu() {
    clear
    echo -e "
${font_color_up}0.${font_color_end}升级脚本
-----------------------------------------
${font_color_up}1.${font_color_end}下载bbr安装脚本
${font_color_up}2.${font_color_end}安装poseidon(docker版)
${font_color_up}3.${font_color_end}更新poseidon(docker版)
${font_color_up}4.${font_color_end}下载bt安装脚本(py3版)
${font_color_up}5.${font_color_end}下载卸载bt脚本
${font_color_up}6.${font_color_end}下载Hotaru探针脚本
${font_color_up}7.${font_color_end}关闭UFW防火墙
${font_color_up}8.${font_color_end}下载快速回程测试脚本
${font_color_up}9.${font_color_end}下载一键dd系统脚本
${font_color_up}10.${font_color_end}设置上海时区并对齐
-----------------------------------------"
    read -p "请输入数字：" num
    case "$num" in
    0)
        update_sh
        ;;
    1)
        wget_bbr
        ;;
    2)
        install_poseidon
        ;;
    3)
        update_poseidon
        ;;
    4)
        install_bt
        ;;
    5)
        rm_bt
        ;;
    6)
        install_hot
        ;;
    7)
        dis_ufw
        ;;
    8)
        de_routing
        ;;
    9)
        ddserver
        ;;
    10)
        time_up
        ;;
    *)
        echo "输入错误！！！"
        sleep 3s
        start_menu
        ;;
    esac
}
server_cmd() {
    if [ ! `command -v wget` ]; then
        apt install -y wget
    fi
    if [ ! `command -v vim` ]; then
        apt install -y vim
    fi
    if [ ! `command -v unzip` ]; then
        apt install -y unzip
    fi
    
    if [ ! `command -v curl` ]; then
        apt install -y curl
    fi
    if [ ! `command -v ntpdate` ]; then
        apt install -y ntpdate
    fi
}
server_cmd
start_menu
