# FF-idx

## docker版FF部署

> 使用固定镜像版本避免自动更新

### 1C1G配置部署镜像

```shell
# 以下二选一
ghcr.io/jlesage/firefox:v25.09.1   # 端口 5800
ghcr.io/eooce/firefox:latest       # 端口 8080
```
> 感谢 [jlesage大佬](https://github.com/jlesage/docker-firefox) 和 [老王](https://github.com/eooce) 提供的镜像

**环境变量**
- VNC_PASSWORD=登录密码

**挂载卷**
- J佬镜像：/config，容量 1G
- 老王镜像：/data/vncuser，容量 1G

**compose示例：**

```yml
services:
  firefox-eooce:
    image: ghcr.io/eooce/firefox:latest
    container_name: firefox-eooce
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      - VNC_PASSWORD=yourpassword
    volumes:
      - ./firefox/data:/data/vncuser
```

### 1C2G配置部署镜像

```shell
lscr.io/linuxserver/firefox:kasm-140.0.2build1-0ubuntu0.24.04.1mt1-ls3    # 端口 3000
```

**环境变量：**
```
- PUID=1000
- PGID=1000
- CUSTOM_USER=登录用户名
- PASSWORD=登录密码
- 可选变量 LC_ALL=zh_CN.UTF-8
```

> 也可以去官方仓库找自己需要的版本：https://github.com/linuxserver/docker-firefox

**挂载卷**
- /config，容量 1G

**compose示例：**

```yml
services:
  firefox:
    image: lscr.io/linuxserver/firefox:kasm-140.0.2build1-0ubuntu0.24.04.1mt1-ls3
    container_name: firefox
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - PUID=1000                    # 宿主机用户ID
      - PGID=1000                    # 宿主机用户组ID
      - CUSTOM_USER=yourusername     # 登录用户名
      - PASSWORD=yourpassword        # 登录密码
    volumes:
      - ./firefox/config:/config
```

## 配置文件（双保险避免自动更新）

- 文件名：`/usr/lib/firefox/distribution/policies.json`
- 文件值：`{"policies":{"DisableAppUpdate":true}}`

## FF网页刷新插件

Auto Refresh Page

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

---

## 一键全自动安装，适用于vps

> 暂时仅支持Debian和乌班图系统

```bash
curl -o vpsnpm.sh -Ls \
  "https://raw.githubusercontent.com/yutian81/FF-idx/main/vpsnpm.sh" && \
chmod +x vpsnpm.sh && \
UUID=1234 \
NEZHA_SERVER=nezha.example.com \
NEZHA_KEY=abcd1234 \
ARGO_DOMAIN=myargo.site \
ARGO_AUTH=eyJhIjoixxxxxx \
NAME=IDX \
./vpsnpm.sh
```

一键卸载
