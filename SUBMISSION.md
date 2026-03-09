# Reactive Network 跨链事件与回调合约 - 提交文档

## 项目信息

- **项目名称**: Reactive Network 跨链事件系统
- **作者**: [bonujel]
- **日期**: [2026-03-09]

## 合约部署信息

### 1. Origin Contract (事件源合约)
- **合约地址**: `0xAC4928eEF4B7D31Cf15b39Cd3cAe1aA476209f47`
- **部署链**: Sepolia Testnet (Chain ID: 11155111)
- **区块浏览器**: https://sepolia.etherscan.io/address/0xAC4928eEF4B7D31Cf15b39Cd3cAe1aA476209f47

### 2. Destination Contract (回调接收合约)
- **合约地址**: `0x015D98D347917c9b664F3778Fea00Bf66aD0087D`
- **部署链**: Sepolia Testnet (Chain ID: 11155111)
- **部署交易**: `0x5f1f1692f3c68e80647ae5f896f370c696ef43c5bf5e8f829e46e807861b0ed4`
- **区块浏览器**: https://sepolia.etherscan.io/address/0x015D98D347917c9b664F3778Fea00Bf66aD0087D
- **回调代理地址**: `0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA` (Sepolia 官方)

### 3. Reactive Contract (监听合约)
- **合约地址**: `0xD1Fd90Cc2f578fe42A70726792AC84ef8d21Ffcc`
- **部署链**: Reactive Lasna Testnet (Chain ID: 5318007)
- **部署交易**: `0x3676a669f926aeabbe3de9219db0ddc612bf95f5b2c029a0267e1e00620208a3`
- **区块浏览器**: https://lasna.reactscan.net/address/0xD1Fd90Cc2f578fe42A70726792AC84ef8d21Ffcc

## 测试结果

### 触发交易
- **交易哈希**: `0xd6f85235cd8bfd56627cb83d5598a2d10a15a3691f233b4398ef343d1f6afc83`
- **发送金额**: 0.001 ETH
- **区块浏览器**: https://sepolia.etherscan.io/tx/0xd6f85235cd8bfd56627cb83d5598a2d10a15a3691f233b4398ef343d1f6afc83

### 事件验证

#### 1. Received 事件 (源链)
- **事件名称**: `Received(address indexed origin, address indexed sender, uint256 indexed value)`
- **验证链接**: https://sepolia.etherscan.io/address/0xAC4928eEF4B7D31Cf15b39Cd3cAe1aA476209f47#events
- **状态**: ✅ 已触发

#### 2. CallbackReceived 事件 (目标链)
- **事件名称**: `CallbackReceived(address indexed origin, address indexed sender, address indexed reactive_sender)`
- **验证链接**: https://sepolia.etherscan.io/address/0x015D98D347917c9b664F3778Fea00Bf66aD0087D#events
- **状态**: ✅ 成功触发
- **回调交易**: `0x5e7401a4c33189f2942b9619159bbbd932fab0f3eacc8c44dac67a065270eead`
- **区块号**: 10412553

## 更新记录

### 2026-03-09 - 成功完成跨链回调
- **问题解决**: 使用正确的 Sepolia 回调代理地址 `0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA`
- **重新部署**:
  - Destination Contract: `0x015D98D347917c9b664F3778Fea00Bf66aD0087D`
  - Reactive Contract: `0xD1Fd90Cc2f578fe42A70726792AC84ef8d21Ffcc`
- **验证结果**: CallbackReceived 事件成功触发，跨链回调完整实现

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

- **GitHub**: https://github.com/bonujel/reactive-demo
- **分支**: main
- **提交**: a14bef368911bd08ca7fb00bd3f6f0996a50dbf9

## 参考资源

- [Reactive Network 官方文档](https://dev.reactive.network/)
- [官方示例仓库](https://github.com/Reactive-Network/reactive-smart-contract-demos)
- [Sepolia 测试网水龙头](https://sepoliafaucet.com/)
