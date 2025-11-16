#!/bin/bash

# ShadCn Pro 应用启动脚本
# 作者: AI Assistant
# 创建时间: 2025-10-26
# 版本: v1.0.0

echo "🚀 ShadCn Pro 应用启动脚本"
echo "=================================="
echo ""

# 显示项目信息
echo "📋 项目信息:"
echo "  名称: ShadCn Pro"
echo "  版本: 1.0.0"
echo "  框架: React 18 + TypeScript + Vite + Shadcn/ui"
echo "  特点: PC端优化 + 权限系统 + 主题切换"
echo ""

# 获取本地IP地址
get_local_ip() {
    # 尝试多种方法获取本地IP地址
    if command -v ip >/dev/null 2>&1; then
        # Linux 系统
        ip route get 1.1.1.1 | awk '{print $7}' | head -1
    elif command -v ifconfig >/dev/null 2>&1; then
        # macOS 系统
        ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1
    else
        echo "127.0.0.1"
    fi
}

LOCAL_IP=$(get_local_ip)
echo "🌐 本地IP地址: $LOCAL_IP"
echo ""

# 检查项目状态
check_project_status() {
    echo "📊 项目状态检查:"

    # 检查依赖
    if [ -d "node_modules" ]; then
        echo "  ✅ 依赖已安装"
    else
        echo "  ❌ 依赖未安装"
    fi

    # 检查配置文件
    if [ -f ".env.dev" ]; then
        echo "  ✅ 环境配置文件存在"
    else
        echo "  ❌ 环境配置文件缺失"
    fi

    # 检查认证配置
    if [ -f ".env.dev" ]; then
        if grep -q "VITE_AUTH_ENABLED=false" .env.dev; then
            echo "  🔓 认证已禁用 (开发模式)"
        else
            echo "  🔒 认证已启用"
        fi
    fi

    # 检查端口占用
    if lsof -Pi :5176 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "  📡 端口 5176 已被占用"
    else
        echo "  📡 端口 5176 可用"
    fi

    echo ""
}

# 检查是否安装了依赖
if [ ! -d "node_modules" ]; then
    echo "📦 首次运行，正在安装依赖..."
    npm install
    echo ""
fi

# 显示项目状态
check_project_status

# 显示菜单
echo "请选择要执行的操作："
echo "1) 启动开发服务器 (npm run dev) [推荐]"
echo "2) 构建生产版本 (npm run build)"
echo "3) 预览生产版本 (npm run preview)"
echo "4) 安装/更新依赖 (npm install)"
echo "5) 清理缓存和重置 (npm run clean)"
echo "6) 退出"
echo ""
echo "💡 提示: 直接按 Enter 键使用默认选项 1"
echo ""

# 设置默认选项为 1
read -p "请输入选项 (1-6) [默认: 1]: " choice
choice=${choice:-1}

case $choice in
    1)
        echo "🔧 启动开发服务器..."

        # 强制关闭 5176 端口
        echo "🔍 检查端口 5176 占用情况..."
        PID=$(lsof -ti:5176)
        if [ ! -z "$PID" ]; then
            echo "⚠️  端口 5176 被进程 $PID 占用，正在关闭..."
            kill -9 $PID 2>/dev/null
            sleep 1
            echo "✅ 端口 5176 已释放"
        else
            echo "✅ 端口 5176 可用"
        fi
        echo ""

        echo "📍 本地访问: http://localhost:5176/"
        echo "🌐 网络访问: http://$LOCAL_IP:5176/"
        echo "🚪 监听地址: http://0.0.0.0:5176/"
        echo "💡 按 Ctrl+C 停止服务器"
        echo "💡 开发服务器运行在端口 5176 (0.0.0.0)"
        echo "🔓 认证已禁用，可直接使用所有功能"
        echo ""
        npm run dev -- --host 0.0.0.0 --port 5176
        ;;
    2)
        echo "🏗️  构建生产版本..."
        npm run build
        echo ""
        if [ $? -eq 0 ]; then
            echo "✅ 构建完成！构建文件位于 dist/ 目录"
            echo "📊 构建大小:"
            du -sh dist/
        else
            echo "❌ 构建失败，请检查错误信息"
        fi
        ;;
    3)
        echo "👀 预览生产版本..."
        if [ ! -d "dist" ]; then
            echo "❌ 未找到构建文件，请先运行构建命令 (选项 2)"
            echo "💡 或直接运行: npm run build && npm run preview"
            exit 1
        fi

        # 强制关闭 5176 端口
        echo "🔍 检查端口 5176 占用情况..."
        PID=$(lsof -ti:5176)
        if [ ! -z "$PID" ]; then
            echo "⚠️  端口 5176 被进程 $PID 占用，正在关闭..."
            kill -9 $PID 2>/dev/null
            sleep 1
            echo "✅ 端口 5176 已释放"
        else
            echo "✅ 端口 5176 可用"
        fi
        echo ""

        echo "📍 本地访问: http://localhost:5176/"
        echo "🌐 网络访问: http://$LOCAL_IP:5176/"
        echo "🚪 监听地址: http://0.0.0.0:5176/"
        echo "💡 按 Ctrl+C 停止预览服务器"
        echo ""
        npm run preview -- --host 0.0.0.0 --port 5176
        ;;
    4)
        echo "📦 安装/更新依赖..."
        npm install
        echo ""
        if [ $? -eq 0 ]; then
            echo "✅ 依赖安装/更新完成！"
        else
            echo "❌ 依赖安装失败，请检查网络连接"
        fi
        ;;
    5)
        echo "🧹 清理缓存和重置..."
        echo "🗑️  清理 node_modules..."
        rm -rf node_modules
        echo "🗑️  清理 package-lock.json..."
        rm -f package-lock.json
        echo "🗑️  清理 dist 目录..."
        rm -rf dist
        echo "🗑️  清理 .cache 目录..."
        rm -rf node_modules/.cache
        echo ""
        echo "✅ 清理完成！"
        echo "💡 现在可以重新运行脚本安装依赖"
        ;;
    6)
        echo "👋 感谢使用 ShadCn Pro！"
        echo ""
        echo "📚 文档位置:"
        echo "  - README.md: 项目说明"
        echo "  - docs/: 完整文档"
        echo "  - aries/: 深度文档"
        echo ""
        echo "🌐 项目地址:"
        echo "  - GitHub: https://github.com/wing/wing-react"
        echo "  - 本地: http://localhost:5176/"
        echo ""
        exit 0
        ;;
    *)
        echo "❌ 无效选项 '$choice'，请重新运行脚本"
        echo "💡 有效选项: 1-6"
        exit 1
        ;;
esac
