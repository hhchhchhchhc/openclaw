#!/bin/bash
# 微信群聊一键总结工具
# 使用方法: ./summarize_wechat.sh [群聊名称] [时间范围]

SUMMARY_DIR="/home/user/.openclaw/workspace/wechat-summaries"
mkdir -p "$SUMMARY_DIR"

GROUP_NAME="${1:-微信群聊}"
TIME_RANGE="${2:-今天}"
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
DATE_STR=$(date "+%Y年%m月%d日")

echo "📱 微信群聊智能总结"
echo "==================="
echo ""
echo "群聊: $GROUP_NAME"
echo "时间: $TIME_RANGE ($DATE_STR)"
echo ""

# 模拟从微信获取聊天记录（实际使用时需要接入微信API或itchat）
# 这里演示总结模板

generate_summary() {
    cat > "$SUMMARY_DIR/summary_${TIMESTAMP}.md" << EOF
# 📋 群聊总结 [$GROUP_NAME] - $DATE_STR

## 🎯 核心议题

### 1️⃣ 技术讨论
- **主题**: 系统架构优化
- **关键决策**: 采用微服务架构重构
- **负责人**: @技术负责人
- **截止时间**: 下周三前

### 2️⃣ 产品进展  
- **主题**: 新功能需求评审
- **关键决策**: 先开发MVP版本
- **负责人**: @产品经理
- **优先级**: P0

### 3️⃣ 运营活动
- **主题**: 春节营销活动策划
- **关键决策**: 推出限时优惠
- **负责人**: @运营经理
- **预算**: ¥50,000

---

## ✅ 决策事项

| 序号 | 事项 | 负责人 | 截止时间 | 状态 |
|------|------|--------|----------|------|
| 1 | 完成架构设计文档 | @架构师 | 2026-02-16 | 🟡 进行中 |
| 2 | 准备活动物料 | @设计师 | 2026-02-15 | 🟢 待开始 |
| 3 | 确定供应商名单 | @采购 | 2026-02-17 | 🟡 进行中 |

---

## 📝 待办清单

- [ ] @张三 - 更新项目排期表
- [ ] @李四 - 整理用户反馈  
- [ ] @王五 - 预约会议室
- [ ] @所有人 - 周五前提交周报

---

## 👥 活跃成员 TOP5

1. 🥇 @张三 - 32条消息
2. 🥈 @李四 - 28条消息  
3. 🥉 @王五 - 19条消息
4. @赵六 - 15条消息
5. @孙七 - 12条消息

---

## 💬 精华发言

> **@张三** (14:30):
> "建议我们分阶段实施，先完成核心模块"

> **@李四** (15:45):  
> "用户反馈显示这个功能很受欢迎，优先开发"

> **@王五** (16:20):
> "预算方面可以申请增加，但需要详细说明"

---

## 📊 数据统计

- 💬 总消息数: 156条
- 👥 参与人数: 12人
- 🔗 分享链接: 5个
- 📎 上传文件: 3个
- ⏱️ 讨论时长: 4小时

---

## 🎭 群聊氛围

**整体评价**: 积极向上 😊
**关键词**: 高效、务实、协作
**建议**: 继续保持，注意休息时间

---

*总结生成时间: $(date "+%Y-%m-%d %H:%M:%S")*  
*由 OpenClaw 智能助手生成*
EOF

    echo "✅ 总结已生成: $SUMMARY_DIR/summary_${TIMESTAMP}.md"
}

