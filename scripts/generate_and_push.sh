#!/bin/bash
# 日报生成脚本 - 调用子代理搜索新闻
# 此脚本只负责调用子代理，实际内容由子代理生成

set -e

WORKSPACE="/root/.openclaw/workspace"
REPO_PATH="${WORKSPACE}/daily-tech-finance-reports"

echo "🚀 开始生成 $(date +%Y-%m-%d) 的科技金融日报..."
echo "📅 当前系统时间: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo ""
echo "⚠️ 注意：此脚本需要由 OpenClaw 子代理调用"
echo "子代理将执行："
echo "  1. session_status 获取当前时间"
echo "  2. kimi_search 搜索新闻"
echo "  3. 生成 Markdown + HTML + PDF"
echo "  4. Git Flow 推送到 GitHub"
echo ""
echo "请确保通过 OpenClaw 运行此脚本，以便子代理可以调用搜索工具。"
