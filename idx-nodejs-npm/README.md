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

---

## 保持后台运行且自启动

### 安装 PM2
```bash
npm install pm2
```

### 运行项目
```bash
# nodejs-argo
pm2 start node_modules/nodejs-argo/index.js --name "nodejs-argo" --node-args="-r dotenv/config"
# node-sbx
pm2 start node_modules/node-sbx/index.js --name "node-sbx" --node-args="-r dotenv/config"
```

### 其他PM命令
```bash
# 查看进程状态
pm2 status
# 查看实时日志
pm2 logs nodejs-argo
# 设置开机自启
pm2 startup
# 保存当前的进程列表
pm2 save
```

### 更新 .env 后需要重启项目
```bash
pm2 restart nodejs-argo
pm2 restart node-sbx
```

### screen 后台运行
```bash
# 创建screen会话
screen -S nodejs-argo
# 运行应用
nodejs-argo
# 按 Ctrl+A 然后按 D 分离会话
# 重新连接
screen -r nodejs-argo
```
