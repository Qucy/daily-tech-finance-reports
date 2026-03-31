# GitHub 自动推送设置指南

## 📋 前置要求

1. **GitHub 账号** - 确保你有一个 GitHub 账号
2. **GitHub CLI** - 已安装 `gh` 命令行工具
3. **Git** - 已安装 `git`

## 🔐 第一步：GitHub 认证

运行以下命令登录 GitHub：

```bash
gh auth login
```

按照提示选择：
- **What account do you want to log into?** → `GitHub.com`
- **What is your preferred protocol for Git operations on this host?** → `HTTPS`
- **Authenticate Git with your GitHub credentials?** → `Yes`
- **How would you like to authenticate GitHub CLI?** → `Login with a web browser`

然后会显示一个验证码，按提示在浏览器中打开并输入。

## 📝 第二步：配置仓库

### 方案 A：使用现有仓库

如果你有现成的仓库，设置环境变量：

```bash
export GITHUB_REPO_URL="https://github.com/你的用户名/你的仓库名.git"
```

### 方案 B：自动创建新仓库（推荐）

脚本会自动创建一个名为 `daily-tech-finance-reports` 的公开仓库。

## 🧪 第三步：测试推送

运行测试脚本：

```bash
cd /root/.openclaw/workspace
./scripts/push_to_github.sh
```

如果成功，你会看到：
```
✅ 完成！报告已推送到 GitHub
📁 位置: reports/2026/03/23/
```

## ⏰ 第四步：配置自动定时任务

已经配置好的定时任务会自动执行：

```bash
openclaw cron add --name "daily-tech-finance-report" --cron "17 8 * * *" --session isolated --message "..."
```

## 📁 报告结构

推送成功后，你的仓库结构会是这样：

```
daily-tech-finance-reports/
├── README.md          # 自动更新的首页
├── reports/
│   └── 2026/
│       └── 03/
│           └── 23/
│               ├── daily_report_2026_03_23.md
│               └── daily_report_2026_03_23.pdf
└── .gitignore
```

## 🔗 访问报告

推送后可以通过以下链接访问：

```
https://github.com/你的用户名/daily-tech-finance-reports/tree/main/reports/2026/03/23
```

## 🛠️ 故障排除

### 问题：gh auth login 失败

**解决**：使用 Token 方式登录

```bash
# 在 GitHub 网站生成 Personal Access Token
# https://github.com/settings/tokens

# 然后使用 token 登录
echo "你的token" | gh auth login --with-token
```

### 问题：推送权限被拒绝

**解决**：检查仓库权限

```bash
# 检查当前登录用户
gh api user -q .login

# 确保仓库是公开的或你有写入权限
```

### 问题：PDF 生成失败

**解决**：检查依赖

```bash
# 确保已安装
which pandoc      # Markdown 转 HTML
which google-chrome  # HTML 转 PDF
```

## 💡 高级配置

### 私有仓库

如果你想用私有仓库，修改脚本中的 `gh repo create` 命令：

```bash
gh repo create "$REPO_NAME" --private ...
```

### 自定义目录结构

修改脚本中的 `REPORT_DIR` 变量：

```bash
# 按周组织
REPORT_DIR="reports/${YEAR}/week-$(date +%U)"

# 按月组织
REPORT_DIR="reports/${YEAR}/${MONTH}"
```

### 添加邮件通知

在脚本末尾添加：

```bash
# 发送通知（需要配置邮件服务）
curl -X POST \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"📊 日报已生成: reports/${YEAR}/${MONTH}/${DAY}/\"}" \
  "你的 webhook URL"
```

## 📞 需要帮助？

如果遇到问题，可以：
1. 检查 `gh auth status` 确认已登录
2. 运行 `git config --list` 确认 git 配置正确
3. 查看脚本输出日志排查问题
