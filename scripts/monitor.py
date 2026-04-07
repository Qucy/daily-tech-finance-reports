#!/usr/bin/env python3
"""
Banking AI Intelligence Monitor
银行业AI情报监控系统

功能:
- 监控Twitter/X KOL和机构账号
- 监控GitHub仓库更新和趋势
- 生成每日情报摘要
- 实时高优先级警报

作者: Kimi Claw
版本: 1.0
日期: 2026-04-05
"""

import os
import sys
import json
import time
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Any
import threading
import schedule

# 尝试导入可选依赖
try:
    import tweepy
    TWITTER_AVAILABLE = True
except ImportError:
    TWITTER_AVAILABLE = False
    print("Warning: tweepy not installed. Twitter monitoring disabled.")

try:
    from github import Github
    GITHUB_AVAILABLE = True
except ImportError:
    GITHUB_AVAILABLE = False
    print("Warning: PyGithub not installed. GitHub monitoring disabled.")

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False
    print("Warning: requests not installed. Some features disabled.")


# ============== 配置 ==============

class Config:
    """配置管理器"""
    
    CONFIG_FILE = "config/monitor_config.json"
    
    def __init__(self):
        self.config = self._load_config()
        self.data_dir = Path(self.config.get("storage", {}).get("data_dir", "./monitor_data"))
        self.data_dir.mkdir(parents=True, exist_ok=True)
        
    def _load_config(self) -> dict:
        """加载配置文件"""
        try:
            with open(self.CONFIG_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"Error: Config file not found: {self.CONFIG_FILE}")
            return {}
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON in config file: {e}")
            return {}
    
    def get(self, key: str, default=None):
        """获取配置项"""
        keys = key.split('.')
        value = self.config
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
                if value is None:
                    return default
            else:
                return default
        return value


# ============== 数据存储 ==============

class DataStore:
    """数据存储管理"""
    
    def __init__(self, data_dir: Path):
        self.data_dir = data_dir
        self.twitter_dir = data_dir / "twitter"
        self.github_dir = data_dir / "github"
        self.reports_dir = data_dir / "reports"
        
        for d in [self.twitter_dir, self.github_dir, self.reports_dir]:
            d.mkdir(parents=True, exist_ok=True)
    
    def save_tweet(self, handle: str, tweet_data: dict):
        """保存推文数据"""
        date_str = datetime.now().strftime("%Y%m%d")
        file_path = self.twitter_dir / f"{handle}_{date_str}.jsonl"
        
        with open(file_path, 'a', encoding='utf-8') as f:
            f.write(json.dumps(tweet_data, ensure_ascii=False) + '\n')
    
    def save_github_event(self, repo: str, event_data: dict):
        """保存GitHub事件"""
        date_str = datetime.now().strftime("%Y%m%d")
        file_path = self.github_dir / f"{repo.replace('/', '_')}_{date_str}.jsonl"
        
        with open(file_path, 'a', encoding='utf-8') as f:
            f.write(json.dumps(event_data, ensure_ascii=False) + '\n')
    
    def load_recent_tweets(self, handle: str, hours: int = 24) -> List[dict]:
        """加载最近推文"""
        tweets = []
        since = datetime.now() - timedelta(hours=hours)
        
        # 加载今天和昨天的文件
        for days_ago in [0, 1]:
            date_str = (datetime.now() - timedelta(days=days_ago)).strftime("%Y%m%d")
            file_path = self.twitter_dir / f"{handle}_{date_str}.jsonl"
            
            if file_path.exists():
                with open(file_path, 'r', encoding='utf-8') as f:
                    for line in f:
                        try:
                            tweet = json.loads(line)
                            tweet_time = datetime.fromisoformat(tweet.get('created_at', ''))
                            if tweet_time > since:
                                tweets.append(tweet)
                        except:
                            continue
        
        return tweets
    
    def save_report(self, report: str, report_type: str = "daily"):
        """保存报告"""
        date_str = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_path = self.reports_dir / f"{report_type}_{date_str}.md"
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(report)
        
        return file_path


# ============== Twitter监控 ==============

