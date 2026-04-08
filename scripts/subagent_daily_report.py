#!/usr/bin/env python3
"""
Daily Report Subagent - 日报生成子代理
此脚本由 sessions_spawn 调用，负责完整的日报生成流程
"""

import os
import sys
import json
import subprocess
from datetime import datetime, timedelta
from pathlib import Path

# 配置
WORKSPACE = Path("/root/.openclaw/workspace/daily-tech-finance-reports")
DATE = datetime.now()
YEAR = DATE.strftime("%Y")
MONTH = DATE.strftime("%m")
DAY = DATE.strftime("%d")
DATE_STR = DATE.strftime("%Y%m%d")
OUTPUT_DIR = WORKSPACE / "reports" / f"{YEAR}{MONTH}" / DAY
LOG_FILE = WORKSPACE / "logs" / f"subagent_{DATE_STR}.log"

def log(msg):
    """打印并记录日志"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {msg}"
    print(line)
    with open(LOG_FILE, "a") as f:
        f.write(line + "\n")

def run_github_monitor():
    """运行 GitHub 监控"""
    log("▶ Step 1: Running GitHub Monitor...")
    monitor_script = WORKSPACE / "scripts" / "monitor.py"
    if monitor_script.exists():
        result = subprocess.run(
            ["python3", str(monitor_script), "--once"],
            cwd=str(WORKSPACE),
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            log("✓ Monitor completed")
        else:
            log(f"⚠ Monitor warning: {result.stderr[:200]}")
    else:
        log("⚠ Monitor script not found")

def get_latest_monitor_report():
    """获取最新的监控报告"""
    monitor_dir = WORKSPACE / "monitor_data" / "reports"
    if monitor_dir.exists():
        reports = sorted(monitor_dir.glob("daily_*.md"), reverse=True)
        if reports:
            return reports[0]
    return None

def read_previous_reports():
    """读取前3天的报告用于去重"""
    log("▶ Step 2: Reading previous reports for deduplication...")
    previous_topics = []
    
    for i in range(1, 4):
        prev_date = DATE - timedelta(days=i)
        prev_dir = WORKSPACE / "reports" / f"{prev_date.strftime('%Y%m')}" / prev_date.strftime("%d")
        
        for report_file in prev_dir.glob("daily_report_*.md"):
            try:
                content = report_file.read_text(encoding="utf-8")
                # 提取标题和主要话题
                lines = content.split("\n")
                for line in lines[:50]:  # 只读前50行
                    if line.startswith("##") and "主线" in line:
                        previous_topics.append(line.strip())
            except Exception as e:
                log(f"⚠ Error reading {report_file}: {e}")
    
    log(f"✓ Found {len(previous_topics)} previous main topics")
    return previous_topics

def generate_search_keywords():
    """生成搜索关键词列表"""
    return {
        "regulatory": [
            "BIS artificial intelligence banking guidance 2026",
            "Federal Reserve AI guidance banking 2026",
            "OCC model risk management AI 2026",
            "EU AI Act banking financial services 2026",
            "中国人民银行 人工智能 银行 2026",
            "银保监会 算法 监管 2026",
            "HKMA fintech AI guidance 2026",
            "MAS Singapore AI finance 2026",
        ],
        "experts": [
            "Andrej Karpathy LLM reasoning 2026",
            "Andrew Ng AI enterprise workflow 2026",
            "Jim Marous digital banking AI 2026",
        ],
        "banking": [
            "JPMorgan COiN AI platform 2026",
            "Goldman Sachs machine learning trading 2026",
            "HSBC innovation AI digital 2026",
            "招商银行 人工智能 金融科技 2026",
            "平安银行 AI 智能风控 2026",
        ],
        "tech": [
            "GPT-5.4 benchmark 2026",
            "Claude 4 SWE-bench 2026",
            "DeepSeek V4 release 2026",
            "Gemini 3.1 enterprise 2026",
            "Agentic AI enterprise adoption 2026",
        ]
    }

def main():
    """主函数"""
    # 确保目录存在
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    
    log("=" * 60)
    log("Daily Report Subagent Started")
    log(f"Date: {YEAR}-{MONTH}-{DAY}")
    log(f"Output: {OUTPUT_DIR}")
    log("=" * 60)
    log("")
    
    # Step 1: 运行 GitHub 监控
    run_github_monitor()
    
    # 获取监控报告
    monitor_report = get_latest_monitor_report()
    if monitor_report:
        log(f"✓ Monitor report: {monitor_report.name}")
    
    # Step 2: 读取历史报告（去重）
    previous_topics = read_previous_reports()
    
    # Step 3: 生成搜索关键词
    log("▶ Step 3: Preparing search keywords...")
    keywords = generate_search_keywords()
    log(f"✓ Keywords prepared: {sum(len(v) for v in keywords.values())} terms")
    
    # Step 4: 创建任务标记文件
    task_marker = OUTPUT_DIR / ".ai_task_ready"
    task_data = {
        "date": f"{YEAR}-{MONTH}-{DAY}",
        "output_dir": str(OUTPUT_DIR),
        "monitor_report": str(monitor_report) if monitor_report else None,
        "previous_topics": previous_topics,
        "keywords": keywords,
        "status": "ready_for_ai_fill"
    }
    
    with open(task_marker, "w") as f:
        json.dump(task_data, f, indent=2)
    
    log(f"✓ Task marker created: {task_marker}")
    log("")
    log("=" * 60)
    log("Subagent preparation complete!")
    log("Next: AI needs to search and fill report content")
    log("=" * 60)
    
    # 输出任务信息到 stdout（父代理可以捕获）
    print("\n" + "=" * 60)
    print("SUBAGENT_TASK_READY")
    print(f"Task file: {task_marker}")
    print(f"Output dir: {OUTPUT_DIR}")
    print("Next action: Run kimi_search and generate reports")
    print("=" * 60)

if __name__ == "__main__":
    main()
