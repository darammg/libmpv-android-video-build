#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

NDK_PATH="$PWD/../../sdk/android-sdk-linux/ndk/25.2.9519653"
[[ "$ndk_triple" == "aarch64"* ]] && ABI=arm64-v8a
[[ "$ndk_triple" == "arm"* ]] && ABI=armeabi-v7a
[[ "$ndk_triple" == "x86_64"* ]] && ABI=x86_64
[[ "$ndk_triple" == "i686"* ]] && ABI=x86

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cmake .. \
	-DCMAKE_TOOLCHAIN_FILE="$NDK_PATH/build/cmake/android.toolchain.cmake" \
	-DANDROID_ABI=$ABI \
	-DANDROID_PLATFORM=android-21 \
	-DCMAKE_INSTALL_PREFIX="$prefix_dir" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_BINARY=OFF \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5

make -j$cores
make install
