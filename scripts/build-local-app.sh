#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="ChatKey"
APP_VERSION="${APP_VERSION:-0.1.0-dev}"
BUILD_NUMBER="${BUILD_NUMBER:-$(date +%Y%m%d%H%M%S)}"
BUNDLE_ID="${BUNDLE_ID:-com.lemon.chatkey.dev}"
DESIGNATED_REQUIREMENT="designated => identifier \"$BUNDLE_ID\""

# 先显式执行 release 构建，再读取产物目录，避免只有目录路径没有实际二进制文件。
(
    cd "$ROOT_DIR"
    swift build -c release >/dev/null
)

BUILD_BIN_DIR="$(cd "$ROOT_DIR" && swift build -c release --show-bin-path)"
APP_DIR="$ROOT_DIR/dist/${APP_NAME}.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$BUILD_BIN_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"

cat > "$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh-Hans</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# 这里显式写入稳定的 designated requirement，而不是让 ad-hoc 签名退化成纯 cdhash 身份。
# 对 ChatKey 这类依赖 TCC / 辅助功能授权的工具来说，系统会把“签名要求”当作受信任身份的一部分。
# 如果每次构建都只按 cdhash 识别，用户刚授予的权限会在下一次重建后立刻失效。
codesign --force --deep --sign - --identifier "$BUNDLE_ID" -r="$DESIGNATED_REQUIREMENT" "$APP_DIR" >/dev/null

echo "Designated requirement:"
codesign -d -r- "$APP_DIR" 2>&1 | sed 's/^/  /'
echo

echo "Built local test app:"
echo "  $APP_DIR"
echo
echo "Next:"
echo "  1. Double-click the app or drag it into /Applications"
echo "  2. Open it once"
echo "  3. Grant Accessibility permission in System Settings if prompted"
