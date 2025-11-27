# Code Signing Setup for iPhone

## ✅ Good News: iPhone is Detected!

Your iPhone is now visible to Flutter:
- **Device ID**: `00008101-000A386A1446001E`
- **Status**: Connected ✅

## ❌ Current Issue: Code Signing

Flutter can see your iPhone but needs a development certificate to deploy the app.

---

## 🔧 **FIX: Set Up Code Signing in Xcode**

Xcode should now be open. Follow these steps:

### Step 1: Sign In with Apple ID

1. In Xcode, go to **Xcode** → **Settings** (or **Preferences**)
2. Click the **"Accounts"** tab
3. Click the **"+"** button (bottom left)
4. Select **"Apple ID"**
5. Enter your **Apple ID** and password
6. Click **"Sign In"**

**Note**: You can use a free Apple ID (no $99 developer account needed for development)

### Step 2: Select Development Team

1. In Xcode, in the left sidebar, click on **"Runner"** (blue icon at the top)
2. In the main area, select the **"Runner"** target (under TARGETS)
3. Click the **"Signing & Capabilities"** tab
4. Under **"Team"**, click the dropdown
5. Select your **Apple ID** (your name/email)
6. Xcode will automatically:
   - Create a development certificate
   - Create a provisioning profile
   - Register your device

**If you see errors:**
- Make sure you're signed in (Step 1)
- Try clicking **"Try Again"** button
- Xcode may need a few seconds to create certificates

### Step 3: Verify Automatic Signing

1. Make sure **"Automatically manage signing"** is **checked** ✅
2. You should see:
   - ✅ **Team**: Your Apple ID
   - ✅ **Provisioning Profile**: Xcode Managed Profile
   - ✅ **Signing Certificate**: Apple Development

### Step 4: Trust Developer Certificate on iPhone

**On your iPhone:**

1. Go to **Settings** → **General** → **VPN & Device Management**
2. Find your developer profile (your name/email)
3. Tap it
4. Tap **"Trust [Your Name]"**
5. Confirm by tapping **"Trust"** again

---

## 🚀 **Run Your App**

After setting up code signing, go back to Terminal and run:

```bash
flutter run -d 00008101-000A386A1446001E
```

Or simply:

```bash
flutter run
```

Flutter will automatically select your connected iPhone.

---

## 🔍 **Troubleshooting**

### Error: "No valid code signing certificates"

**Solution**: Make sure you:
1. ✅ Signed in to Xcode with Apple ID
2. ✅ Selected a Team in Signing & Capabilities
3. ✅ "Automatically manage signing" is checked

### Error: "Device not registered"

**Solution**: 
1. In Xcode: **Window** → **Devices and Simulators**
2. Select your iPhone
3. Click **"Use for Development"**

### Error: "Provisioning profile doesn't match"

**Solution**:
1. In Xcode, go to **Signing & Capabilities**
2. Uncheck and re-check **"Automatically manage signing"**
3. Select your Team again
4. Wait for Xcode to regenerate the profile

### Error: "Untrusted Developer"

**Solution**:
1. On iPhone: **Settings** → **General** → **VPN & Device Management**
2. Trust your developer certificate

---

## 📋 **Quick Checklist**

- [ ] Signed in to Xcode with Apple ID
- [ ] Selected Team in Signing & Capabilities
- [ ] "Automatically manage signing" is checked
- [ ] Trusted developer certificate on iPhone
- [ ] Run `flutter run` again

---

## 💡 **Current Configuration**

Your project is already configured with:
- **Bundle ID**: `com.metanoia.flutter.v2`
- **Signing Style**: Automatic
- **Team**: B3H8XJTG3U (may need to be updated)

---

## ⏱️ **Time Estimate**

- **Signing in**: 1 minute
- **Setting up signing**: 2-3 minutes
- **Trusting certificate**: 1 minute
- **Total**: ~5 minutes

---

*Once code signing is set up, you'll be able to deploy to your iPhone!*








