#!/bin/bash

# Chromium macOS ARM 编译脚本
set -e  # 遇到错误立即退出

echo "🚀 开始编译 Chromium for macOS ARM..."

# 配置变量
export CHROMIUM_DIR="$HOME/chromium"
export DEPOT_TOOLS_DIR="$CHROMIUM_DIR/depot_tools"
export SRC_DIR="$CHROMIUM_DIR/src"

# 检查是否为 Apple Silicon
if [[ $(uname -m) != "arm64" ]]; then
    echo "❌ 此脚本仅适用于 Apple Silicon (ARM64) 平台"
    exit 1
fi

# 检查 macOS 版本
MACOS_VERSION=$(sw_vers -productVersion)
echo "💻 检测到 macOS $MACOS_VERSION (ARM64)"

# 添加到 PATH
export PATH="$DEPOT_TOOLS_DIR:$PATH"

# 创建目录
mkdir -p "$CHROMIUM_DIR"
cd "$CHROMIUM_DIR"

# 步骤 1: 安装 depot_tools
if [ ! -d "$DEPOT_TOOLS_DIR" ]; then
    echo "📥 下载 depot_tools..."
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
else
    echo "✅ depot_tools 已存在，跳过下载"
fi

# 步骤 2: 设置环境变量
export DEPOT_TOOLS_UPDATE=0
export GYP_DEFINES="mac_sdk=13.3 target_arch=arm64"

# 步骤 3: 获取代码
if [ ! -d "$SRC_DIR" ]; then
    echo "📥 获取 Chromium 源代码（这将需要很长时间）..."
    fetch --nohooks chromium
else
    echo "✅ 源代码目录已存在，跳过获取"
    cd "$SRC_DIR"
    # 同步到最新版本
    git fetch origin
fi

cd "$SRC_DIR"

# 步骤 4: 同步依赖和安装 hooks
echo "🔄 同步依赖..."
gclient sync --with_branch_heads --with_tags

# 步骤 5: 安装编译依赖
echo "📦 安装编译依赖..."
./build/install-build-deps.sh --arm

# 步骤 6: 运行 hooks
echo "⚙️  运行 hooks..."
gclient runhooks

# 步骤 7: 配置编译参数
echo "📝 配置编译参数..."
cat > out/Default/args.gn << 'EOF'
# 基本配置
is_debug = false
is_component_build = false
is_official_build = true
symbol_level = 0
blink_symbol_level = 0

# ARM64 特定配置
target_cpu = "arm64"
use_system_xcode = true
mac_sdk_min = "13.3"

# 优化配置
enable_stripping = true
enable_dsyms = false
use_goma = false
use_remoteexec = false

# 功能配置
enable_nacl = false
enable_widevine = true
ffmpeg_branding = "Chrome"
proprietary_codecs = true

# 输出配置
dcheck_always_on = false
EOF

# 生成 Ninja 文件
gn gen out/Default

echo "✅ 配置完成！开始编译..."

# 步骤 8: 开始编译
# 使用 autoninja 自动优化并行任务数
autoninja -C out/Default chrome

echo "🎉 编译完成！"
echo "📁 输出目录: $SRC_DIR/out/Default"
echo "🚀 运行命令: $SRC_DIR/out/Default/Chromium.app/Contents/MacOS/Chromium"
