#!/bin/bash

# 生产环境部署脚本
# 使用方法: chmod +x deploy_production.sh && ./deploy_production.sh

set -e  # 遇到错误立即退出

# 定义变量
GIT_REPO="https://github.com/TeenaWhiteGabrial/naive-service.git"  # 请替换为你的仓库地址
APP_DIR="/usr/src/code/naive-service"
APP_BRANCH="main"  # 请替换为你的分支名
DOCKER_COMPOSE_FILE="docker-compose.prod.yml"
APP_PORT=9090
MONGO_PORT=27017
APP_CONTAINER_NAME="naive-service-app"
MONGO_CONTAINER_NAME="naive-service-mongodb"

echo "🚀 开始部署 Naive Service 项目..."

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "❌ 请使用 sudo 运行此脚本"
   exit 1
fi

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装Docker Compose"
    exit 1
fi

# 检查Git是否安装
if ! command -v git &> /dev/null; then
    echo "❌ Git 未安装，请先安装Git"
    exit 1
fi

# 创建应用目录
echo "📁 创建应用目录..."
mkdir -p "$(dirname "$APP_DIR")"

# 删除旧的代码仓库
if [ -d "$APP_DIR" ]; then
    echo "🗑️  删除旧的代码仓库..."
    rm -rf "$APP_DIR"
fi

# 克隆代码仓库
echo "📥 克隆代码仓库..."
git clone --branch "$APP_BRANCH" "$GIT_REPO" "$APP_DIR"

# 进入应用目录
cd "$APP_DIR"

# 停止现有容器
echo "⏹️  停止现有容器..."
docker-compose -f "$DOCKER_COMPOSE_FILE" down 2>/dev/null || true

# 检查并释放端口
echo "🔍 检查端口占用情况..."

# 检查应用端口
if lsof -i :$APP_PORT >/dev/null 2>&1; then
    echo "⚠️  端口 $APP_PORT 被占用，正在释放..."
    lsof -ti :$APP_PORT | xargs kill -9 2>/dev/null || true
fi

# 检查MongoDB端口
if lsof -i :$MONGO_PORT >/dev/null 2>&1; then
    echo "⚠️  端口 $MONGO_PORT 被占用，正在释放..."
    lsof -ti :$MONGO_PORT | xargs kill -9 2>/dev/null || true
fi

# 清理旧容器
echo "🧹 清理旧容器..."
if [ "$(docker ps -aq -f name=$APP_CONTAINER_NAME)" ]; then
    docker stop $APP_CONTAINER_NAME 2>/dev/null || true
    docker rm $APP_CONTAINER_NAME 2>/dev/null || true
fi

if [ "$(docker ps -aq -f name=$MONGO_CONTAINER_NAME)" ]; then
    docker stop $MONGO_CONTAINER_NAME 2>/dev/null || true
    docker rm $MONGO_CONTAINER_NAME 2>/dev/null || true
fi

# 清理无用的镜像
echo "🧹 清理无用的Docker镜像..."
docker image prune -f

# 构建并启动容器
echo "🔨 构建并启动容器..."
docker-compose -f "$DOCKER_COMPOSE_FILE" up --build -d

# 等待容器启动
echo "⏳ 等待容器启动..."
sleep 10

# 检查容器状态
echo "🔍 检查容器状态..."
if ! docker-compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
    echo "❌ 容器启动失败，查看日志："
    docker-compose -f "$DOCKER_COMPOSE_FILE" logs
    exit 1
fi

# 显示容器状态
echo "📊 容器状态："
docker-compose -f "$DOCKER_COMPOSE_FILE" ps

# 检查应用健康状态
echo "🏥 检查应用健康状态..."
sleep 5

if curl -f http://localhost:$APP_PORT/health 2>/dev/null; then
    echo "✅ 应用健康检查通过"
else
    echo "⚠️  应用可能还在启动中，请稍后检查"
fi

# 显示访问信息
SERVER_IP=$(curl -s http://checkip.amazonaws.com/ || hostname -I | awk '{print $1}')
echo ""
echo "🎉 部署完成！"
echo "📍 应用访问地址：http://$SERVER_IP:$APP_PORT"
echo "📍 本地访问地址：http://localhost:$APP_PORT"
echo ""
echo "📋 常用命令："
echo "  查看日志: docker-compose -f $DOCKER_COMPOSE_FILE logs -f"
echo "  停止服务: docker-compose -f $DOCKER_COMPOSE_FILE down"
echo "  重启服务: docker-compose -f $DOCKER_COMPOSE_FILE restart"
echo "  查看状态: docker-compose -f $DOCKER_COMPOSE_FILE ps" 