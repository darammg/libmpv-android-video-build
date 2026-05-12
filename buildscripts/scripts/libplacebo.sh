#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

# We don't use GPU rendering in Nasly (libmpv used purely for decode + AudioTrack).
# libplacebo is mandatory in mpv 0.37+ but the actual GPU paths are not exercised.
# Disable Vulkan/shaderc/glslang/SPIRV-Cross/lcms2/xxhash to avoid pulling extra deps.
meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--default-library static \
	--wrap-mode nodownload \
	-Dvulkan=disabled \
	-Dd3d11=disabled \
	-Dopengl=disabled \
	-Dshaderc=disabled \
	-Dglslang=disabled \
	-Dlcms=disabled \
	-Dxxhash=disabled \
	-Ddemos=false \
	-Dtests=false \
	-Dbench=false

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install
