#!/usr/bin/env bash

# --- 配置区 ---
SERVICE_NAME="nodejs-argo"
SERVICE_DIR="/opt/${SERVICE_NAME}"
SCRIPT_PATH="${SERVICE_DIR}/vpsnpm.sh"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
TARGET_MODULE="nodejs-argo"
SYSTEM_USER="root"

# ----------------------------------------
# 权限和目录准备
# ----------------------------------------

if [ "$EUID" -ne 0 ] && [ ! -f "$SERVICE_FILE" ]; then
    echo "🚨 首次安装服务需要 root 权限。请使用 sudo 运行此脚本："
    echo "sudo bash $0"
    exit 1
fi

mkdir -p "${SERVICE_DIR}"
cd "${SERVICE_DIR}" || { echo "无法进入目录 ${SERVICE_DIR}，退出。"; exit 1; }

if [[ "$0" != "$SCRIPT_PATH" ]]; then
    echo "🔄 将脚本复制到目标路径: ${SCRIPT_PATH}"
    cp "$0" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
fi

# ----------------------------------------
# 依赖安装和环境准备
# ----------------------------------------

echo "--- 检查和安装 Node.js 依赖: ${TARGET_MODULE} ---"

if [ ! -d "node_modules" ]; then
    echo "node_modules 目录不存在，正在安装 ${TARGET_MODULE}..."
    npm install "${TARGET_MODULE}"
elif ! npm list "${TARGET_MODULE}" --depth=0 >/dev/null 2>&1; then
    echo "检测到 ${TARGET_MODULE} 未安装或版本不匹配，正在重新安装 ${TARGET_MODULE}..."
    npm install "${TARGET_MODULE}"
else
    echo "${TARGET_MODULE} 依赖已安装且版本匹配，跳过 npm install"
fi

# ----------------------------------------
# 检查并安装 Systemd 服务
# ----------------------------------------

if [ ! -f "$SERVICE_FILE" ]; then
    echo "--- 配置 Systemd 服务: ${SERVICE_FILE} ---"

    # 使用 := 语法确保所有变量都被设置并赋值
    # 如果变量未设置或为空，将使用默认值 ('')，并将默认值赋给变量本身
    export UUID=${UUID:=''}
    export NEZHA_SERVER=${NEZHA_SERVER:=''}
    export NEZHA_KEY=${NEZHA_KEY:=''}
    export ARGO_DOMAIN=${ARGO_DOMAIN:=''}
    export ARGO_AUTH=${ARGO_AUTH:=''}
    export CFIP=${CFIP:='cf.090227.xyz'}
    export NAME=${NAME:=''}

    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Auto-configured NodeJS Argo Tunnel Service (Simplified)
After=network.target

[Service]
Type=simple
User=${SYSTEM_USER}
Group=${SYSTEM_USER}

Environment=UUID=${UUID}
Environment=NEZHA_SERVER=${NEZHA_SERVER}
Environment=NEZHA_KEY=${NEZHA_KEY}
Environment=ARGO_DOMAIN=${ARGO_DOMAIN}
Environment=ARGO_AUTH=${ARGO_AUTH}
Environment=CFIP=${CFIP}
Environment=NAME=${NAME}

WorkingDirectory=${SERVICE_DIR}
ExecStart=${SCRIPT_PATH}

StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    echo "✅ Systemd 服务文件创建成功。"

    systemctl daemon-reload
    systemctl enable "${SERVICE_NAME}.service"
    systemctl start "${SERVICE_NAME}.service"

    echo "🎉 服务安装并启动成功！请检查状态：sudo systemctl status ${SERVICE_NAME}"
    exit 0
fi

# ----------------------------------------
# 启动服务 (此部分由 Systemd ExecStart 调用)
# ----------------------------------------

echo "--- 正在启动核心服务 (由 Systemd 调用) ---"

npx "${TARGET_MODULE}"
