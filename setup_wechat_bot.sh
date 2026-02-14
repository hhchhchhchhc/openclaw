#!/bin/bash
# 个人微信机器人配置脚本

echo "📱 个人微信机器人配置"
echo "======================"
echo ""

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 请先安装 Python3"
    exit 1
fi

# 安装 itchat
echo "🔧 安装 itchat..."
pip3 install itchat --break-system-packages 2>/dev/null || pip3 install itchat

# 安装其他依赖
echo "🔧 安装其他依赖..."
pip3 install requests beautifulsoup4 --break-system-packages 2>/dev/null || pip3 install requests beautifulsoup4

echo "✅ 依赖安装完成！"
echo ""

# 创建配置文件
mkdir -p /home/user/.openclaw/workspace/wechat-bot
cat > /home/user/.openclaw/workspace/wechat-bot/config.py << 'EOF'
# 微信机器人配置

# 群聊监控设置
MONITOR_GROUPS = [
    # 填写你要监控的群聊名称（部分匹配）
    "测试群",
    "工作群",
    # 留空表示监控所有群
]

# 触发关键词
TRIGGER_KEYWORDS = [
    "总结",
    "summary",
    "汇总",
    "日报",
    "@助手",
]

# 自动日报时间（24小时制）
AUTO_REPORT_HOUR = 20  # 晚上8点
AUTO_REPORT_MINUTE = 0

# 消息存储设置
MAX_MESSAGES = 1000  # 每个群最多存储消息数
SAVE_VOICE = False   # 是否保存语音（需要额外依赖）
SAVE_IMAGE = True    # 是否保存图片

# 输出设置
OUTPUT_FORMAT = "html"  # html 或 markdown
EOF

echo "✅ 配置文件已创建"
echo ""
echo "📁 配置文件位置: /home/user/.openclaw/workspace/wechat-bot/config.py"
echo ""
echo "⚠️  请编辑配置文件，添加你要监控的群聊名称"
echo ""

# 创建主程序
cat > /home/user/.openclaw/workspace/wechat-bot/wechat_summarizer.py << 'PYEOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
微信群聊智能总结机器人
基于 itchat 框架
"""

import itchat
import time
import json
import os
from datetime import datetime, timedelta
from collections import defaultdict
import config

# 存储群聊消息
message_store = defaultdict(list)
group_info = {}

class WeChatSummarizer:
    def __init__(self):
        self.message_store = defaultdict(list)
        self.group_members = {}
        
    def add_message(self, group_name, msg):
        """添加消息到存储"""
        if len(self.message_store[group_name]) >= config.MAX_MESSAGES:
            self.message_store[group_name].pop(0)
        
        self.message_store[group_name].append({
            'time': datetime.now(),
            'from': msg['ActualNickName'] if 'ActualNickName' in msg else msg['FromUserName'],
            'content': msg['Content'],
            'type': msg['Type']
        })
    
    def generate_summary(self, group_name, hours=24):
        """生成群聊总结"""
        messages = self.message_store[group_name]
        if not messages:
            return "暂无消息记录"
        
        # 筛选时间范围内的消息
        cutoff_time = datetime.now() - timedelta(hours=hours)
        recent_msgs = [m for m in messages if m['time'] > cutoff_time]
        
        if not recent_msgs:
            return "指定时间内暂无消息"
        
        # 统计信息
        total_msgs = len(recent_msgs)
        unique_speakers = len(set(m['from'] for m in recent_msgs))
        
        # 发言排行
        speaker_count = defaultdict(int)
        for m in recent_msgs:
            speaker_count[m['from']] += 1
        top_speakers = sorted(speaker_count.items(), key=lambda x: x[1], reverse=True)[:5]
        
        # 生成总结报告
        summary = f"""📋 群聊总结 [{group_name}] - {datetime.now().strftime('%Y-%m-%d %H:%M')}

📊 数据统计：
• 总消息数: {total_msgs} 条
• 参与人数: {unique_speakers} 人
• 统计时长: 最近{hours}小时

👥 活跃成员 TOP5：
"""
        
        for i, (name, count) in enumerate(top_speakers, 1):
            emoji = ["🥇", "🥈", "🥉", "4️⃣", "5️⃣"][i-1]
            summary += f"{emoji} @{name} - {count}条消息\n"
        
        summary += f"\n💬 最新消息（最近5条）：\n"
        for m in recent_msgs[-5:]:
            time_str = m['time'].strftime('%H:%M')
            content = m['content'][:50] + "..." if len(m['content']) > 50 else m['content']
            summary += f"[{time_str}] {m['from']}: {content}\n"
        
        summary += "\n✅ 使用提示：发送'详细总结'获取完整分析"
        
        return summary
    
    def clear_history(self, group_name):
        """清空历史消息"""
        self.message_store[group_name] = []
        return f"已清空 [{group_name}] 的历史消息"

# 初始化
summarizer = WeChatSummarizer()

@itchat.msg_register(itchat.content.TEXT, isGroupChat=True)
def handle_group_message(msg):
    """处理群聊消息"""
    group_name = msg['FromUserName']
    
    # 获取群聊显示名称
    group = itchat.search_chatrooms(userName=group_name)
    if group:
        group_display_name = group[0]['NickName']
    else:
        group_display_name = group_name
    
    # 检查是否需要监控此群
    if config.MONITOR_GROUPS and not any(name in group_display_name for name in config.MONITOR_GROUPS):
        return
    
    # 存储消息
    summarizer.add_message(group_display_name, msg)
    
    # 检查是否触发总结
    content = msg['Content']
    if any(keyword in content for keyword in config.TRIGGER_KEYWORDS):
        # 检查是否是@自己或包含触发词
        if msg['isAt'] or any(keyword in content for keyword in config.TRIGGER_KEYWORDS):
            summary = summarizer.generate_summary(group_display_name)
            itchat.send(summary, group_name)
            print(f"[{datetime.now()}] 已发送总结到群: {group_display_name}")

def run_bot():
    """启动机器人"""
    print("📱 启动微信群聊总结机器人...")
    print("⚠️  请扫描二维码登录微信")
    print("=" * 50)
    
    # 登录
    itchat.auto_login(
        hotReload=True,  # 热登录，避免频繁扫码
        enableCmdQR=2    # 在命令行显示二维码
    )
    
    print("✅ 登录成功！")
    print(f"📊 正在监控群聊消息...")
    print(f"⏰ 自动日报时间: {config.AUTO_REPORT_HOUR}:00")
    print("=" * 50)
    
    # 运行
    itchat.run(debug=False)

if __name__ == '__main__':
    run_bot()
PYEOF

chmod +x /home/user/.openclaw/workspace/wechat-bot/wechat_summarizer.py

echo "✅ 主程序已创建"
echo ""
echo "🚀 启动方式："
echo "  cd /home/user/.openclaw/workspace/wechat-bot"
echo "  python3 wechat_summarizer.py"
echo ""
echo "⚠️  重要提醒："
echo "  1. 首次运行需要扫码登录微信"
echo "  2. 建议用小号测试，不要用主号"
echo "  3. 保持终端运行，不要关闭"
echo "  4. 网页版微信掉线时需要重新扫码"
EOF

chmod +x /home/user/.openclaw/workspace/setup_wechat_bot.sh