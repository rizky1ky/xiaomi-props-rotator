# Changelog - Xiaomi Props Rotator

## v1.0.2 (versionCode: 102)
- Fixed WebUI shell bridge execution using universal `execShell` (supports KSU WebView native API `ksu.exec`, `window.parent.runShellFromIframe`, and `@kernelsu` ESM module).
- Fixed `mode.txt` & `selected.txt` permissions (`chmod 666`) to ensure shell & Action button can read selections instantly.

## v1.0.1 (versionCode: 101)
- Simplified state storage to simple `mode.txt` and `selected.txt` files.
