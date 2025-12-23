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

# 修改 IDX 配置文件
FILE=".idx/dev.nix"

if [ -f "$FILE" ]; then
    echo "检测到 $FILE，正在优化配置..."
    if ! grep -q "pkgs.openssl_3_3.bin" "$FILE"; then
        sed -i '/pkgs.nodejs_20/a \      pkgs.openssl_3_3.bin' "$FILE"
        echo "已添加 pkgs.openssl_3_3.bin"
    fi
    sed -i 's|command = \["npm" "run" "dev" .*\];|command = ["bash" "start.sh"];|' "$FILE"
    echo "✅ 已修改预览启动命令"
else
    echo "⚠️ 警告: 未找到 $FILE，跳过环境修改"
fi

# 启动服务
npx "${SUB_TYPE}"

echo "----------------------------------------------------"
echo "✅ 检测到 .idx/dev.nix 已更新"
echo "请点击 IDX 界面右下角的 'Rebuild' 按钮以应用新配置。"
echo "或者按下 Ctrl+Shift+P，搜索并运行: 'Rebuild Environment'"
echo "----------------------------------------------------"

