#!/usr/bin/env bash

# --- 配置区 (与安装脚本保持一致) ---
SERVICE_NAME="nodejs-argo"
SERVICE_DIR="/opt/${SERVICE_NAME}"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
# --- 配置区结束 ---

# 权限检查
if [ "$EUID" -ne 0 ]; then
    echo "🚨 卸载服务需要 root 权限。请使用 sudo 运行此脚本："
    echo "sudo bash $0"
    exit 1
fi

echo "========================================"
echo "    📦 正在执行 ${SERVICE_NAME} 服务卸载程序"
echo "========================================"

# 停止和禁用 Systemd 服务
if systemctl is-active --quiet "${SERVICE_NAME}.service"; then
    echo "🛑 停止 Systemd 服务: ${SERVICE_NAME}"
    systemctl stop "${SERVICE_NAME}.service"
else
    echo "ℹ️ 服务 ${SERVICE_NAME} 未运行，跳过停止步骤。"
fi

if systemctl is-enabled --quiet "${SERVICE_NAME}.service"; then
    echo "❌ 禁用开机自启服务: ${SERVICE_NAME}"
    systemctl disable "${SERVICE_NAME}.service"
else
    echo "ℹ️ 服务 ${SERVICE_NAME} 未设置开机自启，跳过禁用步骤。"
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

# 步骤 3: 清理安装目录
if [ -d "$SERVICE_DIR" ]; then
    echo "🔥 彻底删除安装目录及所有内容: ${SERVICE_DIR}"
    rm -rf "$SERVICE_DIR"
else
    echo "ℹ️ 安装目录 ${SERVICE_DIR} 不存在，跳过清理。"
fi

echo "=================================="
echo "✅ ${SERVICE_NAME} 服务已完全卸载！"
echo "=================================="
