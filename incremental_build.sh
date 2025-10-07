#!/bin/bash

# 增量编译脚本
set -e

export CHROMIUM_DIR="$HOME/chromium"
export SRC_DIR="$CHROMIUM_DIR/src"

cd "$SRC_DIR"

echo "🔄 同步最新代码..."
git pull
gclient sync

echo "📝 重新生成构建文件..."
gn gen out/Default

echo "🔨 开始增量编译..."
autoninja -C out/Default chrome

echo "✅ 增量编译完成！"
