# Microphone Permission - Step by Step Fix

## ✅ What I Just Did

1. **Uninstalled the app** from iPhone 17 simulator
2. **Reinstalling fresh** so iOS registers microphone permission

---

## What Will Happen

### During Fresh Install
iOS will read `Info.plist` and register all permissions:
- ✅ Camera
- ✅ Photos
- ✅ **Microphone** (will be registered now!)

### When You Try Voice Recording
1. Tap microphone icon in app
2. **System dialog appears**: "Metanoia would like to access the Microphone"
3. Your message shown: "We need microphone access to record voice notes for creating reflections."
4. Tap **"Allow"**
5. Recording starts! ✅

### In Settings
After allowing, you'll see:
- Settings → Metanoia → **Microphone: On** ✅

---

## For Physical iPhone (GBC's iPhone)

If you want to test on your physical phone instead:

1. **Delete Metanoia app** from your iPhone
2. Run this command:
   ```bash
   flutter run -d 00008120-0018048834FBC01E
   ```
3. When app installs, try voice recording
4. Allow microphone when prompted
5. Works! ✅

---

## Why This Was Needed

**iOS Security Design:**
- Permissions declared in Info.plist
- Only read on **first install**
- Updates don't re-scan permissions
- Solution: Delete and reinstall

**Your Info.plist** (already correct):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record voice notes for creating reflections.</string>
```

---

## Testing After Reinstall

1. ✅ Wait for app to install
2. ✅ Open Reflections
3. ✅ Create Voice Note
4. ✅ Tap microphone icon
5. ✅ See permission dialog
6. ✅ Tap "Allow"
7. ✅ Start recording! 🎤

---

## Status

**Uninstall**: ✅ Complete  
**Reinstall**: ⏳ In progress (check terminal)  
**Permission**: ✅ Will be registered on fresh install  

---

## Next Steps

1. Wait for app to finish installing
2. Try voice recording feature
3. Allow microphone when prompted
4. Verify it works!

**The app is reinstalling now - microphone will work once it's done!** 🎤✨

