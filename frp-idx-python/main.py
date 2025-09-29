import os
import re
import json
import time
import base64
import socket
import shutil
import asyncio
import requests
import platform
import subprocess
import threading
from pathlib import Path
from threading import Thread
from http.server import BaseHTTPRequestHandler, HTTPServer

# Environment variables with defaults
UPLOAD_URL = os.environ.get('UPLOAD_URL', '')            # Subscription or node automatic upload address
PROJECT_URL = os.environ.get('PROJECT_URL', '')          # URL needed for upload subscription or keepalive
AUTO_ACCESS = os.environ.get('AUTO_ACCESS', 'false').lower() == 'true'  # False to turn off automatic keepalive, true to turn on
FILE_PATH = Path(os.environ.get('FILE_PATH', './.cache'))# Path to sub.txt subscription file
SUB_PATH = os.environ.get('SUB_PATH', 'sub')             # Subscription path, default is 'sub'
UUID = os.environ.get('UUID', 'afb07c1f-52fb-46d4-aec5-8f91fe89b27a')  # UUID for cross-platform v1 nezha
NEZHA_SERVER = os.environ.get('NEZHA_SERVER', '')        # Nezha panel address, v1 format: nz.serv00.net:8008, v0 format: nz.serv00.net
NEZHA_PORT = os.environ.get('NEZHA_PORT', '')            # Leave empty for v1 nezha, v0 agent port
NEZHA_KEY = os.environ.get('NEZHA_KEY', '')              # v1 NZ_CLIENT_SECRET or v0 agent key
ARGO_DOMAIN = os.environ.get('ARGO_DOMAIN', '')          # Argo fixed tunnel domain, leave empty for temporary tunnel
ARGO_AUTH = os.environ.get('ARGO_AUTH', '')              # Argo fixed tunnel token or json, leave empty for temporary tunnel
ARGO_PORT = int(os.environ.get('ARGO_PORT', '8001'))     # Argo fixed tunnel port
TUIC_PORT = int(os.environ.get('TUIC_PORT', '60010'))         # Tuic5 port
HY2_PORT = int(os.environ.get('HY2_PORT', '60011'))           # Hysteria2 port
REALITY_PORT = int(os.environ.get('REALITY_PORT', '60012'))   # Reality port
CFIP = os.environ.get('CFIP', 'cf.090227.xyz')         # Preferred domain or IP
CFPORT = int(os.environ.get('CFPORT', '443'))            # Preferred domain or IP port
PORT = int(os.environ.get('PORT', '8080'))               # HTTP subscription port
NAME = os.environ.get('NAME', 'IDX')                     # Node name
CHAT_ID = os.environ.get('CHAT_ID', '')                  # Telegram chat_id
BOT_TOKEN = os.environ.get('BOT_TOKEN', '')              # Telegram bot_token

FRP_IP = os.environ.get('FRP_IP', '')                    # frp 服务端共公网ip
FRP_PORT = int(os.environ.get('FRP_PORT', '7000'))       # 和frp服务端之间的通信端口，通常为7000
FRP_TOKEN = os.environ.get('FRP_TOKEN', '')              # frp服务端和客户端之间的验证token

# Global variables
private_key = ''
public_key = ''
npm_path = os.path.join(FILE_PATH, 'npm')
php_path = os.path.join(FILE_PATH, 'php')
web_path = os.path.join(FILE_PATH, 'web')
bot_path = os.path.join(FILE_PATH, 'bot')
frpc_path = os.path.join(FILE_PATH, 'frpc')
sub_path = os.path.join(FILE_PATH, 'sub.txt')
list_path = os.path.join(FILE_PATH, 'list.txt')
boot_log_path = os.path.join(FILE_PATH, 'boot.log')
config_path = os.path.join(FILE_PATH, 'config.json')

# Create running folder
def create_directory():
    if not os.path.exists(FILE_PATH):
        os.makedirs(FILE_PATH)
        print(f"{FILE_PATH} is created")
    else:
        print(f"{FILE_PATH} already exists")

