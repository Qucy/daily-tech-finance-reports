#!/bin/bash
# trigger_daily_report_subagent.sh
# 触发日报生成子代理 - 由系统 cron 每天调用
# 此脚本简单地将任务转发给 OpenClaw 主会话，由主会话启动子代理

set -e

WORKSPACE="/root/.openclaw/workspace/daily-tech-finance-reports"
DATE=$(date +%Y%m%d)
LOG_FILE="$WORKSPACE/logs/trigger_${DATE}.log"

mkdir -p "$WORKSPACE/logs"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cron triggered daily report generation" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] This script should be called by OpenClaw cron, not system cron" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Please use: openclaw cron add ..." >> "$LOG_FILE"

exit 0
