#!/bin/bash
# daily_report_agent.sh
# 日报生成完整流程 - 由 OpenClaw Cron 调用子代理执行

set -e

WORKSPACE="/root/.openclaw/workspace/daily-tech-finance-reports"
REPORTS_DIR="$WORKSPACE/reports"
DATE=$(date +%Y%m%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
OUTPUT_DIR="$REPORTS_DIR/$YEAR$MONTH/$DAY"
MONITOR_DATA="$WORKSPACE/monitor_data"
LOG_FILE="$WORKSPACE/logs/agent_report_${DATE}.log"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$WORKSPACE/logs"
mkdir -p "$MONITOR_DATA"/{twitter,github,reports}

exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================"
echo "Daily Report Agent - $(date)"
echo "========================================"
echo ""

# Step 1: 运行 GitHub 监控
echo "▶ Step 1: Running GitHub Monitor..."
cd "$WORKSPACE"
if [ -f "scripts/monitor.py" ]; then
    python3 scripts/monitor.py --once 2>/dev/null || echo "Monitor completed (with warnings)"
fi

# 获取最新监控报告
LATEST_MONITOR_REPORT=$(ls -t "$MONITOR_DATA/reports"/daily_*.md 2>/dev/null | head -1)
if [ -n "$LATEST_MONITOR_REPORT" ]; then
    echo "✓ Found monitor report: $(basename $LATEST_MONITOR_REPORT)"
else
    echo "⚠ No monitor report found"
fi

# Step 2: 复制模板到输出目录
echo ""
echo "▶ Step 2: Preparing templates..."

# 创建临时标记文件，表示需要 AI 填充
mkdir -p "$OUTPUT_DIR"
touch "$OUTPUT_DIR/.needs_ai_fill"

# 复制配置文件
cp "$WORKSPACE/config/banking_ai_sources.yaml" "$OUTPUT_DIR/" 2>/dev/null || true
cp "$WORKSPACE/templates/regulatory_radar_template.md" "$OUTPUT_DIR/" 2>/dev/null || true

echo "✓ Templates prepared"

# Step 3: 创建 AI 任务文件
echo ""
echo "▶ Step 3: Creating AI task file..."

cat > "$OUTPUT_DIR/ai_task.json" << EOF
{
  "task": "generate_daily_report",
  "date": "$YEAR-$MONTH-$DAY",
  "output_dir": "$OUTPUT_DIR",
  "monitor_report": "$LATEST_MONITOR_REPORT",
  "requirements": {
    "languages": ["zh_CN", "en_US"],
    "sections": [
      "今日主线/Todays Focus",
      "今日必读/Must-Read Today",
      "专家观点/Expert Insights",
      "监管雷达/Regulatory Radar",
      "同业动态/Peer Bank Intelligence",
      "技术-业务映射/Tech-Business Mapping",
      "GitHub趋势/GitHub Trends",
      "关键阈值监测/Threshold Monitoring",
      "行动建议/Action Items"
    ],
    "sources": {
      "regulatory": ["BIS", "Fed", "OCC", "PBOC", "HKMA", "MAS", "ECB"],
      "banks": ["JPMorgan", "Goldman Sachs", "Citi", "HSBC", "招商银行", "平安银行", "工商银行"],
      "experts": ["Andrej Karpathy", "Andrew Ng", "Jim Marous"]
    }
  }
}
EOF

echo "✓ AI task file created"

# Step 4: 启动子代理填充报告
echo ""
echo "▶ Step 4: Spawning AI subagent..."
echo "   Output: $OUTPUT_DIR"
echo ""

# 这里会由 OpenClaw 调用子代理
# 子代理将读取 ai_task.json 并执行搜索和报告生成

echo "========================================"
echo "Waiting for AI subagent to complete..."
echo "========================================"
