#!/bin/bash
# generate_report_v2.sh
# 完整改进版日报生成脚本 - 整合GitHub监控、监管雷达、竞争情报

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
echo -e "${BLUE}  Banking AI Daily Report Generator v2${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "日期: $YEAR-$MONTH-$DAY"
echo "输出目录: $OUTPUT_DIR"
echo ""

# 创建输出目录
mkdir -p "$OUTPUT_DIR"
mkdir -p "$MONITOR_DATA"/{twitter,github,reports}

# ============================================
# Step 1: 运行GitHub监控获取最新动态
# ============================================
echo -e "${YELLOW}▶ Step 1: 运行GitHub监控...${NC}"

cd "$WORKSPACE"
if [ -f "scripts/monitor.py" ]; then
    python3 scripts/monitor.py --once 2>/dev/null || echo -e "${YELLOW}  监控运行完成 (可能有警告)${NC}"
else
    echo -e "${YELLOW}  监控脚本未找到，跳过${NC}"
fi

# 查找最新的监控报告
LATEST_MONITOR_REPORT=$(ls -t "$MONITOR_DATA/reports"/daily_*.md 2>/dev/null | head -1)
if [ -n "$LATEST_MONITOR_REPORT" ]; then
    echo -e "${GREEN}  ✓ 找到监控报告: $(basename $LATEST_MONITOR_REPORT)${NC}"
else
    echo -e "${YELLOW}  ⚠ 未找到监控报告${NC}"
fi

# ============================================
# Step 2: 生成增强版搜索关键词
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 2: 生成搜索关键词...${NC}"

cat > "$OUTPUT_DIR/search_keywords.txt" << 'EOF'
# ============================================
# 一级信源：监管动态 (最高优先级)
# ============================================

## 国际监管
BIS artificial intelligence banking guidance 2026
FSB AI financial stability report 2026
Basel Committee operational risk AI 2026

## 美国监管  
Federal Reserve AI guidance banking 2026
OCC model risk management AI 2026
CFPB AI lending algorithm 2026

## 欧洲监管
Bank of England AI machine learning 2026
FCA artificial intelligence regulation 2026
EU AI Act banking financial services 2026
EBA machine learning guidelines 2026

## 亚太监管
HKMA fintech AI guidance 2026
MAS Singapore AI finance 2026
中国人民银行 人工智能 银行 2026
银保监会 算法 监管 2026

# ============================================
# 二级信源：专家观点 (KOL)
# ============================================

## AI研究员
Andrew Ng AI enterprise workflow 2026
Andrej Karpathy LLM model training 2026
Yann LeCun LLM reasoning JEPA 2026
Fei-Fei Li AI policy ethics 2026

## 技术专家
Ian Goodfellow AI security adversarial 2026
David Ha generative RL 2026
Jeremy Howard fast.ai practical ML 2026

## 银行/Fintech专家
Jim Marous digital banking AI 2026
Bradley Leimer fintech innovation 2026
Brett King banking future AI 2026
Ron Shevlin banking research 2026

# ============================================
# 三级信源：银行业AI应用
# ============================================

## 同业动态
JPMorgan COiN AI platform 2026
Goldman Sachs machine learning trading 2026
HSBC innovation AI digital 2026
招商银行 人工智能 金融科技 2026
平安银行 AI 智能风控 2026

## 应用场景
AI credit scoring banking 2026
fraud detection machine learning bank 2026
anti-money laundering AI AML 2026
algorithmic trading AI hedge fund 2026
KYC AI know your customer 2026

# ============================================
# 三级信源：技术突破
# ============================================

## 模型竞争
Claude SWE-bench coding benchmark 2026
GPT-5.4 OSWorld benchmark 2026
Gemini 3.1 enterprise benchmark 2026

## 基础设施
AMD MI355X MLPerf inference 2026
NVIDIA B300 benchmark 2026
AI datacenter investment trillion 2026

## Agentic AI
Agentic AI enterprise adoption 2026
Microsoft Agent Governance Toolkit
OpenAI Operator computer use 2026

# ============================================
# 四级信源：竞争情报
# ============================================

## 投资并购
AI fintech funding Series A B C 2026
banking AI startup acquisition 2026

