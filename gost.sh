#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

sh_ver="14"

font_color_up="\033[32m" && font_color_end="\033[0m" && error_color_up="\033[31m" && error_color_end="\033[0m"
info="${font_color_up}[提示]: ${font_color_end}"
error="${error_color_up}[错误]: ${error_color_end}"
note="\033[33m[警告]: \033[0m"
lnkstls_link="https://sh.clapse.com"

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

# 拉取镜像
ginuerzh_gost() {
  if (($(docker images -a | grep -Ei "ginuerzh/gost" | wc -l) == 0)); then
    echo -e "${info}拉取镜像"
    if [[ -n $num ]]; then
      if [ -e /etc/docker/deamon.json ]; then
        echo -e "${note}deamon.json文件存在 !"
      else
        read -rep "加速地址(不需要则回车): " num
        if [[ -n $num ]]; then
          echo "{\"registry-mirrors\": [\"${num}\"]}" >/etc/docker/deamon.json
          systemctl daemon-reload
          systemctl restart docker
        fi
      fi
    fi
    docker pull ginuerzh/gost
    if [[ $? != 0 ]]; then
      echo -e "${error}拉取失败 !" && exit 1
    fi
  fi

}

add_docker() {
  read -rep "端口: " name
  read -rep "操作(-L and -F): " content
  docker run -d --name="gost${name}" --net=host --log-opt max-size=10m --restart=always ginuerzh/gost:latest ${content} &&
    echo -e "${info}创建成功 !"
}

status_docker() {
  docker ps -a --no-trunc | grep ginuerzh/gost
}

delete_docker() {
  read -rep "端口: " port
  docker rm -f $(docker kill gost${port}) 1>/dev/null && echo -e "${info}删除成功 !"
}

config() {
  ginuerzh_gost
  local num
  local dcon
  local fileName="gost.config"
  local upDCon="cat gost.temp"
  # local upDCon="cat cloudflare.json"
  local dkStr="template=\"\""
  local upGCon="cat $fileName"
  local template=`$upGCon 2>/dev/null | awk -F "\"" 'NR==1 {print $2}'`
  local gostCon=`$upGCon 2>/dev/null | awk -F "=" 'NR>1 {print $1}'`
  docker ps -a --no-trunc | grep ginuerzh/gost >gost.temp

  reConfig() {
    init() {
        printf $dkStr >$fileName
    }

    delate() {
      echo -e "${info}Delate docker gost${port}"
      docker rm -f `docker kill "gost${port}"`
    }

    num=0
    for port in $($upDCon | grep -oE "\-L.*\"" | grep -oE "//:[0-9]*" | sed -e "s/\///g" -e "s/://g"); do
    let num++
        dcon=`${upDCon} | grep -oE "\".*\"" | awk -v num=$num 'NR==num {print $3}' | grep -o "//.*?" | sed -e "s/\/\///g" -e "s/?//g"`
        if [ -z "$dcon" ]; then
          dcon="NULL"
        fi
        dkStr="${dkStr}\n${port}=${dcon}"
        if [ -z `printf "$gostCon" | grep -w "$port"` ]; then
          echo -e "${info}${port} is NULL."
          case $1 in
            init) init
            ;;
            *) delate
            ;;
          esac
        fi
    done

    tempVar=`$upGCon | grep -o var | wc -l`
    num=1
    for port in $gostCon; do
      let num++
      temp=`$upGCon | awk -v num=$num -F '=' 'NR==num {print $2}'`
      if (( $tempVar == 0 )); then
        echo -e "${error}Template is NULL."
        exit 1
      elif (( $tempVar == 1 )) ;then
        temp=`echo $template | sed -e "s/var0/$port/g"` 
      elif (( $tempVar == 2 )) ;then
        temp=`echo $template | sed -e "s/var0/$port/g" -e "s/var1/$temp/g"`
      fi
      if [ -z `printf "$dkStr" | grep -w "$port"` ]; then
        echo -e "${info}${port} is NULL, UP ${port} docker...\c"
        docker run -d --name="gost${port}" --net=host --log-opt max-size=10m --restart=always ginuerzh/gost:latest $temp &&
          echo "success."
      fi
    done
    echo -e "${info}Config all updata success."
  }
  
  if [ ! -e "$fileName" ]; then
  echo -e "${info}Set gost.config..."
    if [[ `$upDCon` = *gost* ]]; then
      echo -e "${info}Docker init."
      reConfig init
    else
      echo -e "${info}Default init."
      printf $dkStr >$fileName
    fi
  else
      reConfig
  fi
  rm -f gost.temp
}

