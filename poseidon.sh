#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="0.64"

font_color_up="\033[32m" && font_color_end="\033[0m" && error_color_up="\033[31m" && error_color_end="\033[0m"
info="${font_color_up}[提示]: ${font_color_end}"
error="${error_color_up}[错误]: ${error_color_end}"
note="\033[33m [注意]: \033[0m"

os() {
    arch='uname -m'
    oss=$(lsb_release -a 2>/dev/null | grep "Distributor" | awk '{print $NF}')
    release=$(lsb_release -a 2>/dev/null | grep "Release" | awk '{print $NF}')
    if [ "$arch" = "x86_64" ]; then
        echo -e "${error}暂不支持 x86_64 以外系统 !" && exit 1
    fi
    
    if [ "${oss}" = "Debian" ]; then
        commad="apt"
    elif [ "${oss}" = "ubuntu" ]; then
        commad="apt"
    elif [ "${oss}" = "centos" ]; then
        commad="yum"
    else
        echo -e "${info}不支持的系统 !"
        commad="apt"
    fi
}
os

update_sh() {
    github="https://raw.githubusercontent.com/Lnkstls/autoJs/master/"
    echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	sh_new_ver=$(wget -qO- "${github}/poseidon.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && start_menu
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


wget_bbr() {
    bbrrss="https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" 
    if [ ! -e "./tcp.sh" ]; then
        wget --no-check-certificate -O tcp.sh "${bbrrss}" && chmod +x tcp.sh
    fi
    ./tcp.sh
}

docker_install() {
    if [ ! $(command -v docker) ]; then
        echo -e "${info}开始安装docker..."
        curl -fsSL https://get.docker.com | bash
        curl -L -S "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod a+x /usr/local/bin/docker-compose
        rm -f $(which dc) && ln -s /usr/local/bin/docker-compose /usr/bin/dc > /dev/null
        systemctl start docker > /dev/null && echo -e "${info}docker安装完成"
    fi
    if [ ! -e "v2" ]; then
        mkdir v2
    fi
    cd v2
}


set_tcp_config() {
    tcp_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/tcp/config.json"
    docker_tcp_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/tcp/docker-compose.yml"
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
    read -p "服务端口(默认80):" dc_port
    dc_port=${dc_port:-80}

    if [ -d "$dc_name" ]; then
        echo -e "${error}容器名称重复!"
        sleep 3s
        set_tcp_config
    fi
    
    mkdir $dc_name
    cd $dc_name
    if [ -n "$webapi" -a -n "$token" ]; then
        wget -nv -O config.json $tcp_config
        cat config.json | sed "4s/1/${node_id}/g" | sed "6s|http or https://YOUR V2BOARD DOMAIN|${webapi}|g" | sed "7s/v2board token/${token}/g" | sed "9s/0/${node_speed}/g" | sed "11s/0/${user_ip}/g" | sed "12s/0/${user_speed}/g" >config.json.$$ && mv config.json.$$ config.json
        wget -O docker-compose.yml $docker_tcp_config
        cat docker-compose.yml | sed "s/v2ray-tcp/${dc_name}/g" | sed "s/服务端口/${dc_port}/g" >docker-compose.yml.$$ && mv docker-compose.yml.$$ docker-compose.yml && echo -e "${info}配置文件完成"
        docker-compose up -d && echo $dc_name  && docker-compose logs -f
    else
        echo -e "${error}输入错误 !"
        sleep 3s
        set_ws_config
    fi
}


set_ws_config() {
    ws_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/ws/config.json"
    docker_ws_config="https://raw.githubusercontent.com/ColetteContreras/v2ray-poseidon/master/docker/v2board/ws/docker-compose.yml"
    
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
    read -p "服务端口(默认10086):" ser_port
    ser_port=${ser_port:-10086}

    if [ -d "$dc_name" ]; then
        echo -e "${error}容器名称重复 !"
        sleep 3s
        set_ws_config
    fi
    
    mkdir $dc_name
    cd $dc_name
    
    if [ -n "$webapi" -a -n "$token" ]; then
        wget -O config.json $ws_config
        cat config.json | sed "4s/1/${node_id}/g" | sed "6s|http or https://YOUR V2BOARD DOMAIN|${webapi}|g" | sed "7s/v2board token/${token}/g" | sed "9s/0/${node_speed}/g" | sed "11s/0/${user_ip}/g" | sed "12s/0/${user_speed}/g" >config.json.$$ && mv config.json.$$ config.json
        wget -O docker-compose.yml $docker_ws_config
        cat docker-compose.yml | sed "s/v2ray-ws/${dc_name}/g" | sed "s/80/${dc_port}/g" | sed "s/10086/${ser_port}/g" > docker-compose.yml.$$ && mv docker-compose.yml.$$ docker-compose.yml && echo -e "${info}配置文件完成"
        docker-compose up -d && echo $dc_name  && docker-compose logs -f
    else
        echo -e "${error}输入错误 !"
        sleep 3s
        set_ws_config
    fi
}

install_poseidon() {
    docker_install
    echo -e "
\033[2A
${font_color_up}1.${font_color_end}tcp
${font_color_up}2.${font_color_end}ws
${font_color_up}3.${font_color_end}tls
——————————————————————————————
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
        echo -e "${error}暂不支持 !"
        ;;
    *)
        echo -e "${error}输入错误 !"
        sleep 3s
        install_poseidon
        ;;
    esac

}

install_bt() {
    bt_link="http://download.bt.cn/install/install_panel.sh"
    curl -sSO ${bt_link} && bash install_panel.sh
}
rm_bt() {
    rmbt_link="http://download.bt.cn/install/bt-uninstall.sh"
    wget --no-check-certificate -O bt_uninstall.sh ${rmbt_link} && bash bt_uninstall.sh
}
install_hot() {
    hot_link="https://raw.githubusercontent.com/CokeMine/ServerStatus-Hotaru/master/status.sh"
    wget --no-check-certificate -O status.sh ${hot_link}   && chmod +x status.sh && ./status.sh c
}
dis_ufw() {
    ufw disable && ufw reset && echo -e "${info}关闭完成"
}
update_poseidon() {
    docker pull v2cc/poseidon && echo -e "${info}拉取完成"
    # docker ps -a | grep "-" | awk '{print $NF}' | docker restart && echo "update Yes"
    docker restart $(docker ps -a -q) &> /dev/null && echo -e "${info}更新完成"
    
}
de_routing() {
    if [ ! -e "besttrace.sh" ]; then
        wget --no-check-certificate -O besttrace.sh git.io/besttrace && chmod +x besttrace.sh
    fi
    ./besttrace.sh
}

ddserver() {
    dd_link="https://raw.githubusercontent.com/veip007/dd/master/dd-gd.sh"
    if [ ! -e "dd-gd.sh" ]; then
        wget --no-check-certificate -O dd-gd.sh ${dd_link}  && chmod +x dd-gd.sh
    fi
    ./dd-gd.sh
}

time_up() {
    if [ ! `command -v ntpdate` ]; then
        ${commad} install -y ntpdate
    fi
    timedatectl set-timezone 'Asia/Shanghai' && ntpdate -u pool.ntp.org && hwclock -w
    timedatectl
}

up_crontab() {    
    if [[ 'crontab -l' = *reboot* ]]; then
        echo -e "${note}已存在reboot !"
        crontab -l
    fi
    read -p "每月重启时间(分 时 日 月 星期):" reboot_time
    reboot_time=${reboot_time:-1}
    if [[ 'crontab -l' = *crontab* ]]; then
        echo "${reboot_time} reboot" >> conf.$$ && crontab conf.$$ && rm -f conf.$$ && crontab -l && echo -e "${info}设置完成"
    else
        crontab -l > conf.$$ && echo "${reboot_time} reboot" >> conf.$$ && crontab conf.$$ && rm -f conf.$$ && echo -e "${info}" && crontab -l
    fi
}

superspeed() {
    superspeed_link="https://git.io/superspeed"
    if [ -e "superspeed.sh" ]; then
        wget --no-check-certificate -O superspeed.sh ${superspeed_link} && chmod +x superspeed.sh
    fi
    ./superspeed.sh
}

speedtest_install() {
        if [ "$oss" = "Debian" ] || [ "$oss" = "ubuntu" ]; then
            sudo apt-get install -y gnupg1 apt-transport-https dirmngr
            export INSTALL_KEY=379CE192D401AB61
            export DEB_DISTRO=$(lsb_release -sc)
            sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
            echo "deb https://ookla.bintray.com/debian ${DEB_DISTRO} main" | sudo tee  /etc/apt/sources.list.d/speedtest.list
            sudo apt-get update
            sudo apt-get install -y speedtest && echo -e "${info}安装完成 !"
        elif [ "$oss" = "centos" ]; then
            wget https://bintray.com/ookla/rhel/rpm -O bintray-ookla-rhel.repo
            sudo mv bintray-ookla-rhel.repo /etc/yum.repos.d/
            sudo yum install -y speedtest && echo -e "${info}安装完成 !"
        else
            echo -e "${error}不受支持的系统 !"
        fi
        
}

nat() {
    nat_link="http://arloor.com/sh/iptablesUtils/natcfg.sh"
    if [ ! -e "nat.sh" ]; then
        wget --no-check-certificate -O nat.sh ${nat_link} && chmod +x nat.sh
    fi
    ./nat.sh
}

ddns() {
    ddns_link=https://raw.githubusercontent.com/Lnkstls/ddns-dnspod/master/dnspod_ddns.sh
    ddns_line_link=https://raw.githubusercontent.com/Lnkstls/ddns-dnspod/master/dnspod_ddns_line.sh
    echo -e "
\033[2A
${font_color_up}1.${font_color_end} 外网获取ip
${font_color_up}2.${font_color_end} 网卡获取
——————————————————————————————"
    read -p "请输入数字:" ddns_re
    case "$ddna_re" in
    1)
        if [ ! -e "ddns.sh" ]; then
            wget --no-check-certificate -O ddns.sh ${ddns_link} && chmod +x ddns.sh
        fi
        ./ddns.sh
    ;;
    1)
        if [ ! -e "ddns_line.sh" ]; then
            wget --no-check-certificate -O ddns_line.sh ${ddns_line_link} && chmod +x ddns_line.sh
        fi
        ./ddns_line.sh
    ;;
    *)
        echo "${error}输入错误 !"
        sleep 3s
        ddns
    ;;
    esac
}

