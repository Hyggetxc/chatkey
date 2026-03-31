# ChatKey

[![GitHub Release](https://img.shields.io/github/v/release/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/releases)
[![GitHub Stars](https://img.shields.io/github/stars/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/issues)

ChatKey is a lightweight macOS menu bar app for keeping chat input habits consistent across apps (current release ZIP is about 453 KB, under 1 MB).

It focuses on one narrow problem:

- `Return` and related shortcuts behave differently in different chat apps
- ChatKey keeps those shortcuts aligned per app
- The app stays local, simple, and easy to understand

## Translations

- [English](./README.md)
- [简体中文](./README.zh-CN.md)

## Pain Points

- Keep your input habit consistent across Codex, VS Code, and IM chat tools: `Return` always inserts a new line, and `Command + Return` always sends the message.
- Keyboard habits break when you switch between tools (WeChat, Slack, web chats, AI apps).
- Per-app shortcut setup is scattered and hard to maintain.
- Users want a local-only, lightweight helper instead of a heavy system remapper.

## Download

- Latest release: [GitHub Releases](https://github.com/Hyggetxc/chatkey/releases)
- Install from terminal (GitHub CLI):

```bash
TAG=$(gh release list --repo Hyggetxc/chatkey --limit 1 --json tagName -q '.[0].tagName')
gh release download "$TAG" --repo Hyggetxc/chatkey --pattern "ChatKey-${TAG}.zip" --pattern "ChatKey-${TAG}.zip.sha256" --clobber
ditto -x -k "ChatKey-${TAG}.zip" .
rm -rf /Applications/ChatKey.app
mv ChatKey.app /Applications/ChatKey.app
open /Applications/ChatKey.app
```

## Usage

1. Launch the app.
2. Grant Accessibility permission when prompted.
3. Enable ChatKey from the menu bar if needed.
4. Create or edit per-app rules in Settings.
5. Download releases from GitHub when you want to test a newer build.

## Features

- Menu bar status and quick controls
- Accessibility permission guidance
- Frontmost app detection
- Per-app rules
- Preset chat key mappings
- Custom trigger/output mappings
- Local JSON persistence
- Simplified Chinese / English UI support
- GitHub Releases update checks

## Troubleshooting

### Privacy Prompt Flow (First Launch)

1. If macOS shows “ChatKey can’t be opened”, click `Done` first (do not click “Move to Trash”).
2. Locate `ChatKey.app` in Finder, right-click, and choose `Open`.
3. In the second confirmation dialog, click `Open` again.
4. If it is still blocked, go to `System Settings -> Privacy & Security` and click `Open Anyway`.

### Permission Flow (Accessibility)

1. On first launch, follow the in-app prompt to open Accessibility settings.
2. Go to `System Settings -> Privacy & Security -> Accessibility`.
3. Enable `ChatKey` in the list.
4. Return to ChatKey and refresh status until it shows as authorized.

## Privacy

- Rules and settings are stored locally on your machine.
- ChatKey does not upload your configuration.
- Release assets are only the packaged app and checksum files.

## Support

If ChatKey helps you keep chat shortcuts consistent, please consider starring the repository:

- Web: [Star ChatKey](https://github.com/Hyggetxc/chatkey/stargazers)
- Terminal: `gh repo star Hyggetxc/chatkey`
