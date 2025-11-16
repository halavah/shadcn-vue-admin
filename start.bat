@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ShadCn Pro 应用启动脚本
REM 作者: AI Assistant
REM 创建时间: 2025-10-27
REM 版本: v1.0.0

REM 使用 nvm 动态切换到任意 v22 版本的 Node.js (仅影响当前批处理会话)
echo 🔍 检查 Node.js v22 版本...

REM 检查 nvm 是否可用
nvm version >nul 2>&1
if !errorlevel! neq 0 (
    echo ❌ nvm 未找到或不可用
    echo 💡 请确保已安装 nvm 并添加到 PATH
    echo 💡 Windows 用户可安装 nvm-windows: https://github.com/coreybutler/nvm-windows
    pause
    exit /b 1
)

REM 检查是否有 v22 版本可用
nvm list 22 >nul 2>&1
if !errorlevel! neq 0 (
    echo ❌ 未找到任何 Node.js v22 版本，正在安装最新的 v22 版本...
    nvm install 22
    if !errorlevel! neq 0 (
        echo ❌ 安装失败，请检查网络连接
        pause
        exit /b 1
    )
)

echo 🔄 切换到 Node.js v22 版本 (仅影响当前批处理会话)
nvm use 22
if !errorlevel! neq 0 (
    echo ❌ 无法切换到 Node.js v22 版本
    pause
    exit /b 1
)

REM 显示当前 Node.js 版本
for /f "tokens=*" %%a in ('node --version') do set "NODE_VERSION=%%a"
echo 当前版本: %NODE_VERSION%

echo.
echo 🚀 ShadCn Pro 应用启动脚本
echo ==================================
echo.

REM 显示项目信息
echo 📋 项目信息:
echo   名称: ShadCn Pro
echo   版本: 1.0.0
echo   框架: React 18 + TypeScript + Vite + Shadcn/ui
echo   特点: PC端优化 + 权限系统 + 主题切换
echo.

REM 获取本地IP地址
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set "LOCAL_IP=%%a"
    set "LOCAL_IP=!LOCAL_IP:~1!"
    goto :ip_found
)
:ip_found
if not defined LOCAL_IP set "LOCAL_IP=127.0.0.1"
echo 🌐 本地IP地址: %LOCAL_IP%
echo.

REM 检查依赖
:check_dependencies
if exist "node_modules\" (
    set "DEPS_STATUS=✅ 依赖已安装"
) else (
    set "DEPS_STATUS=❌ 依赖未安装"
    set "NEED_INSTALL=1"
)

REM 检查配置文件
if exist ".env.dev" (
    set "ENV_STATUS=✅ 环境配置文件存在"
) else (
    set "ENV_STATUS=❌ 环境配置文件缺失"
)

REM 检查认证配置
set "AUTH_STATUS=🔒 认证已启用"
if exist ".env.dev" (
    findstr /C:"VITE_AUTH_ENABLED=false" .env.dev >nul 2>&1
    if !errorlevel! equ 0 (
        set "AUTH_STATUS=🔓 认证已禁用 (开发模式)"
    )
)

REM 检查端口占用
netstat -ano | findstr ":5173" | findstr "LISTENING" >nul 2>&1
if !errorlevel! equ 0 (
    set "PORT_STATUS=📡 端口 5173 已被占用"
) else (
    set "PORT_STATUS=📡 端口 5173 可用"
)

REM 显示项目状态
echo 📊 项目状态检查:
echo   %DEPS_STATUS%
echo   %ENV_STATUS%
echo   %AUTH_STATUS%
echo   %PORT_STATUS%
echo.

REM 首次运行时安装依赖
if defined NEED_INSTALL (
    echo 📦 首次运行，正在安装依赖...
    call pnpm install
    if !errorlevel! neq 0 (
        echo ❌ 依赖安装失败，请检查网络连接
        pause
        exit /b 1
    )
    echo.
)

REM 显示菜单
:menu
cls
echo.
echo 🚀 ShadCn Pro 应用启动脚本
echo ==================================
echo.
echo 📋 项目信息:
echo   名称: ShadCn Pro
echo   版本: 1.0.0
echo   框架: React 18 + TypeScript + Vite + Shadcn/ui
echo.
echo 🌐 本地IP地址: %LOCAL_IP%
echo.
echo 📊 项目状态:
echo   %DEPS_STATUS%
echo   %AUTH_STATUS%
echo   %PORT_STATUS%
echo.
echo ==========================================
echo 请选择要执行的操作：
echo ==========================================
echo.
echo   1. 启动开发服务器 (pnpm dev) [推荐]
echo   2. 构建生产版本 (pnpm run build)
echo   3. 预览生产版本 (pnpm run preview)
echo   4. 安装/更新依赖 (pnpm install)
echo   5. 清理缓存和重置
echo   6. 退出
echo.
echo 💡 提示: 直接按 Enter 键使用默认选项 1
echo.

set /p "choice=请输入选项 (1-6) [默认: 1]: "
if not defined choice set "choice=1"

if "%choice%"=="1" goto :start_dev
if "%choice%"=="2" goto :build
if "%choice%"=="3" goto :preview
if "%choice%"=="4" goto :install
if "%choice%"=="5" goto :clean
if "%choice%"=="6" goto :exit
goto :invalid_choice

REM ========== 选项 1: 启动开发服务器 ==========
:start_dev
echo.
echo 🔧 启动开发服务器...
echo ==========================================
echo.

