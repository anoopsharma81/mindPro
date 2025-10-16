#!/bin/bash

# OpenAI API Key Setup Script

echo "🔑 OpenAI API Key Setup"
echo "========================"
echo ""
echo "You need an OpenAI API key to use photo extraction and AI features."
echo ""
echo "To get your API key:"
echo "1. Go to: https://platform.openai.com/api-keys"
echo "2. Sign in or create an account"
echo "3. Click 'Create new secret key'"
echo "4. Copy the key (starts with sk-)"
echo ""
echo -n "Paste your OpenAI API key here: "
read -r OPENAI_KEY

if [ -z "$OPENAI_KEY" ]; then
    echo "❌ No key provided. Exiting."
    exit 1
fi

if [[ ! "$OPENAI_KEY" =~ ^sk- ]]; then
    echo "⚠️  Warning: Key doesn't start with 'sk-'. Are you sure this is correct?"
    echo -n "Continue anyway? (y/n): "
    read -r CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        echo "❌ Cancelled."
        exit 1
    fi
fi

# Update .env file
cat > .env << EOF
# Backend API Configuration
PORT=3001
NODE_ENV=development
OPENAI_API_KEY=$OPENAI_KEY
EOF

echo ""
echo "✅ API key saved to backend/.env"
echo ""
echo "Next steps:"
echo "1. Restart the backend: npm start"
echo "2. Test photo extraction in the app"
echo ""

