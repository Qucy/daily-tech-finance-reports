# 🕵️ Banking AI Intelligence Monitor

银行业AI情报监控系统 - 自动化抓取Twitter/X和GitHub上的银行业AI动态

## 📋 功能特性

- **Twitter/X 监控**: 追踪AI研究员、银行技术负责人、行业专家的实时动态
- **GitHub 监控**: 监控相关仓库的发布、趋势、代码更新
- **智能告警**: 基于关键词和优先级的自动告警系统
- **日报生成**: 自动生成结构化的情报日报
- **数据持久化**: 所有监控数据本地存储，支持历史查询

## 🚀 快速开始

### 1. 环境准备

```bash
# 进入项目目录
cd /root/.openclaw/workspace/daily-tech-finance-reports

# 启动监控（会自动创建虚拟环境并安装依赖）
bash scripts/start_monitor.sh
```

### 2. 配置API凭证（可选但推荐）

**Twitter/X API**:
```bash
export TWITTER_BEARER_TOKEN="your_twitter_bearer_token"
```
获取方式: https://developer.twitter.com/en/portal/dashboard

**GitHub API**:
```bash
export GITHUB_TOKEN="your_github_personal_access_token"
```
获取方式: GitHub Settings → Developer settings → Personal access tokens

### 3. 运行监控

```bash
# 单次运行
python3 scripts/monitor.py --once

# 持续监控（每30分钟检查一次）
python3 scripts/monitor.py --continuous

# 测试连接
python3 scripts/monitor.py --test-twitter
python3 scripts/monitor.py --test-github
```

## 📁 文件结构

```
daily-tech-finance-reports/
├── config/
│   ├── banking_ai_sources.yaml    # 银行业AI信源配置
│   └── monitor_config.json        # 监控器配置
├── templates/
│   └── regulatory_radar_template.md  # 监管雷达模板
├── scripts/
│   ├── monitor.py                 # 主监控脚本
│   └── start_monitor.sh           # 启动脚本
└── monitor_data/                  # 数据存储目录
    ├── twitter/                   # Twitter数据
    ├── github/                    # GitHub数据
    └── reports/                   # 生成的报告
```

## ⚙️ 配置说明

### 监控账号配置 (`config/monitor_config.json`)

#### Twitter/X 账号分类

**AI研究员** (高优先级):
- @karpathy - Andrej Karpathy (LLM, AI基础设施)
- @AndrewYNg - Andrew Ng (企业AI, Landing AI)
- @ylecun - Yann LeCun (深度学习, Meta AI)

**银行/Fintech专家**:
- @jimmarous - Jim Marous (数字银行)
- @bfin - Bradley Leimer (银行创新)

**银行官方账号**:
- @jpmorgan - JPMorgan Chase
- @GoldmanSachs - Goldman Sachs
- @HSBC - HSBC

#### GitHub 监控分类

**银行Fintech相关**:
- huggingface/transformers
- langchain-ai/langchain
- microsoft/promptflow

**搜索监控**:
- `fraud detection machine learning stars:>100`
- `credit scoring AI stars:>50`
- `anti-money laundering AML stars:>30`

### 告警规则

| 优先级 | 条件 | 动作 |
|--------|------|------|
| 🔴 高 | 高优先级账号 + 高互动量 | 立即通知 |
| 🟡 中 | 中优先级账号 + 关键词匹配 | 批量摘要 |
| 🟢 低 | 其他情况 | 日报汇总 |

## 📊 输出格式

### 每日情报报告

```markdown
# 🕵️ 银行业AI情报日报 | 2026-04-05 08:00

## 📊 今日概览
| 来源 | 高优先级 | 中优先级 | 低优先级 | 总计 |
|------|----------|----------|----------|------|
| Twitter/X | 2 | 5 | 10 | 17 |
| GitHub | 1 | 3 | 5 | 9 |

## 🐦 Twitter/X 亮点

### 🔴 高优先级
**@karpathy** • 2026-04-05T02:30:00

GPT-5.4在OSWorld-V基准测试达到75%，首次超越人类基线...

*匹配关键词: LLM, model, breakthrough*

## 🐙 GitHub 动态

### 📦 新发布
**langchain-ai/langchain** - v0.1.50

新增银行级RAG示例和合规工具...
```

### 数据存储格式

**Twitter数据** (`monitor_data/twitter/{handle}_{date}.jsonl`):
```json
{
  "id": "1234567890",
  "text": "推文内容",
  "created_at": "2026-04-05T02:30:00",
  "handle": "karpathy",
  "metrics": {"retweet_count": 1000, "like_count": 5000}
}
```

**GitHub数据** (`monitor_data/github/{repo}_{date}.jsonl`):
```json
{
  "type": "new_release",
  "repo": "langchain-ai/langchain",
  "tag": "v0.1.50",
  "published_at": "2026-04-05T01:00:00"
}
```

## 🔧 高级用法

### 自定义监控账号

编辑 `config/monitor_config.json`:

```json
{
  "twitter_monitor": {
    "accounts": {
      "ai_researchers": [
        {
          "handle": "your_target_handle",
          "name": "Display Name",
          "priority": "high",
          "keywords": ["AI", "banking"],
          "alert_on": ["announcement"]
        }
      ]
    }
  }
}
```

### 添加新的GitHub搜索

```json
{
  "github_monitor": {
    "repositories": {
      "your_category": [
        {
          "search_query": "your search query stars:>50",
          "priority": "medium",
          "track": ["new repos", "stars growth"]
        }
      ]
    }
  }
}
```

### 与日报系统集成

监控报告可以自动集成到日报中:

```bash
# 在 generate_report_improved.sh 中添加
python3 scripts/monitor.py --once
# 读取最新报告并合并
cat monitor_data/reports/daily_*.md >> daily_report.md
```

## ⚠️ 注意事项

### API限制

**Twitter API**:
- 免费版: 每月5000条推文读取限制
- 建议监控频率: 每30分钟一次
- 如果超出限制，监控将自动跳过

**GitHub API**:
- 未认证: 每小时60次请求
- 已认证: 每小时5000次请求
- 强烈建议设置 GITHUB_TOKEN

### 隐私与合规

- 本工具仅读取公开信息
- 遵守各平台的服务条款
- 数据仅本地存储，不上传云端
- 建议定期清理历史数据（默认保留90天）

## 🔮 未来扩展

计划添加的监控源:
- [ ] LinkedIn 公司动态
- [ ] Reddit (r/MachineLearning, r/fintech)
- [ ] arXiv 论文发布
- [ ] Discord AI社区
- [ ] YouTube频道 (Two Minute Papers等)
- [ ] Crunchbase融资信息
- [ ] 微博/微信监控（国内）

## 📝 更新日志

### v1.0 (2026-04-05)
- 初始版本发布
- Twitter/X监控支持
- GitHub监控支持
- 日报生成功能
- 告警系统

## 🤝 贡献

欢迎提交Issue和PR来改进这个监控系统。

## 📄 许可证

MIT License

---

*Created by Kimi Claw for Qucy / HSBC Innovation*
