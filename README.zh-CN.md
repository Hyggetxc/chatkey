# ChatKey

[![GitHub Release](https://img.shields.io/github/v/release/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/releases)
[![GitHub Stars](https://img.shields.io/github/stars/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/issues)

ChatKey 是一个轻量级 macOS 菜单栏应用，用来统一不同应用里的聊天输入习惯。

它只专注一件事：

- 不同聊天应用对 `Return` 等快捷键的行为不一致
- ChatKey 按应用帮你保持输入习惯一致
- 整体保持本地化、简单、易理解

## 语言

- [English](./README.md)
- [简体中文](./README.zh-CN.md)

## 下载

- 最新发布： [GitHub Releases](https://github.com/Hyggetxc/chatkey/releases)
- 当前预发布： [v0.1.0-dev](https://github.com/Hyggetxc/chatkey/releases/tag/v0.1.0-dev)

## 快速开始

1. 在 [Releases](https://github.com/Hyggetxc/chatkey/releases) 下载最新 `.zip`。
2. 将 `ChatKey.app` 移动到 `/Applications`。
3. 首次启动后按提示授予辅助功能权限。
4. 打开设置页，按应用配置规则。

## 解决的痛点

- 帮你确保对话输入习惯始终一致：在 Codex、VS Code、IM 聊天软件等场景中，统一保持 `Return` 是换行、`Command + Return` 是发送消息。
- 按应用设置快捷键分散、维护成本高。
- 希望有一个本地化、轻量、低打扰的键位辅助工具，而不是重型全局改键器。

## 功能

- 菜单栏状态和快速控制
- 辅助功能权限引导
- 前台应用识别
- 按应用配置规则
- 预设聊天键位映射
- 自定义触发键 / 目标动作
- 本地 JSON 持久化
- 简体中文 / English 界面支持
- GitHub Releases 更新检查

## 仓库结构

- `Sources/ChatKey`：主 SwiftUI 应用代码
- `Tests/ChatKeyTests`：单元测试
- `scripts/`：本地构建和打包脚本
- `dist/`：本地构建产物

## 构建

1. 确保本机已安装 Xcode Command Line Tools。
2. 在仓库根目录执行：

```bash
swift build
swift test
```

如果要打出本地可运行的 app：

```bash
./scripts/build-local-app.sh
```

如果要快速覆盖本地最新包测试：

```bash
pkill -x ChatKey || true
rm -rf /Applications/ChatKey.app
cp -R './dist/ChatKey.app' /Applications/ChatKey.app
open /Applications/ChatKey.app
```

正式发布时，GitHub Actions 会先使用 Developer ID Application 证书签名，再执行 notarization 和 staple，然后才上传发布包。这个流程需要在仓库的 Secrets 里配置好对应的签名和公证凭据。

## 常见问题

- 如果 macOS 提示安全验证，先右键 `ChatKey.app` -> `打开` 一次，或使用已 notarize 的发布包。
- 如果菜单栏界面看起来还是旧版本，先执行 `pkill -x ChatKey || true`，再重新打开 `/Applications/ChatKey.app`。

## 使用

1. 启动应用。
2. 按提示授予辅助功能权限。
3. 如果需要，在菜单栏中启用 ChatKey。
4. 在设置页里创建或编辑每个应用的规则。
5. 想测试新版本时，从 GitHub Releases 下载。

## 隐私

- 规则和设置都保存在本地。
- ChatKey 不会上传你的配置。
- Release 产物只包含打包后的应用和校验文件。

## 支持

如果 ChatKey 帮你统一了聊天快捷键，欢迎点个 Star：

- [Star ChatKey](https://github.com/Hyggetxc/chatkey)
