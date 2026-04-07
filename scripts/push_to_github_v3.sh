#!/bin/bash
# push_to_github_v3.sh
# GitHub Daily Report Auto-Push Script v3 - 支持双语版本
# 自动推送中文(sc.md)和英文(en.md)双版本到GitHub

set -e

# 配置
WORKSPACE="/root/.openclaw/workspace/daily-tech-finance-reports"
REPO_NAME="daily-tech-finance-reports"
DATE=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
REPORT_DIR="reports/${YEAR}${MONTH}/${DAY}"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GitHub Auto-Push Script v3${NC}"
echo -e "${BLUE}  Bilingual Edition${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Date: $DATE"
echo "Source: $WORKSPACE/$REPORT_DIR"
echo ""

# 检查GitHub登录状态
if ! gh auth status &>/dev/null; then
    echo -e "${RED}❌ GitHub未登录，请先运行: gh auth login${NC}"
    exit 1
fi

# 获取GitHub用户名
GITHUB_USER=$(gh api user -q .login 2>/dev/null || echo "")
if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}❌ 无法获取GitHub用户名${NC}"
    exit 1
fi
echo -e "${GREEN}✓ GitHub用户: $GITHUB_USER${NC}"

# 检查或克隆仓库
cd "$WORKSPACE"
if [ ! -d "$REPO_NAME/.git" ]; then
    echo -e "${BLUE}📁 克隆仓库...${NC}"
    gh repo clone "$GITHUB_USER/$REPO_NAME" "$REPO_NAME" 2>/dev/null || {
        echo -e "${YELLOW}⚠ 仓库不存在，创建新仓库...${NC}"
        gh repo create "$REPO_NAME" --public --description "AI & Banking Daily Reports (Bilingual)" --gitignore Python 2>/dev/null || true
        git clone "https://github.com/$GITHUB_USER/${REPO_NAME}.git" "$REPO_NAME" 2>/dev/null || {
            echo -e "${RED}❌ 克隆失败，请手动检查${NC}"
            exit 1
        }
    }
fi

cd "$WORKSPACE/$REPO_NAME"

# 确保目录结构存在
mkdir -p "$REPORT_DIR"

# 检查源文件是否存在
SC_FILE="$WORKSPACE/$REPORT_DIR/daily_report_${YEAR}${MONTH}${DAY}.sc.md"
EN_FILE="$WORKSPACE/$REPORT_DIR/daily_report_${YEAR}${MONTH}${DAY}.en.md"

if [ ! -f "$SC_FILE" ] && [ ! -f "$EN_FILE" ]; then
    echo -e "${RED}❌ 未找到报告文件，请先运行 generate_report_v3.sh${NC}"
    echo "  期望路径: $WORKSPACE/$REPORT_DIR/"
    echo "  中文: daily_report_${YEAR}${MONTH}${DAY}.sc.md"
    echo "  英文: daily_report_${YEAR}${MONTH}${DAY}.en.md"
    exit 1
fi

# 复制文件到git仓库
echo -e "${BLUE}📋 复制报告文件...${NC}"

if [ -f "$SC_FILE" ]; then
    cp "$SC_FILE" "$REPORT_DIR/"
    echo -e "${GREEN}  ✓ 中文版本: $(basename $SC_FILE)${NC}"
fi

if [ -f "$EN_FILE" ]; then
    cp "$EN_FILE" "$REPORT_DIR/"
    echo -e "${GREEN}  ✓ 英文版本: $(basename $EN_FILE)${NC}"
fi

# 复制辅助文件
if [ -f "$WORKSPACE/$REPORT_DIR/search_keywords.txt" ]; then
    cp "$WORKSPACE/$REPORT_DIR/search_keywords.txt" "$REPORT_DIR/"
    echo -e "${GREEN}  ✓ 搜索关键词${NC}"
fi

if [ -f "$WORKSPACE/$REPORT_DIR/dedup_prompt.txt" ]; then
    cp "$WORKSPACE/$REPORT_DIR/dedup_prompt.txt" "$REPORT_DIR/"
    echo -e "${GREEN}  ✓ 去重提示${NC}"
fi

# 更新 README.md
echo -e "${BLUE}📝 更新 README...${NC}"

cat > README.md << EOF
# 📊 AI & Banking Daily Reports | 科技金融日报

