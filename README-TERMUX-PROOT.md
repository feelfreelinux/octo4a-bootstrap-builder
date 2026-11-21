# Termux proot (modern Android / Pixel)

Stock Octo4a bootstraps shipped an older Android proot that fails on some
devices (notably Pixels on Android 15+) with:

```text
proot error: execve("/bin/sh"): Function not implemented
proot warning: ptrace(PEEKDATA): I/O error
```

This builder now vendors [Termux proot](https://github.com/termux/proot)
(`v5.1.107.102`) instead of `feelfreelinux/proot`.

## Build notes

- NDK API **24+** (bionic `getifaddrs`)
- Static talloc via NDK `llvm-ar` (host `ar` on macOS cannot archive Android ELF objects)
- Local patch: `patches/0001-ashmem-include-string.h.patch`
- Entrypoint sets `PROOT_LOADER` / `PROOT_LOADER_32`

Validated: Pixel 8 / Android 17 — install succeeds after rebuilding the
bootstrap with this proot. See also octo4a issue #540.
