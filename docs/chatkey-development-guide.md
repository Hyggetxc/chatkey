# ChatKey 开发规范（可复用）

## 1. 文档目标

这份文档用于沉淀 ChatKey 的开发约束、常见问题、验证流程和后续扩展原则。

适用场景：

- 新功能开发
- Bug 修复
- 环境初始化
- 发布前检查
- 后续协作复用

## 2. GSD 开发流程

### Goal

每次开发都应先明确：

- 这次改的是哪条产品链路
- 是否影响按键监听核心链路
- 是否影响规则模型、权限、更新、国际化

### Scope

默认一次只做一层主目标：

- 先改模型或服务
- 再接 UI
- 再补测试
- 最后更新文档

不要把“架构大改 + UI 大改 + 发布流程”混在同一次提交里。

### Done

一个开发任务算完成，至少要满足：

- `swift build` 通过
- `swift test` 通过
- 关键核心加上必要注释
- 技术方案文档已更新
- 如果改了开发方式或踩了新坑，开发规范也同步更新

## 3. 仓库结构约定

当前项目目录：

- `Sources/ChatKey`：主应用源码
- `Tests/ChatKeyTests`：单元测试
- `docs/chatkey-prd.md`：产品规划
- `docs/chatkey-technical-design.md`：技术设计
- `docs/chatkey-development-guide.md`：开发规范

约定：

- UI 视图尽量按职责拆分，不把过大的 SwiftUI 视图塞进同一个文件
- 与系统事件相关的逻辑放在独立服务中，不直接混入 View
- 可测试的纯逻辑优先抽离成纯函数或纯服务

## 4. 架构约束

### 4.1 单一运行时装配入口

运行时状态同步统一从 `AppContainer` 进入。

不要在以下位置直接拉取 UI 状态：

- `EventTapService`
- `ActionDispatcher`
- `KeyEventRouting`

原因：

- EventTap 回调是高频路径
- 直接访问 `@MainActor` / SwiftUI 状态容易引发并发问题
- 运行时快照比跨层读取更稳定

### 4.2 EventTap 回调必须保持轻量

回调里只做：

- 解析按键
- 读取快照
- 计算是否命中
- 派发动作
- 记录最近一次诊断

不要在回调里做：

- 文件 IO
- 网络请求
- 复杂 UI 更新
- 依赖异步等待的逻辑

### 4.3 路由逻辑必须可测试

按键命中逻辑统一放在 `KeyEventRouting`。

约定：

- `KeyEventRouting` 不依赖 View
- `KeyEventRouting` 不依赖持久化
- 输入是事件快照 + 规则快照
- 输出是 `RoutingDecision`

这样后续扩展更多快捷键时，不需要先跑真实 EventTap 才能验证行为。

### 4.4 合成事件必须带标记

`ActionDispatcher` 派发的事件必须打上标记。

原因：

- 防止 EventTap 捕获到自己发出的事件
- 避免无限递归或双重发送

这是核心安全规则，不能省略。

## 5. SwiftUI 开发规则

### 5.1 视图必须控制体积

经验结论：

- 过大的 SwiftUI 视图在当前工具链上可能触发编译器崩溃
- 设置页已经验证过这个问题

规范：

- 一个文件内的主视图职责单一
- 表单区块拆成独立 View
- 复杂 `Binding` 尽量展开成显式闭包

### 5.2 UI 不直接持有系统底层逻辑

View 只负责：

- 展示状态
- 触发操作
- 编辑配置

不要在 View 里直接：

- 创建 Event Tap
- 组装 CGEvent
- 处理权限判断分支

## 6. 注释规范

默认给关键核心代码加注释，重点写“为什么”而不是“这行做了什么”。

必须写注释的地方：

- 系统权限相关
- EventTap 生命周期管理
- 合成事件标记机制
- 规则命中策略
- 原子写入或缓存策略
- 已知会踩坑的并发处理

不建议写的注释：

- 变量名已能表达的废话注释
- 与代码明显重复的描述

## 7. 测试规范

每次新增核心行为，优先补单元测试。

优先测试这些层：

- `KeyEventRouting`
- 默认规则生成
- 默认设置生成
- 规则命中逻辑

不强制在第一时间自动化的内容：

- 真实 EventTap 行为
- 真正的系统授权弹窗
- App Store 更新链路

这类系统级行为先通过手工验证覆盖。

## 8. 文档更新规范

当以下内容发生变化时，必须同步更新技术文档：

- 新模块
- 新数据模型
- 新运行时链路
- 监听器行为变化
- 更新机制变化

当以下内容发生变化时，必须同步更新开发规范：

- 新环境坑
- 新编译器坑
- 新的团队协作约定
- 新的发布检查步骤

## 9. 环境要求

开发 ChatKey 的最低要求：

- 完整版 `Xcode`
- 完成首次启动初始化
- 已同意 Xcode license
- 可正常执行 `swift build`
- 可正常执行 `swift test`

## 10. 已验证过的问题与处理方式

