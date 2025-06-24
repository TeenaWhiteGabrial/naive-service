#!/bin/bash

# 自动部署脚本 - 初始化环境
# 使用方法: chmod +x autoDeploy.sh && ./autoDeploy.sh

set -e  # 遇到错误立即退出

# 定义变量
GIT_REPO="git@github.com:TeenaWhiteGabrial/naive-service.git"
APP_DIR="/usr/src/code/naive-service"
APP_BRANCH="main"

echo "🚀 开始初始化自动部署环境..."

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
    echo "✅ Docker Compose 已安装: $(docker-compose --version)"
elif docker compose version &> /dev/null 2>&1; then
    echo "✅ Docker Compose (plugin) 已安装: $(docker compose version)"
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
    echo "   或者使用一键部署脚本: sudo bash one-click-deploy.sh"
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

# 给脚本执行权限
echo "🔧 设置脚本权限..."
chmod +x deploy_production.sh

echo "✅ 环境初始化完成，开始部署..."

# 运行部署脚本
./deploy_production.sh