# autoJs
常用脚本

## GBControl
```
apt-get -y install vnstat #安装vnstat
vnstat --iflist #网卡列表
vnstat -u -i eth0 #设置为eth0 该配置在/etc/vnstat.conf文件
service vnstat start #启动vnstat
update-rc.d vnstat enable #开机启动
python3 GBControl.py #测试系统debian
-l  # 或者 `--live` 实时流量
-h  # 显示小时流量
-d  # 显示日流量信息
-w  # 显示周流量信息
-m  # 显示月流量信息
-t  # 显示流量最高top10天
``` 

## poseidon
```
wget -O poseidon.sh  https://raw.githubusercontent.com/Lnkstls/autoJs/master/poseidon.sh && chmod +x poseidon.sh && ./poseidon.sh
或
wget -O poseidon.sh https://js.clapse.com/poseidon.sh && chmod +x poseidon.sh && ./poseidon.sh
```
**使用国内镜像**
```
wget -O poseidon.sh https://js.clapse.com/poseidon.sh && chmod +x poseidon.sh && ./poseidon.sh -s cn
```
