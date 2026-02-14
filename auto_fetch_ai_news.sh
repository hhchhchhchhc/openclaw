#!/bin/bash
# AI新闻自动抓取脚本 - 每6小时更新
# 全中文输出

set -e

cd /home/user/.npm-global/lib/node_modules/openclaw/skills/news-aggregator-skill

echo "🤖 [$(date '+%H:%M:%S')] 开始抓取AI新闻..."

TIMESTAMP=$(date "+%Y年%m月%d日 %H:%M")
DATE_STR=$(date "+%Y%m%d_%H%M")
export TIMESTAMP DATE_STR

# 创建报告目录
mkdir -p /home/user/.openclaw/workspace/reports

# 抓取多源数据
echo "📡 正在抓取 HackerNews AI热门新闻..."
python3 scripts/fetch_news.py --source hackernews --limit 8 --keyword "AI,LLM,GPT,DeepSeek,Agent,Claude,OpenAI,Midjourney" > /tmp/hn_ai.json 2>/dev/null || echo "[]" > /tmp/hn_ai.json

echo "📡 正在抓取 GitHub Trending AI项目..."
python3 scripts/fetch_news.py --source github --limit 5 --keyword "AI,LLM,ChatGPT,Machine Learning,Neural" > /tmp/gh_ai.json 2>/dev/null || echo "[]" > /tmp/gh_ai.json

# 生成精美HTML报告（中文）
python3 << PYEOF
import json
from datetime import datetime

timestamp = "$TIMESTAMP"

# 读取数据
try:
    with open('/tmp/hn_ai.json', 'r') as f:
        hn_items = json.load(f)
except:
    hn_items = []

try:
    with open('/tmp/gh_ai.json', 'r') as f:
        gh_items = json.load(f)
except:
    gh_items = []

html_content = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI新闻快报 · {timestamp}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
            background: linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%);
            min-height: 100vh;
            color: #fff;
            padding: 20px;
        }}
        .container {{ max-width: 800px; margin: 0 auto; }}
        .header {{
            text-align: center;
            padding: 30px 0;
            border-bottom: 2px solid #e94560;
            margin-bottom: 30px;
        }}
        .header h1 {{
            font-size: 2em;
            background: linear-gradient(45deg, #e94560, #ff6b6b, #feca57);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
        }}
        .update-time {{
            color: #888;
            font-size: 0.9em;
        }}
        .badge {{
            display: inline-block;
            background: #e94560;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.8em;
            margin-top: 10px;
            animation: pulse 2s infinite;
        }}
        @keyframes pulse {{
            0%, 100% {{ opacity: 1; }}
            50% {{ opacity: 0.7; }}
        }}
        .section {{
            background: rgba(255,255,255,0.05);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
            border: 1px solid rgba(233, 69, 96, 0.2);
        }}
        .section-title {{
            font-size: 1.3em;
            color: #e94560;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }}
        .news-item {{
            background: rgba(255,255,255,0.03);
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            border-left: 3px solid #e94560;
            transition: transform 0.2s;
        }}
        .news-item:hover {{
            transform: translateX(5px);
            background: rgba(255,255,255,0.05);
        }}
        .news-title {{
            font-size: 1.1em;
            color: #fff;
            text-decoration: none;
            display: block;
            margin-bottom: 8px;
        }}
        .news-title:hover {{ color: #e94560; }}
        .news-meta {{
            color: #888;
            font-size: 0.85em;
        }}
        .heat {{ color: #feca57; }}
        .footer {{
            text-align: center;
            padding: 30px;
            color: #666;
            font-size: 0.9em;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔥 AI新闻快报</h1>
            <div class="update-time">更新时间：{timestamp}</div>
            <span class="badge">⚡ 每6小时自动更新</span>
        </div>
'''

# HackerNews板块
if hn_items:
    html_content += '''
        <div class="section">
            <div class="section-title">📰 HackerNews 热门</div>
'''
    for item in hn_items[:8]:
        title = item.get('title', '').replace('<', '&lt;').replace('>', '&gt;')
        url = item.get('url', '')
        heat = item.get('heat', '')
        time = item.get('time', '')
        html_content += f'''
            <div class="news-item">
                <a href="{url}" class="news-title" target="_blank">{title}</a>
                <div class="news-meta"><span class="heat">🔥 {heat}</span> · ⏰ {time}</div>
            </div>
'''
    html_content += '        </div>\n'

# GitHub板块
if gh_items:
    html_content += '''
        <div class="section">
            <div class="section-title">🚀 GitHub Trending AI项目</div>
'''
    for item in gh_items[:5]:
        title = item.get('title', '').replace('<', '&lt;').replace('>', '&gt;')
        url = item.get('url', '')
        heat = item.get('heat', '')
        html_content += f'''
            <div class="news-item">
                <a href="{url}" class="news-title" target="_blank">{title}</a>
                <div class="news-meta"><span class="heat">⭐ {heat}</span></div>
            </div>
'''
    html_content += '        </div>\n'

# 页脚
html_content += '''
        <div class="footer">
            <p>💡 掘金提示：关注热门项目的早期趋势，第一时间跟进可获得流量红利</p>
            <p>🔄 数据来源：HackerNews + GitHub Trending</p>
            <p>🤖 自动更新：每6小时</p>
        </div>
    </div>
</body>
</html>
'''

# 保存HTML报告
report_file = f'/home/user/.openclaw/workspace/reports/ai_news_' + '$DATE_STR' + '.html'
with open(report_file, 'w', encoding='utf-8') as f:
    f.write(html_content)

# 同时更新主index.html
with open('/home/user/.openclaw/workspace/index.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"✅ 报告已生成：{report_file}")
print(f"🌐 主页已更新：index.html")
PYEOF

echo "📤 正在推送到GitHub..."
cd /home/user/.openclaw/workspace
git add reports/ index.html 2>/dev/null || true
git commit -m "🤖 AI新闻自动更新 [${TIMESTAMP}]" || echo "无变更需要提交"
git push origin master || echo "推送失败"

echo ""
echo "✅ [${TIMESTAMP}] AI新闻更新完成！"
echo "🌐 访问地址：https://hhchhchhchhc.github.io/openclaw/"
echo "⏰ 下次更新：6小时后"
EOF

chmod +x /home/user/.openclaw/workspace/auto_fetch_ai_news.sh