#!/bin/bash
# spawn_daily_report_agent.sh
# 启动日报生成子代理 - 由 OpenClaw Cron 调用

set -e

WORKSPACE="/root/.openclaw/workspace/daily-tech-finance-reports"
DATE=$(date +%Y%m%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
REPORT_DIR="reports/${YEAR}${MONTH}/${DAY}"

echo "========================================"
echo "Spawning Daily Report Subagent"
echo "Date: $YEAR-$MONTH-$DAY"
echo "========================================"
echo ""

# 确保目录存在
mkdir -p "$WORKSPACE/$REPORT_DIR"
mkdir -p "$WORKSPACE/logs"

# 创建子代理任务描述
cat > "$WORKSPACE/.subagent_task.md" << 'TASK_EOF'
# Daily Tech-Finance Report Generation Task

## Mission
Generate a comprehensive bilingual (Chinese + English) daily report on AI and Banking for $(date +%Y-%m-%d).

## Workspace
/root/.openclaw/workspace/daily-tech-finance-reports

## Steps to Complete

### Step 1: Gather Intelligence
Use kimi_search to search for today's critical developments in:

**Priority 1 - Regulatory (Search First):**
- BIS artificial intelligence banking guidance 2026
- Federal Reserve AI guidance banking 2026  
- OCC model risk management AI 2026
- EU AI Act banking financial services 2026
- 中国人民银行 人工智能 银行 2026
- 银保监会 算法 监管 2026
- HKMA fintech AI guidance 2026

**Priority 2 - Expert Insights:**
- Andrej Karpathy LLM reasoning 2026
- Andrew Ng AI enterprise workflow 2026
- Jim Marous digital banking AI 2026

**Priority 2b - Chinese AI KOL (宝玉xp):**
- 宝玉xp AI新闻 2026
- 宝玉xp Claude Code 2026
- 宝玉xp ChatGPT 2026
- 宝玉xp 大模型 2026
- 宝玉xp baoyu.io blog

**Priority 3 - Bank AI Initiatives:**
- JPMorgan COiN AI platform 2026
- Goldman Sachs machine learning trading 2026
- HSBC innovation AI digital 2026
- 招商银行 人工智能 金融科技 2026
- 平安银行 AI 智能风控 2026

**Priority 4 - Tech Breakthroughs:**
- GPT-5.4 benchmark 2026
- Claude 4 SWE-bench 2026
- DeepSeek V4 release 2026
- Gemini 3.1 enterprise 2026
- Agentic AI enterprise adoption 2026

### Step 2: Check Previous Reports
Read the last 3 days' reports to avoid duplication:
- reports/$(date -d "-1 day" +%Y%m)/$(date -d "-1 day" +%d)/daily_report_*.md
- reports/$(date -d "-2 day" +%Y%m)/$(date -d "-2 day" +%d)/daily_report_*.md
- reports/$(date -d "-3 day" +%Y%m)/$(date -d "-3 day" +%d)/daily_report_*.md

Target: < 30% similarity with previous reports.

### Step 3: Generate Chinese Report (sc.md)
Create: reports/$(date +%Y%m)/$(date +%d)/daily_report_$(date +%Y%m%d).sc.md

Structure:
1. 今日主线 (Today's Focus) - Main breaking news with timeline
2. 今日必读 (Must-Read Today) - Tech breakthroughs + market dynamics  
3. 专家观点 (Expert Insights) - KOL opinions with banking implications
4. 监管雷达 (Regulatory Radar) - Regulatory updates table + impact assessment
5. 同业动态 (Peer Bank Intelligence) - Major bank AI initiatives table
6. 技术-业务映射 (Tech-Business Mapping) - Tech → banking applications
7. GitHub技术趋势 (GitHub Trends) - Reference monitor_data/reports/daily_*.md
8. 关键阈值监测表 (Threshold Monitoring) - Model benchmarks table
9. 行动建议 (Action Items) - Immediate, short-term, strategic actions

### Step 4: Generate English Report (en.md)
Create: reports/$(date +%Y%m)/$(date +%d)/daily_report_$(date +%Y%m%d).en.md

Mirror the Chinese structure in English.

### Step 5: Push to GitHub
1. Copy both .sc.md and .en.md files to daily-tech-finance-reports repo
2. Update README.md with latest report links
3. Commit with message: "📊 Daily Report: $(date +%Y-%m-%d) - Bilingual"
4. Push to main branch

## Model Filter Rules
✅ INCLUDE: GPT-5.4, Claude 4, Gemini 3.1, DeepSeek V4, Qwen 3
❌ EXCLUDE: Llama 4 Scout (Meta retraining, poor reception)

## Quality Standards
- Include specific numbers (prices, percentages, dates)
- Cite sources (Reuters, Bloomberg, official statements)
- Add timestamps for data
- Use tables for comparisons
- Provide probability-weighted scenarios

## Success Criteria
- Both Chinese and English reports generated
- Reports contain actual content (not templates)
- No placeholder text like "[AI will fill]"
- Successfully pushed to GitHub
- README.md updated

When complete, report: 
- Files created
- GitHub commit URL
- Any issues encountered
TASK_EOF

echo "✓ Subagent task file created"
echo ""
echo "Task Summary:"
echo "  - Date: $YEAR-$MONTH-$DAY"
echo "  - Output: $REPORT_DIR/"
echo "  - Files: daily_report_${DATE}.sc.md + daily_report_${DATE}.en.md"
echo ""
echo "Launching subagent..."
echo ""
