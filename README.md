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