class TwitterMonitor:
    """Twitter监控器"""
    
    def __init__(self, config: Config, data_store: DataStore):
        self.config = config
        self.data_store = data_store
        self.client = None
        self._init_client()
    
    def _init_client(self):
        """初始化Twitter客户端"""
        if not TWITTER_AVAILABLE:
            print("Twitter monitoring disabled: tweepy not installed")
            return
        
        bearer_token = os.getenv("TWITTER_BEARER_TOKEN")
        if not bearer_token:
            print("Twitter monitoring disabled: TWITTER_BEARER_TOKEN not set")
            return
        
        try:
            self.client = tweepy.Client(bearer_token=bearer_token)
            print("Twitter client initialized successfully")
        except Exception as e:
            print(f"Error initializing Twitter client: {e}")
    
    def is_available(self) -> bool:
        """检查是否可用"""
        return self.client is not None
    
    def get_user_tweets(self, handle: str, max_results: int = 5) -> List[dict]:
        """获取用户最新推文"""
        if not self.is_available():
            return []
        
        try:
            # 获取用户ID
            user = self.client.get_user(username=handle)
            if not user.data:
                return []
            
            # 获取推文
            tweets = self.client.get_users_tweets(
                id=user.data.id,
                max_results=max_results,
                tweet_fields=['created_at', 'public_metrics', 'context_annotations']
            )
            
            if not tweets.data:
                return []
            
            result = []
            for tweet in tweets.data:
                tweet_data = {
                    'id': str(tweet.id),
                    'text': tweet.text,
                    'created_at': tweet.created_at.isoformat() if tweet.created_at else None,
                    'handle': handle,
                    'metrics': tweet.public_metrics,
                    'annotations': tweet.context_annotations
                }
                result.append(tweet_data)
                
                # 保存到数据存储
                self.data_store.save_tweet(handle, tweet_data)
            
            return result
            
        except Exception as e:
            print(f"Error fetching tweets for {handle}: {e}")
            return []
    
    def search_tweets(self, query: str, max_results: int = 10) -> List[dict]:
        """搜索推文"""
        if not self.is_available():
            return []
        
        try:
            tweets = self.client.search_recent_tweets(
                query=query,
                max_results=max_results,
                tweet_fields=['created_at', 'public_metrics', 'author_id']
            )
            
            if not tweets.data:
                return []
            
            result = []
            for tweet in tweets.data:
                result.append({
                    'id': str(tweet.id),
                    'text': tweet.text,
                    'created_at': tweet.created_at.isoformat() if tweet.created_at else None,
                    'author_id': str(tweet.author_id) if tweet.author_id else None,
                    'metrics': tweet.public_metrics
                })
            
            return result
            
        except Exception as e:
            print(f"Error searching tweets: {e}")
            return []
    
    def monitor_accounts(self):
        """监控配置的账号"""
        if not self.is_available():
            print("Skipping Twitter monitoring: not available")
            return []
        
        alerts = []
        accounts = self.config.get('twitter_monitor.accounts', {})
        
        for category, handles in accounts.items():
            print(f"\nMonitoring {category}...")
            for account in handles:
                handle = account.get('handle', '').lstrip('@')
                priority = account.get('priority', 'low')
                keywords = account.get('keywords', [])
                
                print(f"  Checking @{handle} (priority: {priority})")
                
                tweets = self.get_user_tweets(handle, max_results=3)
                
                for tweet in tweets:
                    # 检查是否包含关键词
                    text_lower = tweet['text'].lower()
                    matched_keywords = [kw for kw in keywords if kw.lower() in text_lower]
                    
                    if matched_keywords:
                        alert = {
                            'source': 'twitter',
                            'handle': handle,
                            'priority': priority,
                            'tweet': tweet,
                            'matched_keywords': matched_keywords,
                            'detected_at': datetime.now().isoformat()
                        }
                        alerts.append(alert)
                        print(f"    🔔 Alert: {tweet['text'][:80]}...")
        
        return alerts


# ============== GitHub监控 ==============

