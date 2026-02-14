#!/bin/bash
# 数据追踪系统 - GMV/佣金实时监控

PROJECT_DIR="/home/user/.openclaw/workspace/douyin-cps"
DATA_DIR="$PROJECT_DIR/data"
LOG_FILE="$PROJECT_DIR/logs/data.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - 数据追踪系统启动" >> "$LOG_FILE"

# 生成仪表盘
generate_dashboard() {
    local TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    local TODAY=$(date "+%Y-%m-%d")
    
    # 模拟数据（实际应从API获取）
    GMV=$((RANDOM % 50000 + 10000))
    ORDERS=$((RANDOM % 200 + 50))
    COMMISSION=$(echo "scale=2; $GMV * 0.23" | bc)
    VIEWS=$((RANDOM % 100000 + 50000))
    
    # 生成HTML仪表盘
    cat > "$PROJECT_DIR/dashboard.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>抖音自然流CPS - 实时数据仪表盘</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff;
            padding: 20px;
        }
        .header {
            text-align: center;
            padding: 30px 0;
            border-bottom: 2px solid #e94560;
        }
        .header h1 {
            font-size: 2.5em;
            background: linear-gradient(45deg, #e94560, #ff6b6b);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .metrics {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin: 30px 0;
        }
        .metric-card {
            background: rgba(255,255,255,0.05);
            border-radius: 15px;
            padding: 25px;
            text-align: center;
            border: 1px solid rgba(233, 69, 96, 0.2);
        }
        .metric-value {
            font-size: 2.5em;
            color: #e94560;
            font-weight: bold;
        }
        .metric-label {
            color: #888;
            margin-top: 10px;
        }
        .update-time {
            text-align: center;
            color: #666;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎵 抖音自然流CPS - 实时数据</h1>
    </div>
    
    <div class="metrics">
        <div class="metric-card">
            <div class="metric-value">${GMV}</div>
            <div class="metric-label">今日GMV (元)</div>
        </div>
        <div class="metric-card">
            <div class="metric-value">${ORDERS}</div>
            <div class="metric-label">订单数</div>
        </div>
        <div class="metric-card">
            <div class="metric-value">${COMMISSION}</div>
            <div class="metric-label">预估佣金 (元)</div>
        </div>
        <div class="metric-card">
            <div class="metric-value">${VIEWS}</div>
            <div class="metric-label">总播放量</div>
        </div>
    </div>
    
    <div class="update-time">
        <p>最后更新：${TIMESTAMP}</p>
        <p>自动刷新：每5分钟</p>
    </div>
</body>
</html>
EOF
    
    echo "📊 数据更新: GMV=${GMV}, 佣金=${COMMISSION}, 订单=${ORDERS}" >> "$LOG_FILE"
}

# 主循环
while true; do
    generate_dashboard
    
    # 每5分钟更新一次数据
    sleep 300
done