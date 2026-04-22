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

../configure \
	--host=$ndk_triple \
	--prefix="$prefix_dir" \
	--enable-static \
	--disable-shared \
	--disable-rpath \
	CC="$CC" \
	CFLAGS="-fPIC"

make -j$cores
make install
