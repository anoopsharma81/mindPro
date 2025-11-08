# Firebase Functions Deployment Guide

## Overview
This guide explains how to deploy the Metanoia backend to Firebase Functions so AI features work on any device, anywhere.

## What's Been Done

✅ Created Firebase Functions project structure
✅ Converted backend endpoints to Firebase Functions
✅ Updated Flutter app to use Firebase Functions URLs
✅ Added environment-based API URL switching

## Next Steps to Deploy

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Initialize Firebase Project (if not already done)
```bash
firebase init functions
```
- Select existing project: `metanoia-a3035`
- Choose Node.js 18
- Use ESLint: No (for now)
- Install dependencies: Yes

### 4. Set Environment Secrets
```bash
firebase functions:secrets:set OPENAI_API_KEY
```
Enter your OpenAI API key when prompted.

### 5. Deploy to Firebase
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 6. Update Flutter App

After deployment, get your function URLs from Firebase Console or using:
```bash
firebase functions:config:get
```

Update `lib/core/env.dart` with your actual function URLs:
```dart
defaultValue: 'https://YOUR-REGION-metanoia-a3035.cloudfunctions.net/api'
```

For example:
```dart
defaultValue: 'https://us-central1-metanoia-a3035.cloudfunctions.net/api'
```

### 7. Build and Test
```bash
flutter run --dart-define=ENV=prod
```

## Current Setup

### Development (Current)
- Local backend running on Mac: `http://Anups-Laptop.local:3001/api`
- iPhone connects to Mac over local network

### Production (After Deployment)
- Firebase Functions: `https://REGION-metanoia-a3035.cloudfunctions.net`
- Works on any device, anywhere

## Function URLs Structure

After deployment, your URLs will be:
- Health: `https://REGION-PROJECT.cloudfunctions.net/health`
- Transcribe: `https://REGION-PROJECT.cloudfunctions.net/transcribeAudio`
- Structure: `https://REGION-PROJECT.cloudfunctions.net/structureTranscription`
- Extract: `https://REGION-PROJECT.cloudfunctions.net/extractFromDocument`

## Environment Variables

### Required Secrets
- `OPENAI_API_KEY`: Your OpenAI API key

### Setting Secrets
```bash
firebase functions:secrets:set OPENAI_API_KEY
# Enter your API key when prompted
```

## Testing Locally

Before deploying, you can test Firebase Functions locally:
```bash
cd functions
npm install
firebase emulators:start
```

Then update your Flutter app to use:
`http://localhost:5001/metanoia-a3035/us-central1/api`

## Cost Considerations

### Firebase Functions Pricing
- **Free Tier**: 2 million invocations/month
- **Paid**: $0.40 per million invocations

### OpenAI API Costs
- **Whisper API**: $0.006 per minute
- **GPT-4**: $0.03 per 1K tokens input, $0.06 per 1K tokens output

### Estimated Monthly Costs
- Small practice (50 users, 200 calls/day): ~$20-30/month
- Medium practice (200 users, 500 calls/day): ~$50-80/month
- Large practice (500+ users): Scale accordingly

## Rollback Plan

If deployment fails or issues occur:
```bash
firebase functions:delete FUNCTION_NAME
```

## Monitoring

Monitor function logs:
```bash
firebase functions:log
```

View in Firebase Console:
- Go to Functions tab
- Check logs and metrics

## Next Steps After Deployment

1. ✅ Test on iPhone without Mac connection
2. ✅ Monitor function costs
3. ✅ Set up error alerts
4. ✅ Configure auto-scaling
5. ✅ Add rate limiting if needed

## Support

If deployment fails:
1. Check logs: `firebase functions:log`
2. Verify secrets are set: `firebase functions:config:get`
3. Test locally first: `firebase emulators:start`
4. Check Firebase project settings in console

