#!/usr/bin/env sh
# statically builds proot

BUILD_DIR="$(pwd)/build"
REPO_ROOT="$(pwd)"

. ./scripts/config-ndk.sh

# Apply local Android/NDK patches onto the Termux proot sources (kept out-of-tree)
if [ -d "$REPO_ROOT/patches" ]; then
    for p in "$REPO_ROOT"/patches/*.patch; do
        [ -f "$p" ] || continue
        echo "Applying patch $(basename "$p")"
        git -C "$REPO_ROOT/external/proot" apply --whitespace=nowarn "$p" || {
            echo "Warning: patch already applied or failed: $p" >&2
        }
    done
fi

cd external/proot/src

# Build binaries for selected platform
config_ndk $ARCH

echo "Building static proot for $ARCH"

export CFLAGS="-I$STATIC_ROOT/include -DARG_MAX=131072"
export LDFLAGS="-L$STATIC_ROOT/lib"
export PROOT_UNBUNDLE_LOADER='../libexec/proot'

if $BUILD_PRE5
then export ANDROID_PRE5=1
else unset ANDROID_PRE5
fi

# GNUmakefile invokes bare `readelf` for loader-info; prefer NDK llvm-readelf
READELF_WRAP="$(mktemp -d)"
ln -sf "$(dirname "$AR")/llvm-readelf" "$READELF_WRAP/readelf"
export PATH="$READELF_WRAP:$PATH"

# clean previous build
make distclean || true
# Build only — macOS / BSD `install` does not support GNU `install -D`
make V=1

mkdir -p "$INSTALL_ROOT/bin"
mkdir -p "$INSTALL_ROOT/bin/$PROOT_UNBUNDLE_LOADER"

cp -f proot "$INSTALL_ROOT/bin/proot"
# Loaders are built in-tree when PROOT_UNBUNDLE_LOADER is set
if [ -f loader/loader ]; then
    cp -f loader/loader "$INSTALL_ROOT/bin/$PROOT_UNBUNDLE_LOADER/loader"
fi
if [ -f loader/loader-m32 ]; then
    cp -f loader/loader-m32 "$INSTALL_ROOT/bin/$PROOT_UNBUNDLE_LOADER/loader32"
fi

(
    cd "$INSTALL_ROOT/bin"
    for FN in *; do
        [ -f "$FN" ] && "$STRIP" "$FN"
    done
)

(
    cd "$INSTALL_ROOT/bin/$PROOT_UNBUNDLE_LOADER"
    for FN in *; do
        [ -f "$FN" ] && "$STRIP" "$FN"
    done
)

rm -rf "$READELF_WRAP"

cd "$REPO_ROOT"
