#!/bin/bash

set -e  # 遇到错误立即退出

# 基础配置
export FFMPEG_DIR=$HOME/Desktop/FFmpeg
export FFMPEG_BUILD_DIR=$FFMPEG_DIR/../ffmpeg_apple_build

# 支持的平台和架构
IOS_ARCHS=("arm64" "x86_64")  # arm64: 真机, x86_64: 模拟器
MACOS_ARCHS=("x86_64" "arm64")

# SDK 路径
export IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
export IOS_SIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
export MACOS_SDK=$(xcrun --sdk macosx --show-sdk-path)

# 工具链
export CC=$(xcrun -f clang)
export CXX=$(xcrun -f clang++)

# 创建输出目录
mkdir -p "$FFMPEG_BUILD_DIR"

# 编译 iOS 库
echo "=============================================="
echo "开始编译 iOS 平台 FFmpeg"
echo "=============================================="

for ARCH in "${IOS_ARCHS[@]}"; do
    echo ""
    echo "🔨 编译架构: $ARCH"

    # 配置平台相关参数
    case $ARCH in
        arm64)
            PLATFORM="iPhoneOS"
            SDK=$IOS_SDK
            TARGET="arm64-ios-darwin"
            EXTRA_CFLAGS="-arch arm64 -mios-version-min=12.0 -isysroot $SDK"
            EXTRA_LDFLAGS="-arch arm64 -mios-version-min=12.0 -isysroot $SDK"
            ;;
        x86_64)
            PLATFORM="iPhoneSimulator"
            SDK=$IOS_SIMULATOR_SDK
            TARGET="x86_64-ios-darwin"
            EXTRA_CFLAGS="-arch x86_64 -mios-version-min=12.0 -isysroot $SDK"
            EXTRA_LDFLAGS="-arch x86_64 -mios-version-min=12.0 -isysroot $SDK"
            ;;
    esac

    OUTPUT_DIR="$FFMPEG_BUILD_DIR/ios/$ARCH"
    mkdir -p "$OUTPUT_DIR"

    cd "$FFMPEG_DIR"

    # 清理之前的编译
    make distclean || true

    # 配置 FFmpeg
    ./configure \
        --prefix="$OUTPUT_DIR" \
        --enable-cross-compile \
        --target-os=darwin \
        --arch="$ARCH" \
        --cc="$CC" \
        --cxx="$CXX" \
        --extra-cflags="$EXTRA_CFLAGS -Os -fPIC" \
        --extra-ldflags="$EXTRA_LDFLAGS" \
        --enable-shared \
        --disable-static \
        --disable-programs \
        --disable-doc \
        --disable-avdevice \
        --disable-swresample \
        --disable-avfilter \
        --disable-symver \
        --disable-asm \
        --enable-decoder=h264 \
        --enable-decoder=hevc \
        --enable-parser=h264 \
        --enable-parser=hevc \
        --enable-demuxer=h264 \
        --enable-demuxer=hevc \
        --enable-decoder=aac \
        --enable-decoder=mp3 \
        --enable-decoder=vp8 \
        --enable-decoder=vp9 \
        --enable-decoder=av1 \
        --enable-parser=aac \
        --enable-parser=mpeg4video \
        --enable-pic

    # 编译和安装
    echo "📦 编译架构 $ARCH..."
    make -j$(sysctl -n hw.logicalcpu)
    make install

    echo "✅ iOS $ARCH 架构编译成功!"
    echo "📁 输出目录: $OUTPUT_DIR"
done

# 创建 iOS 通用库 (Fat Library)
echo ""
echo "🔗 创建 iOS 通用库..."
IOS_UNIVERSAL_DIR="$FFMPEG_BUILD_DIR/ios/universal"
mkdir -p "$IOS_UNIVERSAL_DIR/lib"

# 复制头文件
cp -r "$FFMPEG_BUILD_DIR/ios/arm64/include" "$IOS_UNIVERSAL_DIR/"

# 合并库文件
for LIB in "$FFMPEG_BUILD_DIR/ios/arm64/lib/"*.dylib; do
    LIB_NAME=$(basename "$LIB")
    if [[ $LIB_NAME == *.dylib ]]; then
        lipo -create \
            "$FFMPEG_BUILD_DIR/ios/arm64/lib/$LIB_NAME" \
            "$FFMPEG_BUILD_DIR/ios/x86_64/lib/$LIB_NAME" \
            -output "$IOS_UNIVERSAL_DIR/lib/$LIB_NAME"
        echo "✅ 合并库: $LIB_NAME"
    fi
done

echo "✅ iOS 通用库创建完成!"

# 编译 macOS 库
echo ""
echo "=============================================="
echo "开始编译 macOS 平台 FFmpeg"
echo "=============================================="

