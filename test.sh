#!/bin/bash

# 加载环境变量
source .env

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Reactive Network 测试脚本${NC}"
echo -e "${BLUE}========================================${NC}"

# 检查必要的环境变量
if [ -z "$ORIGIN_ADDR" ] || [ -z "$CALLBACK_ADDR" ] || [ -z "$REACTIVE_ADDR" ]; then
    echo -e "${RED}错误: 请先运行 deploy.sh 部署合约${NC}"
    exit 1
fi

echo -e "\n${BLUE}合约地址:${NC}"
echo -e "Origin:      ${GREEN}$ORIGIN_ADDR${NC}"
echo -e "Destination: ${GREEN}$CALLBACK_ADDR${NC}"
echo -e "Reactive:    ${GREEN}$REACTIVE_ADDR${NC}"

# 发送测试交易
echo -e "\n${YELLOW}发送 0.001 ETH 到 Origin Contract...${NC}"
TX_HASH=$(cast send $ORIGIN_ADDR \
  --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY \
  --value 0.001ether 2>&1 | grep "transactionHash" | awk '{print $2}')

if [ -z "$TX_HASH" ]; then
    echo -e "${RED}✗ 交易发送失败${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 交易已发送${NC}"
echo -e "  交易哈希: ${BLUE}$TX_HASH${NC}"

# 获取区块浏览器链接
if [ "$ORIGIN_CHAIN_ID" == "11155111" ]; then
    EXPLORER="https://sepolia.etherscan.io"
elif [ "$ORIGIN_CHAIN_ID" == "1" ]; then
    EXPLORER="https://etherscan.io"
else
    EXPLORER="https://etherscan.io"
fi

echo -e "\n${BLUE}查看交易详情:${NC}"
echo -e "${EXPLORER}/tx/$TX_HASH"

echo -e "\n${YELLOW}等待 Reactive Network 处理...${NC}"
echo -e "${BLUE}预计等待时间: 30-60 秒${NC}"

echo -e "\n${BLUE}验证步骤:${NC}"
echo -e "1. 在源链查看 Received 事件: ${EXPLORER}/address/$ORIGIN_ADDR#events"
echo -e "2. 在目标链查看 CallbackReceived 事件: ${EXPLORER}/address/$CALLBACK_ADDR#events"
echo -e "3. 确认跨链回调成功执行"

echo -e "\n${GREEN}✓ 测试完成！${NC}"
