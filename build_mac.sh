OUTDIR=qgc_mac_debug
rm -rf $OUTDIR
cmake -S qgroundcontrol -B $OUTDIR \
-DCMAKE_CXX_FLAGS_INIT:STRING=-DQT_QML_DEBUG \
-DCMAKE_PREFIX_PATH:PATH=/Users/iosdev/Qt/6.8.3/macos \
-DCMAKE_BUILD_TYPE:STRING=Debug \
-DCMAKE_GENERATOR:STRING=Ninja \
-DQT_QMAKE_EXECUTABLE:FILEPATH=/Users/iosdev/Qt/6.8.3/macos/bin/qmake \
-DQT_MAINTENANCE_TOOL:FILEPATH=/Users/iosdev/Qt/MaintenanceTool.app/Contents/MacOS/MaintenanceTool \
-DCMAKE_CXX_COMPILER:FILEPATH=/opt/homebrew/opt/ccache/libexec/clang++ \
-DCMAKE_C_COMPILER:FILEPATH=/opt/homebrew/opt/ccache/libexec/clang \
-DCMAKE_COLOR_DIAGNOSTICS:BOOL=ON \
-DCMAKE_PROJECT_INCLUDE_BEFORE:FILEPATH=/Users/iosdev/Desktop/$OUTDIR/.qtc/package-manager/auto-setup.cmake

cmake --build $OUTDIR --target all
