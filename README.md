# ChatKey

[![GitHub Release](https://img.shields.io/github/v/release/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/releases)
[![GitHub Stars](https://img.shields.io/github/stars/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/Hyggetxc/chatkey?style=flat-square)](https://github.com/Hyggetxc/chatkey/issues)

ChatKey is a lightweight macOS menu bar app for keeping chat input habits consistent across apps.

It focuses on one narrow problem:

- `Return` and related shortcuts behave differently in different chat apps
- ChatKey keeps those shortcuts aligned per app
- The app stays local, simple, and easy to understand

## Translations

- [English](./README.md)
- [简体中文](./README.zh-CN.md)

## Download

- Latest release: [GitHub Releases](https://github.com/Hyggetxc/chatkey/releases)
- Current prerelease: [v0.1.0-dev](https://github.com/Hyggetxc/chatkey/releases/tag/v0.1.0-dev)

## Quick Start

1. Download the latest `.zip` from [Releases](https://github.com/Hyggetxc/chatkey/releases).
2. Move `ChatKey.app` to `/Applications`.
3. Launch the app and grant Accessibility permission when prompted.
4. Open Settings and configure per-app rules.

## Pain Points

- `Return` behavior is inconsistent across chat apps, causing frequent mis-send or line-break mistakes.
- Keyboard habits break when you switch between tools (WeChat, Slack, web chats, AI apps).
- Per-app shortcut setup is scattered and hard to maintain.
- Users want a local-only, lightweight helper instead of a heavy system remapper.

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

## Repository Structure

- `Sources/ChatKey`: main SwiftUI app code
- `Tests/ChatKeyTests`: unit tests
- `scripts/`: local build and packaging helpers
- `dist/`: local build output

## Build

1. Make sure Xcode command line tools are available.
2. From the repository root, run:

```bash
swift build
swift test
```

For a packaged local app bundle:

```bash
./scripts/build-local-app.sh
```

To test the newest local package quickly:

```bash
pkill -x ChatKey || true
rm -rf /Applications/ChatKey.app
cp -R './dist/ChatKey.app' /Applications/ChatKey.app
open /Applications/ChatKey.app
```

For release publishing, GitHub Actions signs the app with a Developer ID Application certificate and notarizes it before uploading the release archive. The workflow expects the signing and notarization secrets to be configured in the repository settings.

## Troubleshooting

- If macOS blocks launch with a security warning, open via right-click -> `Open` once, or use a notarized release build.
- If menu bar UI looks outdated, ensure no old instance is running:
  `pkill -x ChatKey || true`, then relaunch `/Applications/ChatKey.app`.

## Usage

1. Launch the app.
2. Grant Accessibility permission when prompted.
3. Enable ChatKey from the menu bar if needed.
4. Create or edit per-app rules in Settings.
5. Download releases from GitHub when you want to test a newer build.

## Privacy

- Rules and settings are stored locally on your machine.
- ChatKey does not upload your configuration.
- Release assets are only the packaged app and checksum files.

## Support

If ChatKey helps you keep chat shortcuts consistent, please consider starring the repository:

- [Star ChatKey](https://github.com/Hyggetxc/chatkey)
