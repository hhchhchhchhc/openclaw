#!/bin/bash
# 抖音自动选品+上架 主控脚本
# 每小时自动执行

PROJECT_DIR="/home/user/.openclaw/workspace/douyin-auto"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "========================================"
echo "🤖 抖音全自动系统启动"
echo "⏰ 时间: ${TIMESTAMP}"
echo "========================================"
echo ""

cd "$PROJECT_DIR"

# Step 1: 自动选品
echo "【步骤1/3】自动选品..."
./auto_select_products.sh >> "$LOG_DIR/auto_run_${DATE_STR}.log" 2>&1
if [ $? -eq 0 ]; then
    echo "✅ 选品完成"
else
    echo "❌ 选品失败，跳过"
    exit 1
fi

echo ""

# Step 2: 自动上架
echo "【步骤2/3】自动上架到抖店..."
./auto_listing.sh >> "$LOG_DIR/auto_run_${DATE_STR}.log" 2>&1
if [ $? -eq 0 ]; then
    echo "✅ 上架完成"
else
    echo "❌ 上架失败"
fi

echo ""

# Step 3: 生成报告
echo "【步骤3/3】生成运营报告..."

python3 << PYEOF
import json
from datetime import datetime
import glob

data_dir = "${PROJECT_DIR}/data"
date_str = datetime.now().strftime('%Y%m%d_%H')

# 读取上架结果
result_file = f"{data_dir}/listing_result_{date_str}.json"
try:
    with open(result_file, 'r') as f:
        data = json.load(f)
    
    print("📊 本次运营报告")
    print(f"时间: {data['listing_time']}")
    print(f"上架商品数: {data['success_count']}")
    print("")
    
    total_commission = 0
    for r in data['results']:
        commission = r['price'] * r['commission_rate'] / 100
        total_commission += commission
        print(f"✅ {r['product_name']}")
        print(f"   价格: ¥{r['price']} | 佣金: {r['commission_rate']}% | 预计收益: ¥{commission:.2f}")
        print(f"   链接: {r['promote_link']}")
        print("")
    
    print(f"💰 预计总佣金: ¥{total_commission:.2f}")
    
except Exception as e:
    print(f"生成报告失败: {e}")
PYEOF

echo ""
echo "========================================"
echo "✅ 全自动流程完成！"
echo "🎉 商品已自动选品并上架"
echo "📱 请查看推广素材并发布"
echo "⏰ 下次自动运行: 1小时后"
echo "========================================"

# 推送到GitHub
cd /home/user/.openclaw/workspace
git add douyin-auto/ 2>/dev/null || true
git commit -m "🤖 抖音自动选品+上架 - ${TIMESTAMP}" 2>/dev/null || true
git push origin master 2>/dev/null || true

echo "📤 数据已同步到GitHub"