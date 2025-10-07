#!/bin/bash

# 设置变量 macos 其他系统需要更改路径
SDL_SOURCE_DIR=$(pwd)/SDL
BUILD_DIR=${SDL_SOURCE_DIR}/../sdl3_build_android
NDK_PATH=$HOME/Library/Android/Sdk/Ndk/25.2.9519653
CMAKE_BIN=/opt/homebrew/bin/cmake
NINJA_BIN=/opt/homebrew/bin/ninja

# 支持的 ABI 列表
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")

# 清理旧构建
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

for ABI in "${ABIS[@]}"; do
    echo "Building for ABI: ${ABI}"
    
    # 设置 ABI 特定参数
    case ${ABI} in
        "arm64-v8a")
            ANDROID_ABI="arm64-v8a"
            ANDROID_PLATFORM="android-24"
            ;;
        "armeabi-v7a")
            ANDROID_ABI="armeabi-v7a"
            ANDROID_PLATFORM="android-24"
            ;;
        "x86_64")
            ANDROID_ABI="x86_64"
            ANDROID_PLATFORM="android-24"
            ;;
        "x86")
            ANDROID_ABI="x86"
            ANDROID_PLATFORM="android-24"
            ;;
    esac
    
    # 创建 ABI 特定的构建目录
    ABI_BUILD_DIR=${BUILD_DIR}/${ABI}
    mkdir -p ${ABI_BUILD_DIR}
    cd ${ABI_BUILD_DIR}
    
    # 运行 CMake 配置
    ${CMAKE_BIN} ${SDL_SOURCE_DIR} \
        -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=${ANDROID_ABI} \
        -DANDROID_PLATFORM=${ANDROID_PLATFORM} \
        -DANDROID_STL=c++_shared \
        -DCMAKE_BUILD_TYPE=Release \
        -DSDL_SHARED=ON \
        -DSDL_STATIC=OFF \
        -DSDL_TEST=OFF \
        -DSDL_CPUINFO=ON \
        -DSDL_VIDEO=ON \
        -DSDL_RENDER=ON \
        -DSDL_EVENTS=ON \
        -DSDL_LOADSO=ON \
        -DSDL_THREADS=ON \
        -DSDL_TIMERS=ON \
        -DSDL_FILE=ON \
        -DSDL_HAPTIC=ON \
        -DSDL_HIDAPI=ON \
        -DSDL_POWER=ON \
        -DSDL_FILESYSTEM=ON \
        -GNinja
    
    # 编译
    # ${NINJA_BIN} -j$(nproc) #for linux
    ${NINJA_BIN} -j6  # macos or win
    
    echo "Build completed for ${ABI}"
done

echo "All builds completed!"
