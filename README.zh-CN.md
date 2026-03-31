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