# Delete nodes
def delete_nodes():
    try:
        if not UPLOAD_URL:
            return

        if not os.path.exists(sub_path):
            return

        try:
            with open(sub_path, 'r') as file:
                file_content = file.read()
        except:
            return None

        decoded = base64.b64decode(file_content).decode('utf-8')
        nodes = [line for line in decoded.split('\n') if any(protocol in line for protocol in ['vless://', 'vmess://', 'trojan://', 'hysteria2://', 'tuic://'])]

        if not nodes:
            return

        try:
            requests.post(f"{UPLOAD_URL}/api/delete-nodes", 
                          data=json.dumps({"nodes": nodes}),
                          headers={"Content-Type": "application/json"})
        except:
            return None
    except Exception as e:
        print(f"Error in delete_nodes: {e}")
        return None

# Clean up old files
def cleanup_old_files():
    paths_to_delete = ['web', 'bot', 'npm', 'frpc', 'boot.log', 'list.txt']
    for file in paths_to_delete:
        file_path = os.path.join(FILE_PATH, file)
        try:
            if os.path.exists(file_path):
                if os.path.isdir(file_path):
                    shutil.rmtree(file_path)
                else:
                    os.remove(file_path)
        except Exception as e:
            print(f"Error removing {file_path}: {e}")

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'Hello World')
            
        elif self.path == f'/{SUB_PATH}':
            try:
                with open(sub_path, 'rb') as f:
                    content = f.read()
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                self.wfile.write(content)
            except:
                self.send_response(404)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    # 禁用日志输出
    def log_message(self, format, *args):
        pass
    
def run_server():
    server = HTTPServer(('0.0.0.0', PORT), RequestHandler)
    print(f"Server is running on port {PORT}")
    server.serve_forever()
    
# Determine system architecture
def get_system_architecture():
    architecture = platform.machine().lower()
    if 'arm' in architecture or 'aarch64' in architecture:
        return 'arm'
    else:
        return 'amd'