cf_iptable() {
    read -p "Cloudflare Email:" cf_mail
    cf_mail=${cf_mail:-0}
    read -p "Cloudflare Email:" cf_mail
    cf_mail=${cf_mail:-0}
    read -p "Cloudflare Email:" cf_mail
    cf_mail=${cf_mail:-0}
}

start_menu() {
    clear
    echo && echo -e "Author: by @Lnkstls
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end} 升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end} 下载bbr安装脚本
${font_color_up}2.${font_color_end} 安装poseidon(docker版)
${font_color_up}3.${font_color_end} 更新poseidon(docker版)
${font_color_up}4.${font_color_end} 下载bt安装脚本(py3版)
${font_color_up}5.${font_color_end} 下载卸载bt脚本
${font_color_up}6.${font_color_end} 下载Hotaru探针脚本
${font_color_up}7.${font_color_end} 关闭UFW防火墙
${font_color_up}8.${font_color_end} 下载快速回程测试脚本
${font_color_up}9.${font_color_end} 下载一键dd系统脚本
${font_color_up}10.${font_color_end} 设置上海时区并对齐
${font_color_up}11.${font_color_end} 设置每月定时重启任务
${font_color_up}12.${font_color_end} 下载国内测速脚本(Superspeed)
${font_color_up}13.${font_color_end} 安装speedtest
${font_color_up}14.${font_color_end} 下载nat脚本
${font_color_up}15.${font_color_end} 下载ddns脚本
——————————————————————————————
Ctrl+C 退出" && echo
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
    11)
        up_crontab
        ;;
    12)
        superspeed
        ;;
    13)
        speedtest_install
        ;;
    14)
        nat
        ;;
    15)
        ddns
        ;;
    *)
        echo -e "${error}输入错误 !"
        sleep 3s
        start_menu
        ;;
    esac
}
server_cmd() {
    if [ ! -e "poseidon.log" ]; then
        echo -e "${info}更新列表 update"
        ${commad} update && echo "1" > poseidon.log
    fi
    if [ ! `command -v sudo` ]; then
        echo -e "${info}安装依赖 sudo"
        ${commad} install -y sudo
    fi
    if [ ! `command -v wget` ]; then
        echo -e "${info}安装依赖 wget"
        ${commad} install -y wget
    fi
    if [ ! `command -v vim` ]; then
        echo -e "${info}安装依赖 vim"
        ${commad} install -y vim
    fi
    if [ ! `command -v unzip` ]; then
        echo -e "${info}安装依赖 unzip"
        ${commad} install -y unzip
    fi
    if [ ! `command -v curl` ]; then
        echo -e "${info}安装依赖 curl"
        ${commad} install -y curl
    fi
}
server_cmd
start_menu
