# Metanoia - Reflective Intelligence

**AI-powered NHS appraisal assistant for doctors**

## What Is Metanoia?

Metanoia is a Flutter-based mobile and web application that helps NHS doctors streamline their annual appraisal process through intelligent reflective practice and CPD tracking.

### Core Features

- 📝 **Structured Reflections**: Create reflections using "What? So What? Now What?" framework
- 🧠 **AI-Powered Analysis**: Clinical reasoning framework with cognitive bias detection
- 🎤 **Voice Notes**: Record and transcribe reflections on-the-go
- 📸 **Document Extraction**: Extract reflections from photos and documents
- 🎓 **CPD Tracking**: Track continuing professional development activities
- 🏷️ **GMC Domain Mapping**: Automatically map activities to Good Medical Practice domains
- 🔒 **PHI Detection**: Built-in patient information detection for compliance
- 📊 **Export**: Generate appraisal-ready documents
- 📅 **Year-Based Organization**: Organize by appraisal year

### Key Technologies

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Node.js with OpenAI integration
- **Database**: Firebase Firestore
- **Storage**: Firebase Storage
- **Authentication**: Firebase Auth

### Quick Start

See [QUICK_START.md](QUICK_START.md) for a 5-minute setup guide.

### Documentation

- [APP_DESCRIPTION.md](APP_DESCRIPTION.md) - Comprehensive app description
- [USER_GUIDE.md](USER_GUIDE.md) - User documentation
- [PILOT_LAUNCH_READY.md](PILOT_LAUNCH_READY.md) - Launch checklist
- [PROJECT_COMPLETE.md](PROJECT_COMPLETE.md) - Complete project overview

### Getting Started (Development)

```bash
# Install dependencies
flutter pub get

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android

# Run on Web
flutter run -d chrome
```

### Environment Setup

1. Configure Firebase (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md))
2. Set up backend API (see `backend/README.md`)
3. Configure environment variables (see `lib/core/env.dart`)

### Project Structure

```
lib/
├── core/           # Core utilities (env, logger, HTTP client)
├── features/       # Feature modules
│   ├── auth/      # Authentication
│   ├── dashboard/ # Dashboard
│   ├── reflections/ # Reflections management
│   ├── cpd/       # CPD tracking
│   └── profile/   # User profile
├── services/      # API and Firebase services
└── shared/        # Shared widgets and utilities
```

### License

[Add your license here]

### Support

For issues and questions, please contact [your support email or repository issues]
