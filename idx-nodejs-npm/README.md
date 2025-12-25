# IDX部署说明

## 一键bash命令，全自动

```bash
curl -LsO "https://raw.githubusercontent.com/yutian81/FF-idx/main/idx-nodejs-npm/start.sh" \
&& chmod +x start.sh \
&& SUB_TYPE=nodejs-argo \
UUID=544f7c5b-fb9d-474e-aed7-d28d4e53f85c \
NEZHA_SERVER=sos.de5.cc:8008 \
NEZHA_KEY=111222333 \
ARGO_DOMAIN=argo.ccc.net \
ARGO_AUTH=eyxxxxxxxxxxxxxxxxx \
NAME=IDX \
./start.sh
```

**部署完成后，点击页面上的 rebuild，等待重建环境即可**

---

## 手动折腾

### 1. 安装依赖包

```bash
# xray内核
npm install nodejs-argo

# singbox内核
npm install node-sbx
```

### 2. 启动服务

```bash
# xray内核
npx nodejs-argo

# singbox内核
npx node-sbx
```

### 3. 带变量启动

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

### 4. 修改 dev.nix

#### 第一处：依赖包

```bash
  packages = [
    pkgs.nodejs_20
    pkgs.openssl_3_3.bin
  ];
```

#### 第二处：启动命令

**借助 start.sh 文件启动**

```bash
previews = {
  web = {
    command = ["npx" "nodejs-argo"];
    manager = "web";
  };
};
```

#### 第三处：环境变量

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