class GitHubMonitor:
    """GitHub监控器"""
    
    def __init__(self, config: Config, data_store: DataStore):
        self.config = config
        self.data_store = data_store
        self.client = None
        self._init_client()
    
    def _init_client(self):
        """初始化GitHub客户端"""
        if not GITHUB_AVAILABLE:
            print("GitHub monitoring disabled: PyGithub not installed")
            return
        
        token = os.getenv("GITHUB_TOKEN")
        try:
            if token:
                self.client = Github(token)
                print("GitHub client initialized with token")
            else:
                self.client = Github()
                print("GitHub client initialized without token (rate limited)")
        except Exception as e:
            print(f"Error initializing GitHub client: {e}")
    
    def is_available(self) -> bool:
        """检查是否可用"""
        return self.client is not None
    
    def get_repo_info(self, owner: str, repo: str) -> Optional[dict]:
        """获取仓库信息"""
        if not self.is_available():
            return None
        
        try:
            repository = self.client.get_repo(f"{owner}/{repo}")
            
            return {
                'name': repository.name,
                'full_name': repository.full_name,
                'description': repository.description,
                'stars': repository.stargazers_count,
                'forks': repository.forks_count,
                'language': repository.language,
                'updated_at': repository.updated_at.isoformat() if repository.updated_at else None,
                'pushed_at': repository.pushed_at.isoformat() if repository.pushed_at else None
            }
            
        except Exception as e:
            print(f"Error fetching repo {owner}/{repo}: {e}")
            return None
    
    def get_latest_release(self, owner: str, repo: str) -> Optional[dict]:
        """获取最新发布"""
        if not self.is_available():
            return None
        
        try:
            repository = self.client.get_repo(f"{owner}/{repo}")
            releases = repository.get_releases()
            
            if releases.totalCount == 0:
                return None
            
            latest = releases[0]
            return {
                'tag': latest.tag_name,
                'name': latest.title,
                'body': latest.body[:500] if latest.body else None,
                'published_at': latest.published_at.isoformat() if latest.published_at else None,
                'url': latest.html_url
            }
            
        except Exception as e:
            print(f"Error fetching releases for {owner}/{repo}: {e}")
            return None
    
    def search_repos(self, query: str, sort: str = "stars", limit: int = 10) -> List[dict]:
        """搜索仓库"""
        if not self.is_available():
            return []
        
        try:
            repos = self.client.search_repositories(query=query, sort=sort)
            
            result = []
            for repo in repos[:limit]:
                result.append({
                    'full_name': repo.full_name,
                    'description': repo.description,
                    'stars': repo.stargazers_count,
                    'language': repo.language,
                    'updated_at': repo.updated_at.isoformat() if repo.updated_at else None
                })
            
            return result
            
        except Exception as e:
            print(f"Error searching repos: {e}")
            return []
    
    def get_trending_repos(self, language: str = "python", since: str = "daily") -> List[dict]:
        """
        获取趋势仓库
        注意: GitHub官方没有trending API，这里使用搜索作为替代
        """
        if not self.is_available():
            return []
        
        # 构建查询 - 最近创建的优质项目
        date_threshold = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")
        query = f"language:{language} created:>{date_threshold} stars:>100"
        
        return self.search_repos(query, sort="stars", limit=10)
    
    def monitor_repositories(self):
        """监控配置的仓库"""
        if not self.is_available():
            print("Skipping GitHub monitoring: not available")
            return []
        
        alerts = []
        repos_config = self.config.get('github_monitor.repositories', {})
        
        # 监控特定仓库
        for category, repos in repos_config.items():
            print(f"\nMonitoring {category}...")
            
            for repo_info in repos:
                if 'owner' in repo_info and 'repo' in repo_info:
                    owner = repo_info['owner']
                    repo = repo_info['repo']
                    priority = repo_info.get('priority', 'low')
                    track = repo_info.get('track', [])
                    
                    print(f"  Checking {owner}/{repo}")
                    
                    # 检查最新发布
                    if 'releases' in track:
                        release = self.get_latest_release(owner, repo)
                        if release:
                            # 检查是否最近发布
                            pub_date = datetime.fromisoformat(release['published_at'].replace('Z', '+00:00'))
                            if datetime.now().astimezone() - pub_date < timedelta(hours=48):
                                alerts.append({
                                    'source': 'github',
                                    'type': 'new_release',
                                    'priority': priority,
                                    'repo': f"{owner}/{repo}",
                                    'release': release,
                                    'detected_at': datetime.now().isoformat()
                                })
                                print(f"    🔔 New release: {release['tag']}")
        
        # 监控趋势
        print("\nChecking trending repos...")
        trending = self.get_trending_repos()
        for repo in trending[:5]:
            print(f"  📈 {repo['full_name']}: {repo['stars']} stars")
        
        return alerts


# ============== 报告生成器 ==============

