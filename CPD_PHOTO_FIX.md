# CPD Photo Upload Crash - FIXED ✅

## The Problem
App crashed when trying to upload a photo in the CPD Import section on iOS.

## Root Cause
**Missing iOS Permissions**

iOS requires explicit permission descriptions in `Info.plist` for:
- Camera access
- Photo library access

Without these, the app **crashes immediately** when trying to access camera or photos.

## The Fix ✅

Added required permissions to `ios/Runner/Info.plist`:

```xml
<!-- Camera and Photo Library Permissions -->
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to scan CPD certificates and course completion documents.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to import CPD certificates and training documentation.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save exported documents to your photo library.</string>
```

## What These Permissions Do

### NSCameraUsageDescription
- **Purpose**: Access device camera
- **Used for**: "Photo/Certificate" import in CPD
- **User sees**: Permission dialog first time camera is accessed

### NSPhotoLibraryUsageDescription
- **Purpose**: Read photos from library
- **Used for**: "From Gallery" import in CPD
- **User sees**: Permission dialog first time photo library is accessed

### NSPhotoLibraryAddUsageDescription
- **Purpose**: Save photos to library
- **Used for**: Saving exported documents
- **User sees**: Permission dialog when saving files

## How to Test

### 1. Access CPD Import:
```
Dashboard → CPD → Import button (+ icon)
```

### 2. Test Camera:
1. Tap "Photo/Certificate"
2. Should see iOS permission dialog
3. Grant permission
4. Camera opens successfully ✅

### 3. Test Gallery:
1. Tap "From Gallery"
2. Should see iOS permission dialog
3. Grant permission
4. Photo picker opens successfully ✅

## User Experience

### First Time:
```
User taps "Photo/Certificate"
    ↓
iOS shows: "Metanoia Flutter would like to access your camera"
    ↓
User taps: "Allow"
    ↓
Camera opens ✅
```

### Subsequent Times:
```
User taps "Photo/Certificate"
    ↓
Camera opens immediately (permission remembered) ✅
```

## Permission Dialog Text

Users will see:
> **"Metanoia Flutter" Would Like to Access Your Camera**
> 
> We need access to your camera to scan CPD certificates and course completion documents.
> 
> [Don't Allow] [OK]

## iOS Permission Management

### If User Denies Permission:
```
User taps "Don't Allow"
    ↓
App shows error: "Error importing photo: ..."
    ↓
User must grant permission in Settings manually
```

### How to Enable in Settings:
```
Settings → Metanoia Flutter → Photos → All Photos
Settings → Metanoia Flutter → Camera → On
```

## Why This Happens

### Apple's Privacy Requirements:
1. **Mandatory**: All camera/photo access must be declared
2. **User-facing text**: Must explain WHY access is needed
3. **Crash behavior**: Apps crash if permissions missing
4. **One-time prompt**: iOS remembers user's choice

### Android vs iOS:
| Platform | Behavior Without Permissions |
|----------|------------------------------|
| Android | Runtime permission request |
| iOS | **Immediate crash** ❌ |

## Related Files

### Modified:
- `ios/Runner/Info.plist` - Added permission strings ✅

### Uses Image Picker:
- `lib/features/cpd/presentation/cpd_import_page.dart`
  - Line 25: Camera usage
  - Line 50: Gallery usage

## Future Considerations

### Other Permissions That May Be Needed:

1. **Microphone** (if adding voice memos):
   ```xml
   <key>NSMicrophoneUsageDescription</key>
   <string>Record audio notes for reflections</string>
   ```

2. **Location** (if adding location tagging):
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Tag CPD activities with location</string>
   ```

3. **Contacts** (if adding colleague sharing):
   ```xml
   <key>NSContactsUsageDescription</key>
   <string>Share reflections with colleagues</string>
   ```

## Testing Checklist

- [ ] Build app with new permissions
- [ ] Test "Photo/Certificate" → Camera opens
- [ ] Test "From Gallery" → Photo picker opens
- [ ] Test permission denial → Error message shows
- [ ] Test permission re-grant → Works after enabling in Settings

## Summary

**Issue**: CPD photo upload crashed on iOS  
**Cause**: Missing camera/photo permissions in Info.plist  
**Fix**: Added NSCameraUsageDescription, NSPhotoLibraryUsageDescription, NSPhotoLibraryAddUsageDescription  
**Status**: ✅ FIXED - Rebuild and test

---

**The app will now properly request permissions and handle camera/photo access without crashing!** 📸

