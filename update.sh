#!/bin/bash
# AI淘金资讯自动更新脚本 - 多源免费版

set -e

cd /home/user/.openclaw/workspace

echo "🚀 开始抓取AI淘金资讯..."

# 生成时间戳
UPDATE_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# 创建临时目录
mkdir -p /tmp/ai-news

# ==================== 数据源1: HackerNews ====================
echo "📡 抓取 HackerNews..."
curl -s "https://hn.algolia.com/api/v1/search?query=artificial%20intelligence%20OR%20AI%20OR%20machine%20learning&tags=story&hitsPerPage=10" > /tmp/ai-news/hackernews.json

# 解析 HackerNews (使用Python处理JSON)
python3 << 'PYEOF'
import json
import urllib.request
import urllib.parse

try:
    with open('/tmp/ai-news/hackernews.json', 'r') as f:
        data = json.load(f)
    
    stories = []
    for hit in data.get('hits', [])[:5]:
        stories.append({
            'title': hit.get('title', ''),
            'url': hit.get('url', ''),
            'points': hit.get('points', 0),
            'author': hit.get('author', ''),
            'created_at': hit.get('created_at', '')
        })
    
    with open('/tmp/ai-news/hackernews_stories.json', 'w') as f:
        json.dump(stories, f, indent=2)
except Exception as e:
    print(f"HackerNews抓取失败: {e}")
    with open('/tmp/ai-news/hackernews_stories.json', 'w') as f:
        json.dump([], f)
PYEOF

# ==================== 数据源2: GitHub Trending ====================
echo "📡 抓取 GitHub Trending..."
# GitHub trending 没有官方API，我们用搜索API找最近更新的AI项目
python3 << 'PYEOF'
import json
import urllib.request
import urllib.parse
from datetime import datetime, timedelta

try:
    # 搜索最近更新的AI相关仓库
    url = "https://api.github.com/search/repositories?q=AI+OR+artificial-intelligence+OR+machine-learning+created:>2024-01-01&sort=updated&order=desc&per_page=5"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=10) as response:
        data = json.loads(response.read().decode())
    
    repos = []
    for item in data.get('items', [])[:5]:
        repos.append({
            'name': item.get('name', ''),
            'full_name': item.get('full_name', ''),
            'description': item.get('description', ''),
            'url': item.get('html_url', ''),
            'stars': item.get('stargazers_count', 0),
            'language': item.get('language', '')
        })
    
    with open('/tmp/ai-news/github_repos.json', 'w') as f:
        json.dump(repos, f, indent=2)
except Exception as e:
    print(f"GitHub抓取失败: {e}")
    with open('/tmp/ai-news/github_repos.json', 'w') as f:
        json.dump([], f)
PYEOF

# ==================== 数据源3: DuckDuckGo搜索 ====================
echo "📡 搜索 DuckDuckGo..."
python3 << 'PYEOF'
import json
import urllib.request
import urllib.parse
import re
from html import unescape

def duckduckgo_search(query, max_results=5):
    """使用DuckDuckGo HTML搜索"""
    try:
        encoded_query = urllib.parse.quote(query)
        url = f"https://html.duckduckgo.com/html/?q={encoded_query}"
        
        req = urllib.request.Request(
            url, 
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            }
        )
        
        with urllib.request.urlopen(req, timeout=15) as response:
            html = response.read().decode('utf-8')
        
        results = []
        # 解析搜索结果
        title_pattern = r'<a[^>]*class="result__a"[^>]*>(.*?)</a>'
        snippet_pattern = r'<a[^>]*class="result__snippet"[^>]*>(.*?)</a>'
        
        titles = re.findall(title_pattern, html)
        snippets = re.findall(snippet_pattern, html)
        
        for i, (title, snippet) in enumerate(zip(titles[:max_results], snippets[:max_results])):
            # 清理HTML标签
            title_clean = re.sub(r'<[^>]+>', '', title)
            snippet_clean = re.sub(r'<[^>]+>', '', snippet)
            title_clean = unescape(title_clean)
            snippet_clean = unescape(snippet_clean)
            
            results.append({
                'title': title_clean,
                'snippet': snippet_clean,
                'source': 'DuckDuckGo'
            })
        
        return results
    except Exception as e:
        print(f"DuckDuckGo搜索失败: {e}")
        return []

# 搜索多个关键词
all_results = []
queries = [
    "AI工具 赚钱 2025",
    "人工智能 副业 月入",
    "OpenAI 最新功能",
    "AI Agent 创业"
]

for query in queries:
    try:
        results = duckduckgo_search(query, max_results=2)
        all_results.extend(results)
    except Exception as e:
        print(f"搜索'{query}'失败: {e}")

with open('/tmp/ai-news/duckduckgo_results.json', 'w', encoding='utf-8') as f:
    json.dump(all_results[:8], f, indent=2, ensure_ascii=False)
PYEOF

# ==================== 生成HTML内容 ====================
echo "📝 生成HTML内容..."

python3 << 'PYEOF'
import json
from datetime import datetime

# 读取数据
try:
    with open('/tmp/ai-news/hackernews_stories.json', 'r') as f:
        hn_stories = json.load(f)
except:
    hn_stories = []

try:
    with open('/tmp/ai-news/github_repos.json', 'r') as f:
        gh_repos = json.load(f)
except:
    gh_repos = []

try:
    with open('/tmp/ai-news/duckduckgo_results.json', 'r', encoding='utf-8') as f:
        ddgo_results = json.load(f)