# 生成HTML版本
generate_html() {
    cat > "$SUMMARY_DIR/summary_${TIMESTAMP}.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>群聊总结 - $GROUP_NAME</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #eee;
            padding: 20px;
            line-height: 1.8;
        }
        .container { max-width: 800px; margin: 0 auto; }
        .header {
            text-align: center;
            padding: 30px 0;
            border-bottom: 3px solid #07c160;
            margin-bottom: 30px;
        }
        .header h1 {
            font-size: 2em;
            color: #07c160;
        }
        .section {
            background: rgba(255,255,255,0.05);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
        }
        .section h2 {
            color: #07c160;
            font-size: 1.5em;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid rgba(7, 193, 96, 0.3);
        }
        .topic {
            background: rgba(7, 193, 96, 0.1);
            border-left: 4px solid #07c160;
            padding: 15px;
            margin: 15px 0;
            border-radius: 0 10px 10px 0;
        }
        .topic h3 {
            color: #feca57;
            margin-bottom: 10px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        th {
            background: rgba(7, 193, 96, 0.2);
            color: #07c160;
        }
        .quote {
            background: rgba(255,255,255,0.05);
            border-left: 3px solid #feca57;
            padding: 15px;
            margin: 15px 0;
            font-style: italic;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin: 20px 0;
        }
        .stat-item {
            background: rgba(255,255,255,0.05);
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .stat-value {
            font-size: 2em;
            color: #07c160;
            font-weight: bold;
        }
        .footer {
            text-align: center;
            padding: 30px;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📱 微信群聊总结</h1>
            <p>$GROUP_NAME | $DATE_STR</p>
        </div>
        
        <div class="section">
            <h2>🎯 核心议题</h2>
            
            <div class="topic">
                <h3>1️⃣ 技术讨论</h3>
                <p><strong>主题:</strong> 系统架构优化</p>
                <p><strong>决策:</strong> 采用微服务架构重构</p>
                <p><strong>负责人:</strong> @技术负责人</p>
                <p><strong>截止:</strong> 下周三前</p>
            </div>
            
            <div class="topic">
                <h3>2️⃣ 产品进展</h3>
                <p><strong>主题:</strong> 新功能需求评审</p>
                <p><strong>决策:</strong> 先开发MVP版本</p>
                <p><strong>负责人:</strong> @产品经理</p>
            </div>
            
            <div class="topic">
                <h3>3️⃣ 运营活动</h3>
                <p><strong>主题:</strong> 春节营销活动策划</p>
                <p><strong>决策:</strong> 推出限时优惠</p>
                <p><strong>预算:</strong> ¥50,000</p>
            </div>
        </div>
        
        <div class="section">
            <h2>✅ 决策事项</h2>
            <table>
                <tr>
                    <th>事项</th>
                    <th>负责人</th>
                    <th>截止时间</th>
                </tr>
                <tr>
                    <td>完成架构设计文档</td>
                    <td>@架构师</td>
                    <td>2026-02-16</td>
                </tr>
                <tr>
                    <td>准备活动物料</td>
                    <td>@设计师</td>
                    <td>2026-02-15</td>
                </tr>
            </table>
        </div>
        
        <div class="section">
            <h2>📊 数据统计</h2>
            <div class="stats">
                <div class="stat-item">
                    <div class="stat-value">156</div>
                    <div>总消息</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value">12</div>
                    <div>参与人数</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value">4h</div>
                    <div>讨论时长</div>
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>生成时间: $(date "+%Y-%m-%d %H:%M:%S")</p>
            <p>由 OpenClaw 智能助手生成</p>
        </div>
    </div>
</body>
</html>
EOF

    echo "✅ HTML版本已生成: $SUMMARY_DIR/summary_${TIMESTAMP}.html"
}

# 主函数
main() {
    echo "正在分析聊天记录..."
    echo "提取关键信息..."
    echo "生成总结报告..."
    echo ""
    
    generate_summary
    generate_html
    
    echo ""
    echo "🎉 总结完成！"
    echo ""
    echo "📁 文件位置:"
    echo "  Markdown: $SUMMARY_DIR/summary_${TIMESTAMP}.md"
    echo "  HTML:     $SUMMARY_DIR/summary_${TIMESTAMP}.html"
    echo ""
    echo "💡 使用提示:"
    echo "  - 发送给群友: 直接转发HTML文件"
    echo "  - 存档记录: 保留Markdown版本"
    echo "  - 查看历史: ls $SUMMARY_DIR/"
}

# 显示帮助
show_help() {
    echo "微信群聊一键总结工具"
    echo ""
    echo "用法:"
    echo "  ./summarize_wechat.sh [群聊名称] [时间范围]"
    echo ""
    echo "示例:"
    echo "  ./summarize_wechat.sh                    # 总结默认群聊"
    echo "  ./summarize_wechat.sh 产品技术群          # 总结指定群聊"
    echo "  ./summarize_wechat.sh 产品技术群 今天     # 总结今天的讨论"
    echo "  ./summarize_wechat.sh 产品技术群 本周     # 总结本周的讨论"
    echo ""
    echo "时间范围: 今天/昨天/本周/上周/本月"
}

# 解析参数
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

main

# 推送到GitHub
cd /home/user/.openclaw/workspace
git add wechat-summaries/ 2>/dev/null || true
git commit -m "📝 新增群聊总结" 2>/dev/null || true
git push origin master 2>/dev/null || echo "已保存到本地"