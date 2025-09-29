#!/bin/bash

# 哪吒和uuid配置
export UUID="30d13193-1514-4d00-8502-f5731434fab0"  # uuid，部署多个时且同时配置了哪吒v1需要修改，否则哪吒会被覆盖
export NEZHA_SERVER="sos.de5.net:8008"          # 哪吒面板域名 v1填写形式：nezha.xxx.com:8008   v0填写形式：nezha.xxx.com
export NEZHA_PORT=""            # v1哪吒不要填写这个，v0哪吒agnet端口,端口为{443，8443，2096，2087，2083, 2053}之一时开启tls                          
export NEZHA_KEY="811118abcd"             # v1哪吒的NZ_CLIENT_SECRET或v0哪吒agnet密钥

# Argo 隧道配置
export ARGO_DOMAIN="idx-tw.yyy.us.kg"           # Argo域名，留空即启用临时隧道
export ARGO_AUTH="eyJhIjoiOTg1ZDYwN2YyYWU5NjlkNmVjMjZlZTlhMTY4M2Q1OGYiLCJ0IjoiYzdlMGQ0ODctYjJlZC00NzVkLWE2ZmItZjFiYzRlY2Q3MDE1IiwicyI6IlpqYzJORGhsTWpRdFlXVmpaaTAwWWpNekxUaGxNemN0WTJFd1l6ZGlOMlptTkdaaSJ9"             # Argo Token或json，留空即启用临时隧道

# 其他配置
export NAME="IDX"              # 节点名称
export CFIP="cf.090227.xyz"  # 优选IP或优选域名
export CFPORT=443              # 优选IP或优选域名对应端口
export CHAT_ID=""              # tg chat id
export BOT_TOKEN=""            # tg bot token 需要同时填写chat id才会推送节点到tg
export UPLOAD_URL=             # 节点自动推送到订阅器，需要填写部署merge-sub项目后的首页地址，例如：https://merge.eooce.ggff.net

bash <(curl -Ls https://main.ssss.nyc.mn/sb.sh)