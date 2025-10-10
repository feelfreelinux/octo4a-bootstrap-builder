#!/usr/local/env sh
# Builds a small alpine rootfs, and installs octoprint into it.

set -eu

# alpine packages required to install octoprint
readonly O4A_PKGS='alpine-keys apk-tools gcc python3 py3-pip libffi-dev python3-dev rust cargo musl-dev curl git linux-headers dropbear p7zip bash unzip ffmpeg ttyd'
readonly ALPINE_BRANCH='3.22'

case "$ARCH" in
"aarch64")
    ALPINE_ARCH="aarch64";;
"armv7a")
    ALPINE_ARCH="armhf";;
"i686")
    ALPINE_ARCH="x86";;
"x86_64")
    ALPINE_ARCH="x86_64";;
esac

sudo sh scripts/alpine-make-rootfs.sh \
    --arch $ALPINE_ARCH \
    --branch $ALPINE_BRANCH \
    --packages "$O4A_PKGS" \
    --script-chroot \
    build/rootfs.tar.xz ./scripts/setup-alpine-rootfs.sh
