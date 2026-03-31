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

## 解决的痛点

- 帮你确保对话输入习惯始终一致：在 Codex、VS Code、IM 聊天软件等场景中，统一保持 `Return` 是换行、`Command + Return` 是发送消息。
- 按应用设置快捷键分散、维护成本高。
- 希望有一个本地化、轻量、低打扰的键位辅助工具，而不是重型全局改键器。

## 下载

- 最新发布： [GitHub Releases](https://github.com/Hyggetxc/chatkey/releases)
- 终端下载并安装（使用 GitHub CLI）：

```bash
TAG=$(gh release list --repo Hyggetxc/chatkey --limit 1 --json tagName -q '.[0].tagName')
gh release download "$TAG" --repo Hyggetxc/chatkey --pattern "ChatKey-${TAG}.zip" --pattern "ChatKey-${TAG}.zip.sha256" --clobber
ditto -x -k "ChatKey-${TAG}.zip" .
rm -rf /Applications/ChatKey.app
mv ChatKey.app /Applications/ChatKey.app
open /Applications/ChatKey.app
```

## 使用

1. 启动应用。
2. 按提示授予辅助功能权限。
3. 如果需要，在菜单栏中启用 ChatKey。
4. 在设置页里创建或编辑每个应用的规则。
5. 想测试新版本时，从 GitHub Releases 下载。

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

## 常见问题

### 隐私提示流程（首次打开）

1. 如果出现“未打开 ChatKey”的安全提示，先点击 `完成`（不要点“移到废纸篓”）。
2. 在 Finder 中找到 `ChatKey.app`，右键选择 `打开`。
3. 在二次确认弹窗里再次点击 `打开`。
4. 如仍被拦截，前往 `系统设置 -> 隐私与安全性`，点击 `仍要打开`。

### 权限流程（辅助功能）

1. 首次启动后，按提示进入辅助功能授权页。
2. 打开 `系统设置 -> 隐私与安全性 -> 辅助功能`。
3. 在列表里启用 `ChatKey` 开关。
4. 回到 ChatKey，点击刷新状态，确认显示为已授权。

## 隐私

- 规则和设置都保存在本地。
- ChatKey 不会上传你的配置。
- Release 产物只包含打包后的应用和校验文件。

## 支持

如果 ChatKey 帮你统一了聊天快捷键，欢迎点个 Star（网页或终端都可以）：

- 网页： [Star ChatKey](https://github.com/Hyggetxc/chatkey/stargazers)
- 终端： `gh repo star Hyggetxc/chatkey`
