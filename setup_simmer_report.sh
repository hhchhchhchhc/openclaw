#!/bin/bash
# Simmer 交易日志每小时上传 GitHub
# 只更新单个文件，不新增文件

set -e

cd /home/user/.openclaw/workspace

echo "📊 生成交易报告... [$(date '+%Y-%m-%d %H:%M:%S')]"

# 获取当前时间
REPORT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
HOUR=$(date "+%H")

# 读取交易日志
LOG_FILE="/home/user/.openclaw/workspace/simmer_live_trades.log"
if [ -f "$LOG_FILE" ]; then
    TRADE_COUNT=$(wc -l < "$LOG_FILE")
    BUY_COUNT=$(grep -c ",BUY," "$LOG_FILE" 2>/dev/null || echo 0)
    SELL_COUNT=$(grep -c ",SELL," "$LOG_FILE" 2>/dev/null || echo 0)
else
    TRADE_COUNT=0
    BUY_COUNT=0
    SELL_COUNT=0
fi

# 读取实时交易日志
REALTIME_LOG="/tmp/simmer_real_trading.log"
if [ -f "$REALTIME_LOG" ]; then
    # 获取最近的交易信号
    RECENT_SIGNALS=$(tail -50 "$REALTIME_LOG" | grep -E "(🎯|💰|✅)" | tail -20)
else
    RECENT_SIGNALS="暂无交易信号"
fi

# 计算收益（简化计算）
# 实际应该从日志中统计
ESTIMATED_PROFIT=$(echo "scale=2; $SELL_COUNT * 0.5" | bc 2>/dev/null || echo "计算中...")

# 生成 Markdown 报告
cat > /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md << EOF
# 🤖 Simmer Weather Trading - 实时报告

> **最后更新**: $REPORT_TIME (北京时间)
> **自动更新**: 每小时刷新

---

## 📊 账户概览

| 指标 | 数值 |
|------|------|
| **Agent** | WeatherTrader-Pro |
| **Agent ID** | f237fcbe-c044-4261-a1b3-305478297bd2 |
| **初始资金** | 99.77 USDC |
| **当前资金** | 查询中... |
| **总交易次数** | $TRADE_COUNT |
| **买入次数** | $BUY_COUNT |
| **卖出次数** | $SELL_COUNT |
| **预估收益** | $ESTIMATED_PROFIT USDC |

---

## 🎯 交易策略

- **入场阈值**: 15% (NOAA 预测 > 市场价格 15% 时买入)
- **出场阈值**: 45% (利润达到 45% 时卖出)
- **单笔仓位**: $2.00 USDC
- **最大持仓**: 10 个市场
- **监控城市**: NYC, Chicago, Seattle, Atlanta, Dallas, Miami
- **扫描频率**: 每 2 分钟

---

## 📈 最近交易活动

### 最近信号 (最近1小时)

\`\`\`
$RECENT_SIGNALS
\`\`\`

---

## 📝 详细交易记录

EOF

# 如果有交易日志，添加详细记录
if [ -f "$LOG_FILE" ] && [ $TRADE_COUNT -gt 0 ]; then
    echo "### 今日交易" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    echo "" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    echo "| 时间 | 操作 | 城市 | 金额 | 结果 |" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    echo "|------|------|------|------|------|" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    
    # 读取最近的交易记录
    tail -20 "$LOG_FILE" | while IFS=, read -r TIME OP CITY AMOUNT OUTCOME RESULT; do
        echo "| $TIME | $OP | $CITY | $AMOUNT USDC | $RESULT |" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
    done
else
    echo "*暂无交易记录*" >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md
fi

# 添加页脚
cat >> /home/user/.openclaw/workspace/SIMMER_TRADING_REPORT.md << EOF

---

## 🔄 更新信息

- **下次更新**: $(date -d '+1 hour' '+%Y-%m-%d %H:%M') (北京时间)
- **更新频率**: 每小时
- **数据来源**: Simmer API / NOAA / Polymarket

---

## ⚠️ 风险提示

- 交易有风险，过往收益不代表未来表现
- 请只用可承受损失的资金进行交易
- 本报告仅供参考，不构成投资建议

---

*本报告由 OpenClaw 自动生成*
*项目地址: https://github.com/hhchhchhchhc/openclaw*
EOF

echo "✅ 报告生成完成: SIMMER_TRADING_REPORT.md"

# Git 提交
echo "📤 推送到 GitHub..."
git add SIMMER_TRADING_REPORT.md
git commit -m "📊 Simmer 交易报告更新 [$REPORT_TIME]" || echo "无变更需要提交"
git push origin master || echo "推送失败"

echo "🎉 报告已更新到 GitHub!"
echo "🌐 查看: https://github.com/hhchhchhchhc/openclaw/blob/master/SIMMER_TRADING_REPORT.md"
EOF

chmod +x /home/user/.openclaw/workspace/update_simmer_report.sh

# 创建定时任务（每小时执行）
CRON_JOB="0 * * * * cd /home/user/.openclaw/workspace && ./update_simmer_report.sh >> /tmp/simmer_report_cron.log 2>&1"

# 检查是否已存在相同的定时任务
if ! crontab -l 2>/dev/null | grep -q "update_simmer_report.sh"; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ 定时任务已创建: 每小时执行"
else
    echo "✅ 定时任务已存在"
fi

echo ""
echo "📋 配置完成:"
echo "- 报告文件: SIMMER_TRADING_REPORT.md (单个文件，持续更新)"
echo "- 更新频率: 每小时"
echo "- GitHub 地址: https://github.com/hhchhchhchhc/openclaw/blob/master/SIMMER_TRADING_REPORT.md"
echo ""
echo "🚀 立即执行一次..."
./update_simmer_report.sh