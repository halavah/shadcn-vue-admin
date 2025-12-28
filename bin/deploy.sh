#!/bin/bash
# ============================================================================
# Git Deploy Tool (自动提交推送)
# ============================================================================
# 功能说明：
#   自动执行 git 工作流：暂存 -> 提交 -> 拉取 -> 推送
#
# 工作流程：
#   1. 检测当前分支
#   2. 暂存所有更改（git add .）
#   3. 检查是否有更改需要提交
#      - 有更改：使用时间戳提交 -> 拉取 -> 推送
#      - 无更改：检查是否有未推送的提交
#        * 有未推送提交：拉取 -> 推送
#        * 无未推送提交：仅拉取
#   4. 自动处理远程更新
#
# 运行方式：
#   ./deploy.sh
#
# 提交信息格式：
#   时间戳格式：YYYYMMDD_HHMMSS
#   示例：20250122_143052
#
# 使用场景：
#   - 快速保存和同步代码更改
#   - 自动化日常提交推送操作
#   - 确保本地和远程保持同步
#
# 注意事项：
#   - 会提交所有未暂存的更改
#   - 提交信息为时间戳，不包含详细描述
#   - 如果拉取失败，需要手动解决冲突后重新运行
#   - 不会执行强制推送，保证远程历史安全
# ============================================================================
# Navigate to the project root directory
cd "$(dirname "$0")/.."
# Get current branch
current_branch=$(git branch --show-current)
if [ $? -ne 0 ] || [ -z "$current_branch" ]; then
    echo "Failed to detect current branch."
    exit 1
fi
echo "Current branch: $current_branch"
echo ""
# Stage all changes first
echo "Staging all changes..."
git add .
if [ $? -ne 0 ]; then
    echo "Failed to stage changes."
    exit 1
fi
# Check if there are changes to commit
git diff --staged --quiet
if [ $? -eq 0 ]; then
    echo "No changes to commit."
    # Check if there are unpushed commits
    unpushed_commits=$(git log origin/$current_branch..$current_branch 2>/dev/null)
    if [ -n "$unpushed_commits" ]; then
        echo "Found unpushed commits. Syncing with remote..."
        # Pull first
        echo "Pulling latest changes from origin/$current_branch..."
        git pull origin $current_branch
        if [ $? -ne 0 ]; then
            echo "Failed to pull changes."
            exit 1
        fi
        # Push unpushed commits
        echo "Pushing unpushed commits to origin/$current_branch..."
        git push origin $current_branch
        if [ $? -ne 0 ]; then
            echo "Failed to push changes."
            exit 1
        fi
        echo "[OK] Unpushed commits successfully pushed."
        exit 0
    fi
    # If no changes and no unpushed commits, just pull
    echo "Pulling latest changes from origin/$current_branch..."
    git pull origin $current_branch
    exit 0
fi
# Commit changes with timestamped message
timestamp=$(date +"%Y%m%d_%H%M%S")
echo "Committing changes with timestamp: $timestamp..."
git commit -m "$timestamp"
if [ $? -ne 0 ]; then
    echo "Failed to commit changes."
    exit 1
fi
# Pull latest changes from the remote repository
echo "Pulling latest changes from origin/$current_branch..."
git pull origin $current_branch
if [ $? -ne 0 ]; then
    echo "Failed to pull changes. Resolve conflicts if any, and rerun the script."
    exit 1
fi
# Push changes to the repository
echo "Pushing changes to origin/$current_branch..."
git push origin $current_branch
if [ $? -ne 0 ]; then
    echo "Failed to push changes."
    exit 1
fi
echo "Changes successfully pulled, committed, and pushed."
exit 0
