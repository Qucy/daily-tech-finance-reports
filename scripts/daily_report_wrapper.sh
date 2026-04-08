#!/bin/bash
# daily_report_wrapper.sh
# 日报生成包装脚本 - 由系统 cron 调用
# 此脚本生成模板并创建触发文件，等待 OpenClaw 检测后启动子代理

set -e

WORKSPACE="/root/.openclaw/workspace/daily-tech-finance-reports"
DATE=$(date +%Y%m%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
OUTPUT_DIR="$WORKSPACE/reports/$YEAR$MONTH/$DAY"
LOG_FILE="$WORKSPACE/logs/wrapper_${DATE}.log"
TRIGGER_FILE="$WORKSPACE/.trigger_subagent_${DATE}"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$WORKSPACE/logs"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================"
echo "Daily Report Wrapper - $(date)"
echo "========================================"
echo ""

# Step 1: 运行 GitHub 监控
echo "▶ Step 1: Running GitHub Monitor..."
cd "$WORKSPACE"
if [ -f "scripts/monitor.py" ]; then
    python3 scripts/monitor.py --once 2>/dev/null || echo "Monitor completed (with warnings)"
fi

# Step 2: 生成模板（使用 v3 脚本）
echo ""
echo "▶ Step 2: Generating report templates..."
bash "$WORKSPACE/scripts/generate_report_v3.sh"

# Step 3: 创建触发文件
echo ""
echo "▶ Step 3: Creating trigger file for subagent..."
cat > "$TRIGGER_FILE" << EOF
{
  "date": "$YEAR-$MONTH-$DAY",
  "output_dir": "$OUTPUT_DIR",
  "status": "template_ready",
  "timestamp": "$(date -Iseconds)"
}
EOF

echo "✓ Trigger file created: $TRIGGER_FILE"
echo ""
echo "========================================"
echo "Wrapper completed at $(date)"
echo "========================================"
echo ""
echo "Next: Subagent should detect $TRIGGER_FILE and fill content"
echo "Or manually request: '请生成今日日报'"
