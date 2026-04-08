# OpenClaw Cron Setup for Daily Report
# 日报生成定时任务配置说明

## 问题背景

旧的定时任务只生成空模板，没有调用 AI 填充内容。
修复方案：使用 OpenClaw Cron + 子代理完成完整流程。

## 设置步骤

### 方法1: 使用 OpenClaw Cron (推荐)

添加定时任务到 OpenClaw:

```bash
# 每天 6:13 运行日报生成子代理
openclaw cron add \
  --name "daily-tech-finance-report" \
  --schedule "13 6 * * *" \
  --command "sessions_spawn --runtime=subagent --mode=run --task='生成日报' --cwd=/root/.openclaw/workspace/daily-tech-finance-reports"
```

或者使用配置文件方式:

```yaml
# ~/.openclaw/cron.yaml
cron:
  - name: daily-report
    schedule: "13 6 * * *"
    timezone: "Asia/Shanghai"
    action:
      type: sessions_spawn
      runtime: subagent
      mode: run
      cwd: /root/.openclaw/workspace/daily-tech-finance-reports
      task: |
        生成今日科技金融日报：
        1. 搜索监管、专家、银行、技术新闻
        2. 生成中文报告 (daily_report_YYYYMMDD.sc.md)
        3. 生成英文报告 (daily_report_YYYYMMDD.en.md)
        4. 推送到 GitHub
```

### 方法2: 保留系统 Cron，但添加内容生成

修改现有 cron 任务，在生成模板后调用内容填充脚本。

编辑 crontab:
```bash
crontab -e
```

替换原有任务:
```cron
# 旧的（只生成模板）:
# 13 6 * * * cd /root/.openclaw/workspace/daily-tech-finance-reports && bash scripts/generate_report_v2.sh

# 新的（需要手动触发子代理）:
13 6 * * * cd /root/.openclaw/workspace/daily-tech-finance-reports && bash scripts/generate_report_v3.sh && echo "Template generated. Run subagent to fill content." >> logs/cron.log 2>&1
```

**注意**: 系统 cron 无法直接调用 OpenClaw 工具，需要手动或通过其他方式触发子代理。

### 方法3: 手动每日触发 (当前方案)

每天手动执行:
```bash
cd /root/.openclaw/workspace/daily-tech-finance-reports
# 然后请求 AI 助手生成日报
```

## 推荐方案

**使用 OpenClaw 内置 Cron 系统**:

1. 它可以直接调用 sessions_spawn 启动子代理
2. 子代理可以使用 kimi_search 等工具
3. 完整流程自动化，无需人工干预

## 验证

检查定时任务:
```bash
openclaw cron list
```

查看日志:
```bash
tail -f ~/.openclaw/workspace/daily-tech-finance-reports/logs/subagent_*.log
```

## 故障排除

如果报告生成失败:

1. 检查子代理日志: `logs/subagent_YYYYMMDD.log`
2. 检查 GitHub 状态: 确保 token 有效
3. 检查搜索工具: 确保 kimi_search 可用
4. 手动触发测试: 直接运行子代理任务验证流程
