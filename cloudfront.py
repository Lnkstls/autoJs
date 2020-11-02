#!/usr/bin/env python
# coding=utf-8
# python3.8 only

import threading
import requests
import sys
import os
import re
import time
import platform
import subprocess
from queue import Queue
from qqwry import QQwry
from qqwry import updateQQwry
from requests.adapters import HTTPAdapter

# pip3 install qqwry-py3 requests
ptime_reg = re.compile(r' (\d+.\d*)/(\d+.\d*)/(\d+.\d*)/(\d+.\d*)')
PING_WORK_THREAD = 500
runos = ''
session = requests.Session()
session.keep_alive = False
session.mount('https://', HTTPAdapter())
session.mount('http://', HTTPAdapter())

if not os.path.exists('result'):
		os.makedirs('result')

def UsePlatform():
    global runos
    sysstr = platform.system()
    if sysstr == "Windows":
        runos = "Windows"
    elif sysstr == "Linux":
        runos = "Linux"
    else:
        runos = "Other"


def ret_time():
    """
    :return: 输出当前时间字符串 x:x:x
    """
    time_add_fix = 0
    # return "%d:%d:%d" % (time.localtime().tm_hour
    #                      , time.localtime().tm_min, time.localtime().tm_sec)
    now_hour, now_min, now_sec = (time.strftime('%H:%M:%S', time.localtime()).split(':'))
    now_hour = int(now_hour) + time_add_fix
    if now_hour > 24:
        now_hour -= 24
    return "[%d:%s:%s] " % (now_hour, now_min, now_sec)
    # return time.strftime('%H:%M:%S', time.localtime())


# ip to num
def ip2num(ip):
    ip = [int(x) for x in ip.split('.')]
    return ip[0] << 24 | ip[1] << 16 | ip[2] << 8 | ip[3]


# num to ip
def num2ip(num):
    return '%s.%s.%s.%s' % (
        (num & 0xff000000) >> 24, (num & 0x00ff0000) >> 16, (num & 0x0000ff00) >> 8, num & 0x000000ff)


#
def ip_range(start, end):
    return [num2ip(num) for num in range(ip2num(start), ip2num(end) + 1) if num & 0xff]


#
def bThread(iplist):
    threadl = []
    queue = Queue()
    for host in iplist:
        queue.put(host)

    for x in range(0, int(SETTHREAD)):
        threadl.append(tThread(queue))

    for t in threadl:
        t.start()
    for t in threadl:
        t.join()

    # create thread


class tThread(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue

    def run(self):

        while not self.queue.empty():
            host = self.queue.get()
            try:
                checkServer(host)
            except:
                continue


def checkServer(host):
    header = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                      'Chrome/80.0.3987.163 Safari/537.36'}
    aimurl = "http://" + host + ":443"
    response = requests.get(url=aimurl, headers=header, timeout=3)
    serverText = response.headers['server']
    response.close()
    if len(serverText) > 0:
        print("-" * 60 + "\n" + ret_time() + aimurl + " Server: " + serverText)
        print("%s%s" % (ret_time(), getIpInfo(host)))
        if serverText.count('CloudFront'):
            ip_file.write(host + "\n")
            wrtIpInfo(host, serverText)


def getIpInfo(host, ret_ip=True):
    info_ret = qq_wry.lookup(host)
    if info_ret[1] != ' CZ88.NET':
        if ret_ip:
            return "%s %s %s" % (host, info_ret[0], info_ret[1])
        else:
            return "%s %s" % (info_ret[0], info_ret[1])
    else:
        if ret_ip:
            return "%s %s" % (host, info_ret[0])
        else:
            return "%s" % (info_ret[0])


def wrtIpInfo(host, servertext2):
    info_ret = qq_wry.lookup(host)
    if info_ret[1] != ' CZ88.NET':
        ip_info_file.write("%s %s %s  Server:%s\n" % (host, info_ret[0], info_ret[1], servertext2))
    else:
        ip_info_file.write("%s %s  Server:%s\n" % (host, info_ret[0], servertext2))
    return


def ping_ip():
    # if len(regex) == 0:
    #     print("%s%s UP" % (ret_time(), ip))
    #     ptime = ptime_reg.findall(result)
    #     print(ptime)
    #     time.sleep(100)
    while not IP_QUEUE_LIST.empty():
        ip = IP_QUEUE_LIST.get()
        rest = subprocess.call('/usr/bin/ping -c 1 %s' % ip, stdout=subprocess.PIPE, shell=True)
        # 打印运行结果
        if rest == 0:  # UP
            ping_out = subprocess.getoutput('/usr/bin/ping -c 15 -i 0.5 ' + ip)
            reg_out = ptime_reg.search(ping_out)
            if reg_out:
                ip_str = str(ip)
                print("%sIP:%s UP Ping-Avg:%s" % (ret_time(), ip, reg_out.group(2)))
                # ping_ip_retdic[str(ip)] = float(reg_out.group(2))
                ping_ip_retdic.setdefault(str(ip), []).append(float(reg_out.group(2)))
                ping_ip_retdic.setdefault(str(ip), []).append(str(getIpInfo(ip, ret_ip=False)))
        else:
            print("%sIP:%s DOWN" % (ret_time(), ip))
            ping_ip_retdic.setdefault(str(ip), []).append(9999)
            ping_ip_retdic.setdefault(str(ip), []).append(str(getIpInfo(ip, ret_ip=False)))


