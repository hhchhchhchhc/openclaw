#!/bin/bash
# 抖音自动选品系统 - 每小时自动运行
# 全自动选品，无需人工干预

set -e

PROJECT_DIR="/home/user/.openclaw/workspace/douyin-auto"
DATA_DIR="$PROJECT_DIR/data"
LOG_DIR="$PROJECT_DIR/logs"

mkdir -p "$DATA_DIR" "$LOG_DIR"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
DATE_STR=$(date "+%Y%m%d_%H")

echo "🤖 [${TIMESTAMP}] 开始自动选品..."

# 选品策略配置
SELECT_STRATEGY="high_commission"  # 高佣金策略
MIN_COMMISSION=20                  # 最低佣金率20%
MAX_PRICE=200                      # 最高价200元
MIN_PRICE=10                       # 最低价10元
CATEGORY="daily_necessities"       # 日用百货品类

# 模拟从精选联盟抓取高佣商品（实际需接入API）
fetch_products() {
    echo "🔍 正在抓取高佣商品..."
    
    # 这里模拟商品数据，实际应调用抖音精选联盟API
    cat > "$DATA_DIR/products_${DATE_STR}.json" << EOF
{
  "fetch_time": "${TIMESTAMP}",
  "products": [
    {
      "id": "P${DATE_STR}01",
      "name": "便携折叠收纳箱",
      "category": "家居收纳",
      "price": 29.9,
      "commission_rate": 35,
      "commission_amount": 10.47,
      "sales": 15000,
      "rating": 4.8,
      "supplier": "厂家直发",
      "image_url": "https://example.com/img1.jpg",
      "reason": "高佣金+高销量"
    },
    {
      "id": "P${DATE_STR}02", 
      "name": "多功能厨房剪刀",
      "category": "厨房用具",
      "price": 19.9,
      "commission_rate": 40,
      "commission_amount": 7.96,
      "sales": 28000,
      "rating": 4.7,
      "supplier": "品牌旗舰店",
      "image_url": "https://example.com/img2.jpg",
      "reason": "超高佣金率"
    },
    {
      "id": "P${DATE_STR}03",
      "name": "魔术拖把免手洗",
      "category": "清洁工具",
      "price": 39.9,
      "commission_rate": 30,
      "commission_amount": 11.97,
      "sales": 32000,
      "rating": 4.6,
      "supplier": "源头工厂",
      "image_url": "https://example.com/img3.jpg",
      "reason": "爆款潜力"
    },
    {
      "id": "P${DATE_STR}04",
      "name": "便携榨汁杯",
      "category": "小家电",
      "price": 59.9,
      "commission_rate": 25,
      "commission_amount": 14.98,
      "sales": 8500,
      "rating": 4.9,
      "supplier": "品牌授权",
      "image_url": "https://example.com/img4.jpg",
      "reason": "高客单价"
    },
    {
      "id": "P${DATE_STR}05",
      "name": "硅胶保鲜盖套装",
      "category": "厨房收纳",
      "price": 15.9,
      "commission_rate": 45,
      "commission_amount": 7.16,
      "sales": 45000,
      "rating": 4.5,
      "supplier": "厂家直发",
      "image_url": "https://example.com/img5.jpg",
      "reason": "极致性价比"
    }
  ]
}
EOF
    
    echo "✅ 已抓取5个高佣商品"
}

# 智能筛选商品
filter_products() {
    echo "🧠 智能筛选商品..."
    
    python3 << PYEOF
import json
from datetime import datetime

data_file = "${DATA_DIR}/products_${DATE_STR}.json"
output_file = "${DATA_DIR}/selected_${DATE_STR}.json"

with open(data_file, 'r') as f:
    data = json.load(f)

products = data['products']

# 筛选条件
min_commission = ${MIN_COMMISSION}
min_price = ${MIN_PRICE}
max_price = ${MAX_PRICE}

# 智能评分
scored_products = []
for p in products:
    score = 0
    
    # 佣金率评分 (权重40%)
    score += p['commission_rate'] * 0.4
    
    # 销量评分 (权重30%)
    sales_score = min(p['sales'] / 10000, 5)  # 最高5分
    score += sales_score * 0.3
    
    # 评分评分 (权重20%)
    score += p['rating'] * 0.2
    
    # 价格合理性 (权重10%)
    if min_price <= p['price'] <= max_price:
        score += 1
    
    # 佣金金额
    if p['commission_amount'] >= 5:
        score += 1
    
    p['score'] = round(score, 2)
    scored_products.append(p)

# 按评分排序，选前3个
scored_products.sort(key=lambda x: x['score'], reverse=True)
selected = scored_products[:3]

result = {
    'select_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
    'strategy': '${SELECT_STRATEGY}',
    'selected_count': len(selected),
    'products': selected
}

with open(output_file, 'w') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)

print(f"✅ 智能筛选完成，选定{len(selected)}个商品")
for i, p in enumerate(selected, 1):
    print(f"  {i}. {p['name']} - 佣金{p['commission_rate']}% - 评分{p['score']}")
PYEOF
}

# 生成商品详情
generate_details() {
    echo "📝 生成商品详情..."
    
    python3 << PYEOF
import json
from datetime import datetime

with open("${DATA_DIR}/selected_${DATE_STR}.json", 'r') as f:
    data = json.load(f)

products = data['products']

for i, p in enumerate(products, 1):
    detail_file = "${DATA_DIR}/product_${DATE_STR}_${i}.json"
    
    # 自动生成标题、卖点、详情
    title_templates = [
        f"【厂家直发】{p['name']} 限时特价",
        f"【佣金{p['commission_rate']}%】{p['name']}",
        f"月销{p['sales']//10000}万+ {p['name']}"
    ]
    
    selling_points = [
        f"✅ 佣金高达{p['commission_rate']}%，每单赚{p['commission_amount']}元",
        f"✅ 已售{p['sales']}+，用户好评率{p['rating']}分",
        f"✅ 价格{p['price']}元，超高性价比",
        f"✅ {p['supplier']}，品质保证"
    ]
    
    detail = {
        'product_id': p['id'],
        'title': title_templates[0],
        'sub_title': f"限时优惠 | 高佣{p['commission_rate']}% | 已售{p['sales']}+",
        'price': p['price'],
        'original_price': round(p['price'] * 1.5, 1),
        'commission_rate': p['commission_rate'],
        'commission_amount': p['commission_amount'],
        'selling_points': selling_points,
        'category': p['category'],
        'image_url': p['image_url'],
        'stock': 9999,
        'auto_listing': True,
        'listing_time': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    
    with open(detail_file, 'w') as f:
        json.dump(detail, f, indent=2, ensure_ascii=False)
    
    print(f"  ✅ 商品{i}: {p['name']}")
PYEOF
}

# 主流程
main() {
    echo "========================================"
    echo "🤖 抖音自动选品系统 - 全自动模式"
    echo "========================================"
    echo ""
    
    fetch_products
    filter_products
    generate_details
    
    echo ""
    echo "✅ 自动选品完成！"
    echo "📦 已选定3个高佣商品"
    echo "📁 数据保存在: ${DATA_DIR}/"
    echo "⏰ 下次选品: 1小时后"
    echo "========================================"
    
    # 记录日志
    echo "[${TIMESTAMP}] 选品完成，选定3个商品" >> "$LOG_DIR/select.log"
}

main