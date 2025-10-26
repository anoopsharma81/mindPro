# Metanoia Cloud Functions

Firebase Cloud Functions for AI-powered document extraction and reflection generation.

## Features

- **OCR Extraction**: Google Cloud Vision API for photo/image text extraction
- **PDF Parsing**: Extract text from PDF documents
- **AI Generation**: OpenAI GPT-3.5 Turbo for structured reflection creation
- **PHI Detection**: Automatic detection of Protected Health Information
- **NHS Compliance**: UK region deployment, data privacy checks

## Setup

### 1. Install Dependencies

```bash
cd functions
npm install
```

### 2. Configure Environment Variables

Create a `.env` file (copy from `env.example`):

```bash
cp env.example .env
```

Then edit `.env` and add your API keys:

```
OPENAI_API_KEY=sk-your-actual-key-here
GOOGLE_CLOUD_PROJECT_ID=your-firebase-project-id
```

### 3. Set Firebase Secrets

For production, use Firebase secrets instead of .env:

```bash
firebase functions:secrets:set OPENAI_API_KEY
firebase functions:secrets:set GOOGLE_CLOUD_PROJECT_ID
```

### 4. Enable Google Cloud Vision API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. Navigate to "APIs & Services" > "Library"
4. Search for "Cloud Vision API"
5. Click "Enable"

## Development

### Run Functions Locally

```bash
npm run serve
```

This starts the Firebase emulator suite.

### Build TypeScript

```bash
npm run build
```

### Deploy to Firebase

```bash
npm run deploy
```

Or deploy specific function:

```bash
firebase deploy --only functions:extractReflectionFromDocument
```

## API Endpoint

### `extractReflectionFromDocument`

**Type**: HTTPS Callable Function  
**Region**: europe-west2 (London)  
**Auth**: Required

**Request**:
```typescript
{
  userId: string,
  source: 'photo' | 'document' | 'gallery',
  photoUrl: string,  // Firebase Storage URL
  mimeType: string
}
```

**Response**:
```typescript
{
  success: true,
  reflection: {
    title: string,
    what: string,
    soWhat: string,
    nowWhat: string,
    tags: string[],
    suggestedDomains: number[],
    confidence: number  // 0.0-1.0
  },
  metadata: {
    processingTime: number,  // seconds
    extractedText: string
  }
}
```

**Error Response**:
```typescript
{
  success: false,
  error: string,
  code: string
}
```

## Architecture

```
extractReflectionFromDocument
  ↓
extractReflection (orchestrator)
  ↓
  ├─ ocrService.extractText()
  │   ├─ Google Cloud Vision (for images)
  │   └─ pdf-parse (for PDFs)
  │
  ├─ phiDetector.detectPhi()
  │   └─ Regex-based PHI detection
  │
  └─ aiService.generateReflection()
      └─ OpenAI GPT-3.5 Turbo
```

## Cost Estimation

### Google Cloud Vision API
- First 1,000 requests/month: FREE
- After that: $1.50 per 1,000 images

### OpenAI GPT-3.5 Turbo
- Input: ~$0.0005 per request
- Output: ~$0.0015 per request
- Total: ~$0.002 per extraction

### Firebase Cloud Functions
- Free tier: 2M invocations/month
- Compute time: $0.0000025 per GB-second

### Total Cost per Extraction
~$0.0035 per extraction (after free tiers)

**Monthly cost for 1000 users (4 extractions each)**:
- 4,000 extractions × $0.0035 = **$14/month**

## Testing

### Unit Tests

```bash
npm test
```

### Manual Testing with Emulator

1. Start emulator: `npm run serve`
2. Call function from Flutter app (update API endpoint to localhost)
3. Check logs in terminal

### Production Testing

1. Deploy function
2. Test from Flutter app
3. Monitor logs:

```bash
firebase functions:log
```

## Monitoring

### View Logs

```bash
firebase functions:log --only extractReflectionFromDocument
```

### Cloud Console

Go to [Firebase Console](https://console.firebase.google.com) → Functions → Logs

## Security

- ✅ Authentication required for all function calls
- ✅ User ID validation (only own data)
- ✅ PHI detection and logging
- ✅ Secrets stored in Firebase Secret Manager
- ✅ HTTPS-only communication
- ✅ EU region deployment (GDPR compliance)

## Troubleshooting

### "OPENAI_API_KEY not set"
- Set the secret: `firebase functions:secrets:set OPENAI_API_KEY`
- For local: Add to `.env` file

### "Vision API not enabled"
- Enable at: https://console.cloud.google.com/apis/library/vision.googleapis.com

### "Permission denied"
- Check user authentication
- Verify userId matches auth.uid
- Check Firestore security rules

### "OCR failed: No text detected"
- Image quality too low
- No text in image
- Try different image

### "AI generation failed"
- Check OpenAI API key validity
- Check account has credits
- Check rate limits

## Performance

- **Typical processing time**: 5-10 seconds
- **Timeout**: 540 seconds (9 minutes max)
- **Memory**: 512MB allocated
- **Concurrent executions**: Auto-scaled by Firebase

## Limitations

- Max file size: 10MB (Firebase Storage limit)
- Max text length: 2000 characters (to avoid token limits)
- OCR accuracy depends on image quality
- AI generation quality depends on input text

## Future Enhancements

- [ ] GPT-4 Vision for better photo understanding
- [ ] Fine-tuned model for medical reflections
- [ ] Batch processing for multiple documents
- [ ] Real-time progress updates
- [ ] Confidence score calibration
- [ ] Multi-language support

## Support

For issues or questions:
1. Check Firebase logs
2. Review error messages
3. Check API quotas
4. Verify environment configuration



