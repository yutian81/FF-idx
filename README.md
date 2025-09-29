# FF-idx

## docker版FF部署

最低配置 1C2G，理想配置 1C4G

### 镜像选其中之一

```shell
lscr.io/linuxserver/firefox:1143.0.1build1-1xtradeb1.2404.1-ls35
lscr.io/linuxserver/firefox:1142.0.1build1-1xtradeb1.2404.1-ls28
lscr.io/linuxserver/firefox:1141.0.2build1-1xtradeb1.2404.1-ls19
# 以下kasm的镜像更为轻量，但是我部署到容器平台有问题；VPS部署正常
lscr.io/linuxserver/firefox:kasm-140.0.2build1-0ubuntu0.24.04.1mt1-ls3
```

### 建议变量

```yml
PUID=1000
PGID=1000
TZ=Etc/UTC
DOCKER_MODS=linuxserver/mods:universal-package-install
INSTALL_PACKAGES=fonts-noto-cjk
LC_ALL=zh_CN.UTF-8
CUSTOM_USER=登录用户名
PASSWORD=登录密码
```

### 挂载卷

```yml
volumes:
  - /path/to/firefox/config:/config
```

### 开放端口

3000

----

## idx 部署

所有代码来自老王：https://github.com/eooce/Sing-box ，release的other标签

自行根据代码中的提示修改变量；如果不需要idx直连协议，则FRP相关的变量留空

- 空白工作区 shell 方案——代码：`idx-empty-workspace`
- nodejs 方案——代码：`frp-idx-nodejs`
- python 方案——代码：`frp-idx-python`

----

## FRP 部署

不需要IDX直连协议的不需要部署

若需要，则建议部署老王的FRP一键脚本

仓库：https://github.com/eooce/scripts

一键脚本：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/eooce/scripts/master/frp.sh)
```
