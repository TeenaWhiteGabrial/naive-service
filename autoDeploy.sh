#!/bin/bash

# Naive Service 生产环境部署脚本
# 使用方法: chmod +x autoDeploy.sh && sudo ./autoDeploy.sh

set -e  # 遇到错误立即退出

# 定义变量
GIT_REPO="git@github.com:TeenaWhiteGabrial/naive-service.git"
APP_DIR="/usr/src/code/naive-service"
APP_BRANCH="main"
DOCKER_COMPOSE_FILE="docker-compose.prod.yml"
APP_PORT=9090
MONGO_PORT=27017
APP_CONTAINER_NAME="naive-service-app"
MONGO_CONTAINER_NAME="naive-service-mongodb"

echo "🚀 开始生产环境部署 Naive Service 项目..."

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "❌ 请使用 sudo 运行此脚本"
   exit 1
fi

# 检查基础工具是否安装
echo "🔍 检查基础工具..."
for tool in git docker; do
    if ! command -v $tool &> /dev/null; then
        echo "❌ $tool 未安装，请先安装"
        exit 1
    fi
done

# 检查Docker Compose（支持新旧版本）
echo "🔍 检查 Docker Compose..."
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose 已安装"
elif docker compose version &> /dev/null 2>&1; then
    echo "✅ Docker Compose (plugin) 已安装"
    # 如果只有新版本的 docker compose，创建兼容性别名
    if [ ! -f /usr/local/bin/docker-compose ]; then
        echo "🔧 创建 docker-compose 兼容性别名..."
        echo '#!/bin/bash' > /usr/local/bin/docker-compose
        echo 'docker compose "$@"' >> /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        # 创建软链接到常用路径
        ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose 2>/dev/null || true
    fi
else
    echo "❌ Docker Compose 未安装"
    echo "💡 提示：请先安装 Docker Compose"
    echo "   Ubuntu/Debian: sudo apt-get install docker-compose"
    echo "   CentOS/RHEL: sudo yum install docker-compose"
    exit 1
fi

# 创建应用目录
echo "📁 准备应用目录..."
mkdir -p "$(dirname "$APP_DIR")"

# 初始化或更新代码仓库
if [ -d "$APP_DIR/.git" ]; then
    echo "📥 更新现有代码仓库..."
    cd "$APP_DIR"
    git fetch origin
    git reset --hard origin/$APP_BRANCH
    git clean -fd
else
    echo "📥 克隆代码仓库..."
    if [ -d "$APP_DIR" ]; then
        rm -rf "$APP_DIR"
    fi
    git clone --branch "$APP_BRANCH" "$GIT_REPO" "$APP_DIR"
    cd "$APP_DIR"
fi

# 检查是否在正确的项目目录中
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "❌ 未找到 $DOCKER_COMPOSE_FILE 文件，项目可能有问题"
    exit 1
fi

echo "✅ 代码准备完成，开始部署..."

# 优化的停止和清理函数
cleanup_containers() {
    echo "🧹 清理现有容器和服务..."
    
    # 停止 docker-compose 服务（兼容新旧版本）
    if command -v docker-compose &> /dev/null; then
        if docker-compose -f "$DOCKER_COMPOSE_FILE" ps -q 2>/dev/null | grep -q .; then
            echo "⏹️  停止 Docker Compose 服务..."
            docker-compose -f "$DOCKER_COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
        fi
    elif docker compose version &> /dev/null 2>&1; then
        if docker compose -f "$DOCKER_COMPOSE_FILE" ps -q 2>/dev/null | grep -q .; then
            echo "⏹️  停止 Docker Compose 服务..."
            docker compose -f "$DOCKER_COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
        fi
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
            echo "⚠️  端口 $port 被占用，自动释放..."
            fuser -k $port/tcp 2>/dev/null || true
            echo "✅ 端口 $port 已释放"
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

# 确定使用的 Docker Compose 命令
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose 未找到，请检查安装"
    exit 1
fi

# 构建和启动
if $COMPOSE_CMD -f "$DOCKER_COMPOSE_FILE" up --build -d; then
    echo "✅ 容器构建和启动成功"
else
    echo "❌ 容器构建失败"
    echo "📋 查看错误日志: $COMPOSE_CMD -f $DOCKER_COMPOSE_FILE logs"
    exit 1
fi

# 等待容器启动
echo "⏳ 等待容器启动..."
for i in {1..30}; do
    if $COMPOSE_CMD -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
        echo "✅ 容器启动成功"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ 容器启动超时，查看日志："
        $COMPOSE_CMD -f "$DOCKER_COMPOSE_FILE" logs --tail=50
        exit 1
    fi
    echo "⏳ 等待中... ($i/30)"
    sleep 2
done

# 显示容器状态
echo "📊 容器状态："
$COMPOSE_CMD -f "$DOCKER_COMPOSE_FILE" ps

# 健康检查
echo "🏥 检查应用健康状态..."
for i in {1..15}; do
    if curl -f -s http://localhost:$APP_PORT/health >/dev/null 2>&1; then
        echo "✅ 应用健康检查通过"
        break
    fi
    if [ $i -eq 15 ]; then
        echo "⚠️  应用健康检查失败，但容器已启动，请检查应用日志"
        echo "📋 查看应用日志: $COMPOSE_CMD -f $DOCKER_COMPOSE_FILE logs app"
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
echo "  查看日志: $COMPOSE_CMD -f $DOCKER_COMPOSE_FILE logs -f"
echo "  停止服务: $COMPOSE_CMD -f $DOCKER_COMPOSE_FILE down"
echo "  重启服务: $COMPOSE_CMD -f $DOCKER_COMPOSE_FILE restart"
echo "  查看状态: $COMPOSE_CMD -f $DOCKER_COMPOSE_FILE ps"
echo "  进入容器: $COMPOSE_CMD -f $DOCKER_COMPOSE_FILE exec app bash"
echo ""
echo "💡 提示: 如需更新应用，请重新运行此脚本"