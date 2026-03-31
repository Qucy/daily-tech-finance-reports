# 📊 科技金融日报 - HTML 版本与 Git Flow 说明

## 🌐 HTML 版本功能

从 2026-03-27 开始，日报将同时生成 **HTML 网页版本**，提供更美观的阅读体验。

### HTML 版本特性

- ✅ **响应式设计**：完美适配手机、平板、电脑
- ✅ **现代 UI**：渐变背景、卡片式布局、圆角设计
- ✅ **导航链接**：快速跳转到首页、月份目录、Markdown 源文件
- ✅ **徽章标识**：3天过滤、7天去重状态一目了然
- ✅ **代码高亮**：技术内容自动格式化
- ✅ **引用样式**：重复内容提示使用醒目的黄色边框

### 生成的文件

每期日报将包含三个版本：

```
reports/202603/27/
├── daily_report_2026_03_27.md      # Markdown 源文件
├── daily_report_2026_03_27.html    # 🆕 HTML 网页版本
└── daily_report_2026_03_27.pdf     # PDF 导出版本
```

### 在线访问地址

HTML 版本可通过 GitHub Pages 访问：

```
https://Qucy.github.io/daily-tech-finance-reports/reports/202603/27/daily_report_2026_03_27.html
```

---

## 🌿 Git Flow 工作流

从 2026-03-27 开始，日报发布将采用 **Git Flow** 分支管理策略。

### 工作流程

```
main 分支 ──────────────────────────────────────
              │
              │  1. 创建 Feature 分支
              ▼
feature/daily-report-2026-03-27 ─── 2. 提交更改
              │
              │  3. 推送 Feature 分支
              │
              │  4. 合并到 Main
              ▼
main 分支 ──────────────────────────────────────
              │
              │  5. 删除 Feature 分支
              ▼
           [完成]
```

### 详细步骤

#### 1. 创建 Feature 分支
```bash
git checkout main
git checkout -b feature/daily-report-2026-03-27
```

#### 2. 生成报告并提交
```bash
# 生成 Markdown、HTML、PDF
# ...

git add -A
git commit -m "📊 Daily Report: 2026-03-27"
```

#### 3. 推送到远程
```bash
git push -u origin feature/daily-report-2026-03-27
```

#### 4. 合并到 Main
```bash
git checkout main
git merge feature/daily-report-2026-03-27 --no-ff
```

#### 5. 清理 Feature 分支
```bash
git push origin --delete feature/daily-report-2026-03-27
git branch -d feature/daily-report-2026-03-27
```

---

## 🔄 完整自动化流程

### 每天 8:17 AM 的执行流程

1. **获取当前时间**
   - 调用 `session_status` 确认当前日期
   - 计算 3 天前的过滤阈值

2. **Git Flow 开始**
   - 从 main 分支创建 `feature/daily-report-YYYYMMDD`

3. **搜索新闻**
   - Latent Space AINews
   - 国内银行业 AI 动态
   - 最新论文和模型发布

4. **时间过滤**
   - 只保留最近 3 天内的新闻
   - 丢弃 2025 年及更早的内容

5. **7天去重**
   - 检查过去 7 天的报告
   - 重复内容仅保留标题

6. **生成报告**
   - ✅ Markdown 版本
   - ✅ HTML 网页版本（新增）
   - ✅ PDF 导出版本

7. **Git Flow 结束**
   - 提交到 Feature 分支
   - 合并到 Main 分支
   - 推送并清理

8. **发送通知**
   - 微信推送报告链接
   - GitHub 仓库更新

---

## 📱 访问方式

### 方式一：HTML 网页（推荐）
```
https://Qucy.github.io/daily-tech-finance-reports/reports/202603/27/daily_report_2026_03_27.html
```
- 最佳阅读体验
- 支持手机/平板
- 代码高亮、表格样式

### 方式二：GitHub 预览
```
https://github.com/Qucy/daily-tech-finance-reports/blob/main/reports/202603/27/daily_report_2026_03_27.md
```
- 直接查看 Markdown
- 支持版本历史

### 方式三：本地文件
```bash
git clone https://github.com/Qucy/daily-tech-finance-reports.git
open daily-tech-finance-reports/reports/202603/27/daily_report_2026_03_27.html
```

---

## ⚙️ 技术实现

### HTML 生成

使用自定义 HTML 模板 + Markdown 转换：

```bash
# 1. 生成 Markdown
pandoc input.md -o output.html --template=template.html

# 2. 或使用内置转换函数
generate_html() {
    # 注入 CSS 样式
    # 转换 Markdown 内容
    # 添加导航和页脚
}
```

### Git Flow 脚本

```bash
# 分支命名规范
FEATURE_BRANCH="feature/daily-report-${CURRENT_DATE}"

# 创建分支
git checkout -b "$FEATURE_BRANCH"

# 提交并推送
git add -A
git commit -m "📊 Daily Report: ${CURRENT_DATE}"
git push -u origin "$FEATURE_BRANCH"

# 合并到 main
git checkout main
git merge "$FEATURE_BRANCH" --no-ff

# 清理
git push origin --delete "$FEATURE_BRANCH"
git branch -d "$FEATURE_BRANCH"
```

---

## 📊 功能对比

| 功能 | Markdown | HTML | PDF |
|------|----------|------|-----|
| 手机阅读 | ⚠️ 一般 | ✅ 完美 | ✅ 完美 |
| 代码高亮 | ⚠️ 基础 | ✅ 完整 | ✅ 完整 |
| 响应式 | ❌ 不支持 | ✅ 支持 | ✅ 支持 |
| 离线访问 | ✅ 支持 | ✅ 支持 | ✅ 支持 |
| 打印友好 | ❌ 不适合 | ⚠️ 一般 | ✅ 完美 |
| 编辑修改 | ✅ 方便 | ❌ 不方便 | ❌ 不方便 |

---

## 🔮 未来计划

- [ ] 启用 GitHub Pages 自动部署
- [ ] 添加搜索功能
- [ ] 按标签/类别浏览
- [ ] RSS 订阅
- [ ] 邮件订阅

---

## 📞 问题反馈

如有问题，请通过以下方式联系：
- GitHub Issues: https://github.com/Qucy/daily-tech-finance-reports/issues
- 微信: Kimi Claw

---

*最后更新: 2026-03-26*
*版本: v2.0 (HTML + Git Flow)*
