#!/bin/bash

echo "🚀 Deploying Firebase Functions"
echo "================================"
echo ""

# Check if OpenAI key is set
echo "Step 1: Set OpenAI API Key Secret"
echo "-----------------------------------"
echo "You'll be prompted to enter your OpenAI API key."
echo ""
read -p "Press Enter to continue, or Ctrl+C to cancel..."

firebase functions:secrets:set OPENAI_API_KEY

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Failed to set secret. Please run manually:"
    echo "   firebase functions:secrets:set OPENAI_API_KEY"
    exit 1
fi

echo ""
echo "✅ Secret set successfully!"
echo ""

# Build
echo "Step 2: Building TypeScript..."
echo "------------------------------"
cd functions
npm run build

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Build failed. Please fix errors and try again."
    exit 1
fi

echo ""
echo "✅ Build successful!"
echo ""

# Deploy
echo "Step 3: Deploying Functions..."
echo "-------------------------------"
echo "This will take 5-10 minutes..."
echo ""
cd ..
firebase deploy --only functions

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "Your functions are now live at:"
    echo "https://europe-west2-mindclon-dev.cloudfunctions.net"
    echo ""
    echo "Next: Hot restart your Flutter app (press 'r' in terminal)"
else
    echo ""
    echo "❌ Deployment failed. Check errors above."
    exit 1
fi






