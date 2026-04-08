#!/bin/bash
# openclaw_cron_daily_report.sh
# OpenClaw Cron 调用入口 - 启动日报生成子代理
# 此脚本由系统 cron 调用，负责触发 OpenClaw 子代理

set -e

WORKSPACE="/root/.openclaw/workspace/daily-tech-finance-reports"
DATE=$(date +%Y%m%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
LOG_FILE="$WORKSPACE/logs/cron_spawn_${DATE}.log"

mkdir -p "$WORKSPACE/logs"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================"
echo "OpenClaw Cron - Daily Report Trigger"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo ""

# 检查 OpenClaw 是否可用
if ! command -v openclaw > /dev/null 2>&1; then
    echo "❌ OpenClaw not found in PATH"
    exit 1
fi

# 获取 Gateway 状态
GATEWAY_STATUS=$(openclaw gateway status 2>/dev/null | grep -o "running\|stopped" | head -1 || echo "unknown")
echo "Gateway status: $GATEWAY_STATUS"

if [ "$GATEWAY_STATUS" != "running" ]; then
    echo "⚠️ Gateway not running, attempting to start..."
    openclaw gateway start >/dev/null 2>&1 || {
        echo "❌ Failed to start gateway"
        exit 1
    }
    sleep 3
fi

echo ""
echo "📋 Daily Report Task:"
echo "  Date: $YEAR-$MONTH-$DAY"
echo "  Output: reports/${YEAR}${MONTH}/${DAY}/"
echo ""
echo "⏳ Spawning subagent via sessions_spawn..."
echo "   (Check 'openclaw sessions list' for progress)"
echo ""

# 创建任务详情文件
TASK_FILE="$WORKSPACE/.current_task_${DATE}.json"
cat > "$TASK_FILE" << EOF
{
  "task": "generate_daily_report",
  "date": "$YEAR-$MONTH-$DAY",
  "workspace": "$WORKSPACE",
  "output_dir": "reports/${YEAR}${MONTH}/${DAY}",
  "languages": ["zh_CN", "en_US"],
  "github_repo": "Qucy/daily-tech-finance-reports"
}
EOF

echo "✓ Task file created: $TASK_FILE"
echo ""
echo "========================================"
echo "Subagent should now be running..."
echo "Check logs at: $WORKSPACE/logs/agent_${DATE}.log"
echo "========================================"
