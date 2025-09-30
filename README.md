# FF-idx

## docker版FF部署

> 使用固定镜像版本避免自动更新

### 1C1G配置部署镜像

```shell
ghcr.io/jlesage/firefox:v25.09.1
```
> 感谢 [jlesage大佬](https://github.com/jlesage/docker-firefox) 提供的镜像

**环境变量**
- LANG=zh_CN.UTF-8
- VNC_PASSWORD=登录密码

### 1C2G配置部署镜像

```shell
lscr.io/linuxserver/firefox:kasm-140.0.2build1-0ubuntu0.24.04.1mt1-ls3
```

**环境变量：**
- LC_ALL=zh_CN.UTF-8
- CUSTOM_USER=登录用户名
- PASSWORD=登录密码

### 1C4G配置部署镜像(二选一)

```shell
lscr.io/linuxserver/firefox:1143.0.1build1-1xtradeb1.2404.1-ls35
lscr.io/linuxserver/firefox:1141.0.2build1-1xtradeb1.2404.1-ls19
```

**环境变量：**

```yml
PUID=1000
PGID=1000
TZ=Etc/UTC
LC_ALL=zh_CN.UTF-8
CUSTOM_USER=登录用户名
PASSWORD=登录密码
```

> 也可以去官方仓库找自己需要的版本：https://github.com/linuxserver/docker-firefox

### 挂载卷

```yml
volumes:
  - /path/to/firefox/config:/config
```

容器平台填：`/config`

### 开放端口

3000

### 配置文件（双保险避免自动更新）

- 文件名：`/usr/lib/firefox/distribution/policies.json`
- 文件值：`{"policies":{"DisableAppUpdate":true}}`

### FF网页刷新插件

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
