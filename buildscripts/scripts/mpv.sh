#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

# iconv: meson 내장 iconv 검색이 Android NDK 에서 실패하므로
# cc.find_library + declare_dependency 로 직접 찾도록 패치.
sed -i.bak "/^iconv = dependency('iconv'/c\\
iconv_lib = cc.find_library('iconv', dirs: ['$prefix_dir/lib'], required: get_option('iconv'))\\
iconv = declare_dependency(dependencies: iconv_lib, include_directories: include_directories('$prefix_dir/include'))" meson.build

meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--prefer-static \
	--default-library shared \
	-Dgpl=false \
	-Dlibmpv=true \
 	-Dlua=disabled \
 	-Dcplayer=false \
	-Diconv=enabled \
	-Duchardet=enabled \
	-Dvulkan=disabled \
   	-Dlibplacebo=disabled \
 	-Dmanpage-build=disabled \
	-Dc_link_args="['-lc++_static', '-lc++abi']"

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"
