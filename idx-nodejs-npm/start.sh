#!/usr/bin/env bash

if [ ! -d "node_modules" ]; then
  echo "node_modules 不存在，正在安装依赖..."
  npm install
else
  if ! npm ls --depth=0 >/dev/null 2>&1; then
    echo "检测到依赖未安装或版本不匹配，正在安装依赖..."
    npm install
  else
    echo "依赖已安装且版本匹配，跳过 npm install"
  fi
fi

# 配置环境变量
export UUID=""
export NEZHA_SERVER=""
export NEZHA_KEY=""
export ARGO_DOMAIN=""
export ARGO_AUTH=""
export CFIP="cf.090227.xyz"
export NAME="IDX"

# 启动服务
npx nodejs-argo
