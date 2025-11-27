#!/bin/bash

echo "🔧 Installing Rosetta 2 for Flutter Debugging"
echo "=============================================="
echo ""
echo "This will install Rosetta 2, which is needed for Flutter's"
echo "debugging connection (iproxy) on Apple Silicon Macs."
echo ""
echo "You'll be prompted for your Mac password."
echo ""
read -p "Press Enter to continue, or Ctrl+C to cancel..."

sudo softwareupdate --install-rosetta --agree-to-license

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Rosetta 2 installed successfully!"
    echo ""
    echo "Now you can run:"
    echo "  flutter run -d 00008101-000A386A1446001E"
    echo ""
    echo "Debugging and hot reload will work!"
else
    echo ""
    echo "❌ Installation failed. Please run manually:"
    echo "  sudo softwareupdate --install-rosetta --agree-to-license"
fi








