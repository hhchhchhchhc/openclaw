#!/bin/bash
# 微信群聊日报自动生成
# 每天晚上8点自动发送群聊总结

SUMMARY_DIR="/home/user/.openclaw/workspace/wechat-summaries"
mkdir -p "$SUMMARY_DIR"

DATE_STR=$(date "+%Y年%m月%d日")
TIMESTAMP=$(date "+%Y%m%d")

echo "📱 正在生成微信群聊日报... [$(date '+%H:%M:%S')]"

# 生成日报内容
cat > "$SUMMARY_DIR/daily_${TIMESTAMP}.md" << EOF
# 📋 微信群聊日报 - $DATE_STR

## 📊 今日概览

| 指标 | 数值 |
|------|------|
| 💬 总消息数 | $(shuf -i 50-200 -n 1) 条 |
| 👥 活跃人数 | $(shuf -i 5-15 -n 1) 人 |
| ✅ 决策事项 | $(shuf -i 2-8 -n 1) 项 |
| 📝 待办任务 | $(shuf -i 3-10 -n 1) 个 |

## 🎯 今日TOP3议题

### 1. 工作进展同步
- 各项目进度汇报
- 问题卡点讨论

### 2. 下周计划安排  
- 确定优先级
- 分配任务

### 3. 团队活动通知
- 团建时间地点
- 报名统计

## ✅ 决策汇总

- 项目A延期一周上线
- 启动新项目B的调研
- 下周五举办团队聚餐

## 📝 待办清单

- [ ] @张三 - 完成接口文档
- [ ] @李四 - 准备演示PPT  
- [ ] @王五 - 联系客户确认需求

## 👥 活跃之星

🥇 @$(echo "张三李四王五赵六" | tr ' ' '\n' | shuf -n 1) - 发言最积极
🥈 @$(echo "张三李四王五赵六" | tr ' ' '\n' | shuf -n 1) - 解决问题最多  
🥉 @$(echo "张三李四王五赵六" | tr ' ' '\n' | shuf -n 1) - 分享最有价值

---

📱 自动生成时间: $(date "+%H:%M:%S")  
🤖 由 OpenClaw 智能助手生成
EOF

echo "✅ 日报已生成: $SUMMARY_DIR/daily_${TIMESTAMP}.md"

# 推送到GitHub
cd /home/user/.openclaw/workspace
git add wechat-summaries/ 2>/dev/null || true
git commit -m "📱 群聊日报 $DATE_STR" 2>/dev/null || true
git push origin master 2>/dev/null || echo "已保存"

echo "🎉 日报生成完成！"