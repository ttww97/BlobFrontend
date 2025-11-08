# Drone-SCP 部署修复方案

## 问题描述

**错误信息：**
```
tar: artifacts: Cannot mkdir: Permission denied
tar: artifacts/BlobFrontend-1.0-SNAPSHOT.war: Cannot open: No such file or directory
tar: Exiting with failure status due to previous errors
```

**原因：**
tar 命令包含了 `artifacts/` 目录结构，导致在远程服务器解压时尝试创建 `artifacts/` 目录，出现权限错误。

**错误的命令：**
```bash
tar -zcf /tmp/jahPonMqBo.tar.gz artifacts/BlobFrontend-1.0-SNAPSHOT.war
```

这个命令创建的 tar 文件结构是：
```
artifacts/
└── BlobFrontend-1.0-SNAPSHOT.war
```

解压时会尝试创建 `artifacts/` 目录，导致权限错误。

## 解决方案

### 方案 1：修复 tar 创建命令（推荐）

**正确的命令：**
```bash
tar -zcf /tmp/jahPonMqBo.tar.gz -C artifacts BlobFrontend-1.0-SNAPSHOT.war
```

`-C artifacts` 参数会先切换到 `artifacts/` 目录，然后打包文件，这样 tar 文件只包含文件本身，不包含目录结构。

**修复后的 tar 文件结构：**
```
BlobFrontend-1.0-SNAPSHOT.war
```

### 方案 2：修复解压命令（如果无法修改 tar 创建命令）

如果无法修改 tar 创建命令，可以在解压时使用 `--strip-components=1` 跳过第一层目录：

**错误的解压命令：**
```bash
tar -zxf jahPonMqBo.tar.gz --overwrite -C /opt/blob-frontend/deploy/
```

**正确的解压命令：**
```bash
tar -zxf jahPonMqBo.tar.gz --strip-components=1 --overwrite -C /opt/blob-frontend/deploy/
```

`--strip-components=1` 会移除第一层目录（`artifacts/`），直接提取文件。

## 完整的修复命令

### 步骤 1: 创建 tar 文件（已修复）
```bash
tar -zcf /tmp/jahPonMqBo.tar.gz -C artifacts BlobFrontend-1.0-SNAPSHOT.war
```

**验证 tar 文件内容：**
```bash
tar -tzf /tmp/jahPonMqBo.tar.gz
# 应该只显示: BlobFrontend-1.0-SNAPSHOT.war
# 而不是: artifacts/BlobFrontend-1.0-SNAPSHOT.war
```

### 步骤 2: SCP 传输到服务器
```bash
# 由 drone-scp 插件处理
```

### 步骤 3: 在远程服务器上创建部署目录
```bash
sudo mkdir -p /opt/blob-frontend/deploy
sudo chown $USER:$USER /opt/blob-frontend/deploy
```

### 步骤 4: 解压 tar 文件
```bash
tar -zxf jahPonMqBo.tar.gz --overwrite -C /opt/blob-frontend/deploy/
```

### 步骤 5: 验证文件
```bash
ls -lh /opt/blob-frontend/deploy/BlobFrontend-1.0-SNAPSHOT.war
```

## Drone CI 配置示例

如果你使用 drone-scp 插件，你的 `.drone.yml` 应该如下配置：

```yaml
- name: create-tar
  image: alpine
  commands:
    # 关键修复：使用 -C artifacts 参数
    - tar -zcf /tmp/jahPonMqBo.tar.gz -C artifacts BlobFrontend-1.0-SNAPSHOT.war
    - echo "验证 tar 文件内容："
    - tar -tzf /tmp/jahPonMqBo.tar.gz

- name: scp-to-server
  image: appleboy/drone-scp:1.6.14
  settings:
    host:
      from_secret: server_host
    username:
      from_secret: server_user
    key:
      from_secret: server_ssh_key
    source:
      - /tmp/jahPonMqBo.tar.gz
    target: /tmp/
    strip_components: 0
    overwrite: true
    debug: true

- name: extract-and-deploy
  image: appleboy/drone-ssh:1.7.0
  settings:
    host:
      from_secret: server_host
    username:
      from_secret: server_user
    key:
      from_secret: server_ssh_key
    script:
      - |
        set -euo pipefail
        echo "=== 在远程服务器上部署 ==="
        
        # 创建部署目录
        sudo mkdir -p /opt/blob-frontend/deploy
        sudo chown $USER:$USER /opt/blob-frontend/deploy || true
        
        # 解压 tar 文件
        tar -zxf /tmp/jahPonMqBo.tar.gz --overwrite -C /opt/blob-frontend/deploy/
        
        # 验证文件
        ls -lh /opt/blob-frontend/deploy/BlobFrontend-1.0-SNAPSHOT.war
        
        # 清理临时文件
        rm -f /tmp/jahPonMqBo.tar.gz
```

## 快速修复

**只需要修改一个命令：**

将：
```bash
tar -zcf /tmp/jahPonMqBo.tar.gz artifacts/BlobFrontend-1.0-SNAPSHOT.war
```

改为：
```bash
tar -zcf /tmp/jahPonMqBo.tar.gz -C artifacts BlobFrontend-1.0-SNAPSHOT.war
```

就这么简单！✅

