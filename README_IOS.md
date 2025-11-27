# iOS Build & Launch Helper

## Quick Start

Instead of `flutter run -d ios`, use this script:

```bash
./run_ios.sh
```

This script:
1. ✅ Builds your iOS app
2. ✅ Installs it on your iPhone
3. ✅ Launches it immediately

**No more stuck "Installing and launching..." issues!**

## What This Fixes

The `flutter run` command often gets stuck at "Installing and launching..." on iOS devices. This script bypasses that issue by:
- Using `flutter build` instead of `flutter run`
- Manually installing and launching via `devicectl`
- Working reliably every time

## Hot Reload Still Works

Once the app is running, Flutter's hot reload still works perfectly:
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## Device ID

The script uses device ID: `00008101-000A386A1446001E`

If you need to change it:
1. Run `flutter devices` to get your device ID
2. Edit `run_ios.sh` and replace the device ID

## Alternative: Use Flutter Command (If It Works)

If `flutter run` starts working again, you can use it normally:

```bash
flutter run -d 00008101-000A386A1446001E
```

But if it gets stuck, just use `./run_ios.sh` instead!



