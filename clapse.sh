#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="101"

font_color_up="\033[32m" && font_color_end="\033[0m" && error_color_up="\033[31m" && error_color_end="\033[0m"
info="${font_color_up}[提示]: ${font_color_end}"
error="${error_color_up}[错误]: ${error_color_end}"
note="\033[33m[警告]: \033[0m"
fder="./JsSet"
lnkstls_link="https://sh.clapse.com"

if (( $EUID != 0 )); then
  echo -e "${error}仅在root环境下测试 !" && exit 1
fi

Release=$( < /etc/os-release grep "VERSION_ID" | awk -F '=' '{print $2}' | sed "s/\"//g")
# if [ "$arch" = "x86_64" ]; then
#   echo -e "${error}暂不支持 x86_64 以外系统 !" && exit 1
# fi
if [[ -f /etc/redhat-release ]]; then
  Distributor="CentOS"
  Commad="yum"
elif < /etc/issue grep -Eqi "debian"; then
  Distributor="Debian"
  Commad="apt"
elif < /etc/issue  grep -Eqi "ubuntu"; then
  Distributor="Ubuntu"
  Commad="apt"
elif < /etc/issue  grep -Eqi "centos|red hat|redhat"; then
  Distributor="CentOS"
  Commad="yum"
elif < /proc/version  grep -Eqi "debian"; then
  Distributor="Debian"
  Commad="apt"
elif < /proc/version  grep -Eqi "ubuntu"; then
  Distributor="Ubuntu"
  Commad="apt"
elif < /proc/version  grep -Eqi "centos|red hat|redhat"; then
  Distributor="CentOS"
  Commad="yum"
else
  echo -e "${error}未检测到系统版本！" && exit 1
fi