class ReportGenerator:
    """报告生成器"""
    
    def __init__(self, config: Config, data_store: DataStore):
        self.config = config
        self.data_store = data_store
    
    def generate_daily_digest(self, twitter_alerts: List[dict], github_alerts: List[dict]) -> str:
        """生成每日摘要"""
        date_str = datetime.now().strftime("%Y-%m-%d %H:%M")
        
        report = f"""# 🕵️ 银行业AI情报日报 | {date_str}

## 📊 今日概览

| 来源 | 高优先级 | 中优先级 | 低优先级 | 总计 |
|------|----------|----------|----------|------|
| Twitter/X | {sum(1 for a in twitter_alerts if a.get('priority') == 'high')} | {sum(1 for a in twitter_alerts if a.get('priority') == 'medium')} | {sum(1 for a in twitter_alerts if a.get('priority') == 'low')} | {len(twitter_alerts)} |
| GitHub | {sum(1 for a in github_alerts if a.get('priority') == 'high')} | {sum(1 for a in github_alerts if a.get('priority') == 'medium')} | {sum(1 for a in github_alerts if a.get('priority') == 'low')} | {len(github_alerts)} |

---

## 🐦 Twitter/X 亮点

"""
        
        # 按优先级分组
        high_priority = [a for a in twitter_alerts if a.get('priority') == 'high']
        medium_priority = [a for a in twitter_alerts if a.get('priority') == 'medium']
        
        if high_priority:
            report += "### 🔴 高优先级\n\n"
            for alert in high_priority:
                tweet = alert.get('tweet', {})
                report += f"**@{alert.get('handle')}** • {tweet.get('created_at', 'Unknown')}\n\n"
                report += f"{tweet.get('text', '')}\n\n"
                if alert.get('matched_keywords'):
                    report += f"*匹配关键词: {', '.join(alert['matched_keywords'])}*\n\n"
                report += "---\n\n"
        
        if medium_priority:
            report += "### 🟡 中优先级\n\n"
            for alert in medium_priority:
                tweet = alert.get('tweet', {})
                report += f"**@{alert.get('handle')}**: {tweet.get('text', '')[:200]}...\n\n"
        
        if not high_priority and not medium_priority:
            report += "今日无高/中优先级Twitter警报。\n\n"
        
        report += "---\n\n## 🐙 GitHub 动态\n\n"
        
        # GitHub发布
        releases = [a for a in github_alerts if a.get('type') == 'new_release']
        if releases:
            report += "### 📦 新发布\n\n"
            for alert in releases:
                release = alert.get('release', {})
                report += f"**{alert.get('repo')}** - {release.get('tag', 'Unknown')}\n\n"
                report += f"{release.get('name', '')}\n\n"
                if release.get('body'):
                    report += f"{release['body'][:300]}...\n\n"
                report += f"[查看发布]({release.get('url', '')})\n\n"
                report += "---\n\n"
        else:
            report += "今日无重要GitHub发布。\n\n"
        
        report += """---

## 📋 关键发现

*基于今日监控数据的AI分析将在此呈现*

---

*报告生成时间: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}*  
*监控系统: Banking AI Intelligence Monitor v1.0*
"""
        
        return report
    
    def generate_realtime_alert(self, alert: dict) -> str:
        """生成实时警报"""
        priority_emoji = {
            'high': '🔴',
            'medium': '🟡',
            'low': '🟢'
        }
        
        emoji = priority_emoji.get(alert.get('priority', 'low'), '⚪')
        
        if alert.get('source') == 'twitter':
            tweet = alert.get('tweet', {})
            return f"""
{emoji} **高优先级Twitter警报**

**@{alert.get('handle')}** 

{tweet.get('text', '')}

*关键词: {', '.join(alert.get('matched_keywords', []))}*
*时间: {tweet.get('created_at', 'Unknown')}*
"""
        
        elif alert.get('source') == 'github':
            if alert.get('type') == 'new_release':
                release = alert.get('release', {})
                return f"""
{emoji} **GitHub新发布**

**{alert.get('repo')}** 发布了 {release.get('tag', 'Unknown')}

{release.get('name', '')}

[查看详情]({release.get('url', '')})
"""
        
        return f"{emoji} 警报: {json.dumps(alert, indent=2)}"


# ============== 主监控器 ==============

