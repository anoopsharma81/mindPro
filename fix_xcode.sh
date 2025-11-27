#!/bin/bash

echo "🔧 Fixing Xcode Configuration for iPhone Connection"
echo "=================================================="
echo ""

# Check current path
CURRENT_PATH=$(xcode-select -p)
echo "Current xcode-select path: $CURRENT_PATH"
echo ""

if [ "$CURRENT_PATH" != "/Applications/Xcode.app/Contents/Developer" ]; then
    echo "❌ Currently using Command Line Tools instead of full Xcode"
    echo ""
    echo "Switching to full Xcode..."
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully switched to full Xcode"
    else
        echo "❌ Failed to switch. Please run manually:"
        echo "   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
        exit 1
    fi
else
    echo "✅ Already using full Xcode"
fi

echo ""
echo "Running Xcode first launch setup..."
sudo xcodebuild -runFirstLaunch

echo ""
echo "Verifying setup..."
NEW_PATH=$(xcode-select -p)
echo "New xcode-select path: $NEW_PATH"

if [ "$NEW_PATH" == "/Applications/Xcode.app/Contents/Developer" ]; then
    echo ""
    echo "✅ Xcode is now properly configured!"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode: open -a Xcode"
    echo "2. Sign in with your Apple ID (if prompted)"
    echo "3. Go to Window → Devices and Simulators"
    echo "4. Your iPhone should appear there"
    echo "5. Run: flutter devices"
else
    echo "❌ Configuration failed. Please check manually."
fi








