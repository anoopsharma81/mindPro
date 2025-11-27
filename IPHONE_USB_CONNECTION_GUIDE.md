# iPhone USB Connection Guide
## Connect Your iPhone for Development Testing

---

## 🔌 **STEP 1: Physical Connection**

1. **Connect iPhone to Mac** using a USB cable (Lightning or USB-C)
2. **Unlock your iPhone** (enter passcode if needed)
3. **Wait a few seconds** for the connection to establish

---

## 📱 **STEP 2: Trust This Computer**

When you connect your iPhone, you'll see a popup on your iPhone:

1. **On iPhone**: Tap **"Trust"** when prompted
2. **Enter your iPhone passcode** if asked
3. You should see: **"Trusted Computer"** message

**If you don't see the popup:**
- Disconnect and reconnect the cable
- Make sure iPhone is unlocked
- Try a different USB port or cable

---

## 🔓 **STEP 3: Enable Developer Mode (iOS 16+)**

If your iPhone is running iOS 16 or later, you need to enable Developer Mode:

1. **On iPhone**: Go to **Settings** → **Privacy & Security**
2. Scroll down to find **"Developer Mode"**
3. **Toggle it ON**
4. **Restart your iPhone** when prompted
5. After restart, **confirm** you want to enable Developer Mode

**Note**: If you don't see "Developer Mode" option, you may need to connect to Xcode first (see Step 4).

---

## 💻 **STEP 4: Open Xcode (First Time Only)**

For the first connection, you may need to open Xcode:

1. **Open Xcode** on your Mac:
   ```bash
   open -a Xcode
   ```

2. **In Xcode**: 
   - Go to **Xcode** → **Settings** (or **Preferences**)
   - Click **"Accounts"** tab
   - Sign in with your **Apple ID** (if not already signed in)
   - This registers your device for development

3. **Connect iPhone**:
   - In Xcode, go to **Window** → **Devices and Simulators**
   - You should see your iPhone listed
   - If you see a warning, click **"Use for Development"**

---

## ✅ **STEP 5: Verify Connection**

Check if Flutter can see your iPhone:

```bash
flutter devices
```

You should see your iPhone listed, something like:
```
iPhone (mobile) • 00008120-0018048834FBC01E • ios • iOS 17.x
```

**If you don't see it:**
- Make sure iPhone is unlocked
- Try unplugging and replugging the cable
- Check if iPhone shows "Trusted Computer"
- Run `flutter doctor` to check for issues

---

## 🚀 **STEP 6: Run Your App**

Once your iPhone is detected, you can run the app:

```bash
# Run on your connected iPhone
flutter run

# Or specify the device ID
flutter run -d 00008120-0018048834FBC01E
```

**First time running:**
- You may need to **trust the developer** on your iPhone
- Go to **Settings** → **General** → **VPN & Device Management**
- Tap on the developer profile
- Tap **"Trust"**

---

## 🔧 **TROUBLESHOOTING**

### iPhone Not Showing Up

**Check 1: Cable & Connection**
- Try a different USB cable
- Try a different USB port
- Make sure cable supports data (not just charging)

**Check 2: iPhone Settings**
- iPhone must be unlocked
- iPhone must trust the computer
- Developer Mode must be enabled (iOS 16+)

**Check 3: Xcode Setup**
- Open Xcode at least once
- Sign in with Apple ID in Xcode
- Check **Window** → **Devices and Simulators**

**Check 4: Flutter Doctor**
```bash
flutter doctor -v
```
Look for iOS-related issues and fix them.

### "Untrusted Developer" Error

1. On iPhone: **Settings** → **General** → **VPN & Device Management**
2. Find your developer profile (your name or email)
3. Tap it
4. Tap **"Trust [Your Name]"**
5. Confirm by tapping **"Trust"** again

### Developer Mode Not Showing

1. Connect iPhone to Mac
2. Open Xcode
3. In Xcode: **Window** → **Devices and Simulators**
4. Select your iPhone
5. Developer Mode option should appear in iPhone Settings

### "Could not find Developer Disk Image"

This means Xcode version doesn't match iOS version:
- Update Xcode to latest version
- Or update iPhone iOS to match Xcode version

---

## 📋 **QUICK CHECKLIST**

- [ ] iPhone connected via USB cable
- [ ] iPhone unlocked
- [ ] iPhone trusts this computer
- [ ] Developer Mode enabled (iOS 16+)
- [ ] Xcode opened and signed in with Apple ID
- [ ] iPhone appears in `flutter devices`
- [ ] Developer profile trusted on iPhone (first run)

---

## 🎯 **QUICK COMMANDS**

```bash
# Check connected devices
flutter devices

# Run on iPhone (auto-select)
flutter run

# Run on specific device
flutter run -d <device-id>

# Check Flutter setup
flutter doctor

# List iOS simulators
flutter emulators
```

---

## 💡 **TIPS**

1. **Keep iPhone unlocked** while developing (or set longer auto-lock time)
2. **Use original Apple cable** or certified cable for best results
3. **First connection takes longer** - be patient
4. **Hot reload works** on physical devices too!
5. **For wireless debugging** (later): Enable it in Xcode after first USB connection

---

## 🔄 **NEXT STEPS**

Once connected:
1. ✅ Run `flutter devices` to verify
2. ✅ Run `flutter run` to launch app
3. ✅ Test all features on physical device
4. ✅ Test microphone permissions (may need app reinstall)

---

*Last updated: Based on current Flutter/iOS setup*
*For wireless debugging setup, see Xcode documentation*








