# Naive Service Docker 部署指南

## 部署准备

### 1. 服务器要求

- **操作系统**: Linux (Ubuntu 18.04+, CentOS 7+, 或其他主流发行版)
- **内存**: 至少 2GB RAM
- **磁盘**: 至少 10GB 可用空间
- **网络**: 能够访问互联网

### 2. 安装必要软件

#### 安装 Docker

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# CentOS/RHEL
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
```

#### 安装 Docker Compose

```bash
# 方法1: 使用 pip
sudo pip3 install docker-compose

# 方法2: 直接下载
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 安装 Git

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y git

# CentOS/RHEL
sudo yum install -y git
```

## 部署步骤

### 方法一：使用自动化部署脚本（推荐）

1. **下载并运行部署脚本**

```bash
# 克隆项目到服务器
git clone https://github.com/your-username/naive-service.git
cd naive-service

# 修改部署脚本中的配置
vim deploy_production.sh

# 更新以下变量：
# GIT_REPO="https://github.com/your-username/naive-service.git"
# APP_BRANCH="main"  # 你的分支名

# 给脚本执行权限
chmod +x deploy_production.sh

# 运行部署脚本
sudo ./deploy_production.sh
```

### 方法二：手动部署

1. **克隆代码**

```bash
sudo mkdir -p /usr/src/code
cd /usr/src/code
sudo git clone https://github.com/your-username/naive-service.git
cd naive-service
```

2. **构建并启动服务**

```bash
# 基础部署（仅应用+数据库）
sudo docker-compose -f docker-compose.prod.yml up --build -d

# 或者包含 Nginx 反向代理
sudo docker-compose -f docker-compose.prod.yml --profile with-nginx up --build -d
```

3. **查看服务状态**

```bash
# 查看容器状态
sudo docker-compose -f docker-compose.prod.yml ps

# 查看日志
sudo docker-compose -f docker-compose.prod.yml logs -f
```

## 配置说明

### 1. 环境变量配置

创建生产环境配置文件 `.env.production`:

```bash
# 应用配置
NODE_ENV=production
PORT=9090

# 数据库配置
DB_HOST=mongodb
DB_PORT=27017
DB_NAME=StarPeaceCompany
DB_USER=topaz
DB_PASSWORD=ipcMasterTopazzz

# JWT 配置
JWT_SECRET=your-strong-jwt-secret-here
JWT_EXPIRES_IN=30d

# 七牛云配置
QINIU_ACCESS_KEY=your-access-key
QINIU_SECRET_KEY=your-secret-key
QINIU_BUCKET=your-bucket-name
QINIU_UPLOAD_URL=your-upload-url

# 安全配置
CORS_ORIGIN=https://your-domain.com
```

### 2. 端口配置

- **应用端口**: 9090
- **数据库端口**: 27017
- **Nginx端口**: 80, 443 (如果启用)

### 3. 数据持久化

- **MongoDB数据**: 存储在 Docker volume `mongo-data`
- **应用日志**: 挂载到 `./logs` 目录
- **上传文件**: 挂载到 `./uploads` 目录

## 运维命令

### 基本操作

```bash
# 查看容器状态
sudo docker-compose -f docker-compose.prod.yml ps

# 查看实时日志
sudo docker-compose -f docker-compose.prod.yml logs -f

# 重启服务
sudo docker-compose -f docker-compose.prod.yml restart

# 停止服务
sudo docker-compose -f docker-compose.prod.yml down

# 更新并重启服务
sudo docker-compose -f docker-compose.prod.yml pull
sudo docker-compose -f docker-compose.prod.yml up -d
```

### 数据库操作

```bash
# 进入 MongoDB 容器
sudo docker exec -it naive-service-mongodb mongosh

# 备份数据库
sudo docker exec naive-service-mongodb mongodump --host localhost --port 27017 --username topaz --password ipcMasterTopazzz --db StarPeaceCompany --out /data/backup

# 恢复数据库
sudo docker exec naive-service-mongodb mongorestore --host localhost --port 27017 --username topaz --password ipcMasterTopazzz --db StarPeaceCompany /data/backup/StarPeaceCompany
```

### 应用操作

```bash
# 进入应用容器
sudo docker exec -it naive-service-app sh

# 查看应用进程
sudo docker exec naive-service-app pm2 list

# 查看应用日志
sudo docker exec naive-service-app pm2 logs

# 重启应用进程
sudo docker exec naive-service-app pm2 restart all
```

## 监控和日志

### 1. 健康检查

```bash
# 检查应用健康状态
curl http://localhost:9090/health

# 检查容器健康状态
sudo docker inspect naive-service-app | grep Health -A 10
```

### 2. 日志管理

```bash
# 查看应用日志
tail -f logs/out.log
tail -f logs/error.log

# 查看 Nginx 日志 (如果启用)
tail -f logs/nginx/access.log
tail -f logs/nginx/error.log
```

### 3. 性能监控

```bash
# 查看容器资源使用情况
sudo docker stats

# 查看系统资源
htop
free -h
df -h
```

## 故障排除

### 常见问题

1. **端口被占用**
```bash
# 查看端口占用
sudo lsof -i :9090
sudo lsof -i :27017

# 杀死占用进程
sudo kill -9 <PID>
```

2. **容器启动失败**
```bash
# 查看容器日志
sudo docker logs naive-service-app
sudo docker logs naive-service-mongodb

# 检查 Docker 镜像
sudo docker images
```

3. **数据库连接失败**
```bash
# 检查数据库容器状态
sudo docker exec naive-service-mongodb mongosh --eval "db.adminCommand('ping')"

# 检查网络连接
sudo docker network ls
sudo docker network inspect naive-service_app-network
```

4. **内存不足**
```bash
# 清理无用镜像
sudo docker image prune -a

# 清理无用容器
sudo docker container prune

# 清理无用卷
sudo docker volume prune
```

## 安全建议

1. **防火墙配置**
```bash
# 仅开放必要端口
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 9090  # 应用端口 (可选，建议通过Nginx代理)
sudo ufw enable
```

2. **SSL证书配置**
- 使用 Let's Encrypt 获取免费 SSL 证书
- 配置 Nginx HTTPS

3. **定期备份**
- 设置 cron 任务定期备份数据库
- 备份重要配置文件

## 扩展配置

### 1. 负载均衡

如需要负载均衡，可以修改 `docker-compose.prod.yml` 中的 app 服务：

```yaml
app:
  deploy:
    replicas: 3
    resources:
      limits:
        cpus: "0.50"
        memory: 512M
```

### 2. 外部数据库

如果使用外部 MongoDB 服务，修改环境变量：

```bash
DB_HOST=your-external-mongodb-host
DB_PORT=27017
MONGODB_URI=mongodb://user:pass@external-host:27017/dbname
```

然后从 `docker-compose.prod.yml` 中移除 mongodb 服务。 