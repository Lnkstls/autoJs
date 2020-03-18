# autoJs
常用脚本

## 流量控制
- GBControl
```
apt-get -y install vnstat #安装vnstat
vnstat --iflist #网卡列表
vnstat -u -i eth0 #设置为eth0
service vnstat start #启动vnstat
python3 GBControl.py
``` 