except:
    ddgo_results = []

# 生成内容HTML
content_html = []

# HackerNews热门
if hn_stories:
    content_html.append('''
        <div class="card">
            <div class="card-header">
                <span class="card-icon">🔥</span>
                <h3 class="card-title">HackerNews AI热门讨论</h3>
            </div>
            <div class="tags">
                <span class="tag">社区热议</span>
                <span class="tag">技术趋势</span>
            </div>
            <div class="content">
                <ul style="margin-left: 20px; color: #ccc; line-height: 2;">
''')
    for story in hn_stories[:3]:
        title = story.get('title', '').replace('<', '&lt;').replace('>', '&gt;')
        url = story.get('url', 'https://news.ycombinator.com')
        points = story.get('points', 0)
        content_html.append(f'<li><a href="{url}" target="_blank" style="color: #e94560;">{title}</a> ({points}🔼)</li>')
    content_html.append('''
                </ul>
            </div>
        </div>
''')

# GitHub热门AI项目
if gh_repos:
    content_html.append('''
        <div class="card">
            <div class="card-header">
                <span class="card-icon">🚀</span>
                <h3 class="card-title">GitHub热门AI项目</h3>
            </div>
            <div class="tags">
                <span class="tag">开源</span>
                <span class="tag">GitHub Trending</span>
            </div>
''')
    for repo in gh_repos[:2]:
        name = repo.get('name', '').replace('<', '&lt;').replace('>', '&gt;')
        desc = (repo.get('description') or '暂无描述').replace('<', '&lt;').replace('>', '&gt;')
        url = repo.get('url', '')
        stars = repo.get('stars', 0)
        lang = repo.get('language', 'Unknown')
        content_html.append(f'''
            <div style="margin-bottom: 15px; padding: 10px; background: rgba(255,255,255,0.03); border-radius: 8px;">
                <strong style="color: #fff;">⭐ {name}</strong> <span style="color: #888;">({lang} · {stars} stars)</span><br>
                <p style="color: #aaa; margin-top: 5px;">{desc}</p>
                <a href="{url}" target="_blank" style="color: #e94560; font-size: 0.9em;">查看项目 →</a>
            </div>
''')
    content_html.append('</div>')

# DuckDuckGo搜索结果
if ddgo_results:
    content_html.append('''
        <div class="card">
            <div class="card-header">
                <span class="card-icon">🔍</span>
                <h3 class="card-title">AI掘金最新情报</h3>
            </div>
            <div class="tags">
                <span class="tag">实时搜索</span>
                <span class="tag">变现机会</span>
            </div>
''')
    for result in ddgo_results[:3]:
        title = result.get('title', '').replace('<', '&lt;').replace('>', '&gt;')
        snippet = result.get('snippet', '').replace('<', '&lt;').replace('>', '&gt;')
        content_html.append(f'''
            <div class="highlight" style="margin-bottom: 15px;">
                <strong style="color: #fff;">{title}</strong>
                <p style="color: #aaa; margin-top: 8px;">{snippet}</p>
            </div>
''')
    content_html.append('</div>')

# AI掘金Tips
content_html.append('''
        <div class="card">
            <div class="card-header">
                <span class="card-icon">💡</span>
                <h3 class="card-title">AI掘金Tips</h3>
            </div>
            <div class="tags">
                <span class="tag">实操建议</span>
                <span class="tag">赚钱思路</span>
            </div>
            <div class="money-tip">
                <h4>🎯 本周重点关注</h4>
                <ul style="margin-left: 20px; margin-top: 10px; line-height: 1.8;">
                    <li><strong>AI视频生成</strong>：Pika、Runway、HeyGen 竞争白热化，关注新功能发布窗口期</li>
                    <li><strong>AI编程助手</strong>：Cursor 融资 1.05 亿美元，插件生态是下一个爆发点</li>
                    <li><strong>AI Agent</strong>：Manus 爆火证明市场饥渴，垂直场景 Agent 有机会</li>
                    <li><strong>AI数字人</strong>：短视频平台算法开始推AI内容，流量红利期</li>
                </ul>
            </div>
            <div style="margin-top: 15px; padding: 15px; background: rgba(233, 69, 96, 0.1); border-radius: 8px;">
                <strong style="color: #e94560;">💰 变现公式：</strong><br>
                <span style="color: #ccc;">新工具首发(流量) + 教程/模板(产品) + 社群/课程(转化) = 持续收入</span>
            </div>
        </div>
''')

# 写入内容文件
with open('/tmp/ai-news/content.html', 'w', encoding='utf-8') as f:
    f.write('\n'.join(content_html))

print(f"生成了 {len(content_html)} 个内容块")
PYEOF

# ==================== 合并生成最终HTML ====================
echo "🎨 生成最终HTML..."

sed -e "s/{{UPDATE_TIME}}/$UPDATE_TIME/" \
    -e "/<!-- CONTENT_PLACEHOLDER -->/r /tmp/ai-news/content.html" \
    -e "/<!-- CONTENT_PLACEHOLDER -->/d" \
    template.html > index.html

# 清理临时文件
rm -rf /tmp/ai-news

# ==================== Git推送 ====================
echo "📤 推送到GitHub..."
git add index.html
git commit -m "Update: AI淘金资讯 $UPDATE_TIME [多源抓取]" || echo "No changes to commit"
git push origin master || echo "Push failed"

echo "✅ 更新完成: $UPDATE_TIME"
echo "🌐 访问地址: https://hhchhchhchhc.github.io/openclaw/"