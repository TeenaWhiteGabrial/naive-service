#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_message() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}🔍 $1${NC}"
}

echo -e "${BLUE}🚀 开始生产环境部署 Naive Service 项目...${NC}"

# 检查必要工具
print_info "检查基础工具..."

# 检查 git
if ! command -v git &> /dev/null; then
    print_error "Git 未安装"
    echo "请安装 Git: sudo apt install git 或 sudo yum install git"
    exit 1
fi

# 检查 node
if ! command -v node &> /dev/null; then
    print_error "Node.js 未安装"
    echo "请安装 Node.js: https://nodejs.org/"
    exit 1
fi

# 检查 npm
if ! command -v npm &> /dev/null; then
    print_error "npm 未安装"
    exit 1
fi

# 检查 docker
if ! command -v docker &> /dev/null; then
    print_error "Docker 未安装"
    echo "请安装 Docker: sudo apt install docker.io 或 sudo yum install docker"
    exit 1
fi

# 检查 Docker Compose
print_info "检查 Docker Compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    print_error "Docker Compose 未安装"
    echo "请安装 Docker Compose"
    exit 1
fi
print_message "Docker Compose 已安装"

# 准备工作目录
print_info "准备应用目录..."
APP_DIR="/usr/src/code/naive-service"
mkdir -p /usr/src/code

# 下载或更新代码
cd /usr/src/code
if [ -d "naive-service" ]; then
    print_info "更新现有代码仓库..."
    cd naive-service
    git fetch origin
    git reset --hard origin/main
    print_message "代码更新完成"
else
    print_info "克隆代码仓库..."
    git clone https://github.com/TeenaWhiteGabrial/naive-service.git
    cd naive-service
    print_message "代码克隆完成"
fi

# 在服务器环境安装依赖
print_info "在服务器环境安装 Node.js 依赖..."
npm config set registry https://registry.npmmirror.com
npm install
print_message "依赖安装完成"

# 在服务器环境打包项目
print_info "在服务器环境打包项目..."
npm run build
print_message "项目打包完成"

# 创建 Docker 构建目录
print_info "准备 Docker 构建环境..."
BUILD_DIR="/tmp/naive-service-build"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# 复制必要文件到构建目录
cp -r dist $BUILD_DIR/
cp -r node_modules $BUILD_DIR/
cp package*.json $BUILD_DIR/
if [ -d "src/assets" ]; then
    mkdir -p $BUILD_DIR/src
    cp -r src/assets $BUILD_DIR/src/
fi

# 复制 Docker 相关文件
cp docker-compose.prod.yml $BUILD_DIR/
cp Dockerfile.prod $BUILD_DIR/

print_message "构建文件准备完成"

# 清理现有容器和服务
print_info "清理现有容器和服务..."
cd $APP_DIR
$COMPOSE_CMD -f docker-compose.prod.yml down --remove-orphans 2>/dev/null || true

# 检查并释放端口
print_info "检查端口占用情况..."
if ss -tlnp | grep -q ":9090 "; then
    print_warning "端口 9090 被占用，正在释放..."
    fuser -k 9090/tcp 2>/dev/null || true
    sleep 2
fi

if ss -tlnp | grep -q ":27017 "; then
    print_warning "端口 27017 被占用，正在释放..."
    fuser -k 27017/tcp 2>/dev/null || true
    sleep 2
fi

print_message "端口 9090 可用"
print_message "端口 27017 可用"

# 清理无用资源
print_info "清理无用的Docker资源..."
docker system prune -f > /dev/null 2>&1

# 构建并启动容器
print_info "构建并启动容器..."
cd $BUILD_DIR
$COMPOSE_CMD -f docker-compose.prod.yml up --build -d

# 等待服务启动
print_info "等待服务启动..."
sleep 10

# 检查服务状态
print_info "检查服务状态..."
if $COMPOSE_CMD -f docker-compose.prod.yml ps | grep -q "Up"; then
    print_message "容器启动成功"
    
    # 获取服务器IP
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    echo -e "\n${GREEN}🎉 部署成功！${NC}"
    echo -e "📱 应用访问地址: ${BLUE}http://$SERVER_IP:9090${NC}"
    echo -e "📊 健康检查: ${BLUE}http://$SERVER_IP:9090/health${NC}"
    echo -e "\n${YELLOW}📋 常用管理命令:${NC}"
    echo -e "  查看日志: ${BLUE}cd $APP_DIR && $COMPOSE_CMD -f docker-compose.prod.yml logs -f${NC}"
    echo -e "  重启服务: ${BLUE}cd $APP_DIR && $COMPOSE_CMD -f docker-compose.prod.yml restart${NC}"
    echo -e "  停止服务: ${BLUE}cd $APP_DIR && $COMPOSE_CMD -f docker-compose.prod.yml down${NC}"
else
    print_error "容器启动失败"
    echo -e "📋 查看错误日志: ${BLUE}$COMPOSE_CMD -f docker-compose.prod.yml logs${NC}"
    exit 1
fi

# 清理临时构建目录
rm -rf $BUILD_DIR

print_message "部署完成，临时文件已清理"