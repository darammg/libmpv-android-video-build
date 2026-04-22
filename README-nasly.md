# Nasly — Custom libmpv / FFmpeg Build

This branch (`nasly-custom`) is the corresponding source for LGPL components
used by the **Nasly** video player app (Android).

Upstream: [media-kit/libmpv-android-video-build](https://github.com/media-kit/libmpv-android-video-build)

## License & LGPL Compliance

Nasly is a proprietary Android application. It links dynamically against the
following LGPL components built from this repository:

| Component | License | Version |
|---|---|---|
| **mpv** | LGPL v2.1+ (built with `-Dgpl=false`) | commit `78d43740f5...` (depinfo.sh) |
| **FFmpeg** | LGPL v3+ (built with `--disable-gpl --disable-nonfree --enable-version3`) | 6.0 |
| **libswscale / libswresample / libavcodec / libavformat / libavutil / libavfilter** | LGPL v3+ | (part of FFmpeg) |
| **libssh** | LGPL v2.1+ | upstream |
| **libiconv** | LGPL v2.1+ | upstream |
| **fribidi** | LGPL v2.1+ | 1.0.12 |
| **uchardet** | MPL 1.1 / GPL 2.0 / **LGPL 2.1** (triple — Nasly uses LGPL) | upstream |

Other components linked via libmpv (non-LGPL, included for reference):
libass (ISC), harfbuzz (MIT), freetype (FTL), mbedtls (Apache 2.0),
libdav1d (BSD-2), libxml2 (MIT).

### LGPL v3 / v2.1 obligations met

1. **Dynamic linking** — `libmpv.so` is shipped as a shared library in the APK,
   allowing end users to replace it with their own build.
2. **Corresponding source** — provided via this public repository (build
   scripts + patches). Upstream sources are fetched automatically by the
   scripts from their official git repositories.
3. **Modifications marked** — see [Modifications](#modifications) below. All
   changes are in plaintext shell scripts and `.patch` files in this repo.

## Modifications (from upstream `media-kit/libmpv-android-video-build`)

| File | Change |
|---|---|
| `buildscripts/scripts/mpv.sh` | `-Dgpl=false` → force LGPL. `-Diconv=enabled` + `-Duchardet=enabled`. iconv dep resolution patch for Android NDK. `-Dc_link_args` for static libc++. |
| `buildscripts/patches/mpv/ao_audiotrack_volume_ramp.patch` | mpv `ao_audiotrack.c` — one-chunk look-ahead volume ramp (PCM-level fade) to fix pause/seek pops on Android AudioTrack backend. |
| `buildscripts/scripts/ffmpeg.sh` | FFmpeg configure: `--disable-gpl --disable-nonfree --enable-version3` + LGPL-only protocol/decoder selection. |
| `buildscripts/scripts/libiconv.sh` | New — build libiconv for subtitle encoding detection. |
| `buildscripts/scripts/libssh.sh` | New — build libssh (LGPL) for SFTP support in mpv. |
| `buildscripts/scripts/uchardet.sh` | New — build uchardet (LGPL variant) for subtitle charset auto-detection. |
| `buildscripts/patches/media_kit/real.dart.patch` | media_kit Flutter package (v1.2.6) — force `ao=audiotrack` on Android and drop `removePrefix` from filename for SMB/FTP network paths. See `media_kit` below. |

### media_kit (MIT-licensed Flutter package)

The `patches/media_kit/real.dart.patch` file is applied to the pub cache:
`~/.pub-cache/hosted/pub.dev/media_kit-1.2.6/lib/src/player/native/player/real.dart`

Though MIT doesn't require source disclosure, the patch is included here for
build reproducibility. Upstream: [media-kit/media-kit](https://github.com/media-kit/media-kit).

## Reproducing the Build

```bash
git clone https://github.com/darammg/libmpv-android-video-build.git
cd libmpv-android-video-build
git checkout nasly-custom

cd buildscripts
bash build.sh --arch arm64 -n mpv
```

Build output: `buildscripts/prefix/arm64-v8a/lib/libmpv.so`

Copy to Nasly jniLibs:
```bash
cp buildscripts/prefix/arm64-v8a/opt/homebrew/lib/libmpv.so \
   ~/dev/nasly/android/app/src/main/jniLibs/arm64-v8a/
```

## License Texts

- [LGPL v3](https://www.gnu.org/licenses/lgpl-3.0.txt)
- [LGPL v2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt)
- [MPL 1.1](https://www.mozilla.org/en-US/MPL/1.1/)

## Contact for Corresponding Source

Requests for source code for any LGPL component used in **Nasly**:

- GitHub Issues: https://github.com/darammg/libmpv-android-video-build/issues
- Or clone this repository directly — the `nasly-custom` branch contains the
  complete build recipe and all modifications.