update_sh() {
  uname="clapse.sh"
  echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
  local sh_new_ver
  sh_new_ver=$(wget -qO- "${lnkstls_link}/${uname}" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
  [[ -z ${sh_new_ver} ]] && echo -e "${error}检测最新版本失败 !" && sleep 3s && start_menu
  if [[ ${sh_new_ver} != "${sh_ver}" ]]; then
    echo -e "${info}发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
    read -rep "(默认Y): " yn
    [[ -z "${yn}" ]] && yn="Y"
    if [[ ${yn} == [Yy] ]]; then
      wget -O $uname "${lnkstls_link}/${uname}" && chmod +x ${uname}
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

upcs() {
  echo -e "${info}更新列表 update"
  $Commad update -y && echo -e "${info}更新完成 !"
}

add_crontab() {
  if [[ $(crontab -l 2>/dev/null) == *$1* ]]; then
    echo -e "${note}已存在, 是否继续?[N/y]"
    crontab -l | grep "$1"
    read -rep "默认(N):" num
    num=${num:-N}
    if [[ $num == [Nn] ]]; then
      exit 0
    fi
  fi
  crontab -l 2>/dev/null >"$0".temp
  echo "$1" >>"$0".temp &&
    crontab "$0".temp &&
    rm -f "$0".temp &&
    echo -e "${info}添加crontab成功 !" && crontab -l
}

soucn() {
  if [ "$Distributor" = "Debian" ]; then
    cp -f /etc/apt/sources.list /etc/apt/sources.list.bakup
    case $Release in
    8)
      echo -e "${info}写入Debian8源 !"
      echo "deb http://mirrors.cloud.tencent.com/debian jessie main contrib non-free
        deb http://mirrors.cloud.tencent.com/debian jessie-updates main contrib non-free
        #deb http://mirrors.cloud.tencent.com/debian jessie-backports main contrib non-free
        #deb http://mirrors.cloud.tencent.com/debian jessie-proposed-updates main contrib non-free
        deb-src http://mirrors.cloud.tencent.com/debian jessie main contrib non-free
        deb-src http://mirrors.cloud.tencent.com/debian jessie-updates main contrib non-free
        #deb-src http://mirrors.cloud.tencent.com/debian jessie-backports main contrib non-free
        #deb-src http://mirrors.cloud.tencent.com/debian jessie-proposed-updates main contrib non-free" >/etc/apt/sources.list
      ;;
    9)
      echo -e "${info}写入Debian9源 !"
      echo "deb http://mirrors.cloud.tencent.com/debian stretch main contrib non-free
        deb http://mirrors.cloud.tencent.com/debian stretch-updates main contrib non-free
        #deb http://mirrors.cloud.tencent.com/debian stretch-backports main contrib non-free
        #deb http://mirrors.cloud.tencent.com/debian stretch-proposed-updates main contrib non-free
        deb-src http://mirrors.cloud.tencent.com/debian stretch main contrib non-free
        deb-src http://mirrors.cloud.tencent.com/debian stretch-updates main contrib non-free
        #deb-src http://mirrors.cloud.tencent.com/debian stretch-backports main contrib non-free
        #deb-src http://mirrors.cloud.tencent.com/debian stretch-proposed-updates main contrib non-free" >/etc/apt/sources.list
      ;;
    10)
      echo -e "${info}写入Debian10源 !"
      echo "deb https://mirrors.cloud.tencent.com/debian/ buster main contrib non-free
        deb https://mirrors.cloud.tencent.com/debian/ buster-updates main contrib non-free
        deb https://mirrors.cloud.tencent.com/debian/ buster-backports main contrib non-free
        deb https://mirrors.cloud.tencent.com/debian-security buster/updates main contrib non-free
        deb-src https://mirrors.cloud.tencent.com/debian/ buster main contrib non-free
        deb-src https://mirrors.cloud.tencent.com/debian/ buster-updates main contrib non-free
        deb-src https://mirrors.cloud.tencent.com/debian/ buster-backports main contrib non-free
        deb-src https://mirrors.cloud.tencent.com/debian-security buster/updates main contrib non-free" >/etc/apt/sources.list
      ;;
    *)
      echo -e "${error}未匹配到对应系统源,仅支持LTS版本 !" && exit 1
      ;;
    esac
  elif [ "$Distributor" = "Ubuntu" ]; then
    cp -f /etc/apt/sources.list /etc/apt/sources.list.bakup
    case $Release in
    16.04)
      echo -e "${info}写入ubuntu16.04源 !"
      echo "deb http://mirrors.cloud.tencent.com/ubuntu/ xenial main restricted universe multiverse
        deb http://mirrors.cloud.tencent.com/ubuntu/ xenial-security main restricted universe multiverse
        deb http://mirrors.cloud.tencent.com/ubuntu/ xenial-updates main restricted universe multiverse
        #deb http://mirrors.cloud.tencent.com/ubuntu/ xenial-proposed main restricted universe multiverse
        #deb http://mirrors.cloud.tencent.com/ubuntu/ xenial-backports main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial-security main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial-updates main restricted universe multiverse
        #deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial-proposed main restricted universe multiverse
        #deb-src http://mirrors.cloud.tencent.com/ubuntu/ xenial-backports main restricted universe multiverse" >/etc/apt/sources.list
      ;;
    18.04)
      echo -e "${note}写入ubuntu18.04源 !"
      echo "deb http://mirrors.cloud.tencent.com/ubuntu/ bionic main restricted universe multiverse
        deb http://mirrors.cloud.tencent.com/ubuntu/ bionic-security main restricted universe multiverse
        deb http://mirrors.cloud.tencent.com/ubuntu/ bionic-updates main restricted universe multiverse
        #deb http://mirrors.cloud.tencent.com/ubuntu/ bionic-proposed main restricted universe multiverse
        #deb http://mirrors.cloud.tencent.com/ubuntu/ bionic-backports main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic-security main restricted universe multiverse
        deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic-updates main restricted universe multiverse
        #deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic-proposed main restricted universe multiverse
        #deb-src http://mirrors.cloud.tencent.com/ubuntu/ bionic-backports main restricted universe multiverse" >/etc/apt/sources.list
      ;;
    20.04)
      echo -e "${note}写入ubuntu18.04源 !"
      echo "deb http://mirrors.cloud.tencent.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.cloud.tencent.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.cloud.tencent.com/ubuntu/ focal-updates main restricted universe multiverse
