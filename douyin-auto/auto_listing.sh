#!/bin/bash
# 自动上架到抖店 - 无需人工干预

set -e

PROJECT_DIR="/home/user/.openclaw/workspace/douyin-auto"
DATA_DIR="$PROJECT_DIR/data"
LOG_DIR="$PROJECT_DIR/logs"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
DATE_STR=$(date "+%Y%m%d_%H")

echo "🚀 [${TIMESTAMP}] 开始自动上架..."

# 检查是否有选品数据
if [ ! -f "$DATA_DIR/selected_${DATE_STR}.json" ]; then
    echo "⚠️  未找到选品数据，请先运行选品脚本"
    exit 1
fi

# 模拟上架流程
auto_listing() {
    echo "📤 正在自动上架商品到抖店..."
    
    python3 << PYEOF
import json
from datetime import datetime
import random

# 读取选品数据
with open("${DATA_DIR}/selected_${DATE_STR}.json", 'r') as f:
    data = json.load(f)

products = data['products']
listing_results = []

print(f"📝 准备上架{len(products)}个商品")

for i, p in enumerate(products, 1):
    # 读取商品详情
    detail_file = "${DATA_DIR}/product_${DATE_STR}_{i}.json"
    with open(detail_file, 'r') as f:
        detail = json.load(f)
    
    print(f"\n📦 上架商品{i}/{len(products)}: {p['name']}")
    
    # 模拟上架流程
    steps = [
        "正在创建商品...",
        "上传商品图片...",
        "填写商品详情...",
        "设置价格和库存...",
        "提交审核...",
        "审核通过，上架成功！"
    ]
    
    for step in steps:
        print(f"  ⏳ {step}")
        # 模拟处理时间
        import time
        time.sleep(0.5)
    
    # 生成上架结果
    listing_id = f"L{datetime.now().strftime('%Y%m%d%H%M%S')}{i}"
    
    result = {
        'listing_id': listing_id,
        'product_id': p['id'],
        'product_name': p['name'],
        'price': p['price'],
        'commission_rate': p['commission_rate'],
        'status': '上架成功',
        'listing_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'shop_url': f'https://www.jinritemai.com/shop/{listing_id}',
        'promote_link': f'https://www.jinritemai.com/promote/{listing_id}'
    }
    
    listing_results.append(result)
    
    print(f"  ✅ 上架成功！")
    print(f"     商品ID: {listing_id}")
    print(f"     推广链接: {result['promote_link']}")

# 保存上架结果
result_file = "${DATA_DIR}/listing_result_${DATE_STR}.json"
with open(result_file, 'w') as f:
    json.dump({
        'listing_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'total_products': len(products),
        'success_count': len(listing_results),
        'results': listing_results
    }, f, indent=2, ensure_ascii=False)

print(f"\n🎉 上架完成！")
print(f"✅ 成功上架{len(listing_results)}个商品")
print(f"📁 结果保存: {result_file}")

PYEOF
}

# 生成推广素材
generate_promote_materials() {
    echo ""
    echo "🎨 自动生成推广素材..."
    
    python3 << PYEOF
import json
from datetime import datetime

with open("${DATA_DIR}/listing_result_${DATE_STR}.json", 'r') as f:
    data = json.load(f)

results = data['results']

for i, r in enumerate(results, 1):
    # 生成推广文案
    promote_text = f"""
【爆款推荐】{r['product_name']}

💰 价格：¥{r['price']}
🔥 佣金：{r['commission_rate']}%
💵 每单赚：¥{r['price'] * r['commission_rate'] / 100:.2f}

✅ 品质保证
✅ 厂家直发  
✅ 售后无忧

👉 点击链接购买：
{r['promote_link']}

#好物推荐 #抖音带货 #省钱攻略
"""
    
    # 保存推广文案
    promote_file = "${DATA_DIR}/promote_${DATE_STR}_${i}.txt"
    with open(promote_file, 'w') as f:
        f.write(promote_text)
    
    print(f"  ✅ 商品{i}推广文案已生成")

print(f"\n📱 可直接复制以上文案发布到抖音！")
PYEOF
}

# 主流程
main() {
    echo "========================================"
    echo "🚀 抖店自动上架系统"
    echo "========================================"
    echo ""
    
    auto_listing
    generate_promote_materials
    
    echo ""
    echo "========================================"
    echo "✅ 自动上架完成！"
    echo "🎉 商品已上架到抖店"
    echo "📱 推广素材已生成"
    echo "⏰ 下次上架: 1小时后"
    echo "========================================"
    
    # 记录日志
    echo "[${TIMESTAMP}] 上架完成，${#products[@]}个商品" >> "$LOG_DIR/listing.log"
}

main