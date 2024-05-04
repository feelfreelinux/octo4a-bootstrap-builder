#!/env/sh
# statically builds talloc 2.4.1

readonly BUILD_DIR="$(pwd)/build"
mkdir $BUILD_DIR

. ./scripts/config-ndk.sh

cd external/talloc

config_ndk aarch64

cat <<EOF >cross-answers.txt
Checking uname sysname type: "Darwin"
Checking uname machine type: "dontcare"
Checking uname release type: "dontcare"
Checking uname version type: "dontcare"
Checking simple C program: OK
building library support: OK
Checking for large file support: OK
Checking for -D_FILE_OFFSET_BITS=64: OK
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

./configure --prefix=$INSTALL_ROOT \
    --disable-rpath \
    --disable-python \
    --cross-compile \
    --cross-answers=cross-answers.txt

echo "$CC"
./configure "--prefix=$BUILD_ROOT" --disable-rpath --disable-python --cross-compile --cross-answers=cross-answers.txt
