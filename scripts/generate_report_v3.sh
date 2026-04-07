#!/bin/bash
# generate_report_v3.sh
# 双语版本日报生成脚本 - 同时生成中文(sc.md)和英文(en.md)版本

set -e

# ============================================
# 配置
# ============================================
WORKSPACE="/root/.openclaw/workspace/daily-tech-finance-reports"
REPORTS_DIR="$WORKSPACE/reports"
DATE=$(date +%Y%m%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
OUTPUT_DIR="$REPORTS_DIR/$YEAR$MONTH/$DAY"
MONITOR_DATA="$WORKSPACE/monitor_data"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Banking AI Daily Report Generator v3${NC}"
echo -e "${BLUE}  Bilingual Edition (CN/EN)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Date: $YEAR-$MONTH-$DAY"
echo "Output: $OUTPUT_DIR"
echo ""

# 创建输出目录
mkdir -p "$OUTPUT_DIR"
mkdir -p "$MONITOR_DATA"/{twitter,github,reports}

# ============================================
# Step 1: 运行GitHub监控获取最新动态
# ============================================
echo -e "${YELLOW}▶ Step 1: Running GitHub Monitor...${NC}"

cd "$WORKSPACE"
if [ -f "scripts/monitor.py" ]; then
    python3 scripts/monitor.py --once 2>/dev/null || echo -e "${YELLOW}  Monitor completed (with warnings)${NC}"
else
    echo -e "${YELLOW}  Monitor script not found, skipping${NC}"
fi

# 查找最新的监控报告
LATEST_MONITOR_REPORT=$(ls -t "$MONITOR_DATA/reports"/daily_*.md 2>/dev/null | head -1)
if [ -n "$LATEST_MONITOR_REPORT" ]; then
    echo -e "${GREEN}  ✓ Found monitor report: $(basename $LATEST_MONITOR_REPORT)${NC}"
else
    echo -e "${YELLOW}  ⚠ No monitor report found${NC}"
fi

# ============================================
# Step 2: 生成搜索关键词 (中英文)
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 2: Generating search keywords...${NC}"

cat > "$OUTPUT_DIR/search_keywords.txt" << 'EOF'
# ============================================
# 一级信源：监管动态 (最高优先级)
# ============================================

## 国际监管 / International Regulation
BIS artificial intelligence banking guidance 2026
FSB AI financial stability report 2026
Basel Committee operational risk AI 2026
Federal Reserve AI guidance banking 2026
OCC model risk management AI 2026
CFPB AI lending algorithm 2026
Bank of England AI machine learning 2026
FCA artificial intelligence regulation 2026
EU AI Act banking financial services 2026
EBA machine learning guidelines 2026
HKMA fintech AI guidance 2026
MAS Singapore AI finance 2026
中国人民银行 人工智能 银行 2026
银保监会 算法 监管 2026

# ============================================
# 二级信源：专家观点 (KOL)
# ============================================

## AI研究员 / AI Researchers
Andrew Ng AI enterprise workflow 2026
Andrej Karpathy LLM model training 2026
Yann LeCun LLM reasoning JEPA 2026
Fei-Fei Li AI policy ethics 2026

## 银行/Fintech专家 / Banking Experts
Jim Marous digital banking AI 2026
Bradley Leimer fintech innovation 2026
Brett King banking future AI 2026
Ron Shevlin banking research 2026

# ============================================
# 三级信源：银行业AI应用 / Banking AI Applications
# ============================================

## 同业动态 / Bank Initiatives
JPMorgan COiN AI platform 2026
Goldman Sachs machine learning trading 2026
HSBC innovation AI digital 2026
招商银行 人工智能 金融科技 2026
平安银行 AI 智能风控 2026
工商银行 AI 信贷 智能体 2026

## 应用场景 / Use Cases
AI credit scoring banking 2026
fraud detection machine learning bank 2026
anti-money laundering AI AML 2026
algorithmic trading AI hedge fund 2026
KYC AI know your customer 2026

# ============================================
# 四级信源：技术突破 / Tech Breakthroughs
# ============================================
# 
# 【模型筛选标准 / Model Selection Criteria】
# ✅ 关注：行业标杆模型 (GPT/Claude/Gemini)、开源领先者 (DeepSeek/Llama 3/Qwen)、企业级新星
# ❌ 排除：风评不佳、已淘汰或Meta已宣布重新训练的模型 (如 Llama 4 Scout)
#
Claude SWE-bench coding benchmark 2026
GPT-5.4 OSWorld benchmark 2026
Gemini 3.1 enterprise benchmark 2026
DeepSeek V4 benchmark 2026
Qwen 3 enterprise benchmark 2026
Agentic AI enterprise adoption 2026
EOF

echo -e "${GREEN}  ✓ Search keywords saved${NC}"

# ============================================
# Step 3: 生成中文报告模板 (sc.md)
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 3: Generating Chinese report template (sc.md)...${NC}"

cat > "$OUTPUT_DIR/daily_report_${DATE}.sc.md" << EOF
# AI & Banking Daily Report | ${YEAR}-${MONTH}-${DAY}

---

## 📌 今日主线

**核心事件**: [AI将填充今日最重要的1-2个事件]

**关键数据**: [AI将填充核心数据点]

---

## 一、今日必读

### 1.1 技术突破
[AI将填充技术突破相关内容]

### 1.2 市场动态  
[AI将填充市场动态相关内容]

---

## 二、专家观点 🎓

### 2.1 AI研究员

**Andrej Karpathy** (@karpathy)
- **最新观点**: [AI将填充]
- **涉及主题**: [LLM/训练/推理]
- **银行业启示**: [AI将填充]

**Andrew Ng** (@AndrewYNg)
- **最新观点**: [AI将填充]
- **涉及主题**: [企业AI/Agentic workflow]
- **银行业启示**: [AI将填充]

### 2.2 银行/Fintech专家

**Jim Marous** (@jimmarous)
- **最新观点**: [AI将填充]
- **涉及主题**: [数字银行/转型]
- **银行业启示**: [AI将填充]

### 2.3 值得关注的讨论

| 专家 | 话题 | 热度 | 关键观点 |
|------|------|------|----------|
| [专家] | [话题] | 🔥/🌡️/❄️ | [一句话总结] |

---

## 三、监管雷达 🏛️

### 3.1 今日监管动态摘要

| 地区 | 机构 | 动态 | 影响等级 |
|------|------|------|----------|
| [AI将填充] | [AI将填充] | [AI将填充] | 🔴/🟡/🟢 |

### 3.2 重点监管文件解读

**[文件名称]**
- **发布机构**: [机构]
- **核心内容**: [3-5句话概括]
- **生效日期**: [YYYY-MM-DD]

**So What for Banking**:
| 维度 | 影响 | 说明 |
|------|------|------|
| 合规成本 | 🔴/🟡/🟢 | [说明] |
| 业务限制 | 🔴/🟡/🟢 | [说明] |
| 技术架构 | 🔴/🟡/🟢 | [说明] |

**HSBC应对建议**:
- 短期（30天）: [行动]
- 中期（3-6月）: [规划]
- 长期（1年+）: [战略]

### 3.3 合规日历

| 截止日期 | 事项 | 负责团队 | 状态 |
|----------|------|----------|------|
| [YYYY-MM-DD] | [事项] | [团队] | ⏳/✅/🔴 |

---

## 四、同业动态 🏦

### 4.1 主要银行AI举措

| 银行 | 举措 | 技术/供应商 | 影响评估 |
|------|------|-------------|----------|
| JPMorgan | [AI将填充] | [技术] | [评估] |
| Goldman Sachs | [AI将填充] | [技术] | [评估] |
| 招商银行 | [AI将填充] | [技术] | [评估] |
| 平安银行 | [AI将填充] | [技术] | [评估] |

### 4.2 竞争情报

**招聘信号**:
- [银行] 正在招聘 [职位]，暗示 [战略方向]

**专利申请**:
- [银行] 申请 [专利类型]，涉及 [技术领域]

**合作伙伴**:
- [银行] 与 [厂商] 合作，聚焦 [场景]

---

## 五、技术-业务映射 🔧

### 5.1 技术突破 → 银行业务

| 技术突破 | 短期影响（3-6月） | 中期布局（1-2年） | 监管风险 |
|----------|-------------------|-------------------|----------|
| [技术] | [影响] | [布局] | [风险] |

### 5.2 业务场景优先级

1. **智能风控** 🟢
   - 当前成熟度: [评估]
   - 建议行动: [行动]

2. **反欺诈** 🟢
   - 当前成熟度: [评估]
   - 建议行动: [行动]

3. **智能客服** 🟡
   - 当前成熟度: [评估]
   - 建议行动: [行动]

4. **算法交易** 🔴
   - 当前成熟度: [评估]
   - 建议行动: [行动]

---

## 六、GitHub技术趋势 🐙

EOF

# 如果有监控报告，嵌入GitHub动态
if [ -n "$LATEST_MONITOR_REPORT" ]; then
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "### 6.1 本周热门仓库" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo '```' >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    grep "📈" "$LATEST_MONITOR_REPORT" 2>/dev/null | head -10 >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md" || echo "[监控数据将在运行时填充]" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo '```' >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    
    echo "### 6.2 新发布关注" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "[AI将填充新发布信息]" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
else
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "### 6.1 本周热门仓库" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "[运行GitHub监控后填充]" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    
    echo "### 6.2 新发布关注" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "[运行GitHub监控后填充]" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md"
fi

cat >> "$OUTPUT_DIR/daily_report_${DATE}.sc.md" << 'EOF'
---

## 六、关键阈值监测表 📊

| 指标 | 当前值 | 阈值 | 状态 | 更新 |
|------|--------|------|------|------|
| GPT-5.4 OSWorld-V | [值] | 人类72.4% | 🟢/🟡/🔴 | [日期] |
| Claude 4 SWE-bench | [值] | 70% | 🟢/🟡/🔴 | [日期] |
| DeepSeek V4 MMLU | [值] | 90% | 🟢/🟡/🔴 | [日期] |
| Agentic AI企业应用 | [值] | 50% | 🟢/🟡/🔴 | [日期] |
| AMD MI355X性能 | [值] | 1M tokens/sec | 🟢/🟡/🔴 | [日期] |
| AI代理安全事件预期 | [值] | - | 🔴 | [日期] |

> **模型筛选说明**：本报告仅追踪行业标杆模型（GPT/Claude/Gemini）及开源领先者（DeepSeek/Qwen）。已排除风评不佳或已停止迭代的模型（如 Llama 4 Scout，Meta已宣布重新训练）。

---

## 七、行动建议 ✅

### 立即行动（本周）
- [ ] [行动项1]
- [ ] [行动项2]

### 短期规划（本月）
- [ ] [行动项1]
- [ ] [行动项2]

### 战略关注（本季度）
- [ ] [行动项1]
- [ ] [行动项2]

---

## 八、附录

### 8.1 数据来源
- GitHub监控: `scripts/monitor.py`
- 信源配置: `config/banking_ai_sources.yaml`
- 监管模板: `templates/regulatory_radar_template.md`

### 8.2 历史报告
- [昨日报告](./../$(date -d "-1 day" +%Y%m%d)/)
- [上周报告](./../$(date -d "-7 day" +%Y%m%d)/)

---

**报告时间**: ${YEAR}-${MONTH}-${DAY} | **生成耗时**: [AI将填充]

*本报告由AI助手基于公开信息整理，仅供内部参考*
EOF

echo -e "${GREEN}  ✓ Chinese template saved: daily_report_${DATE}.sc.md${NC}"

# ============================================
# Step 4: 生成英文报告模板 (en.md)
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 4: Generating English report template (en.md)...${NC}"

cat > "$OUTPUT_DIR/daily_report_${DATE}.en.md" << EOF
# AI & Banking Daily Report | ${YEAR}-${MONTH}-${DAY}

---

## 📌 Today's Focus

**Key Events**: [AI to fill in the 1-2 most important events today]

**Critical Data**: [AI to fill in key data points]

---

## I. Must-Read Today

### 1.1 Technology Breakthroughs
[AI to fill in technology breakthrough content]

### 1.2 Market Dynamics  
[AI to fill in market dynamics content]

---

## II. Expert Insights 🎓

### 2.1 AI Researchers

**Andrej Karpathy** (@karpathy)
- **Latest View**: [AI to fill in]
- **Topics**: [LLM/Training/Reasoning]
- **Banking Implications**: [AI to fill in]

**Andrew Ng** (@AndrewYNg)
- **Latest View**: [AI to fill in]
- **Topics**: [Enterprise AI/Agentic Workflow]
- **Banking Implications**: [AI to fill in]

### 2.2 Banking/Fintech Experts

**Jim Marous** (@jimmarous)
- **Latest View**: [AI to fill in]
- **Topics**: [Digital Banking/Transformation]
- **Banking Implications**: [AI to fill in]

### 2.3 Notable Discussions

| Expert | Topic | Heat Level | Key Insight |
|--------|-------|------------|-------------|
| [Expert] | [Topic] | 🔥/🌡️/❄️ | [One-sentence summary] |

---

## III. Regulatory Radar 🏛️

### 3.1 Today's Regulatory Summary

| Region | Agency | Development | Impact Level |
|--------|--------|-------------|--------------|
| [AI to fill] | [AI to fill] | [AI to fill] | 🔴/🟡/🟢 |

### 3.2 Key Regulatory Documents

**[Document Name]**
- **Issuing Agency**: [Agency]
- **Core Content**: [3-5 sentence summary]
- **Effective Date**: [YYYY-MM-DD]

**So What for Banking**:
| Dimension | Impact | Details |
|-----------|--------|---------|
| Compliance Cost | 🔴/🟡/🟢 | [Details] |
| Business Restrictions | 🔴/🟡/🟢 | [Details] |
| Tech Architecture | 🔴/🟡/🟢 | [Details] |

**HSBC Response Recommendations**:
- Short-term (30 days): [Actions]
- Medium-term (3-6 months): [Planning]
- Long-term (1 year+): [Strategy]

### 3.3 Compliance Calendar

| Deadline | Item | Responsible Team | Status |
|----------|------|------------------|--------|
| [YYYY-MM-DD] | [Item] | [Team] | ⏳/✅/🔴 |

---

## IV. Peer Bank Intelligence 🏦

### 4.1 Major Bank AI Initiatives

| Bank | Initiative | Technology/Provider | Impact Assessment |
|------|------------|--------------------|--------------------|
| JPMorgan | [AI to fill] | [Tech] | [Assessment] |
| Goldman Sachs | [AI to fill] | [Tech] | [Assessment] |
| Citi | [AI to fill] | [Tech] | [Assessment] |
| HSBC | [AI to fill] | [Tech] | [Assessment] |

### 4.2 Competitive Intelligence

**Hiring Signals**:
- [Bank] is hiring [Role], indicating [Strategic Direction]

**Patent Filings**:
- [Bank] filed [Patent Type] patents covering [Technology Area]

**Partnerships**:
- [Bank] partnered with [Vendor] focusing on [Use Case]

---

## V. Technology-Business Mapping 🔧

### 5.1 Tech Breakthrough → Banking Applications

| Tech Breakthrough | Short-term Impact (3-6M) | Medium-term Strategy (1-2Y) | Regulatory Risk |
|--------------------|---------------------------|------------------------------|-----------------|
| [Tech] | [Impact] | [Strategy] | [Risk] |

### 5.2 Use Case Priority Matrix

1. **Intelligent Risk Control** 🟢
   - Current Maturity: [Assessment]
   - Recommended Actions: [Actions]

2. **Anti-Fraud** 🟢
   - Current Maturity: [Assessment]
   - Recommended Actions: [Actions]

3. **Intelligent Customer Service** 🟡
   - Current Maturity: [Assessment]
   - Recommended Actions: [Actions]

4. **Algorithmic Trading** 🔴
   - Current Maturity: [Assessment]
   - Recommended Actions: [Actions]

---

## VI. GitHub Tech Trends 🐙

EOF

# 如果有监控报告，嵌入GitHub动态（英文版）
if [ -n "$LATEST_MONITOR_REPORT" ]; then
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "### 6.1 Trending Repositories This Week" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo '```' >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    grep "📈" "$LATEST_MONITOR_REPORT" 2>/dev/null | head -10 >> "$OUTPUT_DIR/daily_report_${DATE}.en.md" || echo "[Monitor data to be filled at runtime]" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo '```' >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    
    echo "### 6.2 New Releases to Watch" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "[AI to fill in new release information]" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
else
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "### 6.1 Trending Repositories This Week" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "[Fill after running GitHub monitor]" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    
    echo "### 6.2 New Releases to Watch" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "[Fill after running GitHub monitor]" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.en.md"
fi

cat >> "$OUTPUT_DIR/daily_report_${DATE}.en.md" << 'EOF'
---

## VI. Key Threshold Monitoring 📊

| Metric | Current Value | Threshold | Status | Last Update |
|--------|---------------|-----------|--------|-------------|
| GPT-5.4 OSWorld-V | [Value] | Human 72.4% | 🟢/🟡/🔴 | [Date] |
| Claude 4 SWE-bench | [Value] | 70% | 🟢/🟡/🔴 | [Date] |
| DeepSeek V4 MMLU | [Value] | 90% | 🟢/🟡/🔴 | [Date] |
| Agentic AI Enterprise Adoption | [Value] | 50% | 🟢/🟡/🔴 | [Date] |
| AMD MI355X Performance | [Value] | 1M tokens/sec | 🟢/🟡/🔴 | [Date] |
| AI Agent Security Incidents | [Value] | - | 🔴 | [Date] |

> **Model Selection Note**: This report tracks industry-leading models (GPT/Claude/Gemini) and top open-source alternatives (DeepSeek/Qwen). Excludes poorly-received or discontinued models (e.g., Llama 4 Scout, as Meta announced retraining).

---

## VII. Action Items ✅

### Immediate Actions (This Week)
- [ ] [Action Item 1]
- [ ] [Action Item 2]

### Short-term Planning (This Month)
- [ ] [Action Item 1]
- [ ] [Action Item 2]

### Strategic Focus (This Quarter)
- [ ] [Action Item 1]
- [ ] [Action Item 2]

---

## VIII. Appendix

### 8.1 Data Sources
- GitHub Monitor: `scripts/monitor.py`
- Source Config: `config/banking_ai_sources.yaml`
- Regulatory Template: `templates/regulatory_radar_template.md`

### 8.2 Historical Reports
- [Yesterday's Report](./../$(date -d "-1 day" +%Y%m%d)/)
- [Last Week's Report](./../$(date -d "-7 day" +%Y%m%d)/)

---

**Report Date**: ${YEAR}-${MONTH}-${DAY} | **Generation Time**: [AI to fill]

*This report is compiled by AI assistant based on public information for internal reference only*
EOF

echo -e "${GREEN}  ✓ English template saved: daily_report_${DATE}.en.md${NC}"

# ============================================
# Step 5: 生成重复检测提示
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 5: Generating deduplication prompt...${NC}"

cat > "$OUTPUT_DIR/dedup_prompt.txt" << 'EOF'
重复检测检查清单 / Deduplication Checklist:

在生成今日报告前，请对比前3天报告中的主要主题，避免重复：
Before generating today's report, compare with main topics from the past 3 days to avoid duplication:

[AI将根据实际前3天报告内容填充]

重复度>50%时的补充搜索主题 / Supplementary topics when duplication > 50%:
1. 监管动态 / Regulatory updates (BIS, Fed, PBOC, etc.)
2. 银行业AI应用 / Banking AI applications (JPMorgan, Goldman, etc.)
3. 技术基础设施 / Tech infrastructure (AMD, NVIDIA, datacenters)
4. 竞争情报 / Competitive intelligence (hiring, patents, partnerships)

目标 / Target: 确保与前3日报告重复度<30% / Ensure <30% duplication with past 3 days

---

【模型筛选标准 / Model Filtering Criteria】

✅ 推荐关注的模型 / Models to Track:
   - 闭源标杆: GPT-5.4, Claude 4, Gemini 3.1
   - 开源领先: DeepSeek V4, Qwen 3, Mistral Large 2
   - 垂直领域: 金融专用模型、代码生成模型

❌ 避免收录 / Models to Exclude:
   - Llama 4 Scout (风评不佳，Meta已宣布重新训练)
   - 已停止迭代的旧版本模型
   - 社区反馈持续负面的模型

搜索时优先使用 "latest", "benchmark 2026", "enterprise" 等限定词，
避免检索到过时或低质量模型的新闻。
EOF

echo -e "${GREEN}  ✓ Deduplication prompt saved${NC}"

# ============================================
# Step 6: 复制配置文件到输出目录
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 6: Copying configuration files...${NC}"

cp "$WORKSPACE/config/banking_ai_sources.yaml" "$OUTPUT_DIR/" 2>/dev/null || echo "  Source config copied"
cp "$WORKSPACE/templates/regulatory_radar_template.md" "$OUTPUT_DIR/" 2>/dev/null || echo "  Regulatory template copied"

echo -e "${GREEN}  ✓ Configuration files copied${NC}"

# ============================================
# 完成
# ============================================
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Bilingual Report Generation Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Output Files / 输出文件:"
echo "  📄 $OUTPUT_DIR/daily_report_${DATE}.sc.md (Simplified Chinese)"
echo "  📄 $OUTPUT_DIR/daily_report_${DATE}.en.md (English)"
echo "  🔍 $OUTPUT_DIR/search_keywords.txt"
echo "  📝 $OUTPUT_DIR/dedup_prompt.txt"
echo "  📋 $OUTPUT_DIR/banking_ai_sources.yaml"
echo "  🏛️  $OUTPUT_DIR/regulatory_radar_template.md"
if [ -n "$LATEST_MONITOR_REPORT" ]; then
    echo "  🐙 $(basename $LATEST_MONITOR_REPORT)"
fi
echo ""
echo "Next Steps / 下一步:"
echo "  1. Use AI to fill both report templates"
echo "  2. Search based on search_keywords.txt"
echo "  3. Reference banking_ai_sources.yaml for sources"
echo "  4. Use regulatory_radar_template.md for regulatory sections"
echo ""
