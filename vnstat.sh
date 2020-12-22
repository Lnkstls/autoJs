#! /usr/bin/env bash
# Author: @Lnkstls

TIME=00     # 重置时间
GB=1024     # 流量GB
Range=0 # 0=所有, 1=TX, 2=RX

if (($# != 0)); then
  TIME=$1
  GB=$2
  Range=$3
fi

let GB--
TX=$(vnstat --dumpdb | grep "m;0;" | awk -F ";" '{print $4}')
RX=$(vnstat --dumpdb | grep "m;0;" | awk -F ";" '{print $5}')
if [[ $time != 00 ]]; then
  if [[ $(date +%d%H%M) == "${TIME}0000" ]]; then
    vnstat --delete --force -i $eth &&
      vnstat --create -i $eth
  fi
  let TX+=$(vnstat --dumpdb | grep "m;1;" | awk -F ";" '{print $4}')
  let RX+=$(vnstat --dumpdb | grep "m;1;" | awk -F ";" '{print $5}')
fi
let ALL=${TX}+${RX}
let ALL/=1024
let TX/=1024
let RX/=1024

echo "$(date)
TIME=${TIME}
GB=${GB}
Range=${Range}
TX=${TX}
RX=${RX}
ALL=${ALL}"

case $Range in
0)
  if (($ALL >= $GB)); then
    shutdown -h now
  fi
  ;;
1)
  if (($TX >= $GB)); then
    shutdown -h now
  fi
  ;;
2)
  if (($RX >= $GB)); then
    shutdown -h now
  fi
  ;;
esac