### 10.1 App Store 下载 Xcode 失败

现象：

- 点击“获取”后转一圈又回到“获取”

高概率原因：

- `Clash` / VPN / 代理的 `TUN` 模式干扰 App Store 账户校验链路

建议处理：

- 临时关闭代理 / VPN
- 再执行 Xcode 下载

### 10.2 Xcode 已安装但无法构建

现象：

- `swift build` 提示未同意 Xcode license

处理：

- 打开一次 Xcode 完成初始化
- 或执行 `xcodebuild -runFirstLaunch`

### 10.3 SwiftPM / clang 缓存写入失败

现象：

- `ModuleCache` 或 `org.swift.swiftpm` 不可写

处理：

- 补齐用户级缓存目录
- 在需要时于沙箱外执行 `swift build` / `swift test`

### 10.4 SwiftUI 视图过大导致编译器崩溃

现象：

- `swift-frontend` 报 `SmallVector unable to grow`

处理：

- 拆分大视图文件
- 降低单个 View 的泛型复杂度
- 对复杂 `Binding` 使用显式闭包

### 10.5 Swift 6 并发检查更严格

现象：

- `AppKit` / `ApplicationServices` 常量、通知对象、非 Sendable 类型报错

处理：

- 必要时使用 `@preconcurrency import`
- 不跨 actor 直接传系统对象
- 回调里尽量先提取轻量值，再切回主线程

### 10.6 辅助功能已勾选，但应用内仍显示未授权

现象：

- 系统设置里已经把 `ChatKey` 加到“辅助功能”
- 应用内 `Accessibility` 仍显示未授权
- 监听器状态一直停在缺少权限

高概率原因：

- 本地测试包使用了 ad-hoc 签名
- 如果 designated requirement 退化成纯 `cdhash`，macOS TCC 会把每次重建都视为一个新身份
- 这样系统设置里虽然看起来还是同一个 `ChatKey`，但当前运行进程与旧授权记录并不匹配

处理：

- 使用带稳定 designated requirement 的本地打包脚本重新构建
- 替换 `/Applications/ChatKey.app`
- 清理旧的辅助功能授权记录后重新授权一次

建议命令：

```bash
tccutil reset Accessibility com.lemon.chatkey.dev
```

说明：

- 这一步会删除 ChatKey 旧的辅助功能授权，需要重新勾选一次
- 只在从旧的 `cdhash` 身份切换到新的稳定身份构建时需要重点执行

### 10.7 GitHub Release 发布流程

目的：

- 让测试用户可以直接从 GitHub Releases 下载 `ChatKey.app.zip`
- 让 tag 推送自动生成发布资产，减少手工打包失误

当前约定：

- `v*` tag 会触发 GitHub Actions release workflow
- workflow 会构建 macOS app bundle
- workflow 会打包 `dist/ChatKey.app` 并上传 zip 与 SHA256 文件
- Release 资产使用稳定 bundle id，避免发布版和本地开发版互相干扰

本地验证方式：

```bash
APP_VERSION=0.1.0-dev \
BUILD_NUMBER=$(date +%Y%m%d%H%M%S) \
BUNDLE_ID=com.hyggetxc.chatkey \
./scripts/build-local-app.sh
```

发布前建议确认：

- tag 名称和 `APP_VERSION` 对得上
- Release 页面里能看到 zip 资产
- 用户下载后可直接双击运行

## 11. 后续扩展建议

下一阶段优先级建议：

1. 显式 Secure Input 检测
2. 更完整的诊断面板
3. 点击发送按钮模式
4. 更多按键组合支持
5. GitHub Releases 仓库正式配置

## 12. 发布前检查清单

发布前至少确认：

- `swift build`
- `swift test`
- 权限弹窗能正常出现
- 菜单栏能显示当前监听状态
- 至少在一个真实 IM 上验证：
  - `Return`
  - `Command + Return`
  - 规则切换
  - 总开关启停

如果改动涉及文档、架构或运行时链路，再确认：

- `chatkey-technical-design.md` 已更新
- `chatkey-development-guide.md` 已更新

## 13. 本地测试版安装流程

如果要给当前机器安装一个可双击的测试版：

1. 在项目根目录执行：

```bash
./scripts/build-local-app.sh
```

2. 脚本会输出本地测试包路径：

- `dist/ChatKey.app`

3. 验证方式：

- 直接双击运行
- 或拖到 `/Applications` 后运行

4. 首次验证时需要额外确认：

- 系统已授予 `Accessibility` 权限
- 菜单栏已出现 `ChatKey`
- 在真实 IM 里测试 `Return` 和 `Command + Return`

补充：

- 这个脚本会做 release 构建
- 会生成最小可用的 `.app` 包
- 会使用 ad-hoc 签名，便于本机测试
- 会显式写入稳定的 designated requirement，避免辅助功能授权被每次重建打散
- 如果你之前已经安装过旧测试包，建议先执行一次 `tccutil reset Accessibility com.lemon.chatkey.dev` 再重新授权
