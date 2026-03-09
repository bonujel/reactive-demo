# Reactive Network 跨链事件与回调合约 - 提交文档

## 项目信息

- **项目名称**: Reactive Network 跨链事件系统
- **作者**: [bonujel]
- **日期**: [2026-03-09]

## 合约部署信息

### 1. Origin Contract (事件源合约)
- **合约地址**: `0xAC4928eEF4B7D31Cf15b39Cd3cAe1aA476209f47`
- **部署链**: Sepolia Testnet (Chain ID: 11155111)
- **部署交易**: [查看部署交易]
- **区块浏览器**: https://sepolia.etherscan.io/address/0xAC4928eEF4B7D31Cf15b39Cd3cAe1aA476209f47

### 2. Destination Contract (回调接收合约)
- **合约地址**: `0xD56bdc8080E22DB9B515eAd49bCF9fE8329a6cd2`
- **部署链**: Sepolia Testnet (Chain ID: 11155111)
- **部署交易**: [查看部署交易]
- **区块浏览器**: https://sepolia.etherscan.io/address/0xD56bdc8080E22DB9B515eAd49bCF9fE8329a6cd2

### 3. Reactive Contract (监听合约)
- **合约地址**: `0x02C33C6BBe040bA6cf396a88F27CF71044D91d02`
- **部署链**: Reactive Lasna Testnet (Chain ID: 5318007)
- **部署交易**: [查看部署交易]
- **区块浏览器**: https://lasna.reactscan.net/address/0x02C33C6BBe040bA6cf396a88F27CF71044D91d02

## 测试结果

### 触发交易
- **交易哈希**: `0x803e5150fa9f0f920a4c6059e0bd89aac903daede64b8e6b9b69de239e6f4c8f`
- **发送金额**: 0.001 ETH
- **区块浏览器**: https://sepolia.etherscan.io/tx/0x803e5150fa9f0f920a4c6059e0bd89aac903daede64b8e6b9b69de239e6f4c8f

### 事件验证

#### 1. Received 事件 (源链)
- **事件名称**: `Received(address indexed origin, address indexed sender, uint256 indexed value)`
- **事件日志**: [等待 30-60 秒后查看]
- **验证链接**: https://sepolia.etherscan.io/address/0xAC4928eEF4B7D31Cf15b39Cd3cAe1aA476209f47#events

#### 2. CallbackReceived 事件 (目标链)
- **事件名称**: `CallbackReceived(address indexed origin, address indexed sender, address indexed reactive_sender)`
- **事件日志**: [等待 30-60 秒后查看]
- **验证链接**: https://sepolia.etherscan.io/address/0xD56bdc8080E22DB9B515eAd49bCF9fE8329a6cd2#events

## 架构说明

### 工作流程
```
1. 用户发送 0.001 ETH 到 Origin Contract
   ↓
2. Origin Contract 触发 Received 事件
   ↓
3. Reactive Contract 监听到事件（在 Reactive Network 上）
   ↓
4. Reactive Contract 检查 value >= 0.001 ETH
   ↓
5. Reactive Contract 发出 Callback 事件
   ↓
6. Destination Contract 接收回调并触发 CallbackReceived 事件
```

### 关键技术点

1. **事件订阅机制**
   - 使用 `service.subscribe()` 订阅特定链上的事件
   - 通过 topic_0 识别事件类型

2. **条件触发**
   - `react()` 函数检查事件参数
   - 满足条件时发出跨链回调

3. **安全验证**
   - `authorizedSenderOnly` 修饰符确保只接受授权发送者
   - `rvmIdOnly` 修饰符验证来自 Reactive Network

## 代码仓库

- **GitHub**: [填写仓库链接]
- **分支**: main
- **提交**: [填写最新提交哈希]

## 参考资源

- [Reactive Network 官方文档](https://dev.reactive.network/)
- [官方示例仓库](https://github.com/Reactive-Network/reactive-smart-contract-demos)
- [Sepolia 测试网水龙头](https://sepoliafaucet.com/)
