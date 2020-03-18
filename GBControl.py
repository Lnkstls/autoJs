
import os
limit_total = 0  # limit_total 上传+下载的流量限制，单位GB，如果不限制就是0，如果限制1T就是1024
limit_in = 0  # limit_in 下载的流量限制，单位GB，如果不限制就是0，如果限制1T就是1024
limit_out = 0  # limit_out 上传的流量限制，单位GB，如果不限制就是0，如果限制1T就是1024


NET_IN = 0
NET_OUT = 0

vnstat = os.popen('vnstat --dumpdb').readlines()
for line in vnstat:
    if line[0:4] == "m;0;":
        mdata = line.split(";")
        NET_IN = int(mdata[3])/1024
        NET_OUT = int(mdata[4])/1024

killssr = "systemctl stop docker || echo '已关闭docker'"
if (limit_total != 0 and (NET_IN+NET_OUT) >= limit_total):
    os.system(killssr)
elif (limit_in != 0 and NET_IN >= limit_in):
    os.system(killssr)
elif (limit_out != 0 and NET_OUT >= limit_out):
    os.system(killssr)

print("NET_IN=", NET_IN, "---NET_OUT=", NET_OUT, "---total=", NET_IN+NET_OUT)
