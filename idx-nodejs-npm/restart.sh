#!/usr/bin/env bash

# 定义要修改的 Nix 配置文件路径
IDX_CONFIG_FILE=".idx/dev.nix"

echo "正在检查并修改 IDX 配置文件: ${IDX_CONFIG_FILE}..."

# 检查文件是否存在
if [ ! -f "${IDX_CONFIG_FILE}" ]; then
    echo "错误: 找不到文件 ${IDX_CONFIG_FILE}。请确保您在工作空间根目录运行此脚本。"
    exit 1
fi

# 执行 sed 替换操作
sed -i \
-e '/packages = \[/,/\];/{
  /packages = \[/!d
  s|packages = \[.*|packages = [\
    pkgs.nodejs_20\
    pkgs.openssl_3_3.bin\
  ];|
}' \
-e '/web = {/,/};/{
  /web = {/!d
  s|web = {.*|web = {\
          command = ["bash" "start.sh"];\
          manager = "web";\
        };|
}' "${IDX_CONFIG_FILE}"

echo "IDX 配置文件修改完成。正在重启 IDX 工作空间以应用更改..."
idx restart