# 导出配置
exportConfig() {
if [ -f "gost.config" ]; then
    echo -e "${note}配置文件已存在是否覆盖？[Y/n]"
    read -rep "(默认Y): " yn
    [[ -z "${yn}" ]] && yn="Y"
    if [[ ${yn} == [Yy] ]]; then
      rm -f gost.config
    else
      echo && echo "${info}已取消..." && exit 0
    fi
fi


  # 导出为每3行为一组
  # 1:name
  # 2:gost -L
  # 3:gost -F
  local i
  i=`docker ps --no-trunc --format "table {{.Names}}={{.Command}}" | grep gost | sed -e "s/\/bin\/gost //" -e "s/=/ /" -e "s/\"//g"`
  for item in $i; do
    echo "${item}" >> gost.config 
  done && echo -e "${info}导出成功 gost.config"
}

# 导入配置
importConfig() {
  ginuerzh_gost
  local fileName
  fileName="gost.config"
  if [ ! -f $fileName ]; then
    echo -e "${error}gost.config 文件不存在"
    exit 1
  fi
  # awk '{print $0}' < a.ini | sed -e "s/\"//g" | grep -o "^gost[0-9]*" | 
  # 每三行为一组数据
  for((i=0;i<`expr $(wc -l <gost.config) / 3`;i++)); do
    count0=3
    count1=`expr $i \* $count0 + 1`
    var1=`sed -n "${count1}p" < $fileName`
    count2=`expr $i \* $count0 + 2`
    var2=`sed -n "${count2}p" <  $fileName`
    count3=`expr $i \* $count0 + 3`
    var3=`sed -n "${count3}p" <  $fileName`
    # echo "${count1}---${count2}---$count3"
    echo "${var1}---${var2}---$var3"
    if [ -z `docker ps --no-trunc --format "table {{.Names}}" | grep -ow ${var1}` ];then
      docker run -d --name="${var1}" --net=host --log-opt max-size=10m --restart=always ginuerzh/gost:latest ${var2} ${var3} || (echo -e "${error}创建容器失败" && exit 1)
    else
      echo -e "${note}容器${var1}已存在，是否跳过？[Y/n]"
      read -rep "(默认Y): " yn
      [[ -z "${yn}" ]] && yn="Y"
      if [[ ${yn} == [Yy] ]]; then
       echo -e "${info}跳过${var1}..."
      else
        docker rm -f `docker kill $var1` >/dev/null
        docker run -d --name="${var1}" --net=host --log-opt max-size=10m --restart=always ginuerzh/gost:latest ${var2} ${var3} || (echo -e "${error}创建容器失败" && exit 1)
      fi
    fi

  done
  
}


start_menu() {
  echo && echo -e "
当前版本: [${sh_ver}]
——————————————————————————————
${font_color_up}0.${font_color_end} 升级脚本
——————————————————————————————
${font_color_up}1.${font_color_end} 创建隧道
${font_color_up}2.${font_color_end} 查看隧道
${font_color_up}3.${font_color_end} 删除端口
——————————————————————————————
${font_color_up}4.${font_color_end} 导出配置
${font_color_up}5.${font_color_end} 导入配置
——————————————————————————————
Ctrl+C 退出" && echo
  read -rep "请输入数字: " num
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
  4)
    exportConfig
    ;;
  5)
    importConfig
    ;;
  *)
    echo -e "${error}输入错误"
    sleep 3s
    start_menu
    ;;
  esac
}

if [[ ! $(command -v docker) ]]; then
  echo -e "${error}Docker未安装 !" && exit 1
fi

# 主函数
start_menu