#deb http://mirrors.cloud.tencent.com/ubuntu/ focal-proposed main restricted universe multiverse
#deb http://mirrors.cloud.tencent.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal-security main restricted universe multiverse
deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal-updates main restricted universe multiverse
#deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal-proposed main restricted universe multiverse
#deb-src http://mirrors.cloud.tencent.com/ubuntu/ focal-backports main restricted universe multiverse" >/etc/apt/sources.list
      ;;
    *)
      echo -e "${error}未匹配到对应系统源,仅支持LTS版本 !" && exit 1
      ;;
    esac
  elif [ "$Distributor" = "CentOS" ]; then
    cp -f /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bakup
    case $Release in
    7)
      echo -e "${info}写入centos7源 !"
      wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
      ;;
    8)
      echo -e "${info}写入centos8源 !"
      wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos8_base.repo
      ;;
    *)
      echo -e "${error}未匹配到对应系统源,仅支持LTS版本 !" && exit 1
      ;;
    esac
  else
    echo -e "${error}未匹配到系统 !" && exit 1
  fi
  sleep 3s
  upcs
}
souret() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    if [ -e "/etc/apt/sources.list.bakup" ]; then
      cp -f /etc/apt/sources.list.bakup /etc/apt/sources.list && echo -e "${info}恢复完成 !"
    else
      echo -e "${error}未找到备份 !" && exit 1
    fi
  elif [ "$Distributor" = "CentOS" ]; then
    if [ -e "/etc/yum.repos.d/CentOS-Base.repo.bakup" ]; then
      cp -f /etc/yum.repos.d/CentOS-Base.repo.bakup /etc/yum.repos.d/CentOS-Base.repo && echo -e "${info}恢复完成 !"
    else
      echo -e "${error}未找到备份 !" && exit 1
    fi
  fi
  upcs
}

wget_bbr() {
    if < /etc/security/limits.conf grep -Eqi "soft nofile|soft noproc "; then
    echo -e "${error}已优化limits !"
  else
    echo "*   soft noproc   65535
*   hard noproc   65535
*   soft nofile   65535
*   hard nofile   65535" >>/etc/security/limits.conf && echo -e "${info}limits设置完成 !"
  fi
  if < /etc/profile grep -Eqi "ulimit -u 65535"; then
    echo -e "${error}已优化profile !"
  else
    echo "ulimit -u 65535
ulimit -n 65535
ulimit -d unlimited
ulimit -m unlimited
ulimit -s unlimited
ulimit -t unlimited
ulimit -v unlimited" >>/etc/profile && source /etc/profile && echo -e "${info}profile设置完成 !"
  fi
  cd $fder || exit
  local bbrrss="https://github.000060000.xyz/tcp.sh"
  if [ ! -e "./tcp.sh" ]; then
    wget --no-check-certificate -O tcp.sh $bbrrss && chmod +x tcp.sh
  fi
  ./tcp.sh
}

install_docker() {
  if [ ! "$(command -v docker)" ]; then
    echo -e "${info}开始安装Docker..."
    case $Distributor in
    Debian)
      apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common &&
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - &&
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
      apt update
      apt install -y docker-ce docker-ce-cli containerd.io
      ;;
    Ubuntu)
      apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common &&
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      apt update
      apt install -y docker-ce docker-ce-cli containerd.io
      ;;
    CentOS)
      yum install -y yum-utils
      yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      yum install -y docker-ce docker-ce-cli containerd.io
      ;;
    esac && echo -e "${info}Docker安装完成 !"
  else
    echo -e "${info}Docker已安装 !"
  fi
  if [ ! "$(command -v docker-compose)" ]; then
    echo -e "${info}开始安装Docker-Compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && echo -e "${info}安装成功 !"
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    rm -f "$(which dc)"
    ln -s /usr/bin/docker-compose /usr/bin/dc
  else
    echo -e "${info}Docker-Compose已安装 !"
  fi
}

poseidon() {
  local poseidon_link="${lnkstls_link}/poseidon.sh"
  if [ ! -e poseidon.sh ]; then
    wget --no-check-certificate $poseidon_link && chmod +x poseidon.sh
  fi
  ./poseidon.sh
}

