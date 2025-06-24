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

# 检查Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装Docker Compose"
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