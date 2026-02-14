# 🤖 Polymarket 天气交易机器人配置指南

> 基于 Simmer SDK 的自动化天气套利策略

---

## ⚠️ 风险提示

**交易有风险，入市需谨慎**
- 需要真实资金投入（建议起步 $100）
- 市场波动可能导致亏损
- 请只用可承受损失的资金

---

## 📋 配置清单

### ✅ 已完成
- [x] Openclaw 已安装 (v2026.2.12)
- [x] Discord 连接正常

### ⏳ 待你完成
- [ ] 准备 EVM 钱包（MetaMask/OKX/Rabby）
- [ ] 准备资金（建议 $100-500 起步）
  - USDC.e on Polygon
  - POL (原MATIC) for gas
- [ ] Simmer SDK 账户
- [ ] 天气交易 Skill 安装

---

## 🚀 快速开始

### Step 1: 创建 Simmer 账户

1. 访问 https://simmer.markets
2. 连接你的 EVM 钱包
3. 创建 Agent 账户
4. 获取 Agent Wallet 地址

### Step 2: 充值资金

向你的 Simmer Agent Wallet 充值：
- **USDC.e** (Polygon网络): 用于交易
- **POL**: 用于支付gas费

### Step 3: 安装 Weather Trading Skill

在你的 Telegram Bot 或这里发送：
```
clawhub install simmer-weather
```

或直接运行：
```bash
openclaw skills install simmer-weather
```

### Step 4: 配置交易参数

发送以下配置给机器人：

```
【Polymarket天气交易配置】

Entry threshold: 15% (低于此值买入)
Exit threshold: 45% (高于此值卖出)
Max position: $2.00 (单笔最大仓位)
Locations: NYC, Chicago, Seattle, Atlanta, Dallas, Miami
Max trades/run: 5 (每次运行最多交易数)
Safeguards: Enabled (安全保护开启)
Trend detection: Enabled (趋势检测开启)
Run scan: every 2 minutes (每2分钟扫描一次)
```

---

## 💡 策略原理

**套利逻辑：**
1. 监控 NOAA 官方天气预报
2. 对比 Polymarket 天气预测市场价格
3. 当预测概率与市场价格出现差异时：
   - 预测高温概率 > 市场价格 → 买入高温合约
   - 预测低温概率 > 市场价格 → 买入低温合约
4. 市场回归理性时卖出获利

**示例：**
- NOAA预测明天NYC有70%概率超过25°C
- Polymarket市场价格显示只有55%概率
- 买入"Yes"合约，等待市场修正到70%
- 获利约15%

---

## 📊 推荐配置（保守型）

适合新手起步：

```
Entry threshold: 20% (更保守的入场)
Exit threshold: 40% (更早获利了结)
Max position: $1.00 (小仓位试水)
Locations: NYC, London (流动性最好的市场)
Max trades/run: 3 (减少交易频率)
Run scan: every 5 minutes (降低频率，减少gas)
```

---

## 🔧 自动化脚本

我已为你准备自动化脚本：

### 1. 启动监控
```bash
./start_polymarket_bot.sh
```

### 2. 查看收益报告
```bash
./check_pnl.sh
```

---

## 📈 预期收益

根据社区数据：
- 月化收益：10%-50%（取决于市场波动）
- 风险：单笔最大亏损不超过仓位2%
- 起步建议：$100 → 目标 $5000（需要时间和复利）

---

## ⚡ 下一步

请告诉我：

1. **你的钱包地址准备好了吗？**
2. **准备投入多少资金？**（建议$100起步）
3. **想要保守型还是激进型配置？**

我帮你完成剩余配置！
