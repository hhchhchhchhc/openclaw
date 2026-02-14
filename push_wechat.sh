#!/bin/bash
# 公众号内容推送助手 - 生成优化后的复制格式

cd /home/user/.openclaw/workspace

CONTENT_FILE="$1"
TITLE="$2"

if [ -z "$CONTENT_FILE" ]; then
    echo "用法: ./push_wechat.sh <内容文件.md> [标题]"
    exit 1
fi

if [ -z "$TITLE" ]; then
    TITLE=$(head -1 "$CONTENT_FILE" | sed 's/# //')
fi

echo "📝 正在生成公众号格式..."

# 生成优化后的HTML（适合微信编辑器粘贴）
python3 << PYEOF
import re
import sys

with open('$CONTENT_FILE', 'r', encoding='utf-8') as f:
    content = f.read()

# 提取标题（第一个#开头的行）
lines = content.split('\n')
title = ''
body_lines = []
for line in lines:
    if line.startswith('# ') and not title:
        title = line[2:].strip()
    else:
        body_lines.append(line)

body = '\n'.join(body_lines)

# 转换为微信友好的格式
# 1. 处理标题层次
body = re.sub(r'^## (.+)$', r'<h2 style="font-size:18px;font-weight:bold;color:#e94560;margin:20px 0 10px;border-left:4px solid #e94560;padding-left:10px;">\1</h2>', body, flags=re.MULTILINE)
body = re.sub(r'^### (.+)$', r'<h3 style="font-size:16px;font-weight:bold;color:#333;margin:15px 0 8px;">\1</h3>', body, flags=re.MULTILINE)

# 2. 处理粗体
body = re.sub(r'\*\*(.+?)\*\*', r'<strong style="color:#e94560;">\1</strong>', body)

# 3. 处理引用块
body = re.sub(r'^> (.+)$', r'<blockquote style="border-left:4px solid #e94560;background:#f8f8f8;padding:10px 15px;margin:15px 0;color:#666;">\1</blockquote>', body, flags=re.MULTILINE)

# 4. 处理分隔线
body = re.sub(r'^---+$', r'<hr style="border:none;border-top:1px solid #eee;margin:20px 0;">', body, flags=re.MULTILINE)

# 5. 处理列表
body = re.sub(r'^\* ', r'• ', body, flags=re.MULTILINE)
body = re.sub(r'^- ', r'• ', body, flags=re.MULTILINE)

# 6. 处理链接
body = re.sub(r'\[(.+?)\]\((.+?)\)', r'<a href="\2" style="color:#e94560;text-decoration:none;">\1</a>', body)

# 7. 包装段落
paragraphs = body.split('\n\n')
new_paragraphs = []
for p in paragraphs:
    p = p.strip()
    if not p:
        continue
    # 如果已经是HTML标签，不再包装
    if p.startswith('<') and not p.startswith('•'):
        new_paragraphs.append(p)
    else:
        # 处理换行
        p = p.replace('\n', '<br>')
        new_paragraphs.append(f'<p style="font-size:15px;line-height:1.8;color:#333;margin:10px 0;">{p}</p>')

final_body = '\n\n'.join(new_paragraphs)

# 生成完整HTML
html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; }}
h1 {{ font-size: 22px; font-weight: bold; color: #333; margin-bottom: 20px; text-align: center; }}
</style>
</head>
<body>
<h1>{title}</h1>
{final_body}
<div style="margin-top:30px;padding-top:20px;border-top:1px solid #eee;text-align:center;color:#999;font-size:12px;">
<p>觉得有用？点个赞👍 或分享给朋友</p>
<p>关注「赛博AI淘金」，获取更多AI赚钱情报</p>
</div>
</body>
</html>"""

with open('/tmp/wechat_ready.html', 'w', encoding='utf-8') as f:
    f.write(html)

# 同时生成纯文本版本（适合直接粘贴到公众号）
text_version = content
# 移除markdown标记用于预览
text_version = re.sub(r'\*\*', '', text_version)
text_version = re.sub(r'\[|\]', '', text_version)
text_version = re.sub(r'\(http[^)]+\)', '', text_version)

with open('/tmp/wechat_preview.txt', 'w', encoding='utf-8') as f:
    f.write(text_version)

print(f"✅ 标题: {title}")
print(f"✅ 内容已优化为微信格式")
print(f"📄 HTML版本: /tmp/wechat_ready.html")
print(f"📝 预览版本: /tmp/wechat_preview.txt")

PYEOF

# 显示预览
echo ""
echo "========== 预览 =========="
head -30 /tmp/wechat_preview.txt
echo "..."
echo ""
echo "========== 推送指引 =========="
echo "1. 打开公众号后台: https://mp.weixin.qq.com"
echo "2. 点击左侧'图文消息'或'草稿箱'"
echo "3. 点击'新建图文消息'"
echo "4. 标题: $TITLE"
echo "5. 复制以下内容到正文:"
echo ""
cat /tmp/wechat_preview.txt
echo ""
echo "==========================="

# 可选：复制到剪贴板（如果有xclip或xsel）
if command -v xclip &> /dev/null; then
    cat /tmp/wechat_preview.txt | xclip -selection clipboard
    echo "📋 内容已复制到剪贴板！直接粘贴到公众号编辑器即可"
elif command -v xsel &> /dev/null; then
    cat /tmp/wechat_preview.txt | xsel -b
    echo "📋 内容已复制到剪贴板！直接粘贴到公众号编辑器即可"
fi

echo ""
echo "🎉 准备就绪！按上述步骤粘贴到公众号即可"