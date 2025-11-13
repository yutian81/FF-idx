#!/usr/bin/env bash

# --- 配置区 ---
SERVICE_NAME="nodejs-argo"
SERVICE_DIR="/opt/${SERVICE_NAME}"
SCRIPT_PATH="${SERVICE_DIR}/vpsnpm.sh"
SCRIPT_SOURCE_PATH=$(readlink -f "$0")
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
TARGET_MODULE="nodejs-argo"
SYSTEM_USER="root"
NODE_VERSION="20"

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

if [[ "$SCRIPT_SOURCE_PATH" != "$SCRIPT_PATH" ]]; then
    echo "🔄 将脚本复制到目标路径: ${SCRIPT_PATH}"
    cp "$SCRIPT_SOURCE_PATH" "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
fi

# ----------------------------------------
# Node.js 环境准备
# ----------------------------------------

echo "--- 检查和安装 Node.js 环境 (LTS v${NODE_VERSION}) ---"

if command -v node >/dev/null 2>&1; then
    CURRENT_NODE_VERSION=$(node -v | sed 's/v//')
    echo "✅ Node.js 已安装，当前版本: ${CURRENT_NODE_VERSION}"
else
    echo "⚠️ Node.js 未安装，开始自动安装..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "🚨 无法识别系统类型，请手动安装 Node.js。"
        exit 1
    fi

    # 支持 Debian/Ubuntu, RHEL/CentOS/Fedora, Alpine 系统
    case "$OS" in
        debian|ubuntu|devuan)
            sudo apt update
            sudo apt install -y ca-certificates curl gnupg
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
            echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list >/dev/null
            sudo apt update
            sudo apt install nodejs -y
            ;;
        centos|rhel|fedora)
            sudo dnf install -y nodejs
            ;;
        alpine)
            echo "ℹ️ 检测到 Alpine Linux，使用 apk 安装 Node.js v${NODE_VERSION}..."
            apk update
            # 安装 nodejs-current 及其依赖
            apk add --no-cache nodejs-current npm
            ;;
        *)
            echo "🚨 系统 ${OS} 不支持自动安装 Node.js，请手动安装 Node.js v${NODE_VERSION} 或更高版本。"
            exit 1
            ;;
    esac

    if command -v node >/dev/null 2>&1; then
        echo "🎉 Node.js v${NODE_VERSION} 安装成功！"
    else
        echo "❌ Node.js 安装失败，退出。"
        exit 1
    fi
fi

# ----------------------------------------
# Node.js 依赖安装
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
# 检查并安装 Systemd/OpenRC 服务
# ----------------------------------------

if [ ! -f "$SERVICE_FILE" ]; then
    echo "--- 配置服务 ---"

    # 变量赋值
    UUID=${UUID:='3001b2b7-e810-45bc-a1af-2c302b530d40'}
    NEZHA_SERVER=${NEZHA_SERVER:=''}
    NEZHA_PORT=${NEZHA_PORT:=''}
    NEZHA_KEY=${NEZHA_KEY:=''}
    ARGO_DOMAIN=${ARGO_DOMAIN:=''}
    ARGO_AUTH=${ARGO_AUTH:=''}
    CFIP=${CFIP:='cf.090227.xyz'}
    NAME=${NAME:='NPM'}

    # 检查是否为 OpenRC 系统 (如 Alpine)
    if command -v rc-update >/dev/null 2>&1; then
        OPENRC_SERVICE_FILE="/etc/init.d/${SERVICE_NAME}"
        echo "ℹ️ 检测到 OpenRC 系统，配置 OpenRC 服务文件: ${OPENRC_SERVICE_FILE}"
        cat > "$OPENRC_SERVICE_FILE" << EOF
#!/sbin/openrc-run

name="${SERVICE_NAME}"
description="Auto-configured NodeJS Argo Tunnel Service"

command="/usr/bin/env"
command_args="bash ${SCRIPT_PATH}"
command_background="yes"

directory="${SERVICE_DIR}"
user="${SYSTEM_USER}"

depend() {
    need net
    use dns logger
}

start_pre() {
    export UUID="${UUID}"
    export NEZHA_SERVER="${NEZHA_SERVER}"
    export NEZHA_PORT="${NEZHA_PORT}"
    export NEZHA_KEY="${NEZHA_KEY}"
    export ARGO_DOMAIN="${ARGO_DOMAIN}"
    export ARGO_AUTH="${ARGO_AUTH}"
    export CFIP="${CFIP}"
    export NAME="${NAME}"
}

EOF
        chmod +x "$OPENRC_SERVICE_FILE"
        echo "✅ OpenRC 服务文件创建成功。"
        rc-update add "${SERVICE_NAME}" default
        rc-service "${SERVICE_NAME}" start
        echo "🎉 服务安装并启动成功！请检查状态：rc-service ${SERVICE_NAME} status"
        exit 0
        
    else
        echo "ℹ️ 检测到 Systemd 系统，配置 Systemd 服务文件: ${SERVICE_FILE}"
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
Environment=NEZHA_PORT=${NEZHA_PORT}
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
fi

# ----------------------------------------
# 启动服务 (此部分由 Systemd/OpenRC 调用)
# ----------------------------------------
echo "--- 正在启动核心服务 (由 Systemd/OpenRC 调用) ---"
npx "${TARGET_MODULE}"

# 输出节点信息
echo "--- 复制以下Base64码到代理软件 ---"
cat "${SERVICE_DIR}/tmp/sub.txt"