vnstatcont() {
  if [ ! "$(command -v vnstat)" ]; then
    echo -e "${info}安装vnstat..."
    $Commad install -y vnstat
    vnstat --iflist
    read -rep "选择网络接口(默认eth0): " eth
    eth=${eth:-eth0}
    if ! sed -i "5s/.*/Interface \"${eth}\"/" /etc/vnstat.conf; then
      echo -e "${error}设置网络接口错误 !" && exit 1
    fi
  fi
  cd $fder || exit
  local vnstat_link="${lnkstls_link}/vnstat.sh"
  if [ ! -e vnstat.sh ]; then
    wget --no-check-certificate $vnstat_link && chmod +x vnstat.sh
  fi
  read -rep "重置日期(默认00): " time
  time=${time:-00}
  read -rep "控制流量单位GB(默认1024): " gb
  gb=${gb:-1024}
  read -rep "统计(默认0=所有, 1=上传, 2=下载): " range
  range=${range:-0}
  ./vnstat.sh "$time" "$gb" "$range" &&
    add_crontab "* * * * * bash $(pwd)/vnstat.sh $time $gb $range >$(pwd)/vnstat.log"
}

install_bt() {
  cd $fder || exit
  local bt_link="http://download.bt.cn/install/install_panel.sh"
  if [ ! -e "install_panel.sh" ]; then
    curl -sSO ${bt_link}
  fi
  bash install_panel.sh

  echo -e "${info}登录破解 !"
  sed -i "s|if (bind_user == 'True') {|if (bind_user == 'REMOVED') {|g" /www/server/panel/BTPanel/static/js/index.js
  rm -rf /www/server/panel/data/bind.pl
}

rm_bt() {
  cd $fder || exit
  local rmbt_link="http://download.bt.cn/install/bt-uninstall.sh"
  if [ ! -e "bt_uninstall.sh" ]; then
    wget --no-check-certificate -O bt_uninstall.sh ${rmbt_link}
  fi
  bash bt_uninstall.sh
}

cloudflare() {
  if [ ! "$(command -v gcc)" ]; then
    echo -e "${info}安装gcc..."
    $Commad install -y gcc
  fi
  if [ ! "$(command -v make)" ]; then
    echo -e "${info}安装make..."
    $Commad install -y make
  fi
  cd $fder || exit
  local cloudflare_link="https://proxy.freecdn.workers.dev/?url=https://github.com/badafans/better-cloudflare-ip/releases/latest/download/linux.tar.gz"
  if [ ! -e "linux.tar.gz" ]; then
    wget --no-check-certificate -O linux.tar.gz "$cloudflare_link" &&
      tar -zxf linux.tar.gz &&
      cd linux &&
      ./configure && make
  else
    cd linux || exit
  fi
  # shellcheck disable=SC2164
  cd src
  ./cf.sh
}

install_hot() {
  cd $fder || exit
  local hot_link="https://raw.githubusercontent.com/CokeMine/ServerStatus-Hotaru/master/status.sh"
  wget --no-check-certificate -O status.sh ${hot_link} && chmod +x status.sh && ./status.sh c
}

