#!/bin/bash

# Helper script to build and launch Flutter iOS app
# This avoids the stuck "Installing and launching..." issue

set -e  # Exit on error

# Device and bundle configuration
DEVICE_UDID="00008101-000A386A1446001E"
BUNDLE_ID="com.metanoia.flutter.v2"

echo "🧹 Cleaning up any stuck processes..."
# Kill any existing app processes on device (ignore errors if none running)
xcrun devicectl device process kill --device "$DEVICE_UDID" "$BUNDLE_ID" 2>/dev/null || true
# Kill any stuck Flutter processes
pkill -f "flutter.*run" 2>/dev/null || true
pkill -f "devicectl.*install" 2>/dev/null || true

echo ""
echo "🚀 Building Flutter iOS app (with code signing)..."
flutter build ios --debug || { echo "❌ Flutter build failed. Exiting."; exit 1; }

echo ""
echo "📱 Installing app on device..."
xcrun devicectl device install app \
  --device "$DEVICE_UDID" \
  build/ios/iphoneos/Runner.app || { echo "❌ App installation failed. Exiting."; exit 1; }

echo ""
echo "▶️  Launching app..."
xcrun devicectl device process launch \
  --device "$DEVICE_UDID" \
  "$BUNDLE_ID" || { echo "❌ App launch failed. Exiting."; exit 1; }

echo ""
echo "✅ App launched successfully!"
echo ""
echo "💡 To enable hot reload, run this in a separate terminal:"
echo "   flutter attach -d $DEVICE_UDID"
echo ""
echo "   Or use 'flutter run -d $DEVICE_UDID' and let it attach automatically"
