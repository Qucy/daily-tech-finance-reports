# 📊 日报去重功能说明

## 功能概述

从2026年3月24日起，科技金融日报新增**智能去重**功能，自动检查过去7天的报告内容，避免重复信息。

## 工作原理

### 1. 检查范围
- **时间窗口**：生成报告时自动检查过去 **7天** 的内容
- **检查内容**：报告中的标题、模型名称、论文标题等关键信息
- **匹配方式**：模糊匹配（忽略大小写和空格）

### 2. 去重规则

#### 情况A：内容重复
如果某条信息在过去7天已报道过：

```markdown
### Cursor Composer 2 重磅发布

> ℹ️ **重复内容提示**：该信息已在 **2026-03-23** 的日报中详细报道，此处不再赘述。
```

**特点：**
- 仅保留标题
- 标注历史日期
- 不重复详细描述

#### 情况B：内容更新
如果是之前报道过的内容但有新进展：

```markdown
### GPT-5.4 最新更新

*注：GPT-5.4 于2026-03-05首次发布，本文档更新最新性能数据*

- 新增：多语言支持扩展至50+语言
- 改进：推理速度提升20%
```

### 3. 去重统计

每份报告底部会显示：
```
📊 今日去重统计：
   发现 3 条重复内容，已自动精简
   - 已在 2026-03-23 的日报中提及
   - 已在 2026-03-22 的日报中提及
```

## 好处

| 优势 | 说明 |
|------|------|
| 📉 减少冗余 | 避免每天重复相同信息 |
| ⏱️ 节省时间 | 快速浏览，只关注新内容 |
| 🎯 聚焦重点 | 突出当日真正重要的新闻 |
| 📚 可追溯 | 通过引用链接查看历史详情 |

## 技术实现

### 去重检查函数
```bash
# 检查内容是否在过去7天出现过
check_duplicate() {
    local content_title="$1"
    
    # 遍历过去7天
    for i in $(seq 1 7); do
        local check_date=$(date -d "-$i days" +%Y-%m-%d)
        local check_file="reports/YYYY/MM/DD/daily_report_YYYY_MM_DD.md"
        
        # 检查是否包含相似内容
        if [ -f "$check_file" ]; then
            # 提取标题进行匹配
            if 内容匹配; then
                echo "$check_date"  # 返回重复日期
                return 0
            fi
        fi
    done
    return 1  # 未重复
}
```

### 内容生成函数
```bash
# 根据是否重复决定输出格式
generate_content_item() {
    local title="$1"
    local content="$2"
    local item_date="$3"
    
    local dup_date=$(check_duplicate "$title")
    
    if [ -n "$dup_date" ]; then
        # 重复：仅显示标题+提示
        echo "### $title"
        echo "> ℹ️ 重复内容提示：已在 **${dup_date}** 报道"
    else
        # 新内容：显示完整描述
        echo "### $title"
        echo "$content"
    fi
}
```

## 查看历史内容

如需查看被标记为重复的详细内容，可：

1. **GitHub 仓库**：访问对应日期的报告文件
   ```
   https://github.com/Qucy/daily-tech-finance-reports/tree/main/reports/2026/03/23
   ```

2. **本地查找**：在仓库中按日期查找
   ```bash
   cd daily-tech-finance-reports
   cat reports/2026/03/23/daily_report_2026_03_23.md
   ```

## 注意事项

1. **首次运行**：由于没有历史数据，前7天可能不会触发去重
2. **部分匹配**：标题相似但不完全相同的内容可能被视为新内容
3. **更新内容**：重大更新会作为新条目报道，而非简单去重

## 反馈

如果去重功能有误判或需要调整，请告诉我！
