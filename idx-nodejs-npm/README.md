## Xray 内核

### 安装依赖包
```bash
npm install nodejs-argo
```

### 启动命令
```bash
npx nodejs-argo
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
```

### 环境变量
或使用 `.env` 文件加载变量

```bash
# 加载变量并启动
node -r dotenv/config node_modules/nodejs-argo/index.js
```

----

## SingBox 内核

### 安装依赖包
```bash
npm install node-sbx
```

### 启动命令
```bash
npx npx node-sbx
```

### 带变量启动
```bash
export UUID=""
export NEZHA_SERVER=""
export NEZHA_KEY=""
export ARGO_DOMAIN=""
export ARGO_AUTH=""
export CFIP="cf.090227.xyz"
export NAME="IDX"
npx npx node-sbx
```

### 环境变量
或使用 `.env` 文件加载变量

```bash
# 加载变量并启动
node -r dotenv/config node_modules/node-sbx/index.js
```

---

## 保持自启动

### 借助 start.sh 文件启动
修改 dev.nix 中 previews = { ... }; 其中的启动命令

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
```
