export ANDROID_SDK_ROOT=/Users/iosdev/Library/Android/Sdk
rm -rf /Users/iosdev/Desktop/wk_new_debug
mkdir wk_new_debug
cd /Users/iosdev/Desktop/newUI/WKFly_Consumption 
ls
export PATH=/Users/iosdev/Qt5/5.15.2/android/bin:$PATH
qmake --version

qmake WKFurious.pro -spec android-clang CONFIG+=debug CONFIG+=qml_debug ANDROID_ABIS=arm64-v8a  -o ../../wk_new_debug
