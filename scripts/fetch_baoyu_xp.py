#!/usr/bin/env python3
"""
宝玉xp内容获取脚本
获取中文AI博主宝玉xp的最新内容
"""

import subprocess
import json
from datetime import datetime
from pathlib import Path

def search_baoyu_content(date_str=None):
    """
    搜索宝玉xp的最新内容
    由于微博需要登录，使用kimi_search进行搜索
    """
    if date_str is None:
        date_str = datetime.now().strftime("%Y年%m月%d日")
    
    # 搜索关键词组合
    search_queries = [
        f"宝玉xp {datetime.now().strftime('%Y年%m月')} AI",
        f"宝玉xp {datetime.now().strftime('%Y年%m月%d日')}",
        "宝玉xp Claude",
        "宝玉xp ChatGPT",
        "宝玉xp 大模型",
        "宝玉xp baoyu.io",
    ]
    
    results = []
    for query in search_queries:
        try:
            # 使用kimi_search搜索
            # 注意：这里只是记录搜索词，实际搜索由子代理执行
            results.append({
                "query": query,
                "source": "kimi_search",
                "type": "baoyu_xp_content"
            })
        except Exception as e:
            print(f"搜索失败 {query}: {e}")
    
    return results

def get_baoyu_blog_feed():
    """
    获取宝玉xp博客的最新文章
    博客地址: https://baoyu.io/blog
    """
    blog_url = "https://baoyu.io/blog"
    # 博客内容可以通过 kimi_fetch 获取
    return {
        "url": blog_url,
        "type": "blog_feed",
        "description": "宝玉xp个人博客 - AI技术文章和评论"
    }

def generate_search_tasks():
    """
    生成每日搜索任务列表
    """
    today = datetime.now()
    date_str = today.strftime("%Y年%m月%d日")
    month_str = today.strftime("%Y年%m月")
    
    tasks = [
        {
            "priority": "high",
            "query": f"宝玉xp {month_str} AI新闻",
            "reason": "获取当月AI新闻汇总"
        },
        {
            "priority": "high", 
            "query": "宝玉xp Claude Code",
            "reason": "Claude Code相关内容"
        },
        {
            "priority": "medium",
            "query": "宝玉xp ChatGPT",
            "reason": "ChatGPT相关内容"
        },
        {
            "priority": "medium",
            "query": "宝玉xp 大模型",
            "reason": "大模型相关内容"
        },
        {
            "priority": "low",
            "query": "宝玉xp Agent",
            "reason": "Agent相关内容"
        },
        {
            "priority": "low",
            "query": f"site:baoyu.io {today.strftime('%Y')}",
            "reason": "博客最新文章"
        }
    ]
    
    return tasks

def main():
    """主函数"""
    print("=" * 60)
    print("宝玉xp内容获取脚本")
    print(f"时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    print()
    
    # 生成搜索任务
    tasks = generate_search_tasks()
    
    print("搜索任务列表:")
    print("-" * 60)
    for i, task in enumerate(tasks, 1):
        print(f"{i}. [{task['priority']}] {task['query']}")
        print(f"   目的: {task['reason']}")
        print()
    
    # 输出到文件
    output = {
        "source": "宝玉xp",
        "platform": "微博/博客",
        "date": datetime.now().strftime("%Y-%m-%d"),
        "search_tasks": tasks,
        "blog_url": "https://baoyu.io/blog",
        "weibo_url": "https://weibo.com/u/1727858283",
        "description": "前微软Asp.Net MVP，111万+粉丝，最具影响力AI大V"
    }
    
    # 保存到报告目录
    workspace = Path("/root/.openclaw/workspace/daily-tech-finance-reports")
    today = datetime.now()
    output_dir = workspace / "reports" / f"{today.strftime('%Y%m')}" / today.strftime("%d")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    output_file = output_dir / "baoyu_xp_tasks.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
    
    print(f"✓ 搜索任务已保存: {output_file}")
    print()
    print("使用说明:")
    print("1. 使用 kimi_search 执行上述搜索任务")
    print("2. 整合宝玉xp的内容到日报中")
    print("3. 重点关注: Claude, ChatGPT, Agent, 大模型等主题")

if __name__ == "__main__":
    main()
