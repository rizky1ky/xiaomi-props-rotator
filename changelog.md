# Changelog - Xiaomi Props Rotator

## v1.0.6 (versionCode: 106)
- Applied strict file permissions (`0644 root:root`) and SELinux context restoration (`restorecon`) on all modified module files (`system.prop`, `module.prop`, `mode.txt`, `selected.txt`) to prevent daemon auto-deletion on reboot.

## v1.0.5 (versionCode: 105)
- Removed forced reboot from `action.sh`.
