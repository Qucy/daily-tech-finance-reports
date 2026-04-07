#!/bin/bash
# start_monitor.sh - 启动银行业AI情报监控系统

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"
VENV_DIR="$PROJECT_DIR/.venv"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Banking AI Intelligence Monitor${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查Python版本
echo -e "${YELLOW}▶ 检查Python环境...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3 未安装${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo -e "${GREEN}✓ Python版本: $PYTHON_VERSION${NC}"

# 检查虚拟环境
echo -e "${YELLOW}▶ 检查虚拟环境...${NC}"
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}  创建虚拟环境...${NC}"
    python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
echo -e "${GREEN}✓ 虚拟环境已激活${NC}"

# 检查依赖
echo -e "${YELLOW}▶ 检查依赖...${NC}"
REQUIRED_PACKAGES="tweepy PyGithub requests schedule"
MISSING_PACKAGES=""

for package in $REQUIRED_PACKAGES; do
    if ! python3 -c "import $package" 2>/dev/null; then
        MISSING_PACKAGES="$MISSING_PACKAGES $package"
    fi
done

if [ -n "$MISSING_PACKAGES" ]; then
    echo -e "${YELLOW}  安装缺失的依赖:$MISSING_PACKAGES${NC}"
    pip install -q $MISSING_PACKAGES
fi
echo -e "${GREEN}✓ 所有依赖已安装${NC}"

# 检查配置文件
echo -e "${YELLOW}▶ 检查配置文件...${NC}"
if [ ! -f "$CONFIG_DIR/monitor_config.json" ]; then
    echo -e "${RED}✗ 配置文件不存在: $CONFIG_DIR/monitor_config.json${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 配置文件存在${NC}"

# 检查API凭证
echo -e "${YELLOW}▶ 检查API凭证...${NC}"
if [ -z "$TWITTER_BEARER_TOKEN" ]; then
    echo -e "${YELLOW}⚠ TWITTER_BEARER_TOKEN 未设置 (Twitter监控将被禁用)${NC}"
else
    echo -e "${GREEN}✓ Twitter凭证已设置${NC}"
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}⚠ GITHUB_TOKEN 未设置 (GitHub监控将受速率限制)${NC}"
else
    echo -e "${GREEN}✓ GitHub凭证已设置${NC}"
fi

# 创建数据目录
echo -e "${YELLOW}▶ 创建数据目录...${NC}"
mkdir -p "$PROJECT_DIR/monitor_data"/{twitter,github,reports}
echo -e "${GREEN}✓ 数据目录已就绪${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  环境检查完成！${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 显示使用说明
echo "使用方法:"
echo "  1. 单次运行:   python3 scripts/monitor.py --once"
echo "  2. 持续监控:   python3 scripts/monitor.py --continuous"
echo "  3. 测试连接:   python3 scripts/monitor.py --test-twitter"
echo "                 python3 scripts/monitor.py --test-github"
echo ""

# 默认运行单次监控
cd "$PROJECT_DIR"
echo -e "${YELLOW}▶ 启动单次监控...${NC}"
python3 scripts/monitor.py --once

echo ""
echo -e "${GREEN}监控完成！${NC}"
echo -e "报告保存位置: ${BLUE}$PROJECT_DIR/monitor_data/reports/${NC}"
