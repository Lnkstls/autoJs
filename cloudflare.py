import os
import json
import socket

info, error, note = "\033[1;32m[info]: \033[0m", "\033[1;31m[error]: \033[0m", "\033[33m[note]: \033[0m"
os.system('date')

def pullFile(file):
    with open(file, 'r') as f:
        return f.read()


def pushFile(file, cont):
    with open(file, 'w') as f:
        f.write(cont)

def nowIp(domain):
  return socket.gethostbyname(domain)

def handle(formatIp, domain, port):
  nip = nowIp(domain)
  if formatIp == nip:
    print('%sNo updata required, NowIP: %s' %(info, nip))
  else:
    for i in port:
      print('%sReboot gost%s start...' %(info, i), end='')
      zcmd = os.system('docker restart gost' + str(i))
      if zcmd == 0:
        print('success')
      else:
        print('%dReboot gost%s Error' %(error, i))
        exit(1)
    print('%sIP updata to %s' %(info, nip))
    x['formatIp'] = nip
    pushFile(path, json.dumps(x))
    # print(x)
  # print(locals())

# if root
if os.getuid() != 0:
  print('%sPermission denied' %(error))
  exit(1)

def zMain():
  global x 
  x = json.loads(pullFile(path))
  formatIp, domain, port = x['formatIp'], x['domain'], x['port']
  try:
    if domain == '':
      print('%sConfig error !' %(error))
    else:
      handle(formatIp, domain, port)
  except KeyError:
    print('%sLoading config error !' %(error))

# init file
path = os.getcwd() + "/cloudflare.config"
if os.path.exists(path):
  zMain()
else:
  print("%sInit config..." %(info))
  cont = {
    'formatIp': '0.0.0.0',
    'domain': '',
    'port': []
  }
  pushFile(path, json.dumps(cont))
  zMain()
