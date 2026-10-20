#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="VibeNote"
APP_DIR="$ROOT_DIR/dist/${APP_NAME}.app"
cd "$ROOT_DIR"
swift build -c release
EXECUTABLE="$(swift build -c release --show-bin-path)/${APP_NAME}"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp assets/design/logo.svg "$APP_DIR/Contents/Resources/VibeNoteLogo.svg"

ICONSET_DIR="$ROOT_DIR/.build/VibeNote.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"
ICON_SOURCE="$ROOT_DIR/assets/design/AppIcon-1024.png"
sips -s format png "$ICON_SOURCE" --out "$ICONSET_DIR/icon_1024x1024.png" >/dev/null
for SIZE in 16 32 128 256 512; do
  DOUBLE_SIZE=$((SIZE * 2))
  sips -z "$SIZE" "$SIZE" "$ICONSET_DIR/icon_1024x1024.png" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}.png" >/dev/null
  sips -z "$DOUBLE_SIZE" "$DOUBLE_SIZE" "$ICONSET_DIR/icon_1024x1024.png" --out "$ICONSET_DIR/icon_${SIZE}x${SIZE}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/VibeNote.icns"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>VibeNote</string>
	<key>CFBundleExecutable</key>
	<string>VibeNote</string>
	<key>CFBundleIdentifier</key>
	<string>com.vibenote.VibeNote</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>VibeNote</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleIconFile</key>
	<string>VibeNote.icns</string>
	<key>CFBundleShortVersionString</key>
	<string>0.1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>NSHumanReadableCopyright</key>
	<string>© 2026 Bá Vương. All rights reserved.</string>
	<key>LSMultipleInstancesProhibited</key>
	<true/>
	<key>LSMinimumSystemVersion</key>
	<string>13.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeName</key>
			<string>Text Document</string>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>LSItemContentTypes</key>
			<array>
				<string>public.text</string>
				<string>public.source-code</string>
				<string>public.data</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
PLIST

echo "Built $APP_DIR"
