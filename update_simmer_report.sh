#!/bin/bash
# Simmer 交易日志每小时上传 GitHub
# 只更新单个文件 SIMMER_TRADING_REPORT.md

set -e

cd /home/user/.openclaw/workspace

echo "📊 生成交易报告... [$(date '+%Y-%m-%d %H:%M:%S')]"

# 获取当前时间
REPORT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
DATE_STR=$(date "+%Y-%m-%d")
HOUR=$(date "+%H")

# 读取交易日志
LOG_FILE="/home/user/.openclaw/workspace/simmer_live_trades.log"
if [ -f "$LOG_FILE" ]; then
    TRADE_COUNT=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
    BUY_COUNT=$(grep -c ",BUY," "$LOG_FILE" 2>/dev/null || echo 0)
    SELL_COUNT=$(grep -c ",SELL," "$LOG_FILE" 2>/dev/null || echo 0)
    
    # 计算今日交易
    TODAY_TRADES=$(grep "^$DATE_STR" "$LOG_FILE" 2>/dev/null | wc -l || echo 0)
else
    TRADE_COUNT=0
    BUY_COUNT=0
    SELL_COUNT=0
    TODAY_TRADES=0
fi

# 读取实时交易日志
REALTIME_LOG="/tmp/simmer_real_trading.log"
if [ -f "$REALTIME_LOG" ]; then
    # 获取最近的交易信号（最近50行）
    RECENT_SIGNALS=$(tail -100 "$REALTIME_LOG" 2>/dev/null | grep -E "(🎯|💰|✅|执行交易)" | tail -30 || echo "暂无信号")
    
    # 检查机器人状态
    if pgrep -f "run_real_trading.sh" > /dev/null; then
        BOT_STATUS="🟢 运行中"
    else
        BOT_STATUS="🔴 已停止"
    fi
else
    RECENT_SIGNALS="暂无交易信号"
    BOT_STATUS="⚪ 未启动"
fi

# 生成 Markdown 报告
cat > /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md << EOF
# 🤖 Simmer Weather Trading - 实时报告

> **最后更新**: $REPORT_TIME (北京时间)  
> **自动更新**: 每小时刷新  
> **机器人状态**: $BOT_STATUS

---

## 📊 账户概览

| 指标 | 数值 |
|------|------|
| **Agent** | WeatherTrader-Pro |
| **Agent ID** | \`f237fcbe-c044-4261-a1b3-305478297bd2\` |
| **初始资金** | 99.77 USDC |
| **总交易次数** | $TRADE_COUNT |
| **今日交易** | $TODAY_TRADES |
| **买入次数** | $BUY_COUNT |
| **卖出次数** | $SELL_COUNT |

---

## 🎯 交易策略配置

\`\`\`json
{
  "entry_threshold": "15%",
  "exit_threshold": "45%",
  "max_position": "$2.00",
  "max_trades_per_run": 5,
  "locations": ["NYC", "Chicago", "Seattle", "Atlanta", "Dallas", "Miami"],
  "scan_interval": "2 minutes",
  "safeguards": true,
  "trend_detection": true
}
\`\`\`

---

## 📈 最近交易活动

### 最近信号

\`\`\`
$RECENT_SIGNALS
\`\`\`

---

## 📝 详细交易记录

EOF

# 如果有交易日志，添加详细记录
if [ -f "$LOG_FILE" ] && [ $TRADE_COUNT -gt 0 ]; then
    echo "" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    echo "| 时间 | 操作 | 城市 | 金额 | 方向 | 结果 |" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    echo "|------|------|------|------|------|------|" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    
    # 读取最近的交易记录（倒序，最新的在前）
    tail -30 "$LOG_FILE" 2>/dev/null | while IFS=, read -r TIME OP CITY AMOUNT OUTCOME RESULT; do
        echo "| $TIME | $OP | $CITY | $AMOUNT | $OUTCOME | $RESULT |" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    done
else
    echo "" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    echo "*暂无交易记录*" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
fi

# 添加页脚
cat >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md << EOF

---

## 🔄 更新信息

- **下次更新**: $(date -d '+1 hour' '+%H:%M') (北京时间)
- **更新频率**: 每小时
- **数据来源**: Simmer API / NOAA / Polymarket
- **报告文件**: 本文件每小时自动覆盖更新

---

## ⚠️ 风险提示

- 交易有风险，过往收益不代表未来表现
- 请只用可承受损失的资金进行交易
- 本报告仅供参考，不构成投资建议

---

## 🔗 相关链接

- [GitHub 仓库](https://github.com/hhchhchhchhc/openclaw)
- [Simmer 平台](https://simmer.markets)
- [Polymarket](https://polymarket.com)

---

*本报告由 OpenClaw 自动生成*  
*$100 → $5000 挑战进行中... 🚀*
EOF

echo "✅ 报告生成完成: SIMMER_TRADING_REPORT.md"
echo "   - 总交易: $TRADE_COUNT 次"
echo "   - 今日交易: $TODAY_TRADES 次"
echo "   - 机器人状态: $BOT_STATUS"

# Git 提交
echo ""
echo "📤 推送到 GitHub..."
cd /home/user/.openclaw/workspace
git add SIMMER_TRADING_REPORT.md
git commit -m "📊 Simmer 交易报告更新 [$REPORT_TIME]" || echo "无变更需要提交"

# 推送（如果之前因为密钥失败，这次可能也会失败，但文件已生成）
if git push origin master 2>/dev/null; then
    echo "🎉 报告已更新到 GitHub!"
    echo "🌐 查看: https://github.com/hhchhchhchhc/openclaw/blob/master/SIMMER_TRADING_REPORT.md"
else
    echo "⚠️  GitHub 推送失败（可能因密钥检测），但本地文件已更新"
    echo "📝 本地报告: /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md"
fi

echo ""
echo "[$REPORT_TIME] 报告更新完成 ✅"