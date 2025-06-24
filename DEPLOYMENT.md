# Naive Service 生产环境部署指南

## 🚀 快速部署

### 一键部署（推荐）

```bash
# 1. 下载部署脚本到服务器
wget https://raw.githubusercontent.com/TeenaWhiteGabrial/naive-service/main/autoDeploy.sh

# 2. 给脚本执行权限
chmod +x autoDeploy.sh

# 3. 运行部署
sudo ./autoDeploy.sh
```

就这么简单！脚本会自动完成所有部署工作。

## 📋 部署要求

### 服务器配置
- **操作系统**: Linux (Ubuntu 18.04+, CentOS 7+)
- **内存**: 至少 2GB RAM
- **磁盘**: 至少 5GB 可用空间
- **网络**: 能够访问互联网和GitHub

### 必需软件
- Git
- Docker
- Docker Compose

> 💡 **提示**: 如果服务器没有安装这些软件，部署脚本会提示您安装命令。

## 🔧 手动部署（备选方案）

如果自动部署失败，可以按以下步骤手动部署：

### 1. 安装依赖

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y git docker.io docker-compose

# CentOS/RHEL
sudo yum install -y git docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

### 2. 克隆项目

```bash
sudo mkdir -p /usr/src/code
cd /usr/src/code
sudo git clone git@github.com:TeenaWhiteGabrial/naive-service.git
cd naive-service
```

### 3. 启动服务

```bash
# 构建并启动所有服务
sudo docker-compose -f docker-compose.prod.yml up --build -d

# 查看服务状态
sudo docker-compose -f docker-compose.prod.yml ps
```

## 📊 服务信息

### 端口配置
- **应用端口**: 9090
- **数据库端口**: 27017 (内部)
- **Nginx端口**: 80, 443 (可选)

### 服务组件
- **应用服务**: Node.js + PM2
- **数据库**: MongoDB 6.0.2
- **反向代理**: Nginx (可选)

### 访问地址
- **应用**: http://服务器IP:9090
- **健康检查**: http://服务器IP:9090/health

## 🛠️ 运维操作

### 查看服务状态

```bash
cd /usr/src/code/naive-service

# 查看所有容器状态
sudo docker-compose -f docker-compose.prod.yml ps

# 查看实时日志
sudo docker-compose -f docker-compose.prod.yml logs -f

# 查看特定服务日志
sudo docker-compose -f docker-compose.prod.yml logs app
sudo docker-compose -f docker-compose.prod.yml logs mongodb
```

### 服务管理

```bash
# 重启服务
sudo docker-compose -f docker-compose.prod.yml restart

# 停止服务
sudo docker-compose -f docker-compose.prod.yml down

# 重新部署（更新代码）
sudo ./autoDeploy.sh
```

### 进入容器

```bash
# 进入应用容器
sudo docker exec -it naive-service-app bash

# 进入MongoDB容器
sudo docker exec -it naive-service-mongodb mongosh
```

## 🔍 故障排除

### 常见问题

#### 1. 端口被占用
```bash
# 查看端口占用
sudo ss -tlnp | grep :9090
sudo ss -tlnp | grep :27017

# 脚本会自动处理端口占用问题
```

#### 2. 容器启动失败
```bash
# 查看详细错误日志
sudo docker-compose -f docker-compose.prod.yml logs --tail=100

# 检查镜像是否正确拉取
sudo docker images | grep misaka-images
```

#### 3. 健康检查失败
```bash
# 手动检查应用状态
curl http://localhost:9090/health

# 查看应用内部日志
sudo docker exec naive-service-app pm2 logs
```

#### 4. 内存不足
```bash
# 清理无用的Docker资源
sudo docker system prune -f

# 查看系统资源使用
free -h
df -h
```

### 重置部署

如果遇到严重问题，可以完全重置：

```bash
# 停止并删除所有容器
sudo docker-compose -f docker-compose.prod.yml down -v

# 清理Docker资源
sudo docker system prune -a -f

# 重新运行部署脚本
sudo ./autoDeploy.sh
```

## 🔒 安全配置

### 防火墙设置

```bash
# Ubuntu (ufw)
sudo ufw allow 22        # SSH
sudo ufw allow 9090      # 应用端口
sudo ufw enable

# CentOS (firewalld)
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --reload
```

### 环境变量

项目使用的主要环境变量（在 docker-compose.prod.yml 中配置）：

```yaml
environment:
  NODE_ENV: production
  PORT: 9090
  DB_HOST: mongodb
  DB_PORT: 27017
  DB_NAME: StarPeaceCompany
  DB_USER: topaz
  DB_PASSWORD: ipcMasterTopazzz
```

> ⚠️ **安全提示**: 生产环境请修改默认的数据库密码

## 📈 性能优化

### 容器资源限制

可以在 docker-compose.prod.yml 中添加资源限制：

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: "0.5"
```

### 启用 Nginx (可选)

```bash
# 启用Nginx反向代理
sudo docker-compose -f docker-compose.prod.yml --profile with-nginx up -d
```

## 🔄 更新部署

### 自动更新

```bash
# 重新运行部署脚本即可自动更新
sudo ./autoDeploy.sh
```

### 手动更新

```bash
cd /usr/src/code/naive-service

# 拉取最新代码
sudo git pull origin main

# 重新构建并启动
sudo docker-compose -f docker-compose.prod.yml up --build -d
```

## 📞 技术支持

如果遇到问题：

1. 检查 [故障排除](#-故障排除) 部分
2. 查看项目 GitHub Issues
3. 联系项目维护者

---

## 📝 部署脚本说明

`autoDeploy.sh` 脚本会自动执行以下操作：

1. ✅ 检查系统环境（git, docker, docker-compose）
2. ✅ 克隆或更新项目代码
3. ✅ 清理旧容器和端口占用
4. ✅ 构建并启动新容器
5. ✅ 验证服务健康状态
6. ✅ 显示访问信息和管理命令

整个过程全自动化，无需手动干预。 