ddserver() {
#    0) 升级本脚本
#  1) CentOS 7 (DD) 用户名：root 密码：Pwd@CentOS
#  2) CentOS 6 (阿里云镜像) 用户名：root 密码：MoeClub.org
#  3) CentOS 6 用户名：root 密码：MoeClub.org
#  4) Debian 7 x32 用户名：root 密码：MoeClub.org
#  5) Debian 8 x64 用户名：root 密码：MoeClub.org
#  6) Debian 9 x64 用户名：root 密码：MoeClub.org
#  7) Debian 10 x64 用户名：root 密码：cxthhhhh.com
#  8) Ubuntu 14.04x64 用户名：root 密码：MoeClub.org
#  9) Ubuntu 16.04x64 用户名：root 密码：MoeClub.org
#  10) Ubuntu 18.04x64 用户名：root 密码：MoeClub.org
#  11) 萌咖Win7x64 用户名:Administrator  密码：Vicer
#  12) Win2019 By:MeowLove  密码：cxthhhhh.com
#  13) Win2016 By:MeowLove  密码：cxthhhhh.com
#  14) Win2012 R2 By:MeowLove  密码：cxthhhhh.com
#  15) Win2008 R2 By:MeowLove  密码：cxthhhhh.com
#  16) Windows 7 Vienna By:MeowLove  密码：cxthhhhh.com
#  17) Windows 2003 Vienna By:MeowLove  密码：cxthhhhh.com
#  18) Win7x32 By:老司机  用户名:Administrator  密码：Windows7x86-Chinese
#  19) Win-2003x32 By:老司机  用户名:Administrator  密码：WinSrv2003x86-Chinese
#  20) Win2008x64 By:老司机  用户名:Administrator  密码：WinSrv2008x64-Chinese
#  21) Win2012R2x64 By:老司机  用户名:Administrator  密码：WinSrv2012r2
#  22) CentOS 8 用户名：root 密码：cxthhhhh.com 推荐512M以上使用
#  23) Win7x64 By:net.nn  用户名:Administrator  密码：nat.ee
#  24) Win7x64 Uefi启动的VPS专用(如:甲骨文)By:net.nn  用户名:Administrator  密码：nat.ee
#  25) Win8.1x64 By:net.nn  用户名:Administrator  密码：nat.ee
#  26) Win8.1x64 Uefi启动的VPS专用(如:甲骨文)By:net.nn  用户名:Administrator  密码：nat.ee
#  27) 2008r2x64 By:net.nn  用户名:Administrator  密码：nat.ee
#  28) 2008r2x64 Uefi启动的VPS专用(如:甲骨文)By:net.nn  用户名:Administrator  密码：nat.ee
#  29) Win8.1x64 By:net.nn  用户名:Administrator  密码：nat.ee
#  30) Win8.1x64 Uefi启动的VPS专用(如:甲骨文)By:net.nn  用户名:Administrator  密码：nat.ee
#  自定义安装请使用：bash InstallNET.sh -dd '您的直连'

  cd $fder || exit
  local dd_link="https://raw.githubusercontent.com/veip007/dd/master/dd-gd.sh"
  if [ ! -e "dd-gd.sh" ]; then
    wget --no-check-certificate -O dd-gd.sh ${dd_link} && chmod +x dd-gd.sh
  fi
  ./dd-gd.sh
}

time_up() {
  if [ ! "$(command -v ntpdate)" ]; then
    $Commad install -y ntpdate
  fi
  timedatectl set-timezone 'Asia/Shanghai' && ntpdate -u pool.ntp.org && hwclock -w
  timedatectl
}

autoCdn() {
  local fileName="cloudflare.py"
#  local autoCdn_link="${lnkstls_link}/${fileName}"
    if [ ! -e $fileName ]; then
    wget --no-check-certificate $lnkstls_link
  fi
  if [ ! "$(command -v python3)" ]; then
    echo -e "${info}安装python3..."
    $Commad install -y python3
  fi
  python3 $fileName >cloudflare.log &&
    add_crontab "* * * * * python3 $(pwd)/${fileName}>$(pwd)/cloudflare.log"
}

superspeed() {
  cd $fder || exit
  superspeed_link="https://git.io/superspeed"
  wget --no-check-certificate -O superspeed.sh ${superspeed_link} && chmod +x superspeed.sh
  ./superspeed.sh
}

speedtest_install() {
  if [ "$Distributor" = "Debian" ] || [ "$Distributor" = "Ubuntu" ]; then
    apt install -y gnupg1 apt-transport-https dirmngr
    curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
    apt-get install -y speedtest && echo -e "${info}安装完成 !" && speedtest
  elif [ "$Distributor" = "CentOS" ]; then
    wget https://bintray.com/ookla/rhel/rpm -O bintray-ookla-rhel.repo
    mv bintray-ookla-rhel.repo /etc/yum.repos.d/
    yum install -y speedtest && echo -e "${info}安装完成 !" && speedtest
  else
    echo -e "${error}不受支持的系统 !" && exit 1
  fi
}

nat() {
  cd $fder || exit
  local nat_link="https://arloor.com/sh/iptablesUtils/natcfg.sh"
  if [ ! -e "nat.sh" ]; then
    wget --no-check-certificate -O nat.sh ${nat_link} && chmod +x nat.sh
  fi
  ./nat.sh
}

