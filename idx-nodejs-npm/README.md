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
export CFIP=""
export NAME=""
npx npx node-sbx
```

### 环境变量
或使用 `.env` 文件加载变量

```bash
npx npx node-sbx --env-file ./myapp-nodejs/.env
```
