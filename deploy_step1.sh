#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 加载环境变量
export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Reactive Network 分步部署${NC}"
echo -e "${BLUE}========================================${NC}"

# 步骤 1: 部署 Origin Contract
echo -e "\n${GREEN}步骤 1: 部署 Origin Contract 到 Sepolia...${NC}"
ORIGIN_OUTPUT=$(forge create --rpc-url "$ORIGIN_RPC" --private-key "$ORIGIN_PRIVATE_KEY" \
  src/OriginContract.sol:OriginContract 2>&1)

if [ $? -eq 0 ]; then
    ORIGIN_ADDR=$(echo "$ORIGIN_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
    echo -e "${GREEN}✓ Origin Contract 部署成功${NC}"
    echo -e "  地址: ${BLUE}$ORIGIN_ADDR${NC}"

    # 保存到 .env
    sed -i "s|^ORIGIN_ADDR=.*|ORIGIN_ADDR=$ORIGIN_ADDR|" .env
else
    echo -e "${RED}✗ Origin Contract 部署失败${NC}"
    echo "$ORIGIN_OUTPUT"
    exit 1
fi

# 步骤 2: 部署 Destination Contract
echo -e "\n${GREEN}步骤 2: 部署 Destination Contract 到 Sepolia...${NC}"
DEST_OUTPUT=$(forge create --rpc-url "$DESTINATION_RPC" --private-key "$DESTINATION_PRIVATE_KEY" \
  src/DestinationContract.sol:DestinationContract \
  --value 0.02ether \
  --constructor-args "$DESTINATION_CALLBACK_PROXY_ADDR" 2>&1)

if [ $? -eq 0 ]; then
    CALLBACK_ADDR=$(echo "$DEST_OUTPUT" | grep "Deployed to:" | awk '{print $3}')
    echo -e "${GREEN}✓ Destination Contract 部署成功${NC}"
    echo -e "  地址: ${BLUE}$CALLBACK_ADDR${NC}"

    # 保存到 .env
    sed -i "s|^CALLBACK_ADDR=.*|CALLBACK_ADDR=$CALLBACK_ADDR|" .env
else
    echo -e "${RED}✗ Destination Contract 部署失败${NC}"
    echo "$DEST_OUTPUT"
    exit 1
fi

# 输出部署摘要
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  部署摘要（第 1 阶段）${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Origin Contract:      ${GREEN}$ORIGIN_ADDR${NC}"
echo -e "Destination Contract: ${GREEN}$CALLBACK_ADDR${NC}"
echo -e ""
echo -e "${YELLOW}注意：Reactive Contract 需要等 Reactive RPC 恢复后再部署${NC}"
echo -e "${YELLOW}运行 ./deploy_reactive.sh 来完成部署${NC}"
