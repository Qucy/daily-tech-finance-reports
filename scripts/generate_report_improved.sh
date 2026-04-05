#!/bin/bash
# generate_report_improved.sh
# 改进后的报告生成脚本，包含重复检测和补充搜索逻辑

set -e

# 配置
REPORTS_DIR="/root/.openclaw/workspace/daily-tech-finance-reports/reports"
DATE=$(date +%Y%m%d)
YEAR_MONTH=$(date +%Y%m)
DAY=$(date +%d)
OUTPUT_DIR="$REPORTS_DIR/$YEAR_MONTH/$DAY"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

echo "================================"
echo "生成日期: $DATE"
echo "输出目录: $OUTPUT_DIR"
echo "================================"

# Step 1: 检查前3天的报告是否存在
echo ""
echo "Step 1: 检查前3天报告..."

for i in 1 2 3; do
    PREV_DATE=$(date -d "-$i days" +%Y%m%d)
    PREV_YEAR_MONTH=$(date -d "-$i days" +%Y%m)
    PREV_DAY=$(date -d "-$i days" +%d)
    PREV_REPORT="$REPORTS_DIR/$PREV_YEAR_MONTH/$PREV_DAY/daily_report_${PREV_DATE}.md"
    
    if [ -f "$PREV_REPORT" ]; then
        echo "  ✅ 找到 $PREV_DATE 的报告"
    else
        echo "  ⚠️  未找到 $PREV_DATE 的报告"
    fi
done

# Step 2: 生成基础搜索关键词
echo ""
echo "Step 2: 生成搜索关键词..."

cat > "$OUTPUT_DIR/search_keywords.txt" << 'EOF'
# 基础搜索关键词（始终执行）
AI artificial intelligence latest news 2026
Large language model LLM breakthrough 2026
AI funding investment startup 2026

# 条件触发关键词（重复度>50%时执行）
## 主题1: Agentic AI企业应用
Agentic AI enterprise adoption statistics Gartner 2026
AI agent workflow automation enterprise 2026

## 主题2: 意见领袖动态
Andrew Ng AI workflow agentic enterprise 2026
Andrej Karpathy autoresearch AI agent 2026
Yann LeCun LLM latest opinion 2026

## 主题3: 银行业AI应用
AI banking financial services credit scoring fraud detection 2026
AI fintech lending automation 2026

## 主题4: AI基础设施
AI datacenter infrastructure investment trillion 2026
GPU shortage AI chip supply Nvidia 2026

## 主题5: AI人才与竞争
AI talent war hiring compensation OpenAI Google 2026
AI researcher move startup big tech 2026

## 主题6: 模型竞争
Claude Sonnet Opus SWE-bench benchmark 2026
GPT-5.4 Gemini 3.1 coding benchmark comparison 2026

## 主题7: 中国AI动态
China AI large model Baidu Alibaba Tencent 2026
Chinese AI chip Huawei寒武纪 2026

## 主题8: 安全与监管
AI safety regulation EU AI Act 2026
AI alignment research breakthrough 2026
EOF

echo "  ✅ 搜索关键词已保存到 $OUTPUT_DIR/search_keywords.txt"

# Step 3: 生成报告模板（使用AI填充）
echo ""
echo "Step 3: 生成报告模板..."

cat > "$OUTPUT_DIR/daily_report_${DATE}.md" << 'EOF'
# AI & Banking Daily Report | 2026-04-05

---

## 今日主线：[AI将填充]

**核心数据**：[AI将填充]

---

## 一、今日必读：[AI将填充]

[AI将根据补充搜索内容填充]

---

## 二、专家观点：[AI将填充]

[AI将填充Andrew Ng、Karpathy等最新观点]

---

## 三、银行业AI应用：[AI将填充]

[AI将填充与用户背景相关的银行业AI内容]

---

## 四、模型竞争：[AI将填充]

[AI将填充Claude、GPT、Gemini最新基准对比]

---

## 五、AI基础设施：[AI将填充]

[AI将填充GPU短缺、数据中心投资等内容]

---

## 六、关键阈值监测表

| 指标 | 当前值 | 阈值 | 状态 |
|-----|-------|------|------|
| [AI将填充] | [AI将填充] | [AI将填充] | [AI将填充] |

---

**报告时间**：2026-04-05 | **数据来源**：[AI将填充]

*本报告由AI助手基于公开信息整理，仅供信息参考*
EOF

echo "  ✅ 报告模板已保存到 $OUTPUT_DIR/daily_report_${DATE}.md"

# Step 4: 生成重复检测提示
echo ""
echo "Step 4: 生成重复检测提示..."

cat > "$OUTPUT_DIR/dedup_prompt.txt" << 'EOF'
重复检测检查清单：

在生成今日报告前，请对比以下内容：

前3天报告中的主要主题：
1. DeepSeek V4华为芯片（4月4日已报道）→ 避免重复
2. Google Chinchilla算法（4月4日已报道）→ 避免重复
3. 视频生成模型竞争（Seedance/Sora/Veo，4月4日已报道）→ 避免重复
4. 智能体编码数据（Claude SWE-bench，4月4日已报道）→ 如提及需更新数据
5. 模型小型化（StepFun/小米，4月4日已报道）→ 避免重复

如果今日内容与上述主题重复度>50%，请触发补充搜索：
- Agentic AI企业应用
- Andrew Ng/Karpathy最新观点
- 银行业AI应用
- AI芯片短缺
- AI人才战争
- 数据中心投资

目标：确保与前几日报告重复度<30%
EOF

echo "  ✅ 重复检测提示已保存到 $OUTPUT_DIR/dedup_prompt.txt"

echo ""
echo "================================"
echo "报告生成准备完成！"
echo "================================"
echo ""
echo "下一步："
echo "1. 阅读前3天报告，识别重复主题"
echo "2. 执行基础搜索 + 补充搜索（如需要）"
echo "3. 使用AI填充报告模板"
echo "4. 生成最终报告"
echo ""
echo "输出文件："
echo "  - $OUTPUT_DIR/search_keywords.txt"
echo "  - $OUTPUT_DIR/daily_report_${DATE}.md"
echo "  - $OUTPUT_DIR/dedup_prompt.txt"
