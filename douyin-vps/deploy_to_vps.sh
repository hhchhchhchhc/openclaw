#!/bin/bash
# 抖店+VPS自动部署脚本
# 一键配置VPS环境并启动自动化系统

set -e

VPS_IP="${1:-}"
SSH_KEY="${2:-}"

echo "🚀 抖店+VPS自动部署系统"
echo "========================"
echo ""

if [ -z "$VPS_IP" ]; then
    echo "❌ 请提供VPS IP地址"
    echo "用法: ./deploy_to_vps.sh <VPS_IP> [SSH密钥路径]"
    exit 1
fi

echo "📡 目标VPS: $VPS_IP"
echo "⏳ 开始部署..."
echo ""

# SSH连接参数
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10"
if [ -n "$SSH_KEY" ]; then
    SSH_OPTS="$SSH_OPTS -i $SSH_KEY"
fi

# 检查连接
echo "🔍 检查VPS连接..."
if ! ssh $SSH_OPTS root@$VPS_IP "echo '连接成功'" 2>/dev/null; then
    echo "❌ 无法连接到VPS，请检查："
    echo "   1. IP地址是否正确"
    echo "   2. SSH端口是否开放(默认22)"
    echo "   3.  root密码/密钥是否正确"
    exit 1
fi

echo "✅ VPS连接成功"
echo ""

# 上传部署脚本
echo "📤 上传部署文件..."
ssh $SSH_OPTS root@$VPS_IP "mkdir -p /root/douyin-deploy"

# 创建远程部署脚本
ssh $SSH_OPTS root@$VPS_IP "cat > /root/douyin-deploy/setup.sh << 'REMOTE_EOF'
#!/bin/bash
set -e

echo '📦 开始安装依赖...'

# 更新系统
apt update -qq

# 安装基础工具
apt install -y -qq git python3 python3-pip ffmpeg curl wget

# 安装Python依赖
pip3 install -q requests beautifulsoup4 pillow moviepy qrcode itchat

# 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y -qq nodejs

echo '✅ 环境安装完成'

# 克隆项目
cd /root
if [ -d "openclaw" ]; then
    cd openclaw && git pull
else
    git clone https://github.com/hhchhchhchhc/openclaw.git
fi

echo '✅ 项目代码已更新'

# 创建系统服务
cat > /etc/systemd/system/douyin-automation.service << 'SERVICE_EOF'
[Unit]
Description=抖音自动化系统
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/openclaw/douyin-cps
ExecStart=/bin/bash /root/openclaw/douyin-cps/start_system.sh
Restart=always
RestartSec=30
StandardOutput=append:/var/log/douyin-automation.log
StandardError=append:/var/log/douyin-automation.log

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# 启用服务
systemctl daemon-reload
systemctl enable douyin-automation

echo '✅ 系统服务已创建'

# 创建监控脚本
cat > /root/check_status.sh << 'CHECK_EOF'
#!/bin/bash
echo "=== 抖音自动化系统状态 ==="
echo ""
echo "🔄 服务状态:"
systemctl status douyin-automation --no-pager -l

echo ""
echo "📊 运行日志（最近20行）:"
tail -20 /var/log/douyin-automation.log 2>/dev/null || echo "暂无日志"

echo ""
echo "💾 磁盘使用:"
df -h / | tail -1

echo ""
echo "🧠 内存使用:"
free -h | grep "Mem:"
CHECK_EOF

chmod +x /root/check_status.sh

echo ''
echo '🎉 部署完成！'
echo ''
echo '📋 常用命令:'
echo '  查看状态: systemctl status douyin-automation'
echo '  启动服务: systemctl start douyin-automation'
echo '  停止服务: systemctl stop douyin-automation'
echo '  查看日志: tail -f /var/log/douyin-automation.log'
echo '  状态检查: /root/check_status.sh'
echo ''
REMOTE_EOF

chmod +x /root/douyin-deploy/setup.sh

# 执行远程部署
echo "🔧 在VPS上执行部署..."
ssh $SSH_OPTS root@$VPS_IP "bash /root/douyin-deploy/setup.sh"

echo ""
echo "✅ 部署完成！"
echo ""
echo "📱 VPS信息:"
echo "  IP地址: $VPS_IP"
echo "  SSH登录: ssh root@$VPS_IP"
echo ""
echo "🎉 抖店+VPS自动化系统已部署完成！"
echo ""
echo "💡 下一步:"
echo "  1. SSH登录VPS: ssh root@$VPS_IP"
echo "  2. 查看运行状态: /root/check_status.sh"
echo "  3. 配置抖店API: nano /root/openclaw/douyin-cps/config.json"
echo "  4. 启动服务: systemctl start douyin-automation"