for ARCH in "${MACOS_ARCHS[@]}"; do
    echo ""
    echo "🔨 编译架构: $ARCH"

    OUTPUT_DIR="$FFMPEG_BUILD_DIR/macos/$ARCH"
    mkdir -p "$OUTPUT_DIR"

    cd "$FFMPEG_DIR"

    # 清理之前的编译
    make distclean || true

    # 配置 FFmpeg for macOS
    ./configure \
        --prefix="$OUTPUT_DIR" \
        --target-os=darwin \
        --arch="$ARCH" \
        --cc="$CC" \
        --cxx="$CXX" \
        --extra-cflags="-arch $ARCH -mmacosx-version-min=10.15 -isysroot $MACOS_SDK" \
        --extra-ldflags="-arch $ARCH -mmacosx-version-min=10.15 -isysroot $MACOS_SDK" \
        --enable-shared \
        --disable-static \
        --disable-programs \
        --disable-doc \
        --disable-avdevice \
        --disable-swresample \
        --disable-avfilter \
        --disable-symver \
        --disable-asm \
        --enable-decoder=h264 \
        --enable-decoder=hevc \
        --enable-parser=h264 \
        --enable-parser=hevc \
        --enable-demuxer=h264 \
        --enable-demuxer=hevc \
        --enable-decoder=aac \
        --enable-decoder=mp3 \
        --enable-decoder=vp8 \
        --enable-decoder=vp9 \
        --enable-decoder=av1 \
        --enable-parser=aac \
        --enable-parser=mpeg4video \
        --enable-pic

    # 编译和安装
    echo "📦 编译架构 $ARCH..."
    make -j$(sysctl -n hw.logicalcpu)
    make install

    echo "✅ macOS $ARCH 架构编译成功!"
    echo "📁 输出目录: $OUTPUT_DIR"
done

# 创建 macOS 通用库 (Fat Library)
echo ""
echo "🔗 创建 macOS 通用库..."
MACOS_UNIVERSAL_DIR="$FFMPEG_BUILD_DIR/macos/universal"
mkdir -p "$MACOS_UNIVERSAL_DIR/lib"

# 复制头文件
cp -r "$FFMPEG_BUILD_DIR/macos/arm64/include" "$MACOS_UNIVERSAL_DIR/"

# 合并库文件
for LIB in "$FFMPEG_BUILD_DIR/macos/arm64/lib/"*.dylib; do
    LIB_NAME=$(basename "$LIB")
    if [[ $LIB_NAME == *.dylib ]]; then
        lipo -create \
            "$FFMPEG_BUILD_DIR/macos/arm64/lib/$LIB_NAME" \
            "$FFMPEG_BUILD_DIR/macos/x86_64/lib/$LIB_NAME" \
            -output "$MACOS_UNIVERSAL_DIR/lib/$LIB_NAME"
        echo "✅ 合并库: $LIB_NAME"
    fi
done

echo "✅ macOS 通用库创建完成!"

# 最终输出总结
echo ""
echo "=============================================="
echo "🎉 Apple 平台 FFmpeg 编译完成!"
echo "=============================================="
echo ""
echo "📦 输出目录结构:"
echo "ffmpeg_apple_build/"
echo "├── ios/"
echo "│   ├── arm64/              # iOS 真机库"
echo "│   ├── x86_64/             # iOS 模拟器库"
echo "│   └── universal/          # iOS 通用库"
echo "│       ├── include/        # 头文件"
echo "│       └── lib/            # 通用库文件"
echo "└── macos/"
echo "    ├── arm64/              # Apple Silicon Mac 库"
echo "    ├── x86_64/             # Intel Mac 库"
echo "    └── universal/          # macOS 通用库"
echo "        ├── include/        # 头文件"
echo "        └── lib/            # 通用库文件"
echo ""
echo "✅ 支持的编解码器:"
echo "   - H.264 (AVC) 解码器"
echo "   - H.265 (HEVC) 解码器"
echo "   - AAC 解码器"
echo "   - MP3 解码器"
echo "   - VP8 解码器"
echo "   - VP9 解码器"
echo "   - AV1 解码器"
echo ""
echo "🔧 部署信息:"
echo "   - iOS 最低版本: 12.0"
echo "   - macOS 最低版本: 10.15 (Catalina)"
echo "   - 架构支持: arm64, x86_64"
echo "=============================================="

# 验证库文件
echo ""
echo "🔍 验证生成的库文件..."

echo "iOS 通用库信息:"
for LIB in "$IOS_UNIVERSAL_DIR/lib/"*.dylib; do
    if [[ -f "$LIB" ]]; then
        echo "📄 $(basename "$LIB"):"
        lipo -info "$LIB"
    fi
done

echo ""
echo "macOS 通用库信息:"
for LIB in "$MACOS_UNIVERSAL_DIR/lib/"*.dylib; do
    if [[ -f "$LIB" ]]; then
        echo "📄 $(basename "$LIB"):"
        lipo -info "$LIB"
    fi
done