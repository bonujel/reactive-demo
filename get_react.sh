#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 加载环境变量
if [ ! -f .env ]; then
    echo "错误: .env 文件不存在"
    exit 1
fi

export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)

# 显示配置
echo "========================================="
echo "  获取 Reactive REACT 代币"
echo "========================================="
echo ""
echo "RPC: $ORIGIN_RPC"
echo "地址: $(cast wallet address --private-key $ORIGIN_PRIVATE_KEY)"
echo ""
echo "正在发送 1 SepETH 到 Reactive 水龙头..."
echo "你将收到 100 REACT（比例 1:100）"
echo ""

# 发送交易
cast send 0x9b9BB25f1A81078C544C829c5EB7822d747Cf434 \
  --rpc-url "$ORIGIN_RPC" \
  --private-key "$ORIGIN_PRIVATE_KEY" \
  --value 1ether

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ 交易已发送！"
    echo ""
    echo "等待 1-2 分钟后，检查 Reactive Network 余额："
    echo "  ./check_balance.sh"
else
    echo ""
    echo "✗ 交易发送失败"
    echo ""
    echo "可能的原因："
    echo "1. RPC 连接失败 - 尝试更换 RPC"
    echo "2. 余额不足 - 检查 Sepolia 余额"
    echo "3. 私钥错误 - 检查 .env 配置"
fi
