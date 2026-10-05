#!/usr/bin/env bash
# Script deploy nhanh cho mod này
set -e

MOD_NAME="StarterMod"
TARGET_DIR="/sdcard/StardewValley/desktop/Mods/$MOD_NAME"

echo "Đang biên dịch $MOD_NAME..."
/root/.dotnet/dotnet build -c Release

echo "Đang triển khai vào $TARGET_DIR..."
mkdir -p "$TARGET_DIR"
cp bin/Release/*.dll "$TARGET_DIR/" 2>/dev/null || true
cp bin/Release/*.pdb "$TARGET_DIR/" 2>/dev/null || true
cp manifest.json "$TARGET_DIR/"
if [ -d "assets" ]; then
    cp -r assets "$TARGET_DIR/"
fi

echo "Đã triển khai thành công! Hãy mở game để kiểm tra."
