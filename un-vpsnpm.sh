#!/usr/bin/env bash

# --- 配置区 (与安装脚本保持一致) ---
SERVICE_NAME="nodejs-argo"
SERVICE_DIR="/opt/${SERVICE_NAME}"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
OPENRC_SERVICE_FILE="/etc/init.d/${SERVICE_NAME}"
# --- 配置区结束 ---

# 权限检查
if [ "$EUID" -ne 0 ]; then
    echo "🚨 卸载服务需要 root 权限。请使用 sudo 运行此脚本："
    echo "sudo bash $0"
    exit 1
fi

echo "=================================="
echo "📦 正在执行 ${SERVICE_NAME} 服务卸载程序"
echo "=================================="

# --- 步骤 1: 停止和禁用服务 ---

if command -v systemctl >/dev/null 2>&1; then
    # Systemd 逻辑
    echo "--- 处理 Systemd 服务 ---"
    if systemctl is-active --quiet "${SERVICE_NAME}.service"; then
        echo "🛑 停止 Systemd 服务: ${SERVICE_NAME}"
        systemctl stop "${SERVICE_NAME}.service"
    else
        echo "ℹ️ Systemd 服务 ${SERVICE_NAME} 未运行，跳过停止。"
    fi
    
    if systemctl is-enabled --quiet "${SERVICE_NAME}.service"; then
        echo "❌ 禁用开机自启服务: ${SERVICE_NAME}"
        systemctl disable "${SERVICE_NAME}.service"
    else
        echo "ℹ️ Systemd 服务 ${SERVICE_NAME} 未设置开机自启，跳过禁用。"
    fi

    # 删除 Systemd Unit 文件
    if [ -f "$SERVICE_FILE" ]; then
        echo "🗑️ 删除 Systemd 服务文件: ${SERVICE_FILE}"
        rm -f "$SERVICE_FILE"
        echo "🔄 重新加载 Systemd 配置..."
        systemctl daemon-reload
    else
        echo "ℹ️ Systemd 服务文件 ${SERVICE_FILE} 不存在，跳过删除。"
    fi

elif command -v rc-service >/dev/null 2>&1; then
    # OpenRC 逻辑
    echo "--- 处理 OpenRC 服务 ---"
    if rc-service "${SERVICE_NAME}" status 2>/dev/null | grep -q 'started'; then
        echo "🛑 停止 OpenRC 服务: ${SERVICE_NAME}"
        rc-service "${SERVICE_NAME}" stop
    else
        echo "ℹ️ OpenRC 服务 ${SERVICE_NAME} 未运行，跳过停止。"
    fi

    if rc-update show | grep -q "${SERVICE_NAME}"; then
        echo "❌ 禁用开机自启服务: ${SERVICE_NAME}"
        rc-update del "${SERVICE_NAME}" default
    else
        echo "ℹ️ OpenRC 服务 ${SERVICE_NAME} 未设置开机自启，跳过禁用。"
    fi

    # 删除 OpenRC Init 文件
    if [ -f "$OPENRC_SERVICE_FILE" ]; then
        echo "🗑️ 删除 OpenRC 服务文件: ${OPENRC_SERVICE_FILE}"
        rm -f "$OPENRC_SERVICE_FILE"
    else
        echo "ℹ️ OpenRC 服务文件 ${OPENRC_SERVICE_FILE} 不存在，跳过删除。"
    fi

else
    echo "⚠️ 未检测到 Systemd 或 OpenRC 服务管理器，跳过服务文件清理。"
fi


# --- 步骤 2: 清理安装目录 ---
echo "--- 清理安装目录 ---"
if [ -d "$SERVICE_DIR" ]; then
    echo "🔥 彻底删除安装目录及所有内容: ${SERVICE_DIR}"
    rm -rf "$SERVICE_DIR"
else
    echo "ℹ️ 安装目录 ${SERVICE_DIR} 不存在，跳过清理。"
fi

echo "=================================="
echo "✅ ${SERVICE_NAME} 服务已完全卸载！"
echo "=================================="
