#!/bin/bash

set -e  # 遇到错误立即退出

# 基础配置
export FFMPEG_DIR=$HOME/Desktop/FFmpeg
export FFMPEG_BUILD_DIR=$FFMPEG_DIR/../ffmpeg_linux_build

# 支持的架构
ARCHS=("x86_64" "aarch64" "armv7l")

# 检测当前系统架构
HOST_ARCH=$(uname -m)
echo "🔍 检测到主机架构: $HOST_ARCH"

# 创建输出目录
mkdir -p "$FFMPEG_BUILD_DIR"

# 依赖检查函数
check_dependencies() {
    echo "🔍 检查系统依赖..."

    local deps=("gcc" "g++" "make" "pkg-config" "yasm" "nasm")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "❌ 缺少以下依赖: ${missing_deps[*]}"
        echo "请使用以下命令安装:"

        if command -v apt &> /dev/null; then
            echo "sudo apt update && sudo apt install -y ${missing_deps[*]}"
        elif command -v yum &> /dev/null; then
            echo "sudo yum install -y ${missing_deps[*]}"
        elif command -v dnf &> /dev/null; then
            echo "sudo dnf install -y ${missing_deps[*]}"
        elif command -v pacman &> /dev/null; then
            echo "sudo pacman -S ${missing_deps[*]}"
        elif command -v zypper &> /dev/null; then
            echo "sudo zypper install ${missing_deps[*]}"
        else
            echo "请根据您的 Linux 发行版安装以上依赖"
        fi
        return 1
    fi

    echo "✅ 所有依赖已安装"
    return 0
}

# 检查外部库函数
check_external_libs() {
    local arch=$1
    echo "🔍 检查外部库支持..."

    # 检查 x264
    if pkg-config --exists x264; then
        echo "✅ 发现系统 x264 库"
        X264_FLAGS="--enable-libx264 --enable-encoder=libx264"
        X264_CFLAGS=$(pkg-config --cflags x264)
        X264_LDFLAGS=$(pkg-config --libs x264)
    else
        echo "⚠️  未发现 x264 库，禁用 H.264 编码"
        X264_FLAGS="--disable-libx264"
        X264_CFLAGS=""
        X264_LDFLAGS=""
    fi

    # 检查 x265
    if pkg-config --exists x265; then
        echo "✅ 发现系统 x265 库"
        X265_FLAGS="--enable-libx265 --enable-encoder=libx265"
        X265_CFLAGS=$(pkg-config --cflags x265)
        X265_LDFLAGS=$(pkg-config --libs x265)
    else
        echo "⚠️  未发现 x265 库，禁用 H.265 编码"
        X265_FLAGS="--disable-libx265"
        X265_CFLAGS=""
        X265_LDFLAGS=""
    fi
}

# 编译函数
build_ffmpeg() {
    local arch=$1
    local cross_compile=$2

    echo ""
    echo "=============================================="
    echo "正在编译 FFmpeg for 架构: $arch"
    echo "=============================================="

    OUTPUT_DIR="$FFMPEG_BUILD_DIR/$arch"
    mkdir -p "$OUTPUT_DIR"

    cd "$FFMPEG_DIR"

    # 清理之前的编译
    make distclean || true

    # 架构特定配置
    case $arch in
        x86_64)
            CPU="x86-64"
            EXTRA_CFLAGS="-march=x86-64 -mtune=generic"
            EXTRA_LDFLAGS=""
            ;;
        aarch64)
            CPU="cortex-a57"
            EXTRA_CFLAGS="-march=armv8-a"
            EXTRA_LDFLAGS=""
            ;;
        armv7l)
            CPU="cortex-a7"
            EXTRA_CFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=hard"
            EXTRA_LDFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=hard"
            ;;
    esac

    # 检查外部库
    check_external_libs "$arch"

    # 配置 FFmpeg
    echo "⚙️  配置 FFmpeg..."
    ./configure \
        --prefix="$OUTPUT_DIR" \
        --target-os=linux \
        --arch="$arch" \
        --cpu="$CPU" \
        --cc="$CC" \
        --cxx="$CXX" \
        --extra-cflags="$EXTRA_CFLAGS $X264_CFLAGS $X265_CFLAGS -Os -fPIC" \
        --extra-ldflags="$EXTRA_LDFLAGS $X264_LDFLAGS $X265_LDFLAGS" \
        --enable-shared \
        --disable-static \
        --disable-programs \
        --disable-doc \
        --disable-avdevice \
        --disable-swresample \
        --disable-avfilter \
        --disable-symver \
        --enable-pic \
        --enable-gpl \
        $X264_FLAGS \
        $X265_FLAGS \
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
        --enable-demuxer=aac \
        --enable-demuxer=mp3

    # 编译和安装
    echo "📦 编译架构 $arch..."
    make -j$(nproc)
    make install

    echo "✅ Linux $arch 架构编译成功!"
    echo "📁 输出目录: $OUTPUT_DIR"
}

# 主编译流程
echo "=============================================="
echo "🚀 开始编译 Linux 平台 FFmpeg"
echo "=============================================="

