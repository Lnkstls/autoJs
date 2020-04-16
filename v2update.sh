#!/bin/sh
file=(v2ray-ws) #服务名称
upcmd='docker pull'

font_color_up="\033[32m" && font_color_end="\033[0m"

start(){
    clear
    if [ ${#file[*]} -ne 0 ]; then
    docker pull v2cc/poseidon&&echo "${font_color_up}pull yes${font_color_end}" 
        for((i=0;i<${#file[*]};i++)); do
            docker restart ${file[i]}&&echo "${font_color_up}restart ${file[i]} yes${font_color_end}"
        done
    fi
}
start