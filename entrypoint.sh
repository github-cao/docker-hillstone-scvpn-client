#!/bin/bash

# ==============================================================================
# SCVPN Docker 容器入口脚本 (v15 - 终极版)
# ==============================================================================

# 从环境变量中读取 VPN 配置
VPN_SERVER=${VPN_SERVER:-"172.16.10.1"}
VPN_PORT=${VPN_PORT:-"2222"}
VPN_USER=${VPN_USER:-"admin"}
VPN_PASS=${VPN_PASS:-"admin"}

echo "================================================="
echo "  SCVPN & SOCKS5 Proxy Container (v15)"
echo "================================================="
echo "VPN Server: ${VPN_SERVER}"
echo "VPN Port:   ${VPN_PORT}"
echo "VPN User:   ${VPN_USER}"
echo "-------------------------------------------------"

# 检查 scvpn 命令
if ! command -v scvpn &> /dev/null; then
    echo "错误: 'scvpn' 命令未找到。"
    exit 1
fi

# 步骤 1: 重置 scvpn 配置
echo "正在重置 SCVPN 配置..."
scvpn reset
sleep 1

# 步骤 2: 使用 expect 自动化登录 (v15 - 模拟真实Shell)
echo "正在尝试自动化登录 VPN (模拟真实Shell模式)..."
/usr/bin/expect <<EOF
# 设置一个较长的超时时间
set timeout 120

# --- 关键改动: 先启动一个真实的Shell ---
spawn /bin/bash

# 在Shell中，发送 scvpn start 命令来启动程序
send "scvpn start\r"

# 后续的交互逻辑保持不变
expect "server:"
sleep 0.5
send -- "${VPN_SERVER}\r"

expect "port:"
sleep 0.5
send -- "${VPN_PORT}\r"

expect "username:"
sleep 0.5
send -- "${VPN_USER}\r"

expect "password:"
sleep 0.5
send -- "${VPN_PASS}\r"

expect -glob "Save password?*:"
sleep 0.5
send "y\r"

expect {
    -glob "*press Enter to continue*" {
        puts "\n检测到 'press Enter' 提示，发送回车。"
        send "\r"
    }
    eof {
        puts "\nscvpn 进程已退出 (EOF)。后续将通过 status 命令检查结果。"
    }
}

puts "\n数据输入脚本执行完毕。"
EOF

# 步骤 3: 循环验证 VPN 连接状态
echo "-------------------------------------------------"
echo "登录数据已输入，现在开始通过 'scvpn status' 验证真实连接状态..."
for i in {1..15}; do
    STATUS_OUTPUT=$(scvpn status 2>&1)
    echo "验证尝试 $i/15: 'scvpn status' 返回 -> ${STATUS_OUTPUT}"

    if echo "${STATUS_OUTPUT}" | grep -q -E "is running|connected"; then
        echo "✅ 成功: VPN 连接状态已确认！"
        
        # 步骤 4: 启动 SOCKS5 代理
        echo "-------------------------------------------------"
        echo "启动 SOCKS5 代理 (microsocks) 在 0.0.0.0:1080 ..."
        microsocks -i 0.0.0.0 -p 1080 &
        
        echo "================================================="
        echo "      容器已准备就绪!"
        echo "SOCKS5 代理正在运行于: <Docker主机IP>:1080"
        echo "================================================="
        
        tail -f /dev/null
        exit 0
    fi
    
    sleep 2
done

# 步骤 5: 如果循环结束仍未成功，则报告错误并退出
echo "-------------------------------------------------"
echo "❌ 失败: 在多次尝试后仍无法确认 VPN 已连接。"
echo "如果此方法依然失败，则此客户端可能无法被自动化。请检查凭据后联系VPN管理员。"
echo "容器将退出。"
exit 1

