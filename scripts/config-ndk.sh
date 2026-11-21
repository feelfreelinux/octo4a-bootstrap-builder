#!/usr/bin/env sh

# Supported platforms
# Note - currently disabling pre Android 21 targets
ARCHS='aarch64 armv7a x86_64 i686'

# Configures NDK for android cross-compilation
if [[ -z "${NDK_PATH}" ]]; then
    echo "NDK Path not set" >&2
    exit 1
fi

config_ndk() {
    if [ "$(uname)" == "Darwin" ]; then
        export TOOLCHAIN=$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64
    else
        export TOOLCHAIN=$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64
    fi

    case "$1" in
    "aarch64")
        export TARGET=aarch64-linux-android
        export ARCH_NDK="arm64-v8a"
        ;;
    "armv7a")
        export TARGET=armv7a-linux-androideabi
        export ARCH_NDK="armeabi-v7a"
        ;;
    "i686")
        export TARGET=i686-linux-android
        export ARCH_NDK="x86"
        ;;
    "x86_64")
        export TARGET=x86_64-linux-android
        export ARCH_NDK="x86_64"
        ;;
    esac

    if $BUILD_PRE5; then
        export INSTALL_ROOT="$BUILD_DIR/root-$1-pre5/root"
        export STATIC_ROOT="$BUILD_DIR/static-$1-pre5/root"
        export API=16
    else
        export INSTALL_ROOT="$BUILD_DIR/root-$1/root"
        export STATIC_ROOT="$BUILD_DIR/static-$1/root"
        # API 24+: bionic provides getifaddrs/freeifaddrs needed by modern Termux proot
        export API=24
    fi

    # Configure and build.
    export AR="$TOOLCHAIN/bin/llvm-ar"
    export CC="$TOOLCHAIN/bin/$TARGET$API-clang"
    export AS="$CC"
    export CXX="$TOOLCHAIN/bin/$TARGET$API-clang++"
    export LD="$TOOLCHAIN/bin/ld"
    export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
    export STRIP="$TOOLCHAIN/bin/llvm-strip"
}