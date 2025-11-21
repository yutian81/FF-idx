## IDX部署说明

### 一键全自动

```bash
curl -LsO "https://raw.githubusercontent.com/yutian81/FF-idx/main/idx-nodejs-npm/start.sh" \
&& chmod +x start.sh \
&& SUB_TYPE="nodejs-argo" \
UUID="your_uuid" \
NEZHA_SERVER="your_nezha_server" \
NEZHA_KEY="your_nezha_key" \
ARGO_DOMAIN="your_argo_domain" \
ARGO_AUTH="your_argo_auth" \
./start.sh \
&& curl -LsO "https://raw.githubusercontent.com/yutian81/FF-idx/main/idx-nodejs-npm/restart.sh" \
&& chmod +x restart.sh \
&& ./restart.sh
```

### 安装依赖包

```bash
# xray内核
npm install nodejs-argo

# singbox内核
npm install node-sbx
```

### 启动命令

```bash
# xray内核
npx nodejs-argo

# singbox内核
npx node-sbx
```

### 带变量启动

```bash
export UUID=""
export NEZHA_SERVER=""
export NEZHA_KEY=""
export ARGO_DOMAIN=""
export ARGO_AUTH=""
export CFIP=""
export NAME=""
npx nodejs-argo
# 或 npx node-sbx
```

---

## 保持自启动

### 借助 start.sh 文件启动

- 修改 dev.nix 中 previews = { ... }; 其中的启动命令

```bash
previews = {
  web = {
    command = ["bash" "start.sh"];
    manager = "web";
  };
};
```

### 不要 start.sh 直接启动

```bash
previews = {
  enable = true;
  previews = {
    web = {
      command = ["npx" "nodejs-argo"];
      manager = "web";
      env = {
        UUID="";
        NEZHA_SERVER="";
        NEZHA_KEY="";
        ARGO_DOMAIN="";
        ARGO_AUTH="";
        CFIP="cf.090227.xyz";
        NAME="IDX";
      };
    };
  };
};
```

- 或者将变量放在全局

```bash
env = {
  UUID="";
  NEZHA_SERVER="";
  NEZHA_KEY="";
  ARGO_DOMAIN="";
  ARGO_AUTH="";
  CFIP="cf.090227.xyz";
  NAME="IDX";
};

previews = {
  enable = true;
  previews = {
    web = {
      command = ["npx" "nodejs-argo"];
      manager = "web";
    };
  };
};
```
