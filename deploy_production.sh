#!/bin/bash

# 生产环境部署脚本
# 使用方法: chmod +x deploy_production.sh && ./deploy_production.sh
# 注意: 此脚本假设已经在正确的项目目录中运行

set -e  # 遇到错误立即退出

# 定义变量
DOCKER_COMPOSE_FILE="docker-compose.prod.yml"
APP_PORT=9090
MONGO_PORT=27017
APP_CONTAINER_NAME="naive-service-app"
MONGO_CONTAINER_NAME="naive-service-mongodb"

echo "🚀 开始部署 Naive Service 项目..."

# 检查是否在正确的项目目录中
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "❌ 未找到 $DOCKER_COMPOSE_FILE 文件，请确保在正确的项目目录中运行此脚本"
    exit 1
fi

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "❌ 请使用 sudo 运行此脚本"
   exit 1
fi

# 优化的停止和清理函数
cleanup_containers() {
    echo "🧹 清理现有容器和服务..."
    
    # 停止 docker-compose 服务
    if docker-compose -f "$DOCKER_COMPOSE_FILE" ps -q 2>/dev/null | grep -q .; then
        echo "⏹️  停止 Docker Compose 服务..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    fi
    
    # 清理指定名称的容器（如果存在）
    for container in $APP_CONTAINER_NAME $MONGO_CONTAINER_NAME; do
        if [ "$(docker ps -aq -f name=$container)" ]; then
            echo "🗑️  清理容器: $container"
            docker stop $container 2>/dev/null || true
            docker rm $container 2>/dev/null || true
        fi
    done
}

# 检查端口占用的函数
check_ports() {
    echo "🔍 检查端口占用情况..."
    
    for port in $APP_PORT $MONGO_PORT; do
        if ss -tlnp | grep -q ":$port "; then
            echo "⚠️  端口 $port 被占用"
            # 显示占用进程但不强制杀死，让用户决定
            echo "占用进程信息："
            ss -tlnp | grep ":$port " || true
            
            read -p "是否要停止占用端口 $port 的进程? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                fuser -k $port/tcp 2>/dev/null || true
                echo "✅ 端口 $port 已释放"
            fi
        else
            echo "✅ 端口 $port 可用"
        fi
    done
}

# 执行清理
cleanup_containers

# 检查端口
check_ports

# 清理无用的镜像和容器
echo "🧹 清理无用的Docker资源..."
docker container prune -f >/dev/null 2>&1 || true
docker image prune -f >/dev/null 2>&1 || true

# 构建并启动容器
echo "🔨 构建并启动容器..."
docker-compose -f "$DOCKER_COMPOSE_FILE" up --build -d

# 等待容器启动
echo "⏳ 等待容器启动..."
for i in {1..30}; do
    if docker-compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
        echo "✅ 容器启动成功"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ 容器启动超时，查看日志："
        docker-compose -f "$DOCKER_COMPOSE_FILE" logs --tail=50
        exit 1
    fi
    echo "⏳ 等待中... ($i/30)"
    sleep 2
done

# 显示容器状态
echo "📊 容器状态："
docker-compose -f "$DOCKER_COMPOSE_FILE" ps

# 健康检查
echo "🏥 检查应用健康状态..."
for i in {1..15}; do
    if curl -f -s http://localhost:$APP_PORT/health >/dev/null 2>&1; then
        echo "✅ 应用健康检查通过"
        break
    fi
    if [ $i -eq 15 ]; then
        echo "⚠️  应用健康检查失败，但容器已启动，请检查应用日志"
        echo "📋 查看应用日志: docker-compose -f $DOCKER_COMPOSE_FILE logs app"
        break
    fi
    echo "⏳ 健康检查中... ($i/15)"
    sleep 2
done

# 显示访问信息
SERVER_IP=$(curl -s --connect-timeout 5 http://checkip.amazonaws.com/ 2>/dev/null || hostname -I | awk '{print $1}' || echo "localhost")
echo ""
echo "🎉 部署完成！"
echo "📍 应用访问地址："
echo "  - 外网访问: http://$SERVER_IP:$APP_PORT"
echo "  - 本地访问: http://localhost:$APP_PORT"
echo ""
echo "📋 常用管理命令："
echo "  查看日志: docker-compose -f $DOCKER_COMPOSE_FILE logs -f"
echo "  停止服务: docker-compose -f $DOCKER_COMPOSE_FILE down"
echo "  重启服务: docker-compose -f $DOCKER_COMPOSE_FILE restart"
echo "  查看状态: docker-compose -f $DOCKER_COMPOSE_FILE ps"
echo "  进入容器: docker-compose -f $DOCKER_COMPOSE_FILE exec app bash"
echo ""
echo "💡 提示: 如需更新应用，请重新运行此脚本" 