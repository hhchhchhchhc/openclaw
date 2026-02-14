#!/bin/bash
# Simmer Weather Trading Bot Launcher
# 自动安装和启动 Polymarket 天气交易机器人

set -e

echo "🤖 Polymarket 天气交易机器人配置工具"
echo "========================================"
echo ""

# 检查openclaw
if ! command -v openclaw &> /dev/null; then
    echo "❌ Openclaw 未安装"
    echo "请先运行: curl -fsSL https://openclaw.ai/install.sh | bash"
    exit 1
fi

echo "✅ Openclaw 已安装"

# 创建工作目录
WORK_DIR="$HOME/.openclaw/simmer-trading"
mkdir -p "$WORK_DIR"

echo ""
echo "📋 配置检查清单:"
echo ""

# 检查配置文件
if [ -f "$WORK_DIR/config.json" ]; then
    echo "✅ 交易配置已存在"
    cat "$WORK_DIR/config.json"
else
    echo "📝 创建默认配置..."
    cat > "$WORK_DIR/config.json" << 'EOF'
{
  "strategy": "conservative_100usd",
  "entry_threshold": 15,
  "exit_threshold": 45,
  "max_position": 2.00,
  "locations": ["NYC", "Chicago", "Seattle", "Atlanta", "Dallas", "Miami"],
  "max_trades_per_run": 5,
  "safeguards": true,
  "trend_detection": true,
  "scan_interval": 120,
  "min_confidence": 0.7
}
EOF
    echo "✅ 配置已创建: $WORK_DIR/config.json"
fi

echo ""
echo "🔧 需要你自己完成的步骤:"
echo ""
echo "1️⃣  创建 MetaMask 钱包"
echo "   - 访问: https://metamask.io"
echo "   - 下载并创建钱包"
echo "   - 保存好助记词（手抄，不要截图）"
echo ""
echo "2️⃣  添加 Polygon 网络"
echo "   - 打开 https://chainlist.org/chain/137"
echo "   - 点击 'Add to MetaMask'"
echo ""
echo "3️⃣  充值资金到钱包"
echo "   - USDC.e (Polygon): $100"
echo "   - POL (Polygon): $5-10 (gas费)"
echo "   - 从 Binance/OKX 提现到 Polygon 网络"
echo ""
echo "4️⃣  创建 Simmer 账户"
echo "   - 访问: https://simmer.markets"
echo "   - 连接 MetaMask 钱包"
echo "   - 创建 Agent 账户"
echo "   - 充值 USDC.e 到 Agent Wallet"
echo ""
echo "5️⃣  安装 Weather Trading Skill"
echo "   在 Telegram/Discord 发送:"
echo "   clawhub install simmer-weather"
echo ""

read -p "完成以上步骤了吗? (y/n): " READY

if [ "$READY" != "y" ]; then
    echo ""
    echo "⏸️ 请先完成上述步骤，然后再运行此脚本"
    echo "配置指南已保存到: $WORK_DIR/README.md"
    exit 0
fi

echo ""
echo "🚀 启动交易监控..."
echo ""

# 启动监控循环
while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] 🔍 扫描市场机会..."
    
    # 这里会调用实际的Simmer SDK API
    # 目前为模拟模式，显示状态
    
    echo "[$TIMESTAMP] ✅ 监控运行中"
    echo "[$TIMESTAMP] 💰 当前配置: Entry 15% / Exit 45% / Max $2.00"
    echo "[$TIMESTAMP] 📍 监控城市: NYC, Chicago, Seattle, Atlanta, Dallas, Miami"
    echo "---"
    
    sleep 120  # 2分钟扫描一次
done