dnspod() {
  cd $fder || exit
  local dnspod_link="${lnkstls_link}/dnspod.sh"
  local dnspod_line_link="${lnkstls_link}/dnspod_line.sh"
  echo -e "
\033[2A
——————————————————————————————
${font_color_up}1.${font_color_end} 外网获取ip
——————————————————————————————"
  read -rep "请输入数字: " dnspod_re
  case "$dnspod_re" in
  1)
    if [ ! -e "dnspod.sh" ]; then
      wget --no-check-certificate ${dnspod_link} && chmod +x dnspod.sh
    fi
    read -rep "请输入APP_ID: " APP_ID
    read -rep "请输入APP_Token: " APP_Token
    read -rep "请输入Domain: " domain
    read -rep "请输入Host: " host
    read -rep "请输入TTL(默认600): " ttl
    ttl=${ttl:-600}
    ./dnspod.sh "$APP_ID" "$APP_Token" "$domain" "$host" "$ttl" &&
      add_crontab "* * * * * bash $(pwd)/dnspod.sh ${APP_ID} ${APP_Token} ${domain} ${host} ${ttl} >$(pwd)/dnspod.log"
    ;;
  2)
    if [ ! -e "dnspod_line.sh" ]; then
      wget --no-check-certificate -O dnspod.sh ${dnspod_line_link} && chmod +x dnspod_line.sh
    fi
    vim dnspod_line.sh
    ;;
  *)
    echo "${error}输入错误 !"
    sleep 3s
    dnspod
    ;;
  esac
}

besttrace() {
  cd $fder || exit
  if [ ! -e "besttrace" ]; then
    wget --no-check-certificate "${lnkstls_link}/besttrace" && chmod +x besttrace
  fi
  start_besttrace() {
    read -rep "IP or 域名(Ctrl+C退出): " ip
    ./besttrace -g cn "$ip"
    echo && start_besttrace
  }
  start_besttrace
}

haproxy() {
  if [ ! -e "haproxy.sh" ]; then
    wget --no-check-certificate "${lnkstls_link}/haproxy.sh" && chmod +x haproxy.sh
  fi
  ./haproxy.sh
}

network_opt() {
  if < /etc/security/limits.conf grep -Eqi "soft nofile|soft noproc "; then
    echo -e "${error}已优化limits !"
  else
    echo "*   soft noproc   65535
*   hard noproc   65535
*   soft nofile   65535
*   hard nofile   65535" >>/etc/security/limits.conf && echo -e "${info}limits设置完成 !"
  fi
  if < /etc/profile grep -Eqi "ulimit -u 65535"; then
    echo -e "${error}已优化profile !" && exit 0
  else
    echo "ulimit -u 65535
ulimit -n 65535
ulimit -d unlimited
ulimit -m unlimited
ulimit -s unlimited
ulimit -t unlimited
ulimit -v unlimited" >>/etc/profile && source /etc/profile && echo -e "${info}profile设置完成 !"
  fi
  read -rep "需要重启VPS后，才能全局生效，是否现在重启 ? [Y/n] :" yn
  [ -z "${yn}" ] && yn="y"
  if [[ $yn == [Yy] ]]; then
    echo -e "${info}重启中..."
    reboot
  fi
}

gost() {
  local gost_link="${lnkstls_link}/gost.sh"
  if [ ! -e gost.sh ]; then
    wget --no-check-certificate ${gost_link} && chmod +x gost.sh
  fi
  ./gost.sh
}

ddns_cloudflare() {
  if [ ! "$(command -v python3)" ]; then
    $Commad install -y python3
  fi
  cd $fder || exit
  local link="${lnkstls_link}/ddns_cloudflare.py"
  if [ ! -e ddns_cloudflare.py ]; then
      wget --no-check-certificate $link
  fi
  read -rep "区域id: " cid
  read -rep "邮箱: " email
  read -rep "全局密钥: " key
  read -rep "域名: " domain
  read -rep "模式(可选): " methed
#  cid=${cid:-0}
#  email=${email:-0}
#  key=${key:-0}
#  domain=${domain:-0}
  methed=${methed:-net}

  python3 ddns_cloudflare.py "$cid" "$email" "$key" "$domain" "$methed" &&
    add_crontab "* * * * * python3 $(pwd)/ddns_cloudflare.py $cid $email $key $domain $methed >$(pwd)/ddns_cloudflare.log"
}

