#!/bin/bash
# 收益追踪和报表生成

LOG_FILE="$HOME/.openclaw/simmer-trading/trades.log"
REPORT_FILE="$HOME/.openclaw/simmer-trading/pnl_report.md"

if [ ! -f "$LOG_FILE" ]; then
    echo "暂无交易记录"
    exit 0
fi

echo "📊 Polymarket 交易收益报告"
echo "==========================="
echo "生成时间: $(date)"
echo ""

# 统计交易次数
TOTAL_TRADES=$(wc -l < "$LOG_FILE")
BUY_TRADES=$(grep -c ",BUY," "$LOG_FILE" 2>/dev/null || echo 0)
SELL_TRADES=$(grep -c ",SELL," "$LOG_FILE" 2>/dev/null || echo 0)

echo "📈 交易统计:"
echo "  总交易次数: $TOTAL_TRADES"
echo "  买入次数: $BUY_TRADES"
echo "  卖出次数: $SELL_TRADES"
echo ""

# 显示最近交易
echo "🕐 最近5笔交易:"
echo "时间 | 操作 | 城市 | NOAA | 市场 | 价差"
echo "-----|------|------|------|------|------"
tail -5 "$LOG_FILE" | while IFS=, read -r TIME OP LOC NOAA MARKET DIFF; do
    echo "$TIME | $OP | $LOC | ${NOAA}% | ${MARKET}% | ${DIFF}%"
done

echo ""
echo "💡 提示: 实际收益请在 Polymarket 官网查看"
echo "   访问: https://polymarket.com/portfolio"