#!/bin/bash

# 一键部署脚本 - 可直接在服务器上运行
# 使用方法: curl -fsSL https://raw.githubusercontent.com/TeenaWhiteGabrial/naive-service/main/one-click-deploy.sh | sudo bash
# 或者: wget -qO- https://raw.githubusercontent.com/TeenaWhiteGabrial/naive-service/main/one-click-deploy.sh | sudo bash

set -e  # 遇到错误立即退出

# 定义变量
GIT_REPO="git@github.com:TeenaWhiteGabrial/naive-service.git"
GIT_REPO_HTTPS="https://github.com/TeenaWhiteGabrial/naive-service.git"
APP_DIR="/usr/src/code/naive-service"
APP_BRANCH="main"

echo "🚀 Naive Service 一键部署开始..."

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "❌ 请使用 sudo 运行此脚本"
   exit 1
fi

# 检查并安装基础工具
echo "🔍 检查和安装基础工具..."

# 检查系统类型
if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian 系统
    PACKAGE_MANAGER="apt-get"
    UPDATE_CMD="apt-get update"
    INSTALL_CMD="apt-get install -y"
elif command -v yum &> /dev/null; then
    # CentOS/RHEL 系统
    PACKAGE_MANAGER="yum"
    UPDATE_CMD="yum update -y"
    INSTALL_CMD="yum install -y"
else
    echo "❌ 不支持的系统类型，请手动安装 git, docker, docker-compose"
    exit 1
fi

# 更新包管理器
echo "📦 更新包管理器..."
$UPDATE_CMD

# 安装 Git
if ! command -v git &> /dev/null; then
    echo "📥 安装 Git..."
    $INSTALL_CMD git
fi

# 安装 Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 安装 Docker..."
    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        # Ubuntu/Debian Docker 安装
        $INSTALL_CMD ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        $INSTALL_CMD docker-ce docker-ce-cli containerd.io docker-compose-plugin
    else
        # CentOS/RHEL Docker 安装
        $INSTALL_CMD docker docker-compose
    fi
    
    # 启动并启用 Docker 服务
    systemctl start docker
    systemctl enable docker
else
    echo "✅ Docker 已安装"
fi

# 安装 Docker Compose
install_docker_compose() {
    echo "🔧 安装 Docker Compose..."
    
    # 尝试多种安装方式
    if [ "$PACKAGE_MANAGER" = "apt-get" ]; then
        # 尝试通过包管理器安装
        if $INSTALL_CMD docker-compose 2>/dev/null; then
            echo "✅ 通过包管理器安装 Docker Compose 成功"
            return 0
        fi
    fi
    
    # 尝试通过 curl 下载安装
    echo "📥 从 GitHub 下载 Docker Compose..."
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")' || echo "v2.24.1")
    
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # 创建软链接到 /usr/bin
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    # 验证安装
    if command -v docker-compose &> /dev/null; then
        echo "✅ Docker Compose 安装成功"
    else
        echo "❌ Docker Compose 安装失败"
        return 1
    fi
}

# 检查 Docker Compose
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose 已安装"
elif docker compose version &> /dev/null; then
    echo "✅ Docker Compose (plugin) 已安装"
    # 创建 docker-compose 别名
    echo '#!/bin/bash' > /usr/local/bin/docker-compose
    echo 'docker compose "$@"' >> /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    install_docker_compose
fi

echo "✅ 基础工具安装完成"

# 创建应用目录
echo "📁 准备应用目录..."
mkdir -p "$(dirname "$APP_DIR")"

# 尝试使用 SSH 克隆，失败则使用 HTTPS
echo "📥 获取代码仓库..."
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
    
    # 尝试 SSH 克隆
    if git clone --branch "$APP_BRANCH" "$GIT_REPO" "$APP_DIR" 2>/dev/null; then
        echo "✅ 使用 SSH 成功克隆"
    else
        echo "⚠️  SSH 克隆失败，尝试 HTTPS..."
        git clone --branch "$APP_BRANCH" "$GIT_REPO_HTTPS" "$APP_DIR"
        echo "✅ 使用 HTTPS 成功克隆"
    fi
    cd "$APP_DIR"
fi

# 给脚本执行权限
echo "🔧 设置脚本权限..."
chmod +x deploy_production.sh

echo "✅ 环境准备完成，开始部署应用..."

# 运行部署脚本
./deploy_production.sh

echo ""
echo "🎉🎉🎉 一键部署完成！"
echo "💡 提示：如需重新部署，只需重新运行此脚本即可" 