xrayx() {
  cd ${fder} || exit
  local link="${lnkstls_link}/xrayx.py"
  if [ ! -e xrayx.py ]; then
    wget --no-check-certificate ${link} && chmod +x xrayx.sh
  fi
  #  Python环境
  if [ ! "$(command -v python3)" ]; then
    echo -e "${info}安装Python3..."
    $Commad install -y python3
  fi
  if [ ! "$(command -v pip)" ]; then
    echo -e "${info}安装Python-pip..."
    $Commad install -y python-pip
  fi
  #  pip环境
  if pip list | grep -w "PyYAML"; then
    echo -e "${info}安装Python-pip..."
    pip install PyYAML
  fi
}

start_menu() {
  clear
  echo && echo -e "Author: @Lnkstls
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end}   升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end}   bbr安装脚本
${font_color_up}2.${font_color_end}   安装Docker、Docker-compose
${font_color_up}3.${font_color_end}   poseidon脚本
${font_color_up}4.${font_color_end}   流量控制脚本
${font_color_up}5.${font_color_end}   宝塔安装脚本(py3版)
${font_color_up}6.${font_color_end}   卸载宝塔脚本
${font_color_up}7.${font_color_end}   Hotaru探针脚本
${font_color_up}8.${font_color_end}   Cloudflare筛选脚本(better-cloudflare-ip)
${font_color_up}9.${font_color_end}   一键dd系统脚本(萌咖)
${font_color_up}10.${font_color_end}  设置上海时区并对齐
${font_color_up}11.${font_color_end}  Cloudflare监测
${font_color_up}12.${font_color_end}  国内测速脚本(Superspeed)
${font_color_up}13.${font_color_end}  安装speedtest
${font_color_up}14.${font_color_end}  nat脚本
${font_color_up}15.${font_color_end}  ddns脚本(DnsPod)
${font_color_up}16.${font_color_end}  bettrace路由测试
${font_color_up}17.${font_color_end}  Haproxy脚本
${font_color_up}18.${font_color_end}  ddns_cloudflare
${font_color_up}19.${font_color_end}  Gost脚本
${font_color_up}20.${font_color_end}  Xrayx安装
——————————————————————————————
Ctrl+C 退出" && echo
  read -rep "请输入数字: " num
  case "$num" in
  0)
    update_sh
    ;;
  1)
    wget_bbr
    ;;
  2)
    install_docker
    ;;
  3)
    poseidon
    ;;
  4)
    vnstatcont
    ;;
  5)
    install_bt
    ;;
  6)
    rm_bt
    ;;
  7)
    install_hot
    ;;
  8)
    cloudflare
    ;;
  9)
    ddserver
    ;;
  10)
    time_up
    ;;
  11)
    autoCdn
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
    dnspod
    ;;
  16)
    besttrace
    ;;
  17)
    haproxy
    ;;
  18)
#    network_opt
    ddns_cloudflare
    ;;
  19)
    gost
    ;;
  20)
    xrayx
    ;;
  *)
    echo -e "${error}输入错误 !"
    sleep 3s
    start_menu
    ;;
  esac
}

ARGS=$(getopt -a -o :s:h -l source::,help -- "$@")
eval set -- "$ARGS"
for opt in "$@"; do
  case $opt in
  -s | --all)
    shift
    case $1 in
    cn)
      soucn
      ;;
    ret)
      souret
      ;;
    -- | *)
      echo -e "${error}错误参数 !" && exit 1
      ;;
    esac
    break
    ;;
  -h | --help)
    echo -e "参数列表:
  -s  --source  cn 使用腾讯云源镜像
                ret 恢复备份
  -h  --help    帮助"
    exit 1
    ;;
  esac
done

if [ ! -e "clapse.log" ]; then
  upcs
  echo "0" >clapse.log
fi
if [ ! -d "$fder" ]; then
  mkdir $fder
fi
mad=(sudo wget vim unzip curl iperf3 screen htop git)
for item in "${mad[@]}"; do
    if [ ! "$(command -v "${item}")" ]; then
      echo -e "${info}安装${item}..."
      $Commad install -y "$item"
    fi
  done

start_menu
