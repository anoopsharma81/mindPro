# Faster Installation Guide

## What I Did

**Stopped**: Slow simulator installation  
**Started**: Faster installation on **GBC's iPhone** (your physical device)

Physical devices are typically **faster** than simulators for fresh installations.

---

## Why Simulator Was Slow

### Simulator Issues
- Virtual hardware (slower)
- Shares Mac's resources
- Large app size
- Multiple Flutter instances running
- Fresh install = all frameworks installed

### Typical Times
- **Simulator**: 3-5 minutes (slow)
- **Physical iPhone**: 1-2 minutes (faster)
- **Hot reload**: 1-2 seconds (instant)
- **Hot restart**: 10-20 seconds (quick)

---

## What's Installing Now

**Target**: GBC's iPhone (00008120-0018048834FBC01E)  
**App**: Metanoia with all latest fixes  
**Permissions**: Will be registered fresh  

---

## After Installation Completes

### Test Microphone Permission

1. **Delete old app** from physical iPhone if it's there
2. **Wait for new install** to complete
3. **Open app**
4. **Try voice recording**:
   - Reflections → Create Voice Note
   - Or tap mic icon
5. **System asks**: "Metanoia would like to access Microphone"
6. **Tap "Allow"**
7. **Works!** 🎤

### Verify in Settings

Settings → Metanoia → Microphone: On ✅

---

## Speed Tips for Future

### Fast Development
```bash
# Hot reload (changes only)
Press 'r' in terminal - 1-2 seconds ⚡

# Hot restart (reset state)
Press 'R' in terminal - 10-20 seconds 🔥

# Full rebuild (only when needed)
flutter run - 1-2 minutes
```

### When to Use Each

**Hot Reload (`r`):**
- UI changes
- Logic changes
- Most code updates
- **Fastest!** ⚡

**Hot Restart (`R`):**
- State reset needed
- Environment changes
- Constructor changes
- **Fast!** 🔥

**Full Rebuild:**
- Dependency changes (pubspec.yaml)
- Native code changes (iOS/Android)
- Permission changes
- **Slow** ⏳

**Reinstall (Delete + Install):**
- Permission registration
- Bundle ID changes
- Fresh start needed
- **Slowest** 🐢

---

## If Still Slow

### Free Up Resources

**Close unnecessary apps:**
```bash
# Close Chrome (if not needed)
pkill -f "Chrome"

# Close other simulators
xcrun simctl shutdown all
```

**Check what's running:**
```bash
# See active Flutter processes
ps aux | grep flutter | grep -v grep
```

---

## Alternative: Use Physical Device Only

Physical devices are faster and more reliable:

```bash
# Always use GBC's iPhone
flutter run -d 00008120-0018048834FBC01E

# Check it's connected
flutter devices | grep "GBC"
```

---

## Current Status

**Action**: Installing on GBC's iPhone  
**Progress**: Check your terminal for updates  
**Time**: Should complete in 1-2 minutes  
**Next**: Test microphone permission  

---

## Watch Terminal

You should see:
```
Launching lib/main.dart on GBC's iPhone...
Running Xcode build...
Xcode build done.
Installing and launching...  ← Takes 1-2 minutes
flutter: [INFO] Firebase initialized  ← Installation complete!
```

---

**The app is installing on your physical iPhone now - should be much faster!** 📱⚡

