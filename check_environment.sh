#!/bin/bash

# macOS ARM 环境检查脚本
echo "🔍 检查编译环境..."

# 检查架构
echo "架构: $(uname -m)"

# 检查 macOS 版本
echo "macOS 版本: $(sw_vers -productVersion)"

# 检查 Xcode
if xcode-select -p &>/dev/null; then
    echo "✅ Xcode 命令行工具已安装"
    echo "Xcode 路径: $(xcode-select -p)"
else
    echo "❌ Xcode 命令行工具未安装"
    echo "请运行: xcode-select --install"
fi

# 检查可用磁盘空间
DISK_SPACE=$(df -h $HOME | awk 'NR==2 {print $4}')
echo "可用磁盘空间: $DISK_SPACE"

# 检查内存
MEMORY=$(sysctl -n hw.memsize)
MEMORY_GB=$((MEMORY / 1024 / 1024 / 1024))
echo "物理内存: ${MEMORY_GB}GB"

# 检查 Python
echo "Python 版本: $(python3 --version 2>/dev/null || echo '未安装')"

# 检查 Git
echo "Git 版本: $(git --version 2>/dev/null || echo '未安装')"

# 推荐配置检查
echo ""
echo "📋 推荐配置:"
echo "   - 磁盘空间: 至少 100GB (当前: $DISK_SPACE)"
echo "   - 内存: 建议 16GB+ (当前: ${MEMORY_GB}GB)"
echo "   - macOS: 13.0+ (当前: $(sw_vers -productVersion))"
