# 开发规约与最佳实践

> **适用范围**：基于 Flutter + Rust（`flutter_rust_bridge`）构建的跨平台应用。核心业务逻辑在 Rust 侧，Flutter 作为纯展示层，通过 Stream 响应状态变化。

---

## 项目架构概览

### 技术栈

| 层级 | 模块 | 职责 |
|------|------|------|
| UI 层 | Flutter / Dart | 纯展示，响应式渲染 |
| 桥接层 | `flutter_rust_bridge` | Dart ↔ Rust 同步/异步调用 |
| 业务层 | `rust_wallet` | 核心业务逻辑与状态管理 |
| 安全层 | `rust_secret` | PIN 码、加解密等密码学操作 |

### 目录结构
```
lib/
  src/
    widgets/          # UI 组件、页面、业务视图
    rust/             # flutter_rust_bridge 自动生成的桥接代码
    utils/            # 全局工具类（logger.dart, bridge_helper.dart 等）

rust/                 # 桥接协议层，导出 API 供 Dart 调用

rust_wallet/
  src/managers/       # 业务管理器核心逻辑
  locales/            # 多语言（i18n）资源文件

rust_secret/          # 安全与密码学底层实现
```

---

## 开发规范

### 1. 编码前置要求

- **先确认再实现**：遇到逻辑不明确的问题，必须先厘清思路再开始编码。
- **单一职责（SRP）**：每个模块、文件、函数只负责单一职责，代码放在最合适的目录中。
- **高内聚低耦合**：保持清晰的抽象层次，减少模块间依赖，提升可维护性与复用性。

### 2. 异步通信（Dart ↔ Rust）

Dart 通过 Bridge 调用 Rust 时，若返回类型为 `Future<BridgeSubscription>`，**必须**使用 `convertSubscriptionToStream` 转换为 `Stream`，供 UI 层响应式消费。
```dart
// 参考实现
// lib/src/utils/bridge_helper.dart
final stream = await convertSubscriptionToStream(subscription);
```

### 3. UI 开发

- **响应式渲染**：使用 `StreamBuilder` 消费 `Stream` 数据，驱动 UI 更新。
- **禁止硬编码文本**：所有用户可见文本必须走 i18n，参考：
  - 组件封装：`lib/src/widgets/localized_text.dart`
  - 资源文件：`rust_wallet/locales/`

### 4. 日志规范

在关键业务路径与异常处理处添加日志，确保问题可追踪。

| 语言 | 工具 |
|------|------|
| Dart | `lib/src/utils/logger.dart` |
| Rust | `log` crate |

### 5. 提交前检查

| 检查项 | 要求 |
|--------|------|
| 编译 | 项目必须成功编译，否则不得提交 |
| 单元测试 | 所有现有测试必须通过；若修改导致测试失败，需同步修复 |
|`agent.md` 文件|检查 `agent.md` 文件合理性，如果需要，则对其内容进行增加、修改或删除，以确保该文件始终准确反映项目的最新状态与规范|

---

## 快速参考

| 场景 | 参考文件 |
|------|----------|
| Dart↔Rust 桥接订阅转 Stream | `bridge_helper.dart` |
| UI 多语言文本组件 | `localized_text.dart` |
| 多语言资源 | `rust_wallet/locales/` |
| Dart 日志 | `logger.dart` |
| Rust 日志 | `log` crate |