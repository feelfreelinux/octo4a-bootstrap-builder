#!/usr/bin/env sh
# statically builds talloc 2.4.1

BUILD_DIR="$(pwd)/build"

. ./scripts/config-ndk.sh

cd external/talloc

# Build binaries for each supported platform
config_ndk $ARCH

echo "Building static talloc for $ARCH"

DEF_CFLAGS="$CFLAGS"

if $BUILD_PRE5
then
FILE_OFFSET_BITS='NO'
export CFLAGS="$CFLAGS -D__ANDROID_API__=14"
else
FILE_OFFSET_BITS='OK'
export CFLAGS="$DEF_CFLAGS"
fi

cat <<EOF >cross-answers.txt
Checking uname sysname type: "Linux"
Checking uname machine type: "dontcare"
Checking uname release type: "dontcare"
Checking uname version type: "dontcare"
Checking simple C program: OK
building library support: OK
Checking for large file support: OK
Checking for -D_FILE_OFFSET_BITS=64: $FILE_OFFSET_BITS
Checking for WORDS_BIGENDIAN: OK
Checking for C99 vsnprintf: OK
Checking for HAVE_SECURE_MKSTEMP: OK
rpath library support: OK
-Wl,--version-script support: FAIL
Checking correct behavior of strtoll: OK
Checking correct behavior of strptime: OK
Checking for HAVE_IFACE_GETIFADDRS: OK
Checking for HAVE_IFACE_IFCONF: OK
Checking for HAVE_IFACE_IFREQ: OK
Checking getconf LFS_CFLAGS: OK
Checking for large file support without additional flags: OK
Checking for working strptime: OK
Checking for HAVE_SHARED_MMAP: OK
Checking for HAVE_MREMAP: OK
Checking for HAVE_INCOHERENT_MMAP: OK
Checking getconf large file support flags work: OK
EOF

# clean previous build
make distclean || true

./configure --prefix=$INSTALL_ROOT \
    --disable-rpath \
    --disable-python \
    --cross-compile \
    --cross-answers=cross-answers.txt

make

mkdir -p "$STATIC_ROOT/include"
mkdir -p "$STATIC_ROOT/lib"

# Use NDK llvm-ar: host `ar` on macOS cannot archive Android ELF objects
# (produces an empty .a and proot then fails to link talloc symbols).
"$AR" rcs "$STATIC_ROOT/lib/libtalloc.a" \
    bin/default/talloc.c.*.o \
    bin/default/lib/replace/replace.c.*.o \
    bin/default/lib/replace/closefrom.c.*.o \
    bin/default/lib/replace/getifaddrs.c.*.o \
    bin/default/lib/replace/replace.empty.c.*.o \
    2>/dev/null || "$AR" rcs "$STATIC_ROOT/lib/libtalloc.a" bin/default/talloc*.o

# Prefer the shared-build's object that contains the full talloc implementation
if ! "$AR" t "$STATIC_ROOT/lib/libtalloc.a" | grep -q .; then
    echo "Failed to create non-empty libtalloc.a" >&2
    exit 1
fi

cp -f talloc.h "$STATIC_ROOT/include"

cd $BUILD_DIR/..