if __name__ == '__main__':
    UsePlatform()
    if runos != 'Linux':
        print('%sOnly sup Linux!  Now:%s' % (ret_time(), runos))
        sys.exit()
    print('\n############# Cloud Front Scan #################')
    print('               Author hostloc.com')
    print('################################################')
    print('Init->Update 2020.10.16 Author Ali')
    print('Init->OS: %s' % runos)
    print('Init->IP Data File exists: %s' % os.path.exists('QQway.dat'))
    if not os.path.exists('QQway.dat'):
        print("%sDownload QQwry.dat" % ret_time())
        download_ret = updateQQwry('QQway.dat')
        if int(download_ret) < 0:
            print("%sDownload QQwry.dat Error:" % ret_time(), int(download_ret))
            print("-1：下载copywrite.rar时出错\n"
                  "-2：解析copywrite.rar时出错\n"
                  "-3：下载qqwry.rar时出错\n"
                  "-4：qqwry.rar文件大小不符合copywrite.rar的数据\n"
                  "-5：解压缩qqwry.rar时出错\n"
                  "-6：保存到最终文件时出错")
            sys.exit()
        else:
            print("%sDownload QQwry.dat Success~ Status:%s" % (ret_time(), int(download_ret)))
    qq_wry = QQwry()
    qq_wry.load_file('QQway.dat')
    # Run
    print(
        'Init->IP Data: Load:%s Version:%s-%s' % (qq_wry.is_loaded(), qq_wry.get_lastone()[0], qq_wry.get_lastone()[1]))
    print('Init->Start Time: %s' % ret_time())
    print('################################################\n')
   	#sys.argv.append('*')
    #sys.argv.append('200')
    global SETTHREAD
    global ip_file
    global ip_info_file
   
    try:
        SETTHREAD = sys.argv[2]
        ip_file = open("./result/IP-%s段.txt" % sys.argv[1].split('-')[0], "w")
        ip_info_file = open("./result/IP归属地-%s段.txt" % sys.argv[1].split('-')[0], "w")
        iplist = ip_range(sys.argv[1].split('-')[0], sys.argv[1].split('-')[1])
        print("%sScan IP:%s Thread:%s" % (ret_time(), sys.argv[1], sys.argv[2]))
        print(ret_time() + 'Will scan ' + str(len(iplist)) + " host .. Sleep 1sec...\n")
        time.sleep(1)
        print(ret_time() + 'Scan...\n')
        bThread(iplist)
        print("%sStop Close file." % ret_time())
        ip_file.flush()
        ip_file.close()
        ip_info_file.flush()
        ip_info_file.close()
    except KeyboardInterrupt:
        print('%sKeyboard Interrupt!' % ret_time())
        print("%sStop Close file." % ret_time())
        ip_file.flush()
        ip_file.close()
        ip_info_file.flush()
        ip_info_file.close()
        print('Exit..')
        sys.exit()
    except IndexError:
        print('%sError Check argv!' % ret_time())
        print('Exit..')
        sys.exit()
    print("%sScan Stop." % ret_time())
    print("%sWait nf. 3sec..." % ret_time())
    time.sleep(3)
    print("%sStart. Read Ip File" % ret_time())
    # PingIp
    start_time = time.time()
    IP_QUEUE_LIST = Queue()
    ping_ip_retdic = {}
    with open("./result/IP-%s段.txt" % sys.argv[1].split('-')[0], mode="r", encoding="utf-8") as ip_file_pt:
        for ip_line in ip_file_pt:
            print("%sRead IP:%s" % (ret_time(), ip_line.strip('\n')))
            IP_QUEUE_LIST.put(ip_line.strip('\n'))
    # init done
    ping_threads = []
    for i in range(PING_WORK_THREAD):
        thread = threading.Thread(target=ping_ip)
        thread.start()
        ping_threads.append(thread)

    for thread in ping_threads:
        thread.join()

    ping_ip_retdic_sort = sorted(ping_ip_retdic.items(), key=lambda ip_item: ip_item[1][0], reverse=False)
    # print(ping_ip_retdic_sort)
    print('%sPing执行所用时间：%s' % (ret_time(), time.time() - start_time))
    with open("./result/IP-Ping-%s段.txt" % sys.argv[1].split('-')[0], "w") as ping_file:
        for ip_line in ping_ip_retdic_sort:
            ping_file.write("%s     %s    %s\n" % (ip_line[0], ip_line[1][0], ip_line[1][1]))
            print("%s Write file:%s     %s   %s" % (ret_time(), ip_line[0], ip_line[1][0], ip_line[1][1]))
    print('%sExit...' % ret_time())
    sys.exit()