# Download file based on architecture
def download_file(file_name, file_url):
    file_path = os.path.join(FILE_PATH, file_name)
    try:
        response = requests.get(file_url, stream=True)
        response.raise_for_status()
        
        with open(file_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        print(f"Download {file_name} successfully")
        return True
    except Exception as e:
        if os.path.exists(file_path):
            os.remove(file_path)
        print(f"Download {file_name} failed: {e}")
        return False

# Get files for architecture
def get_files_for_architecture(architecture):
    if architecture == 'arm':
        base_files = [
            {"fileName": "web", "fileUrl": "https://arm64.ssss.nyc.mn/sb"},
            {"fileName": "bot", "fileUrl": "https://arm64.ssss.nyc.mn/2go"},
            {"fileName": "frpc", "fileUrl": "https://arm64.ssss.nyc.mn/frpc"}
        ]
    else:
        base_files = [
            {"fileName": "web", "fileUrl": "https://amd64.ssss.nyc.mn/sb"},
            {"fileName": "bot", "fileUrl": "https://amd64.ssss.nyc.mn/2go"},
            {"fileName": "frpc", "fileUrl": "https://amd64.ssss.nyc.mn/frpc"}
        ]

    if NEZHA_SERVER and NEZHA_KEY:
        if NEZHA_PORT:
            npm_url = "https://arm64.ssss.nyc.mn/agent" if architecture == 'arm' else "https://amd64.ssss.nyc.mn/agent"
            base_files.insert(0, {"fileName": "npm", "fileUrl": npm_url})
        else:
            php_url = "https://arm64.ssss.nyc.mn/v1" if architecture == 'arm' else "https://amd64.ssss.nyc.mn/v1"
            base_files.insert(0, {"fileName": "php", "fileUrl": php_url})

    return base_files

# Authorize files with execute permission
def authorize_files(file_paths):
    for file_name in file_paths:
        absolute_file_path = os.path.join(FILE_PATH, file_name)
        if os.path.exists(absolute_file_path):
            try:
                os.chmod(absolute_file_path, 0o755)
                print(f"Empowerment success for {absolute_file_path}: 755")
            except Exception as e:
                print(f"Empowerment failed for {absolute_file_path}: {e}")

# Configure Argo tunnel
def argo_type():
    if not ARGO_AUTH or not ARGO_DOMAIN:
        print("ARGO_DOMAIN or ARGO_AUTH variable is empty, use quick tunnels")
        return

    if "TunnelSecret" in ARGO_AUTH:
        with open(os.path.join(FILE_PATH, 'tunnel.json'), 'w') as f:
            f.write(ARGO_AUTH)
        
        tunnel_id = ARGO_AUTH.split('"')[11]
        tunnel_yml = f"""
tunnel: {tunnel_id}
credentials-file: {os.path.join(FILE_PATH, 'tunnel.json')}
protocol: http2

ingress:
  - hostname: {ARGO_DOMAIN}
    service: http://localhost:{ARGO_PORT}
    originRequest:
      noTLSVerify: true
  - service: http_status:404
"""
        with open(os.path.join(FILE_PATH, 'tunnel.yml'), 'w') as f:
            f.write(tunnel_yml)
    else:
        print("ARGO_AUTH mismatch TunnelSecret, use token connect to tunnel")

# Execute shell command and return output
def exec_cmd(command):
    try:
        process = subprocess.Popen(
            command, 
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        stdout, stderr = process.communicate()
        return stdout + stderr
    except Exception as e:
        print(f"Error executing command: {e}")
        return str(e)

# Upload nodes to subscription service
def upload_nodes():
    if UPLOAD_URL and PROJECT_URL:
        subscription_url = f"{PROJECT_URL}/{SUB_PATH}"
        json_data = {
            "subscription": [subscription_url]
        }
        
        try:
            response = requests.post(
                f"{UPLOAD_URL}/api/add-subscriptions",
                json=json_data,
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                print('Subscription uploaded successfully')
        except Exception as e:
            pass
    
    elif UPLOAD_URL:
        if not os.path.exists(list_path):
            return
        
        with open(list_path, 'r') as f:
            content = f.read()
        
        nodes = [line for line in content.split('\n') if any(protocol in line for protocol in ['vless://', 'vmess://', 'trojan://', 'hysteria2://', 'tuic://'])]
        
        if not nodes:
            return
        
        json_data = json.dumps({"nodes": nodes})
        
        try:
            response = requests.post(
                f"{UPLOAD_URL}/api/add-nodes",
                data=json_data,
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                print('Nodes uploaded successfully')
        except:
            return None
    else:
        return

# Add automatic access task
def add_visit_task():
    if not AUTO_ACCESS or not PROJECT_URL:
        print("Skipping adding automatic access task")
        return
    
    try:
        response = requests.post(
            'https://keep.gvrander.eu.org/add-url',
            json={"url": PROJECT_URL},
            headers={"Content-Type": "application/json"}
        )
        print('automatic access task added successfully')
    except Exception as e:
        print(f'Failed to add URL: {e}')

# Clean up files after 90 seconds
def clean_files():
    def _cleanup():
        time.sleep(90)  # Wait 90 seconds
        files_to_delete = [boot_log_path, frpc_path, config_path, list_path, web_path, bot_path, php_path, npm_path]
        
        if NEZHA_PORT:
            files_to_delete.append(npm_path)
        elif NEZHA_SERVER and NEZHA_KEY:
            files_to_delete.append(php_path)
        
        for file in files_to_delete:
            try:
                if os.path.exists(file):
                    if os.path.isdir(file):
                        shutil.rmtree(file)
                    else:
                        os.remove(file)
            except:
                pass
        
        print('\033c', end='')  # Clear console
        print('App is running')
        print('Thank you for using this script, enjoy!')
    
    threading.Thread(target=_cleanup, daemon=True).start()


# Download and run necessary files
async def download_files_and_run():
    global private_key, public_key

    HOSTNAME = socket.gethostname()

    architecture = get_system_architecture()
    files_to_download = get_files_for_architecture(architecture)
    
    if not files_to_download:
        print("Can't find a file for the current architecture")
        return
    
    # Download all files
    download_success = True
    for file_info in files_to_download:
        if not download_file(file_info["fileName"], file_info["fileUrl"]):
            download_success = False
    
    if not download_success:
        print("Error downloading files")
        return
    
    # Authorize files
    files_to_authorize = ['npm', 'web', 'bot', 'frpc'] if NEZHA_PORT else ['php', 'web', 'bot', 'frpc']
    authorize_files(files_to_authorize)
    
    # Check TLS
    port = NEZHA_SERVER.split(":")[-1] if ":" in NEZHA_SERVER else ""
    if port in ["443", "8443", "2096", "2087", "2083", "2053"]:
        nezha_tls = "true"
    else:
        nezha_tls = "false"

    # Configure nezha
    if NEZHA_SERVER and NEZHA_KEY:
        if not NEZHA_PORT:
            # Generate config.yaml for v1
            config_yaml = f"""
client_secret: {NEZHA_KEY}
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
disable_nat: false
disable_send_query: false
gpu: false
insecure_tls: false
ip_report_period: 1800
report_delay: 1
server: {NEZHA_SERVER}
skip_connection_count: false
skip_procs_count: false
temperature: false
tls: {nezha_tls}
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: {UUID}"""
            
            with open(os.path.join(FILE_PATH, 'config.yaml'), 'w') as f:
                f.write(config_yaml)

    if HY2_PORT or REALITY_PORT or TUIC_PORT:
            config_toml = f"""
serverAddr = "{FRP_IP}"
serverPort = {FRP_PORT}
loginFailExit = false

auth.method = "token"
auth.token = "{FRP_TOKEN}"

transport.heartbeatInterval = 10
transport.heartbeatTimeout = 30
transport.dialServerKeepalive = 10
transport.dialServerTimeout = 30
transport.tcpMuxKeepaliveInterval = 10
transport.poolCount = 5

[[proxies]]
name = "{HOSTNAME}-hy2"
type = "udp"
localIP = "127.0.0.1"
localPort = {HY2_PORT}
remotePort = {HY2_PORT}

[[proxies]]
name = "{HOSTNAME}-tuic"
type = "udp"
localIP = "127.0.0.1"
localPort = {TUIC_PORT}
remotePort = {TUIC_PORT}

[[proxies]]
name = "{HOSTNAME}-reality"
type = "tcp"
localIP = "127.0.0.1"
localPort = {REALITY_PORT}
remotePort = {REALITY_PORT}"""
            
            with open(os.path.join(FILE_PATH, 'frpc.toml'), 'w') as f:
                f.write(config_toml)

    # Generate reality-keypair
    key_file_path = os.path.join(FILE_PATH, 'key.txt')

    if os.path.exists(key_file_path):
        with open(key_file_path, 'r') as f:
            content = f.read()
            private_key_match = re.search(r'PrivateKey:\s*(.*)', content)
            public_key_match = re.search(r'PublicKey:\s*(.*)', content)
    else:
        # Generate reality-keypair
        keypair_output = exec_cmd(f"{os.path.join(FILE_PATH, 'web')} generate reality-keypair")

        # Try to extract keys from command output
        private_key_match = re.search(r'PrivateKey:\s*(.*)', keypair_output)
        public_key_match = re.search(r'PublicKey:\s*(.*)', keypair_output)

        # Save to key.txt if successfully extracted
        if private_key_match and public_key_match:
            with open(key_file_path, 'w') as f:
                f.write(f"PrivateKey: {private_key_match.group(1)}\n")
                f.write(f"PublicKey: {public_key_match.group(1)}\n")

    if private_key_match and public_key_match:
        private_key = private_key_match.group(1)
        public_key = public_key_match.group(1)
        print(f'Private Key: {private_key}')
        print(f'Public Key: {public_key}')
    else:
        print('Failed to extract privateKey or publicKey.')
    
    # Generate private.key
    exec_cmd('openssl ecparam -genkey -name prime256v1 -out "private.key"')
    
    # Generate cert.pem
    exec_cmd('openssl req -new -x509 -days 3650 -key "private.key" -out "cert.pem" -subj "/CN=bing.com"')
    
    # Generate configuration file
    config = {
        "log": {
            "disabled": True,
            "level": "info",
            "timestamp": True
        },
        "dns": {
            "servers": [
                {
                    "address": "8.8.8.8",
                    "address_resolver": "local"
                },
                {
                    "tag": "local",
                    "address": "local"
                }
            ]
        },
        "inbounds": [
            {
                "tag": "vmess-ws-in",
                "type": "vmess",
                "listen": "::",
                "listen_port": ARGO_PORT,
                "users": [
                    {
                        "uuid": UUID
                    }
                ],
                "transport": {
                    "type": "ws",
                    "path": "/vmess-argo",
                    "early_data_header_name": "Sec-WebSocket-Protocol"
                }
            },
            {
                "tag": "vless-in",
                "type": "vless",
                "listen": "::",
                "listen_port": REALITY_PORT,
                "users": [
                    {
                        "uuid": UUID,
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "tls": {
                    "enabled": True,
                    "server_name": "www.iij.ad.jp",
                    "reality": {
                        "enabled": True,
                        "handshake": {
                            "server": "www.iij.ad.jp",
                            "server_port": 443
                        },
                        "private_key": private_key,
                        "short_id": [""]
                    }
                }
            },
            {
                "tag": "hysteria-in",
                "type": "hysteria2",
                "listen": "::",
                "listen_port": HY2_PORT,
                "users": [
                    {
                        "password": UUID
                    }
                ],
                "masquerade": "https://bing.com",
                "tls": {
                    "enabled": True,
                    "alpn": ["h3"],
                    "certificate_path": "cert.pem",
                    "key_path": "private.key"
                }
            },
            {
                "tag": "tuic-in",
                "type": "tuic",
                "listen": "::",
                "listen_port": TUIC_PORT,
                "users": [
                    {
                        "uuid": UUID
                    }
                ],
                "congestion_control": "bbr",
                "tls": {
                    "enabled": True,
                    "alpn": ["h3"],
                    "certificate_path": "cert.pem",
                    "key_path": "private.key"
                }
            }
        ],
        "outbounds": [
            {
                "type": "direct",
                "tag": "direct"
            },
            {
                "type": "block",
                "tag": "block"
            },
            {
                "type": "wireguard",
                "tag": "wireguard-out",
                "server": "162.159.195.100",
                "server_port": 4500,
                "local_address": [
                    "172.16.0.2/32",
                    "2606:4700:110:83c7:b31f:5858:b3a8:c6b1/128"
                ],
                "private_key": "mPZo+V9qlrMGCZ7+E6z2NI6NOV34PD++TpAR09PtCWI=",
                "peer_public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                "reserved": [26, 21, 228]
            }
        ],
        "route": {
            "rule_set": [
                {
                    "tag": "netflix",
                    "type": "remote",
                    "format": "binary",
                    "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-netflix.srs",
                    "download_detour": "direct"
                },
                {
                    "tag": "openai",
                    "type": "remote",
                    "format": "binary",
                    "url": "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/openai.srs",
                    "download_detour": "direct"
                }
            ],
            "rules": [
                {
                    "rule_set": ["openai", "netflix"],
                    "outbound": "wireguard-out"
                }
            ],
            "final": "direct"
        }
    }
    
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)

    if HY2_PORT or REALITY_PORT or TUIC_PORT:
        command = f"nohup {os.path.join(FILE_PATH, 'frpc')} -c {os.path.join(FILE_PATH, 'frpc.toml')} >/dev/null 2>&1 &" 
        
        try:
            exec_cmd(command)
            print('frpc is running')
            time.sleep(2)
        except Exception as e:
            print(f"frpc running error: {e}")

    # Run nezha
    if NEZHA_SERVER and NEZHA_PORT and NEZHA_KEY:
        tls_ports = ['443', '8443', '2096', '2087', '2083', '2053']
        nezha_tls = '--tls' if NEZHA_PORT in tls_ports else ''
        command = f"nohup {os.path.join(FILE_PATH, 'npm')} -s {NEZHA_SERVER}:{NEZHA_PORT} -p {NEZHA_KEY} {nezha_tls} >/dev/null 2>&1 &"
        
        try:
            exec_cmd(command)
            print('npm is running')
            time.sleep(1)
        except Exception as e:
            print(f"npm running error: {e}")
    
    elif NEZHA_SERVER and NEZHA_KEY:
        # Run V1
        command = f"nohup {FILE_PATH}/php -c \"{FILE_PATH}/config.yaml\" >/dev/null 2>&1 &"
        try:
            exec_cmd(command)
            print('php is running')
            time.sleep(1)
        except Exception as e:
            print(f"php running error: {e}")
    else:
        print('NEZHA variable is empty, skipping running')
    
    # Run sbX
    command = f"nohup {os.path.join(FILE_PATH, 'web')} run -c {os.path.join(FILE_PATH, 'config.json')} >/dev/null 2>&1 &"
    try:
        exec_cmd(command)
        print('web is running')
        time.sleep(1)
    except Exception as e:
        print(f"web running error: {e}")
    
    # Run cloudflared
    if os.path.exists(os.path.join(FILE_PATH, 'bot')):
        if re.match(r'^[A-Z0-9a-z=]{120,250}$', ARGO_AUTH):
            args = f"tunnel --edge-ip-version auto --no-autoupdate --protocol http2 run --token {ARGO_AUTH}"
        elif "TunnelSecret" in ARGO_AUTH:
            args = f"tunnel --edge-ip-version auto --config {os.path.join(FILE_PATH, 'tunnel.yml')} run"
        else:
            args = f"tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile {os.path.join(FILE_PATH, 'boot.log')} --loglevel info --url http://localhost:{ARGO_PORT}"
        
        try:
            exec_cmd(f"nohup {os.path.join(FILE_PATH, 'bot')} {args} >/dev/null 2>&1 &")
            print('bot is running')
            time.sleep(2)
        except Exception as e:
            print(f"Error executing command: {e}")
    
    time.sleep(5)
    
    # Extract domains and generate sub.txt
    await extract_domains()

# Extract domains from cloudflared logs
async def extract_domains():
    argo_domain = None

    if ARGO_AUTH and ARGO_DOMAIN:
        argo_domain = ARGO_DOMAIN
        print(f'ARGO_DOMAIN: {argo_domain}')
        await generate_links(argo_domain)
    else:
        try:
            with open(boot_log_path, 'r') as f:
                file_content = f.read()
            
            lines = file_content.split('\n')
            argo_domains = []
            
            for line in lines:
                domain_match = re.search(r'https?://([^ ]*trycloudflare\.com)/?', line)
                if domain_match:
                    domain = domain_match.group(1)
                    argo_domains.append(domain)
            
            if argo_domains:
                argo_domain = argo_domains[0]
                print(f'ArgoDomain: {argo_domain}')
                await generate_links(argo_domain)
            else:
                print('ArgoDomain not found, re-running bot to obtain ArgoDomain')
                # Remove boot.log and restart bot
                if os.path.exists(boot_log_path):
                    os.remove(boot_log_path)
                
                try:
                    exec_cmd('pkill -f "[b]ot" > /dev/null 2>&1')
                except:
                    pass
                
                time.sleep(1)
                args = f'tunnel --edge-ip-version auto --no-autoupdate --protocol http2 --logfile {FILE_PATH}/boot.log --loglevel info --url http://localhost:{ARGO_PORT}'
                exec_cmd(f'nohup {os.path.join(FILE_PATH, "bot")} {args} >/dev/null 2>&1 &')
                print('bot is running.')
                time.sleep(6)  # Wait 6 seconds
                await extract_domains()  # Try again
        except Exception as e:
            print(f'Error reading boot.log: {e}')
            
# Send notification to Telegram
def send_telegram():
    if not BOT_TOKEN or not CHAT_ID:
        # print("Telegram bot token or chat ID is empty. Skip pushing nodes to TG")
        return

    try:
        with open(FILE_PATH / 'sub.txt', 'r', encoding='utf-8') as file:
            message = file.read().strip()

        formatted_message = f"*{NAME}节点推送通知*\n```\n{message}\n```"

        url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
        params = {
            "chat_id": CHAT_ID,
            "text": formatted_message,
            "parse_mode": "Markdown" 
        }

        response = requests.post(url, params=params)

        if response.status_code == 200:
            print("Telegram message sent successfully")
        else:
            print(f"Failed to send Telegram message. Status code: {response.status_code}, response: {response.text}")
    except Exception as e:
        print(f"Failed to send Telegram message: {e}")

# Generate links and subscription content
async def generate_links(argo_domain):
    # Get ISP info
    try:
        meta_info = subprocess.check_output(
            'curl -s https://speed.cloudflare.com/meta | awk -F\\" \'{print $26"-"$18}\' | sed -e \'s/ /_/g\'',
            shell=True
        ).decode().strip()
        ISP = meta_info
    except:
        ISP = "Unknown"

    # Wait 2 seconds before generating nodes
    time.sleep(2)

    # Generate vmess node
    vmess_config = {
        "v": "2",
        "ps": f"{NAME}-{ISP}",
        "add": CFIP,
        "port": CFPORT,
        "id": UUID,
        "aid": "0",
        "scy": "none",
        "net": "ws",
        "type": "none",
        "host": argo_domain,
        "path": "/vmess-argo?ed=2560",
        "tls": "tls",
        "sni": argo_domain,
        "alpn": "",
        "fp": "chrome"
    }
    vmess_node = f"vmess://{base64.b64encode(json.dumps(vmess_config).encode()).decode()}"

    sub_txt = vmess_node  # Always generate vmess node

    # Generate other nodes based on port
    if TUIC_PORT:  
        tuic_node = f"\ntuic://{UUID}:@{FRP_IP}:{TUIC_PORT}?sni=www.bing.com&congestion_control=bbr&udp_relay_mode=native&alpn=h3&allow_insecure=1#{NAME}-{ISP}"
        sub_txt += tuic_node

    if HY2_PORT:  
        hysteria_node = f"\nhysteria2://{UUID}@{FRP_IP}:{HY2_PORT}/?sni=www.bing.com&insecure=1&alpn=h3&obfs=none#{NAME}-{ISP}"
        sub_txt += hysteria_node

    if REALITY_PORT:  
        vless_node = f"\nvless://{UUID}@{FRP_IP}:{REALITY_PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.iij.ad.jp&fp=chrome&pbk={public_key}&type=tcp&headerType=none#{NAME}-{ISP}"
        sub_txt += vless_node

    # Save to files
    with open(sub_path, 'w') as f:
        f.write(base64.b64encode(sub_txt.encode()).decode())
    
    with open(list_path, 'w') as f:
        f.write(sub_txt)
    
    print(f"{FILE_PATH}/sub.txt saved successfully")
    print(base64.b64encode(sub_txt.encode()).decode())
    
    # Additional actions
    send_telegram()
    upload_nodes()
  
    return sub_txt   
    
# Main function to start the server
async def start_server():
    delete_nodes()
    cleanup_old_files()
    create_directory()
    argo_type()
    await download_files_and_run()
    add_visit_task()
    clean_files()

def run_async():
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(start_server())
    
    while True:
        time.sleep(3600)

if __name__ == "__main__":
    server_thread = Thread(target=run_server)
    server_thread.daemon = True
    server_thread.start()
 

    run_async()
