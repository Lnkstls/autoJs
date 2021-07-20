import http.client
import json
import socket
import sys
import time


print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))

class HttpNet:
    __HOST = "api.cloudflare.com"
    __url = "/client/v4/zones/"
    _result = {}

    def __init__(self, reg_id: str = '', email: str = '', key: str = ''):
        '''

        :param reg_id: 区域id
        :param email: 邮箱
        :param key: 全局Key
        '''
        self.__reg_id = reg_id
        self.__email = email
        self.__key = key
        self.__url = self.__url + reg_id
        self.__header = {
            "Content-Type": "application/json",
            "X-Auth-Email": email,
            "X-Auth-Key": key
        }

    def get_dnsrecords(self) -> dict:
        # print(self.__cloudflare, self.__reg_id)
        var = http.client.HTTPSConnection(self.__HOST)
        var.request('GET', self.__url + '/dns_records', headers=self.__header)
        var = var.getresponse()
        if self._result == {}:
            if var.status == 200:
                var = var.read()
                self._result = json.loads(str(var, encoding='utf-8'))
                return self._result
            else:
                print('Cloudflare api超时!')
                sys.exit(1)
        else:
            return self._result

    def get_dnsip(self, obj: object, name: str) -> str:
        for s in obj['result']:
            if s['name'] == name:
                return s['content']
        print('未读取到域名!')
        sys.exit(1)

    def get_dnsid(self, obj: object, name: str) -> str:
        for s in obj['result']:
            if s['name'] == name:
                return s['id']
        print('未读取到ip id!')
        sys.exit(1)

    def patch_dnsip(self, cid: str, name: str, ip: str):
        var = http.client.HTTPSConnection(self.__HOST)
        var.request('PATCH', self.__url + '/dns_records/' + cid,
                    body=json.dumps({"type": "A", "name": name, "content": ip, "ttl": 1, "proxied": False}),
                    headers=self.__header)
        var = var.getresponse().read()
        return json.loads(str(var, encoding='utf-8'))


class LoadNet:
    _load_ip, _net_ip = '', ''

    def __init__(self):
        pass

    def get_dns_ip(self, domain: str) -> str:
        return socket.gethostbyname(domain)

    def get_load_ip(self) -> str:
        if self._load_ip == '':
            self._load_ip = socket.gethostbyname(socket.gethostname())
            return self._load_ip
        else:
            return self._load_ip

    def get_net_ip(self, method: int = 0) -> str:
        if method == 0:
            var = http.client.HTTPConnection('ip.03k.org')
            var.request('GET', '/')
            var = var.getresponse().read()
            return str(var, encoding='utf-8')

if len(sys.argv) < 6:
    print('参数错误! 参数: 区域id, 邮箱, 全局密钥, 域名, 模式')
    sys.exit(1)


cid, email, key, domain, method = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
# print(cid, email, key, domain, method)

http_obj = HttpNet(cid, email, key)
load_obj = LoadNet()
dns_ip = load_obj.get_dns_ip(domain)
print('dns ip: %s' % dns_ip)


def start_ip(ip):
    if dns_ip == ip:
        print('dns解析ip相同!')
        sys.exit(0)
    else:
        domain_list = http_obj.get_dnsrecords()
        bef_ip = http_obj.get_dnsip(domain_list, domain)
        print('Cloudflare ip: %s' % bef_ip)
        if bef_ip == ip:
            print('Cloudflare ip相同!')
            sys.exit(1)

        patch_p = http_obj.patch_dnsip(http_obj.get_dnsid(domain_list, domain), domain, ip)
        print(patch_p)

if sys.argv[5] == 'load':
    now_ip = load_obj.get_load_ip()
    print('本地ip: %s' % now_ip)
    start_ip(now_ip)
elif sys.argv[5] == 'net':
    net_ip = load_obj.get_net_ip()
    print('网络ip: %s' % net_ip)
    start_ip(net_ip)
else:
    print('参数错误! 模式错误!')
    sys.exit(1)








# test = HttpNet('9549fe1184b6b881054e479b2685a75e', '2378977735@qq.com', '838e5586ed75e6c7bb3cffc70c6c27dd4483f')
# p = test.getDnsId(test.getDnsRecords(), 'test.aiv2.top')
# z = test.getDnsRecords('/dns_records/ffd54a2876216e49b6e1044fdeaf4de5')

# p = test.patch_dnsip(test.get_dnsid(test.get_dnsrecords(), 'test.aiv2.top'), 'test.aiv2.top', '127.0.0.3')
# test1 = LoadNet()
# p = test1.get_load_ip()
# print(p)
# print(z)