class IntelligenceMonitor:
    """主监控器"""
    
    def __init__(self):
        self.config = Config()
        self.data_store = DataStore(self.config.data_dir)
        self.twitter = TwitterMonitor(self.config, self.data_store)
        self.github = GitHubMonitor(self.config, self.data_store)
        self.report_gen = ReportGenerator(self.config, self.data_store)
        self.running = False
    
    def run_once(self):
        """运行单次监控"""
        print(f"\n{'='*60}")
        print(f"监控运行时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print('='*60)
        
        # Twitter监控
        print("\n📱 开始Twitter监控...")
        twitter_alerts = self.twitter.monitor_accounts()
        print(f"   发现 {len(twitter_alerts)} 条Twitter警报")
        
        # GitHub监控
        print("\n🐙 开始GitHub监控...")
        github_alerts = self.github.monitor_repositories()
        print(f"   发现 {len(github_alerts)} 条GitHub警报")
        
        # 生成并保存报告
        print("\n📄 生成报告...")
        report = self.report_gen.generate_daily_digest(twitter_alerts, github_alerts)
        report_path = self.data_store.save_report(report, "daily")
        print(f"   报告已保存: {report_path}")
        
        # 处理高优先级警报
        all_alerts = twitter_alerts + github_alerts
        high_priority = [a for a in all_alerts if a.get('priority') == 'high']
        
        if high_priority:
            print(f"\n🔔 高优先级警报 ({len(high_priority)} 条):")
            for alert in high_priority:
                alert_text = self.report_gen.generate_realtime_alert(alert)
                print(alert_text)
        
        return twitter_alerts, github_alerts
    
    def scheduled_job(self):
        """定时任务"""
        try:
            self.run_once()
        except Exception as e:
            print(f"Error in scheduled job: {e}")
    
    def run_continuous(self):
        """持续运行"""
        self.running = True
        
        # 获取监控间隔
        twitter_interval = self.config.get('twitter_monitor.check_interval_minutes', 30)
        github_interval = self.config.get('github_monitor.check_interval_minutes', 60)
        
        print(f"\n开始持续监控...")
        print(f"Twitter检查间隔: {twitter_interval} 分钟")
        print(f"GitHub检查间隔: {github_interval} 分钟")
        print("按 Ctrl+C 停止\n")
        
        # 设置定时任务
        schedule.every(twitter_interval).minutes.do(self.run_once)
        
        # 立即运行一次
        self.run_once()
        
        # 持续运行
        while self.running:
            schedule.run_pending()
            time.sleep(60)
    
    def stop(self):
        """停止监控"""
        self.running = False
        print("\n监控已停止")


# ============== 命令行入口 ==============

def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Banking AI Intelligence Monitor')
    parser.add_argument('--once', action='store_true', help='Run once and exit')
    parser.add_argument('--continuous', action='store_true', help='Run continuously')
    parser.add_argument('--test-twitter', action='store_true', help='Test Twitter connection')
    parser.add_argument('--test-github', action='store_true', help='Test GitHub connection')
    
    args = parser.parse_args()
    
    monitor = IntelligenceMonitor()
    
    if args.test_twitter:
        print("Testing Twitter connection...")
        if monitor.twitter.is_available():
            # 测试获取一条推文
            tweets = monitor.twitter.get_user_tweets("Twitter", max_results=1)
            if tweets:
                print(f"✅ Twitter connection OK. Sample tweet: {tweets[0]['text'][:100]}...")
            else:
                print("⚠️ Twitter connected but no tweets fetched")
        else:
            print("❌ Twitter not available. Check TWITTER_BEARER_TOKEN")
        return
    
    if args.test_github:
        print("Testing GitHub connection...")
        if monitor.github.is_available():
            # 测试获取仓库信息
            info = monitor.github.get_repo_info("microsoft", "TypeScript")
            if info:
                print(f"✅ GitHub connection OK. Sample repo: {info['full_name']} ({info['stars']} stars)")
            else:
                print("⚠️ GitHub connected but couldn't fetch repo")
        else:
            print("❌ GitHub not available")
        return
    
    if args.continuous:
        try:
            monitor.run_continuous()
        except KeyboardInterrupt:
            monitor.stop()
    else:
        # 默认运行一次
        monitor.run_once()


if __name__ == "__main__":
    main()
