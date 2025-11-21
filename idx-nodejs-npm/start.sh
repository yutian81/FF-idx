#!/usr/bin/env bash

export SUB_TYPE=${SUB_TYPE:-'nodejs-argo'} # 可选 node-sbx
export UUID=${UUID:-'32f88fd1-fb7b-489f-ba09-a1c3d55f5294'}
export NEZHA_SERVER=${NEZHA_SERVER:-}
export NEZHA_KEY=${NEZHA_KEY:-}
export ARGO_DOMAIN=${ARGO_DOMAIN:-}
export ARGO_AUTH=${ARGO_AUTH:-}
export CFIP=${CFIP:-'cf.090227.xyz'}
export NAME=${NAME:-'IDX'}

# 安装依赖
if [ ! -d "node_modules" ]; then
  echo "node_modules 目录不存在，正在安装 ${SUB_TYPE}..."
  npm install "${SUB_TYPE}"
elif ! npm list "${SUB_TYPE}" --depth=0 >/dev/null 2>&1; then
  echo "检测到 ${SUB_TYPE} 未安装或版本不匹配，正在安装 ${SUB_TYPE}..."
  npm install "${SUB_TYPE}"
else
  echo "${SUB_TYPE} 依赖已安装且版本匹配，跳过 npm install"
fi

# 启动服务
npx "${SUB_TYPE}"
