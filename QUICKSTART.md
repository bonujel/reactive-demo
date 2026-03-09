# 快速开始指南

## 1. 环境准备

```bash
# 克隆或创建项目
cd demo1

# 安装依赖
forge install

# 复制环境配置
cp .env.example .env
```

## 2. 配置 .env 文件

编辑 `.env` 文件，填写以下信息：

```bash
# 获取 Sepolia RPC
# 推荐使用 Infura 或 Alchemy

# 获取私钥
# 从 MetaMask 导出私钥（测试账户）

# Reactive Network RPC（已预填）
REACTIVE_RPC=https://kopli-rpc.rkt.ink

# 系统合约地址（已预填）
SYSTEM_CONTRACT_ADDR=0x0000000000000000000000000000000000FFFFFF
DESTINATION_CALLBACK_PROXY_ADDR=0x33Bbb7D0a2F1029550B0e91f653c4055DC9F4Dd8
```

## 3. 获取测试币

### Sepolia ETH
- 访问: https://sepoliafaucet.com/
- 或: https://faucet.quicknode.com/ethereum/sepolia

### Reactive REACT
```bash
# 发送 SepETH 到 Reactive 水龙头（1:100 比例）
cast send 0x9b9BB25f1A81078C544C829c5EB7822d747Cf434 \
  --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY \
  --value 1ether

# 你将收到 100 REACT
```

## 4. 编译合约

```bash
forge build
```

## 5. 部署合约

```bash
# 使用自动化脚本
./deploy.sh

# 或手动部署
source .env

# 步骤 1: Origin
forge create --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY \
  src/OriginContract.sol:OriginContract

# 步骤 2: Destination
forge create --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY \
  src/DestinationContract.sol:DestinationContract \
  --value 0.02ether \
  --constructor-args $DESTINATION_CALLBACK_PROXY_ADDR

# 步骤 3: Reactive
TOPIC_0=0x8cabf31d2b1b11ba52dbb302817a3c9c83e4b2a5194d35121ab1354d69f6a4cb
forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY \
  src/ReactiveContract.sol:ReactiveContract \
  --value 0.1ether \
  --constructor-args $SYSTEM_CONTRACT_ADDR $ORIGIN_CHAIN_ID $DESTINATION_CHAIN_ID $ORIGIN_ADDR $TOPIC_0 $CALLBACK_ADDR
```

## 6. 测试跨链回调

```bash
# 使用自动化脚本
./test.sh

# 或手动测试
cast send $ORIGIN_ADDR \
  --rpc-url $ORIGIN_RPC \
  --private-key $ORIGIN_PRIVATE_KEY \
  --value 0.001ether
```

## 7. 验证结果

### 查看源链事件
```bash
# 在 Sepolia Etherscan 查看
https://sepolia.etherscan.io/address/[ORIGIN_ADDR]#events
```

### 查看目标链事件
```bash
# 在 Sepolia Etherscan 查看
https://sepolia.etherscan.io/address/[CALLBACK_ADDR]#events
```

### 查看 Reactive Contract
```bash
# 在 Reactive Scan 查看
https://kopli.reactscan.net/address/[REACTIVE_ADDR]
```

## 常见问题

### Q: 部署失败 "insufficient funds"
A: 确保账户有足够的测试币（Sepolia ETH 和 REACT）

### Q: 回调没有触发
A:
1. 检查发送金额是否 >= 0.001 ETH
2. 等待 30-60 秒让 Reactive Network 处理
3. 确认 Destination Contract 有足够余额（0.02 ETH）

### Q: 如何计算事件 topic_0
A:
```bash
cast keccak "Received(address,address,uint256)"
# 输出: 0x8cabf31d2b1b11ba52dbb302817a3c9c83e4b2a5194d35121ab1354d69f6a4cb
```

## 项目结构

```
demo1/
├── src/
│   ├── OriginContract.sol       # 事件源合约
│   ├── DestinationContract.sol  # 回调接收合约
│   └── ReactiveContract.sol     # Reactive 监听合约
├── lib/                         # 依赖库
├── deploy.sh                    # 自动化部署脚本
├── test.sh                      # 自动化测试脚本
├── .env.example                 # 环境配置模板
├── README.md                    # 项目文档
├── QUICKSTART.md               # 本文件
└── SUBMISSION.md               # 提交模板
```

## 下一步

- 修改 `ReactiveContract.sol` 中的触发条件
- 添加更复杂的回调逻辑
- 尝试监听其他链上的事件
- 探索 Reactive Network 的其他功能
