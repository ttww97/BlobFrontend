# BlobFrontend

前端项目，构建 WAR 包并部署到 Tomcat（端口 8080）。

## 项目结构

```
BlobFrontend/
├── frontend/              # 前端代码（Vue3 + Vite）
├── pom.xml               # Maven 构建配置（构建 WAR）
├── .github/workflows/    # GitHub Actions 工作流
├── config/               # Nginx 配置（可选）
└── README.md            # 本文件
```

## 构建和部署

### 本地构建

```bash
mvn clean package -DskipTests
```

构建产物：`target/BlobFrontend-1.0-SNAPSHOT.war`

### 部署到 Tomcat

1. 将 WAR 包复制到 Tomcat webapps 目录
2. 重命名为 `ROOT.war`
3. 启动 Tomcat

### GitHub Actions 自动部署

推送到 `main` 或 `master` 分支时自动触发构建和部署。

## 配置要求

### GitHub Secrets

- `SERVER_HOST`: 服务器 IP 地址
- `SERVER_USER`: SSH 用户名
- `SERVER_SSH_PRIVATE_KEY`: SSH 私钥
- `SERVER_PORT` (可选): SSH 端口，默认 22

### 服务器配置

- Tomcat 路径：`/usr/local/tomcat`
- 部署目录：`/opt/blob-frontend/deploy/`
- Java 环境：`JAVA_HOME=/usr/lib/jvm/jdk-24.0.1`

## 端口配置

- 前端服务：8080（Tomcat）

