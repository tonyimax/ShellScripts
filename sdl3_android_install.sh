#!/bin/bash

# 安装目录 for app darwin ,for ubuntu linux
#for macos
#OS_NAME=darwin

#for linux
OS_NAME=linux

#for macos
#NDK_HOME=${ANDROID_HOME}/ndk/25.2.9519653
#for linux
NDK_HOME=${ANDROID_HOME}/ndk/25.1.8937393

INSTALL_DIR=$HOME/Desktop/sdl3_install_android
BUILD_DIR=$HOME/Desktop/sdl3_build_android

mkdir -p ${INSTALL_DIR}

# 复制库文件
for ABI in arm64-v8a armeabi-v7a x86_64 x86; do
    if [ -f "${BUILD_DIR}/${ABI}/libSDL3.so" ]; then
        mkdir -p ${INSTALL_DIR}/lib/${ABI}
        cp ${BUILD_DIR}/${ABI}/libSDL3.so ${INSTALL_DIR}/lib/${ABI}/
        
        # 复制 c++_shared  darwin for apple , linux for ubuntu
        # cp ${NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so ${INSTALL_DIR}/lib/${ABI}/
        # 复制 c++_shared - 新路径
        case ${ABI} in
            "arm64-v8a")
                CXX_PATH="${NDK_HOME}/toolchains/llvm/prebuilt/${OS_NAME}-x86_64/sysroot/usr/lib/aarch64-linux-android"
                ;;
            "armeabi-v7a")
                CXX_PATH="${NDK_HOME}/toolchains/llvm/prebuilt/${OS_NAME}-x86_64/sysroot/usr/lib/arm-linux-androideabi"
                ;;
            "x86_64")
                CXX_PATH="${NDK_HOME}/toolchains/llvm/prebuilt/${OS_NAME}-x86_64/sysroot/usr/lib/x86_64-linux-android"
                ;;
            "x86")
                CXX_PATH="${NDK_HOME}/toolchains/llvm/prebuilt/${OS_NAME}-x86_64/sysroot/usr/lib/i686-linux-android"
                ;;
        esac
	
	if [ -f "${CXX_PATH}/libc++_shared.so" ]; then
            cp "${CXX_PATH}/libc++_shared.so" ${INSTALL_DIR}/lib/${ABI}/
            echo "Copied libc++_shared.so for ${ABI}"
        else
            echo "Warning: libc++_shared.so not found for ${ABI} at ${CXX_PATH}"
        fi
	
    fi
done

# 复制头文件
mkdir -p ${INSTALL_DIR}/include
cp -r ../SDL/include/SDL3 ${INSTALL_DIR}/include/

# 复制 CMake 配置文件
find ${BUILD_DIR} -name "*.cmake" -exec cp {} ${INSTALL_DIR}/ \;

echo "SDL3 installed to: ${INSTALL_DIR}"
