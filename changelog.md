# Changelog - Xiaomi Props Rotator

## v1.0.5 (versionCode: 105)
- Removed forced `svc power reboot` from `action.sh` which caused filesystem unmount corruption and module deletion on boot.
- Action button now safely updates properties and prompts the user to reboot manually from root manager.

## v1.0.4 (versionCode: 104)
- Fixed service.sh shebang and function crash.
