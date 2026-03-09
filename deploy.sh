#!/bin/bash

# 加载环境变量
source .env

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Reactive Network 部署脚本${NC}"
echo -e "${BLUE}========================================${NC}"

# 步骤 1: 部署 Origin Contract
echo -e "\n${GREEN}步骤 1: 部署 Origin Contract...${NC}"
ORIGIN_OUTPUT=$(forge create --broadcast --rpc-url "$ORIGIN_RPC" --private-key "$ORIGIN_PRIVATE_KEY" \
  src/OriginContract.sol:OriginContract 2>&1)

if [ $? -eq 0 ]; then
    ORIGIN_ADDR=$(echo "$ORIGIN_OUTPUT" | grep -oP 'Deployed to: \K0x[a-fA-F0-9]{40}')
    echo -e "${GREEN}✓ Origin Contract 部署成功${NC}"
    echo -e "  地址: ${BLUE}$ORIGIN_ADDR${NC}"
else
    echo -e "${RED}✗ Origin Contract 部署失败${NC}"
    echo "$ORIGIN_OUTPUT"
    exit 1
fi

# 步骤 2: 部署 Destination Contract
echo -e "\n${GREEN}步骤 2: 部署 Destination Contract...${NC}"
DEST_OUTPUT=$(forge create --broadcast --rpc-url "$DESTINATION_RPC" --private-key "$DESTINATION_PRIVATE_KEY" \
  src/DestinationContract.sol:DestinationContract \
  --value 0.02ether \
  --constructor-args "$DESTINATION_CALLBACK_PROXY_ADDR" 2>&1)

if [ $? -eq 0 ]; then
    CALLBACK_ADDR=$(echo "$DEST_OUTPUT" | grep -oP 'Deployed to: \K0x[a-fA-F0-9]{40}')
    echo -e "${GREEN}✓ Destination Contract 部署成功${NC}"
    echo -e "  地址: ${BLUE}$CALLBACK_ADDR${NC}"
else
    echo -e "${RED}✗ Destination Contract 部署失败${NC}"
    echo "$DEST_OUTPUT"
    exit 1
fi

# 步骤 3: 部署 Reactive Contract
echo -e "\n${GREEN}步骤 3: 部署 Reactive Contract...${NC}"
TOPIC_0="0x8cabf31d2b1b11ba52dbb302817a3c9c83e4b2a5194d35121ab1354d69f6a4cb"

REACTIVE_OUTPUT=$(forge create --broadcast --rpc-url "$REACTIVE_RPC" --private-key "$REACTIVE_PRIVATE_KEY" \
  src/ReactiveContract.sol:ReactiveContract \
  --value 0.1ether \
  --constructor-args "$SYSTEM_CONTRACT_ADDR" "$ORIGIN_CHAIN_ID" "$DESTINATION_CHAIN_ID" "$ORIGIN_ADDR" "$TOPIC_0" "$CALLBACK_ADDR" 2>&1)

if [ $? -eq 0 ]; then
    REACTIVE_ADDR=$(echo "$REACTIVE_OUTPUT" | grep -oP 'Deployed to: \K0x[a-fA-F0-9]{40}')
    echo -e "${GREEN}✓ Reactive Contract 部署成功${NC}"
    echo -e "  地址: ${BLUE}$REACTIVE_ADDR${NC}"
else
    echo -e "${RED}✗ Reactive Contract 部署失败${NC}"
    echo "$REACTIVE_OUTPUT"
    exit 1
fi

# 输出部署摘要
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}  部署摘要${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Origin Contract:      ${GREEN}$ORIGIN_ADDR${NC}"
echo -e "Destination Contract: ${GREEN}$CALLBACK_ADDR${NC}"
echo -e "Reactive Contract:    ${GREEN}$REACTIVE_ADDR${NC}"

# 保存地址到 .env
echo -e "\n${GREEN}保存地址到 .env 文件...${NC}"
sed -i "s/^ORIGIN_ADDR=.*/ORIGIN_ADDR=$ORIGIN_ADDR/" .env
sed -i "s/^CALLBACK_ADDR=.*/CALLBACK_ADDR=$CALLBACK_ADDR/" .env
sed -i "s/^REACTIVE_ADDR=.*/REACTIVE_ADDR=$REACTIVE_ADDR/" .env

echo -e "\n${GREEN}✓ 部署完成！${NC}"
echo -e "\n${BLUE}测试命令:${NC}"
echo -e "cast send $ORIGIN_ADDR --rpc-url \$ORIGIN_RPC --private-key \$ORIGIN_PRIVATE_KEY --value 0.001ether"
