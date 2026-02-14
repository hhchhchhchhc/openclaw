#!/bin/bash
# 抖音自然流CPS全自动系统启动脚本

set -e

PROJECT_DIR="/home/user/.openclaw/workspace/douyin-cps"
cd "$PROJECT_DIR"

echo "🎵 抖音自然流CPS全自动系统"
echo "============================"
echo ""

# 检查配置
if [ ! -f "$PROJECT_DIR/config.json" ]; then
    echo "📝 首次运行，创建默认配置..."
    cat > "$PROJECT_DIR/config.json" << 'EOF'
{
  "project_name": "抖音自然流CPS",
  "mode": "全自动",
  "platform": "抖音",
  "strategy": "自然流+搜索流量",
  
  "niche": {
    "primary": "3C数码",
    "secondary": ["家电", "智能家居"],
    "commission_rate": "15-30%",
    "price_range": "100-1000"
  },
  
  "content": {
    "videos_per_day": 10,
    "accounts": 3,
    "style": "像素级拆解+AI混剪",
    "duration": "15-30秒"
  },
  
  "traffic": {
    "seo_enabled": true,
    "search_optimization": true,
    "hashtag_strategy": "精准长尾词"
  },
  
  "automation": {
    "product_selection": true,
    "video_generation": true,
    "posting": true,
    "data_tracking": true
  }
}
EOF
    echo "✅ 配置已创建"
fi

echo "📊 当前配置："
cat "$PROJECT_DIR/config.json" | python3 -m json.tool 2>/dev/null || cat "$PROJECT_DIR/config.json"

echo ""
echo "🔧 系统模块："
echo "  1️⃣  智能选品系统 - 自动抓取高佣金商品"
echo "  2️⃣  AI视频生成 - 批量生成带货视频"
echo "  3️⃣  SEO优化 - 自动标题/标签优化"
echo "  4️⃣  自动发布 - 定时发布到多账号"
echo "  5️⃣  数据追踪 - GMV/佣金实时监控"
echo ""

# 启动各个模块
echo "🚀 启动系统模块..."

# 模块1：智能选品
nohup "$PROJECT_DIR/scripts/product_selector.sh" > "$PROJECT_DIR/logs/product.log" 2>&1 &
echo "✅ 智能选品系统已启动 (PID: $!)"

# 模块2：视频生成
nohup "$PROJECT_DIR/scripts/video_generator.sh" > "$PROJECT_DIR/logs/video.log" 2>&1 &
echo "✅ AI视频生成已启动 (PID: $!)"

# 模块3：自动发布
nohup "$PROJECT_DIR/scripts/auto_poster.sh" > "$PROJECT_DIR/logs/post.log" 2>&1 &
echo "✅ 自动发布系统已启动 (PID: $!)"

# 模块4：数据追踪
nohup "$PROJECT_DIR/scripts/data_tracker.sh" > "$PROJECT_DIR/logs/data.log" 2>&1 &
echo "✅ 数据追踪已启动 (PID: $!)"

echo ""
echo "🎉 抖音自然流CPS全自动系统已启动！"
echo ""
echo "📁 项目目录：$PROJECT_DIR"
echo "📊 数据面板：$PROJECT_DIR/dashboard.html"
echo "📈 实时日志：tail -f $PROJECT_DIR/logs/*.log"
echo ""
echo "⚠️  重要提示："
echo "  - 请确保已配置抖音开放平台API"
echo "  - 需要准备3-5个抖音账号"
echo "  - 首次建议手动测试再全自动"
echo ""
echo "💡 查看实时数据：./show_dashboard.sh"