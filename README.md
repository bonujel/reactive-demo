# Reactive Network 跨链事件与回调合约

## 项目概述

这是一个基于 Reactive Network 的跨链事件系统示例，演示如何在一个链上触发事件，并通过 Reactive Smart Contracts (RSCs) 在另一链上执行回调。

## 架构说明

### 三合约模式

1. **OriginContract** (事件源合约)
   - 部署在源链（如 Sepolia）
   - 接收 ETH 并触发 `Received` 事件
   - 事件包含：origin、sender、value

2. **ReactiveContract** (监听合约)
   - 部署在 Reactive Network
   - 订阅源链上的 `Received` 事件
   - 当 value >= 0.001 ETH 时触发回调

3. **DestinationContract** (回调接收合约)
   - 部署在目标链（如 Sepolia）
   - 接收来自 Reactive Network 的回调
   - 触发 `CallbackReceived` 事件

## 部署步骤

### 前置准备

1. 安装 Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. 配置环境变量（复制 `.env.example` 为 `.env` 并填写）

3. 获取测试币
   - Sepolia ETH: https://sepoliafaucet.com/
   - Reactive REACT: 发送 SepETH 到 `0x9b9BB25f1A81078C544C829c5EB7822d747Cf434`（1:100 比例）

### 部署流程

#### 步骤 1: 部署 Origin Contract

```bash
source .env
forge create --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY \
  src/OriginContract.sol:OriginContract
```

记录部署地址为 `ORIGIN_ADDR`

#### 步骤 2: 部署 Destination Contract

```bash
forge create --rpc-url $DESTINATION_RPC --private-key $DESTINATION_PRIVATE_KEY \
  src/DestinationContract.sol:DestinationContract \
  --value 0.02ether \
  --constructor-args $DESTINATION_CALLBACK_PROXY_ADDR
```

记录部署地址为 `CALLBACK_ADDR`

#### 步骤 3: 部署 Reactive Contract

```bash
# Received 事件的 topic_0
TOPIC_0=0x8cabf31d2b1b11ba52dbb302817a3c9c83e4b2a5194d35121ab1354d69f6a4cb

forge create --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY \
  src/ReactiveContract.sol:ReactiveContract \
  --value 0.1ether \
  --constructor-args $SYSTEM_CONTRACT_ADDR $ORIGIN_CHAIN_ID $DESTINATION_CHAIN_ID $ORIGIN_ADDR $TOPIC_0 $CALLBACK_ADDR
```

#### 步骤 4: 测试跨链回调

```bash
cast send $ORIGIN_ADDR --rpc-url $ORIGIN_RPC --private-key $ORIGIN_PRIVATE_KEY --value 0.001ether
```

## 验证结果

1. 在源链区块浏览器查看 `Received` 事件
2. 在目标链区块浏览器查看 `CallbackReceived` 事件
3. 确认跨链回调成功执行

## 关键参数说明

- **SYSTEM_CONTRACT_ADDR**: Reactive Network 系统合约地址
- **DESTINATION_CALLBACK_PROXY_ADDR**: 目标链回调代理地址
- **ORIGIN_CHAIN_ID / DESTINATION_CHAIN_ID**: 链 ID（参考 Reactive 文档）
- **topic_0**: 事件签名的 keccak256 哈希值

## 参考资源

- [Reactive Network 文档](https://dev.reactive.network/)
- [官方示例仓库](https://github.com/Reactive-Network/reactive-smart-contract-demos)
- [Chainlist](https://chainlist.org/)
