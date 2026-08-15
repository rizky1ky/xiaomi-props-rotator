# Changelog - Xiaomi Props Rotator

## v1.0.3 (versionCode: 103)
- Fixed module deletion issue after running Action and rebooting.
- Fixed `MODPATH` resolution in `action.sh` to ensure absolute path fallback (`/data/adb/modules/xiaomi_prop`).
- Safe `module.prop` description updating via temporary files to prevent corrupted/0-byte prop files.
- Removed destructive comment stripper in `update-binary`.

## v1.0.2 (versionCode: 102)
- Fixed WebUI shell bridge execution using universal `execShell`.
