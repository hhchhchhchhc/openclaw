#!/bin/bash
# AI新闻每10分钟推送脚本

set -e

cd /home/user/.npm-global/lib/node_modules/openclaw/skills/news-aggregator-skill

echo "🤖 正在抓取最新AI新闻..."

# 抓取AI相关新闻（多源）
python3 scripts/fetch_news.py --source hackernews --limit 5 --keyword "AI,LLM,GPT,DeepSeek,Agent,Claude,OpenAI" > /tmp/hn_ai.json 2>/dev/null || echo "[]" > /tmp/hn_ai.json
python3 scripts/fetch_news.py --source github --limit 5 --keyword "AI,LLM,ChatGPT,Machine Learning" > /tmp/gh_ai.json 2>/dev/null || echo "[]" > /tmp/gh_ai.json

# 生成Markdown报告
cat > /tmp/ai_news_report.md << 'EOF'
# 🔥 AI新闻快报 · $(date "+%Y-%m-%d %H:%M")

> 每10分钟自动更新 · 来源：HackerNews + GitHub Trending

EOF

# 处理HackerNews数据
if [ -s /tmp/hn_ai.json ] && [ "$(cat /tmp/hn_ai.json)" != "[]" ]; then
    echo "" >> /tmp/ai_news_report.md
    echo "## 📰 HackerNews 热门" >> /tmp/ai_news_report.md
    echo "" >> /tmp/ai_news_report.md
    
    python3 << PYEOF
import json

try:
    with open('/tmp/hn_ai.json', 'r') as f:
        items = json.load(f)
    
    for i, item in enumerate(items[:5], 1):
        title = item.get('title', '')
        url = item.get('url', '')
        heat = item.get('heat', '')
        time = item.get('time', '')
        print(f"### {i}. [{title}]({url})")
        print(f"🔥 {heat} · ⏰ {time}")
        print()
except Exception as e:
    print(f"获取HackerNews失败: {e}")
PYEOF
    >> /tmp/ai_news_report.md
fi

# 处理GitHub数据
if [ -s /tmp/gh_ai.json ] && [ "$(cat /tmp/gh_ai.json)" != "[]" ]; then
    echo "" >> /tmp/ai_news_report.md
    echo "## 🚀 GitHub Trending AI项目" >> /tmp/ai_news_report.md
    echo "" >> /tmp/ai_news_report.md
    
    python3 << PYEOF
import json

try:
    with open('/tmp/gh_ai.json', 'r') as f:
        items = json.load(f)
    
    for i, item in enumerate(items[:5], 1):
        title = item.get('title', '')
        url = item.get('url', '')
        heat = item.get('heat', '')
        print(f"### {i}. [{title}]({url})")
        print(f"⭐ {heat}")
        print()
except Exception as e:
    print(f"获取GitHub失败: {e}")
PYEOF
    >> /tmp/ai_news_report.md
fi

# 添加页脚
cat >> /tmp/ai_news_report.md << 'EOF'

---

💡 **掘金Tips**：关注热门项目的早期趋势，第一时间跟进可获得流量红利

🔄 下次更新：10分钟后

#AI新闻 #HackerNews #GitHub #AI掘金
EOF

echo "✅ 报告生成完成"

# 显示预览
cat /tmp/ai_news_report.md

echo ""
echo "==========================="
echo "📤 已保存到: /tmp/ai_news_report.md"
echo "🕐 更新时间: $(date)"
echo "==========================="