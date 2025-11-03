#!/usr/bin/env bash

TARGET_MODULE="nodejs-argo"

# 安装依赖
if [ ! -d "node_modules" ]; then
  echo "node_modules 目录不存在，正在安装 ${TARGET_MODULE}..."
  npm install "${TARGET_MODULE}"
elif ! npm list "${TARGET_MODULE}" --depth=0 >/dev/null 2>&1; then
  echo "检测到 ${TARGET_MODULE} 未安装或版本不匹配，正在安装 ${TARGET_MODULE}..."
  npm install "${TARGET_MODULE}"
else
  echo "${TARGET_MODULE} 依赖已安装且版本匹配，跳过 npm install"
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
npx "${TARGET_MODULE}"