Bilingual daily reports on AI and Banking (English + 简体中文)

---

## 📅 Latest Reports | 最新报告

| Date | Chinese (中文) | English |
|------|----------------|---------|
EOF

# 获取最近7天的报告列表
for i in 0 1 2 3 4 5 6; do
    D=$(date -d "-$i days" +%Y%m%d)
    Y=$(date -d "-$i days" +%Y)
    M=$(date -d "-$i days" +%m)
    DAY=$(date -d "-$i days" +%d)
    DIR="reports/${D:0:6}/${D:6:2}"
    
    if [ -f "$DIR/daily_report_${D}.sc.md" ] || [ -f "$DIR/daily_report_${D}.en.md" ]; then
        SC_LINK="[SC](${DIR}/daily_report_${D}.sc.md)"
        EN_LINK="[EN](${DIR}/daily_report_${D}.en.md)"
        
        # 如果文件不存在，显示为 -
        [ -f "$DIR/daily_report_${D}.sc.md" ] || SC_LINK="-"
        [ -f "$DIR/daily_report_${D}.en.md" ] || EN_LINK="-"
        
        echo "| ${Y}-${M}-${DAY} | ${SC_LINK} | ${EN_LINK} |" >> README.md
    fi
done

cat >> README.md << 'EOF'

---

## 📁 Directory Structure | 目录结构

```
reports/
└── YYYYMM/
    └── DD/
        ├── daily_report_YYYYMMDD.sc.md    # 简体中文
        ├── daily_report_YYYYMMDD.en.md    # English
        ├── search_keywords.txt            # 搜索关键词
        └── dedup_prompt.txt               # 去重提示
```

---

## 🔄 Update Schedule | 更新频率

**Daily at 06:13 CST** (错峰避免API限流)

- 中文版本: `.sc.md` (Simplified Chinese)
- 英文版本: `.en.md` (English)

---

## 📊 Report Sections | 报告章节

| Section | 章节 |
|---------|------|
| Today's Focus | 今日主线 |
| Must-Read Today | 今日必读 |
| Expert Insights | 专家观点 |
| Regulatory Radar | 监管雷达 |
| Peer Bank Intelligence | 同业动态 |
| Tech-Business Mapping | 技术-业务映射 |
| GitHub Trends | GitHub趋势 |
| Threshold Monitoring | 关键阈值监测 |
| Action Items | 行动建议 |

---

## 🏦 Coverage | 覆盖范围

- **Regulatory Updates**: Fed, OCC, BIS, ECB, PBOC, HKMA, MAS
- **Bank AI Initiatives**: JPMorgan, Goldman Sachs, Citi, HSBC, 招商银行, 平安银行
- **Tech Breakthroughs**: LLM benchmarks, Agentic AI, Infrastructure
- **Competitive Intel**: Hiring, Patents, Partnerships

---

*Generated automatically by AI assistant | AI助手自动生成*
*Version 3.0 - Bilingual Edition*
EOF

echo -e "${GREEN}  ✓ README更新完成${NC}"

# Git 操作
echo -e "${BLUE}🚀 推送到 GitHub...${NC}"

git add -A

# 检查是否有变更
if git diff --cached --quiet; then
    echo -e "${YELLOW}⚠ 没有需要提交的变更${NC}"
    exit 0
fi

# 提交并推送
git commit -m "📊 Daily Report: ${DATE} - Bilingual" \
    -m "- Chinese version: daily_report_${YEAR}${MONTH}${DAY}.sc.md" \
    -m "- English version: daily_report_${YEAR}${MONTH}${DAY}.en.md" \
    -m "- AI Coding Agents updates" \
    -m "- Banking AI applications" || {
    echo -e "${YELLOW}⚠ 提交失败，可能没有变更${NC}"
    exit 0
}

git push origin HEAD:main 2>/dev/null || git push origin HEAD:master 2>/dev/null || {
    echo -e "${RED}❌ 推送失败${NC}"
    exit 1
}

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 推送成功!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "📁 Report Location:"
echo "  $REPORT_DIR/"
echo ""
echo "📄 Files:"
ls -la "$REPORT_DIR/" 2>/dev/null || echo "  (请检查本地目录)"
echo ""
echo "🔗 GitHub URL:"
echo "  https://github.com/$GITHUB_USER/$REPO_NAME/tree/main/$REPORT_DIR"
echo ""
