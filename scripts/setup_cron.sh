#!/bin/bash
# setup_cron.sh - 设置定时任务

set -e

WORKSPACE="/root/.openclaw/workspace/daily-tech-finance-reports"
LOG_DIR="$WORKSPACE/logs"

echo "========================================"
echo "  设置定时任务 (Cron Jobs)"
echo "========================================"
echo ""

# 创建日志目录
mkdir -p "$LOG_DIR"

# 检查cron
if ! command -v crontab > /dev/null 2>&1; then
    echo "安装 cron..."
    apt-get update -qq && apt-get install -y -qq cron
fi

# 获取当前crontab
CURRENT_CRON=$(crontab -l 2>/dev/null || echo "")

# 删除旧任务
CURRENT_CRON=$(echo "$CURRENT_CRON" | grep -v "Banking AI Monitor" | grep -v "daily-tech-finance-reports" || true)

# 生成cron内容
CRON_CONTENT="# Banking AI Monitor - 定时任务
# GitHub监控 - 每3小时
0 */3 * * * cd $WORKSPACE && python3 scripts/monitor.py --once >> $LOG_DIR/monitor.log 2>&1

# 日报生成 - 每天6:13 (双语版本 v3)
13 6 * * * cd $WORKSPACE && bash scripts/generate_report_v3.sh >> $LOG_DIR/report_gen.log 2>&1

# 清理日志 - 每周日
0 3 * * 0 find $LOG_DIR -name '*.log' -mtime +30 -delete 2>/dev/null"

# 安装新crontab
if [ -n "$CURRENT_CRON" ]; then
    echo -e "${CURRENT_CRON}\n\n${CRON_CONTENT}" | crontab -
else
    echo "$CRON_CONTENT" | crontab -
fi

echo "✓ 定时任务已设置"
echo ""
echo "任务列表:"
echo "--------"
crontab -l | tail -15
echo ""
echo "说明:"
echo "  - GitHub监控: 每3小时 (00:00, 03:00, 06:00...)"
echo "  - 日报生成: 每天6:13"
echo "  - 日志清理: 每周日凌晨3点"
echo ""
echo "日志位置:"
echo "  $LOG_DIR/monitor.log"
echo "  $LOG_DIR/report_gen.log"
