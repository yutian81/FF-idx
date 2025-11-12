## 一键全自动安装

```bash
curl -o idx.sh -Ls \
  "https://raw.githubusercontent.com/yutian81/FF-idx/main/idx-nodejs-npm/idx.sh" && \
chmod +x idx.sh && \
UUID=1234 \
NEZHA_SERVER=nezha.example.com \
NEZHA_KEY=abcd1234 \
ARGO_DOMAIN=myargo.site \
ARGO_AUTH=eyJhIjoixxxxxx \
CFIP=cf.090227.xyz \
NAME=IDX \
./idx.sh
```

再修改 dev.nix 中 previews = { ... }; 其中的启动命令

```bash
previews = {
  web = {
    command = ["bash" "idx.sh"];
    manager = "web";
  };
};
```

----

## 手动部署说明

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
