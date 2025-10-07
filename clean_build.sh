#!/bin/bash

# 清理编译环境脚本
export CHROMIUM_DIR="$HOME/chromium"
export SRC_DIR="$CHROMIUM_DIR/src"

echo "🧹 清理编译环境..."

cd "$SRC_DIR"

if [ -d "out/Default" ]; then
    echo "删除输出目录..."
    rm -rf out/Default
fi

echo "✅ 清理完成！"
