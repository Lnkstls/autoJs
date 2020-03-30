#! /usr/bin/env python3

import os
import time
limit_total = 0  # limit_total 上传+下载的流量限制，单位GB，如果不限制就是0，如果限制1T就是1024
limit_in = 0  # limit_in 下载的流量限制，单位GB，如果不限制就是0，如果限制1T就是1024
limit_out = 0  # limit_out 上传的流量限制，单位GB，如果不限制就是0，如果限制1T就是1024
limit_rema = 1  # unit GB 剩余流量限制
logsPwd = "/www/autoJs/GBControl.logs" #日志目录
killssr = "halt" #shell命令

NET_IN = 0
NET_OUT = 0

vnstat = os.popen('vnstat --dumpdb').readlines()
for line in vnstat:
    if line[0:4] == "m;0;":
        mdata = line.split(";")
        NET_IN = int(mdata[3])/1024
        NET_OUT = int(mdata[4])/1024


if (limit_total != 0 and (NET_IN+NET_OUT) >= (limit_total-limit_rema)):
    os.system(killssr)
elif (limit_in != 0 and NET_IN >= (limit_in-limit_rema)):
    os.system(killssr)
elif (limit_out != 0 and NET_OUT >= (limit_out-limit_rema)):
    os.system(killssr)


print("NET_IN=", NET_IN, "---NET_OUT=", NET_OUT, "---total=", NET_IN+NET_OUT)
print("rema=", limit_rema, end="，")
if (limit_total != 0):
    print("total=", limit_total)
elif (limit_in != 0):
    print("in=", limit_in)
elif (limit_out != 0):
    print("out=", limit_out)
else:
    print("limit=null")

print("logsPwd=", logsPwd)

# logs
def setContent(content, file):
    # self.file=file if file!=None else None
    # self.file=file if file!='' else print(False)
    with open(file, 'a', encoding='utf-8') as f:
        return f.write(content+"\n")
def setStr(var):
    return str(var)
# +NET_IN+"---NET_OUT="+NET_OUT+"---total="+NET_IN+NET_OUT
localTime = time.strftime("%m-%d %H:%m", time.localtime()) 
content = "["+setStr(localTime)+"]"+"NET_IN="+setStr(NET_IN)+"---NET_OUT="+setStr(NET_OUT)+"---total="+setStr(NET_IN+NET_OUT)
setContent(content, logsPwd)