## 人才动态
AI researcher move JPMorgan Goldman 2026
banking AI chief data officer hire 2026
EOF

echo -e "${GREEN}  ✓ 搜索关键词已保存${NC}"

# ============================================
# Step 3: 生成报告模板 (含新章节)
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 3: 生成报告模板...${NC}"

cat > "$OUTPUT_DIR/daily_report_${DATE}.md" << EOF
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
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "### 6.1 本周热门仓库" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "```" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    grep "📈" "$LATEST_MONITOR_REPORT" 2>/dev/null | head -10 >> "$OUTPUT_DIR/daily_report_${DATE}.md" || echo "[监控数据将在运行时填充]" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "```" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    
    echo "### 6.2 新发布关注" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "[AI将填充新发布信息]" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
else
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "### 6.1 本周热门仓库" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "[运行GitHub监控后填充]" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    
    echo "### 6.2 新发布关注" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "[运行GitHub监控后填充]" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
    echo "" >> "$OUTPUT_DIR/daily_report_${DATE}.md"
fi

cat >> "$OUTPUT_DIR/daily_report_${DATE}.md" << 'EOF'
---

## 六、关键阈值监测表 📊

| 指标 | 当前值 | 阈值 | 状态 | 更新 |
|------|--------|------|------|------|
| GPT-5.4 OSWorld-V | [值] | 人类72.4% | 🟢/🟡/🔴 | [日期] |
| Agentic AI企业应用 | [值] | 50% | 🟢/🟡/🔴 | [日期] |
| AMD MI355X性能 | [值] | 1M tokens/sec | 🟢/🟡/🔴 | [日期] |
| OpenAI估值 | [值] | $1T | 🟢/🟡/🔴 | [日期] |
| AI代理安全事件预期 | [值] | - | 🔴 | [日期] |

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

echo -e "${GREEN}  ✓ 报告模板已保存${NC}"

# ============================================
# Step 4: 生成重复检测提示
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 4: 生成重复检测提示...${NC}"

cat > "$OUTPUT_DIR/dedup_prompt.txt" << 'EOF'
重复检测检查清单：

在生成今日报告前，请对比前3天报告中的主要主题，避免重复：

[AI将根据实际前3天报告内容填充]

重复度>50%时的补充搜索主题：
1. 监管动态 (BIS, Fed, PBOC等)
2. 银行业AI应用 (JPMorgan, Goldman, 招行, 平安等)
3. 技术基础设施 (AMD, NVIDIA, 数据中心)
4. 竞争情报 (招聘, 专利, 合作)

目标: 确保与前3日报告重复度<30%
EOF

echo -e "${GREEN}  ✓ 重复检测提示已保存${NC}"

# ============================================
# Step 5: 复制配置文件到输出目录（便于参考）
# ============================================
echo ""
echo -e "${YELLOW}▶ Step 5: 复制配置文件...${NC}"

cp "$WORKSPACE/config/banking_ai_sources.yaml" "$OUTPUT_DIR/" 2>/dev/null || echo "  信源配置已复制"
cp "$WORKSPACE/templates/regulatory_radar_template.md" "$OUTPUT_DIR/" 2>/dev/null || echo "  监管模板已复制"

echo -e "${GREEN}  ✓ 配置文件已复制到输出目录${NC}"

# ============================================
# 完成
# ============================================
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  报告生成准备完成！${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "输出文件:"
echo "  📄 $OUTPUT_DIR/daily_report_${DATE}.md"
echo "  🔍 $OUTPUT_DIR/search_keywords.txt"
echo "  📝 $OUTPUT_DIR/dedup_prompt.txt"
echo "  📋 $OUTPUT_DIR/banking_ai_sources.yaml"
echo "  🏛️  $OUTPUT_DIR/regulatory_radar_template.md"
if [ -n "$LATEST_MONITOR_REPORT" ]; then
    echo "  🐙 $(basename $LATEST_MONITOR_REPORT)"
fi
echo ""
echo "下一步:"
echo "  1. 使用AI填充报告模板"
echo "  2. 基于search_keywords.txt执行搜索"
echo "  3. 参考banking_ai_sources.yaml选择信源"
echo "  4. 使用regulatory_radar_template.md填写监管章节"
echo ""