REM 强制关闭 5173 端口
echo 🔍 检查端口 5173 占用情况...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5173" ^| findstr "LISTENING"') do (
    echo ⚠️  端口 5173 被进程 %%a 占用，正在关闭...
    taskkill /F /PID %%a >nul 2>&1
    timeout /t 1 /nobreak >nul
    echo ✅ 端口 5173 已释放
    goto :port_freed_dev
)
echo ✅ 端口 5173 可用
:port_freed_dev
echo.

echo 📍 本地访问: http://localhost:5173/
echo 🌐 网络访问: http://%LOCAL_IP%:5173/
echo 🚪 监听地址: http://0.0.0.0:5173/
echo.
echo 💡 按 Ctrl+C 停止服务器
echo 💡 开发服务器运行在端口 5173 (0.0.0.0)
echo 🔓 认证已禁用，可直接使用所有功能
echo.
echo ==========================================
echo.
call pnpm dev --host 0.0.0.0 --port 5173
goto :end

REM ========== 选项 2: 构建生产版本 ==========
:build
echo.
echo 🏗️  构建生产版本...
echo ==========================================
echo.
call pnpm run build
if !errorlevel! equ 0 (
    echo.
    echo ✅ 构建完成！构建文件位于 dist\ 目录
    echo.
    echo 📊 构建信息:
    if exist "dist\" (
        for /f "tokens=3" %%a in ('dir /s "dist" ^| findstr /C:"File(s)"') do echo   文件数量: %%a
        for /f "tokens=3" %%a in ('dir /s "dist" ^| findstr /C:"bytes"') do echo   总大小: %%a bytes
    )
    echo.
    echo 💡 提示: 可以选择选项 3 预览构建结果
) else (
    echo.
    echo ❌ 构建失败，请检查错误信息
)
echo.
pause
goto :menu

REM ========== 选项 3: 预览生产版本 ==========
:preview
if not exist "dist\" (
    echo.
    echo ❌ 未找到构建文件，请先运行构建命令 (选项 2)
    echo 💡 或直接运行: pnpm run build && pnpm run preview
    echo.
    pause
    goto :menu
)
echo.
echo 👀 预览生产版本...
echo ==========================================
echo.

REM 强制关闭 5173 端口
echo 🔍 检查端口 5173 占用情况...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":5173" ^| findstr "LISTENING"') do (
    echo ⚠️  端口 5173 被进程 %%a 占用，正在关闭...
    taskkill /F /PID %%a >nul 2>&1
    timeout /t 1 /nobreak >nul
    echo ✅ 端口 5173 已释放
    goto :port_freed_preview
)
echo ✅ 端口 5173 可用
:port_freed_preview
echo.

echo 📍 本地访问: http://localhost:5173/
echo 🌐 网络访问: http://%LOCAL_IP%:5173/
echo 🚪 监听地址: http://0.0.0.0:5173/
echo.
echo 💡 按 Ctrl+C 停止预览服务器
echo.
echo ==========================================
echo.
call pnpm run preview --host 0.0.0.0 --port 5173
goto :end

REM ========== 选项 4: 安装/更新依赖 ==========
:install
echo.
echo 📦 安装/更新依赖...
echo ==========================================
echo.
call pnpm install
if !errorlevel! equ 0 (
    echo.
    echo ✅ 依赖安装/更新完成！
    set "DEPS_STATUS=✅ 依赖已安装"
) else (
    echo.
    echo ❌ 依赖安装失败，请检查网络连接
)
echo.
pause
goto :menu

REM ========== 选项 5: 清理缓存和重置 ==========
:clean
echo.
echo 🧹 清理缓存和重置...
echo ==========================================
echo.
echo 🗑️  清理 node_modules...
if exist "node_modules\" (
    rd /s /q "node_modules"
    echo   ✅ node_modules 已删除
) else (
    echo   ℹ️  node_modules 不存在
)
echo.
echo 🗑️  清理 package-lock.json...
if exist "package-lock.json" (
    del /f /q "package-lock.json"
    echo   ✅ package-lock.json 已删除
) else (
    echo   ℹ️  package-lock.json 不存在
)
echo.
echo 🗑️  清理 dist 目录...
if exist "dist\" (
    rd /s /q "dist"
    echo   ✅ dist 目录已删除
) else (
    echo   ℹ️  dist 目录不存在
)
echo.
echo ✅ 清理完成！
echo 💡 现在可以重新运行脚本安装依赖
echo.
set "DEPS_STATUS=❌ 依赖未安装"
set "NEED_INSTALL=1"
pause
goto :menu

REM ========== 选项 6: 退出 ==========
:exit
cls
echo.
echo 👋 感谢使用 ShadCn Pro！
echo.
echo ==========================================
echo 📚 文档位置:
echo ==========================================
echo   - README.md: 项目说明
echo   - docs\: 完整文档
echo   - aries\: 深度文档
echo.
echo ==========================================
echo 🌐 项目地址:
echo ==========================================
echo   - GitHub: https://github.com/wing/wing-react
echo   - 本地: http://localhost:5173/
echo.
echo ==========================================
echo 快捷命令:
echo ==========================================
echo   pnpm dev      - 启动开发服务器
echo   pnpm run build   - 构建生产版本
echo   pnpm run preview  - 预览生产版本
echo   pnpm install      - 安装依赖
echo.
exit /b 0

REM ========== 无效选项 ==========
:invalid_choice
echo.
echo ❌ 无效选项 '%choice%'
echo 💡 有效选项: 1-6
echo.
pause
goto :menu

:end
echo.
echo ==========================================
echo 服务已停止
echo ==========================================
echo.
pause
