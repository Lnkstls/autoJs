# autoJs
常用脚本

## 流量控制
- [GBControl](https://github.com/LnksGit/autoJs/blob/master/GBControl.py)
```
apt-get -y install vnstat #安装vnstat
vnstat --iflist #网卡列表
vnstat -u -i eth0 #设置为eth0
service vnstat start #启动vnstat
vi /etc/rc.local
写入 service vnstat start #开机启动
python3 GBControl.py
``` 