# 检查依赖
if ! check_dependencies; then
    echo "❌ 依赖检查失败，请先安装缺失的依赖"
    exit 1
fi

# 设置编译器
export CC=${CC:-gcc}
export CXX=${CXX:-g++}
export STRIP=${STRIP:-strip}

echo "🔧 使用编译器:"
echo "   CC: $(which $CC)"
echo "   CXX: $(which $CXX)"

# 决定编译哪些架构
if [ "$1" == "all" ]; then
    # 编译所有架构（需要交叉编译环境）
    echo "🔨 编译所有支持的架构..."
    TO_BUILD=("${ARCHS[@]}")
else
    # 只编译当前主机架构
    echo "🔨 编译当前主机架构: $HOST_ARCH"
    case $HOST_ARCH in
        x86_64)
            TO_BUILD=("x86_64")
            ;;
        aarch64)
            TO_BUILD=("aarch64")
            ;;
        armv7l)
            TO_BUILD=("armv7l")
            ;;
        *)
            echo "⚠️  未知架构 $HOST_ARCH，默认使用 x86_64"
            TO_BUILD=("x86_64")
            ;;
    esac
fi

# 执行编译
for ARCH in "${TO_BUILD[@]}"; do
    build_ffmpeg "$ARCH" "false"
done

# 创建统一头文件目录（如果编译了多个架构）
if [ ${#TO_BUILD[@]} -gt 1 ]; then
    echo ""
    echo "🔗 创建统一头文件目录..."
    UNIFIED_INCLUDE_DIR="$FFMPEG_BUILD_DIR/include"
    mkdir -p "$UNIFIED_INCLUDE_DIR"

    # 使用第一个架构的头文件
    cp -r "$FFMPEG_BUILD_DIR/${TO_BUILD[0]}/include"/* "$UNIFIED_INCLUDE_DIR/" 2>/dev/null || true
    echo "📁 统一头文件目录: $UNIFIED_INCLUDE_DIR"
fi

# 最终输出总结
echo ""
echo "=============================================="
echo "🎉 Linux 平台 FFmpeg 编译完成!"
echo "=============================================="
echo ""
echo "📦 输出目录结构:"
echo "ffmpeg_linux_build/"
for ARCH in "${TO_BUILD[@]}"; do
    echo "├── $ARCH/"
    echo "│   ├── bin/               # 可执行文件"
    echo "│   ├── lib/               # 库文件 (.so)"
    echo "│   ├── include/           # 头文件"
    echo "│   └── share/             # 资源文件"
done
if [ ${#TO_BUILD[@]} -gt 1 ]; then
    echo "└── include/               # 统一头文件"
fi
echo ""
echo "✅ 支持的编解码器:"
echo "   - H.264 (AVC) 解码器"
echo "   - H.265 (HEVC) 解码器"
if [ -n "$X264_FLAGS" ] && [[ "$X264_FLAGS" == *"enable"* ]]; then
    echo "   - H.264 编码器 (libx264)"
fi
if [ -n "$X265_FLAGS" ] && [[ "$X265_FLAGS" == *"enable"* ]]; then
    echo "   - H.265 编码器 (libx265)"
fi
echo "   - AAC 解码器"
echo "   - MP3 解码器"
echo "   - VP8 解码器"
echo "   - VP9 解码器"
echo "   - AV1 解码器"
echo ""
echo "🔧 部署信息:"
echo "   - 平台: Linux"
echo "   - 架构: ${TO_BUILD[*]}"
echo "   - 库类型: 动态库 (.so)"
echo "   - 位置无关代码: 启用"
echo "=============================================="

# 验证库文件
echo ""
echo "🔍 验证生成的库文件..."

for ARCH in "${TO_BUILD[@]}"; do
    LIB_DIR="$FFMPEG_BUILD_DIR/$arch/lib"
    if [ -d "$LIB_DIR" ]; then
        echo ""
        echo "📁 架构 $ARCH 的库文件:"
        for LIB in "$LIB_DIR"/*.so; do
            if [[ -f "$LIB" ]]; then
                LIB_NAME=$(basename "$LIB")
                echo "   📄 $LIB_NAME"
                # 显示库信息
                file "$LIB" | head -1
            fi
        done
    fi
done

# 使用说明
echo ""
echo "💡 使用说明:"
echo "1. 在项目中使用库文件:"
echo "   export LD_LIBRARY_PATH=\"$FFMPEG_BUILD_DIR/$HOST_ARCH/lib:\$LD_LIBRARY_PATH\""
echo "   gcc -I$FFMPEG_BUILD_DIR/$HOST_ARCH/include -L$FFMPEG_BUILD_DIR/$HOST_ARCH/lib -lavcodec -lavformat -lswscale -lavutil myapp.c"
echo ""
echo "2. 安装到系统目录:"
echo "   sudo cp -r $FFMPEG_BUILD_DIR/$HOST_ARCH/lib/* /usr/local/lib/"
echo "   sudo cp -r $FFMPEG_BUILD_DIR/$HOST_ARCH/include/* /usr/local/include/"
echo "   sudo ldconfig"