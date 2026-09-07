# Binary provenance

The `okf-*` executables vendored in this directory are pre-compiled releases of
**OKF Agent Memory** ([okf-memory/okf-agent-memory](https://github.com/okf-memory/okf-agent-memory)),
the Go CLI implementing the Open Knowledge Format (OKF) v0.2 specification.

- Upstream version: **v0.1.2** (`okf version v0.1.2 (OKF v0.2 specification)`)
- Source: https://github.com/okf-memory/okf-agent-memory/releases/tag/v0.1.2
- Binaries are byte-identical to the upstream release assets; verify with:
  `sha256sum -c SHA256SUMS`
- `install_okf()` re-downloads from the same release URL pattern:
  `https://github.com/okf-memory/okf-agent-memory/releases/download/<version>/<bin_name>`

## SHA256SUMS

```
a65272beaf507388186f522cb67980a288fdfc8ca63e39901abbb152b7e64e64  okf-darwin-amd64
c3d45a0c5fee96f9af7250adb1f36a6af3ae26ea68b9ccf8001acd2a1b8f6836  okf-darwin-arm64
b561a7a478f3ccd661ee561fadc2b762aeb9cbc19d962d267077a169c1c9084c  okf-linux-amd64
4b6e3553b265763e405ab0f4dea2ef0c371e0ce48b7d417c78a36292287a2d71  okf-windows-amd64.exe
```
