export PATH=/Users/iosdev/Library/Android/sdk/ndk/25.1.8937393/prebuilt/darwin-x86_64/bin:$PATH
cd ~/Desktop/wk_new_debug
make INSTALL_ROOT=~/Desktop/wk_new_debug/android-build install
/Users/iosdev/Qt5/5.15.2/android/bin/qmake -install qinstall -exe libWKFurious_arm64-v8a.so ~/Desktop/wk_new_debug/android-build/libs/arm64-v8a/libWKFurious_arm64-v8a.so
/Users/iosdev/Qt5/5.15.2/android/bin/androiddeployqt --input ~/Desktop/wk_new_debug/android-WKFurious-deployment-settings.json --output ~/Desktop/wk_new_debug/android-build --android-platform android-35 --jdk /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home --gradle
