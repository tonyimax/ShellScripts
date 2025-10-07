#!/bin/bash

# 安装 Homebrew（如果尚未安装）
if ! command -v brew &> /dev/null; then
    echo "安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 添加 Homebrew 到 PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 安装 libusb
echo "安装 libusb..."
brew install libusb

# 验证安装
echo "验证安装..."
pkg-config --modversion libusb-1.0
