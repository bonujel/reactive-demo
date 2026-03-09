#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 加载环境变量
export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)

# 获取地址
ADDRESS=$(cast wallet address --private-key $ORIGIN_PRIVATE_KEY)

echo "========================================="
echo "  余额查询"
echo "========================================="
echo ""
echo "地址: $ADDRESS"
echo ""

echo "Sepolia 余额:"
cast balance $ADDRESS --rpc-url "$ORIGIN_RPC" --ether 2>/dev/null || echo "  查询失败"

echo ""
echo "Reactive 余额:"
cast balance $ADDRESS --rpc-url "$REACTIVE_RPC" --ether 2>/dev/null || echo "  查询失败（可能需要等待 1-2 分钟）"
