#!/bin/bash

# Docker 镜像预拉取脚本
# 预先下载项目所需的所有镜像
# 使用方法: sudo ./preload-images.sh

set -e

echo "🚀 开始预拉取项目所需的Docker镜像..."
echo "================================"

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "❌ 请使用 sudo 运行此脚本"
   exit 1
fi

# 检查Docker是否安装并运行
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker 服务未运行，请启动 Docker 服务"
    exit 1
fi

# 定义项目需要的所有镜像
declare -A IMAGES=(
    ["MongoDB"]="registry.cn-hangzhou.aliyuncs.com/misaka-images/mongo:6.0.2"
    ["Node.js (构建阶段)"]="registry.cn-hangzhou.aliyuncs.com/misaka-images/node:20.8.1-alpine"
    ["Node.js (开发环境)"]="registry.cn-hangzhou.aliyuncs.com/misaka-images/node:20.8.1"
    ["Nginx (可选)"]="registry.cn-hangzhou.aliyuncs.com/misaka-images/nginx:alpine"
)

# 拉取镜像的函数
pull_image() {
    local name="$1"
    local image="$2"
    
    echo "📦 拉取 $name 镜像..."
    echo "   镜像: $image"
    
    if docker pull "$image"; then
        echo "✅ $name 镜像拉取成功"
        return 0
    else
        echo "❌ $name 镜像拉取失败"
        return 1
    fi
}

# 显示镜像信息
show_image_info() {
    echo "📋 项目需要的Docker镜像清单："
    echo "================================"
    for name in "${!IMAGES[@]}"; do
        echo "• $name: ${IMAGES[$name]}"
    done
    echo ""
}

# 检查已存在的镜像
check_existing_images() {
    echo "🔍 检查已存在的镜像..."
    local existing_count=0
    
    for name in "${!IMAGES[@]}"; do
        local image="${IMAGES[$name]}"
        if docker image inspect "$image" >/dev/null 2>&1; then
            echo "✅ $name 镜像已存在"
            ((existing_count++))
        else
            echo "❌ $name 镜像不存在，需要拉取"
        fi
    done
    
    echo "📊 已存在 $existing_count/${#IMAGES[@]} 个镜像"
    echo ""
}

# 主要拉取流程
main() {
    show_image_info
    check_existing_images
    
    echo "🚀 开始拉取镜像..."
    local success_count=0
    local failed_images=()
    
    for name in "${!IMAGES[@]}"; do
        local image="${IMAGES[$name]}"
        
        # 检查镜像是否已存在
        if docker image inspect "$image" >/dev/null 2>&1; then
            echo "⏭️  跳过 $name (已存在)"
            ((success_count++))
            continue
        fi
        
        if pull_image "$name" "$image"; then
            ((success_count++))
        else
            failed_images+=("$name")
        fi
        echo ""
    done
    
    # 显示结果
    echo "📊 拉取完成统计："
    echo "✅ 成功: $success_count/${#IMAGES[@]}"
    
    if [ ${#failed_images[@]} -gt 0 ]; then
        echo "❌ 失败: ${#failed_images[@]}"
        echo "失败的镜像:"
        for img in "${failed_images[@]}"; do
            echo "  • $img"
        done
        return 1
    else
        echo "🎉 所有镜像拉取成功！"
        return 0
    fi
}

# 显示镜像大小
show_image_sizes() {
    echo "📊 镜像大小统计："
    for name in "${!IMAGES[@]}"; do
        local image="${IMAGES[$name]}"
        if docker image inspect "$image" >/dev/null 2>&1; then
            local size=$(docker image inspect "$image" --format='{{.Size}}' | awk '{printf "%.1f MB", $1/1024/1024}')
            echo "  • $name: $size"
        fi
    done
}

# 显示帮助信息
show_help() {
    echo "用法: sudo $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -c, --check    仅检查已存在的镜像"
    echo "  -s, --sizes    显示镜像大小统计"
    echo "  -l, --list     显示镜像清单"
    echo ""
}

# 解析命令行参数
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -c|--check)
        show_image_info
        check_existing_images
        exit 0
        ;;
    -s|--sizes)
        show_image_sizes
        exit 0
        ;;
    -l|--list)
        show_image_info
        exit 0
        ;;
    "")
        if main; then
            echo ""
            show_image_sizes
            echo ""
            echo "💡 提示: 现在可以运行 sudo ./autoDeploy.sh 进行部署"
        else
            exit 1
        fi
        ;;
    *)
        echo "❌ 未知选项: $1"
        show_help
        exit 1
        ;;
esac 