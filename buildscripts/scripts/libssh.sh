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

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

# toolchain = .../ndk/VER/toolchains/llvm/prebuilt/HOST → ndk root = 4 levels up
ndk_dir="$(cd "$toolchain/../../../.." && pwd)"

cmake .. \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_TOOLCHAIN_FILE="$ndk_dir/build/cmake/android.toolchain.cmake" \
	-DANDROID_ABI=${prefix_dir##*/} \
	-DANDROID_PLATFORM=android-21 \
	-DCMAKE_INSTALL_PREFIX="$prefix_dir" \
	-DCMAKE_FIND_ROOT_PATH="$prefix_dir" \
	-DCMAKE_PREFIX_PATH="$prefix_dir" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS="-DS_IWRITE=S_IWUSR -UHAVE_IFADDRS_H -fPIC -Wno-error" \
	-DHAVE_IFADDRS_H=OFF \
	\
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_STATIC_LIB=ON \
	-DWITH_SERVER=OFF \
	-DWITH_EXAMPLES=OFF \
	-DWITH_MBEDTLS=ON \
	-DMBEDTLS_ROOT_DIR="$prefix_dir" \
	-DMBEDTLS_INCLUDE_DIR="$prefix_dir/include" \
	-DMBEDTLS_LIBRARY="$prefix_dir/lib/libmbedtls.a" \
	-DMBEDCRYPTO_LIBRARY="$prefix_dir/lib/libmbedcrypto.a" \
	-DMBEDX509_LIBRARY="$prefix_dir/lib/libmbedx509.a" \
	-DWITH_GCRYPT=OFF \
	-DWITH_GSSAPI=OFF \
	-DWITH_ZLIB=OFF \
	-DWITH_PCAP=OFF \
	-DWITH_NACL=OFF \
	-DUNIT_TESTING=OFF \
	-DCLIENT_TESTING=OFF \
	-DSERVER_TESTING=OFF

cmake --build . -j$cores
cmake --install .
