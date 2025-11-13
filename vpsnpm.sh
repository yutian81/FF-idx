#!/usr/bin/env bash

# --- 配置区 ---
SERVICE_NAME="nodejs-argo"
SERVICE_DIR="/opt/${SERVICE_NAME}"
SCRIPT_PATH="${SERVICE_DIR}/vpsnpm.sh"
SCRIPT_SOURCE_PATH=$(readlink -f "$0")
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
OPENRC_SERVICE_FILE="/etc/init.d/${SERVICE_NAME}"
TARGET_MODULE="nodejs-argo"
SYSTEM_USER="root"

# 变量定义和赋值
define_vars() {
    unset NAME
    # 变量赋值
    export UUID=${UUID:-'3001b2b7-e810-45bc-a1af-2c302b530d40'}
    export NEZHA_SERVER=${NEZHA_SERVER:-''}
    export NEZHA_PORT=${NEZHA_PORT:-''}
    export NEZHA_KEY=${NEZHA_KEY:-''}
    export ARGO_DOMAIN=${ARGO_DOMAIN:-''}
    export ARGO_AUTH=${ARGO_AUTH:-''}
    export CFIP=${CFIP:-'cf.090227.xyz'}
    export NAME=${NAME:-'NPM'}
}

# 权限和工作目录设置
setup_environment() {
    # 权限检查：允许非 root 用户执行已安装的服务脚本，但首次安装必须是 root
    if [ "$EUID" -ne 0 ] && [ ! -f "$SERVICE_FILE" ] && [ ! -f "$OPENRC_SERVICE_FILE" ]; then
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
}

# Node.js 环境准备
install_node() {
    echo "--- 检查和安装 Node.js 环境 ---"
    if command -v node >/dev/null 2>&1; then
        CURRENT_NODE_VERSION=$(node -v | sed 's/v//')
        echo "✅ Node.js 已安装，版本: ${CURRENT_NODE_VERSION}"
        return 0
    fi

    echo "⚠️ Node.js 未安装，开始自动安装..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "🚨 无法识别系统类型，请手动安装 Node.js。"
        exit 1
    fi

    case "$OS" in
        debian|ubuntu|devuan)
            apt update
            apt install -y nodejs npm
            ;;
        centos|rhel|fedora)
            dnf install -y nodejs
            ;;
        alpine)
            apk update
            apk add --no-cache nodejs-current npm
            ;;
        *)
            echo "🚨 系统 ${OS} 不支持自动安装 Node.js，请手动安装"
            exit 1
            ;;
    esac

    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node -v | sed 's/v//')
        echo "🎉 Node.js 安装成功！版本: ${NODE_VERSION}"
    else
        echo "❌ Node.js 安装失败，退出。"
        exit 1
    fi
}

# Node.js 依赖安装
install_deps() {
    echo "--- 检查和安装 Node.js 依赖: ${TARGET_MODULE} ---"
    if [ ! -d "node_modules" ] || ! npm list "${TARGET_MODULE}" --depth=0 >/dev/null 2>&1; then
        echo "正在安装/重新安装 ${TARGET_MODULE}..."
        npm install "${TARGET_MODULE}"
    else
        echo "${TARGET_MODULE} 依赖已安装且版本匹配，跳过 npm install"
    fi
}

# 创建并启动服务 (始终重建/覆盖)
create_service() {
    define_vars # 变量赋值
    
    echo "--- 配置并重启服务 ---"
    if command -v rc-update >/dev/null 2>&1; then
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
        
        rc-service "${SERVICE_NAME}" stop 2>/dev/null || true
        rc-update add "${SERVICE_NAME}" default 2>/dev/null || true
        rc-service "${SERVICE_NAME}" start
        echo "🎉 服务安装并启动成功！请检查状态：rc-service ${SERVICE_NAME} status"
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

# 环境变量
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
        systemctl restart "${SERVICE_NAME}.service" # 始终重启，确保新配置生效
        
        echo "🎉 服务安装并启动成功！请检查状态：sudo systemctl status ${SERVICE_NAME}"
    fi
}

# 核心进程执行
start_core_process() {
    echo "--- 正在启动核心服务 (npx ${TARGET_MODULE}) ---"
    npx "${TARGET_MODULE}"
}

# 主执行逻辑
if [[ -z "$INVOCATION_ID" && -z "$OPENRC_INIT_DIR" ]]; then
    setup_environment # 设置环境和权限
    install_node # 安装 Node.js
    install_deps # 安装依赖
    create_service # 创建/重启服务
    start_core_process # 运行npx核心进程
    exit 0 # 安装模式结束，退出。
fi

echo "--- 正在以服务模式启动核心进程 ---"
start_core_process
