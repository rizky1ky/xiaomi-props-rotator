# Changelog - Xiaomi Props Rotator

## v1.0.4 (versionCode: 104)
- Fixed module disappearing after reboot bug:
  1. Replaced `#!/data/adb/magisk/busybox sh` with standard `#!/system/bin/sh` in `service.sh`.
  2. Fixed missing `get_property` function crash in `service.sh`.
  3. Replaced destructive `mv` with non-destructive `cp` in `action.sh` to preserve file inodes and prevent overlayfs corruption.

## v1.0.3 (versionCode: 103)
- Fixed MODPATH resolution.
