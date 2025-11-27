# Web Deployment Plan for Metanoia App

## Overview
Deploy the Flutter app as a Progressive Web App (PWA) accessible via web browser, hosted on Firebase Hosting.

## Current Status
✅ Flutter web support enabled  
✅ Firebase web configuration exists  
✅ Web-specific code checks in place (kIsWeb)  
✅ File picker and image picker support web  
⚠️ Voice recording disabled on web (expected)  
❌ Firebase Hosting not configured  
❌ Web app metadata needs updating  

## Implementation Steps

### 1. Configure Firebase Hosting
- Add hosting configuration to `firebase.json`
- Set up public directory for web build output
- Configure redirects and headers

### 2. Update Web Metadata
- Update `web/index.html` with proper app name and description
- Update `web/manifest.json` with NHS branding
- Add proper meta tags for SEO and PWA

### 3. Build Flutter Web App
- Run `flutter build web --release`
- Verify build output in `build/web/`

### 4. Deploy to Firebase Hosting
- Run `firebase deploy --only hosting`
- Get public URL (e.g., `https://mindclon-dev.web.app`)

### 5. Test Web App
- Authentication (Google Sign-In, Apple Sign-In)
- File uploads (documents, photos)
- Reflection creation and editing
- CPD tracking
- Learning loops
- Export functionality

## Web-Specific Considerations

### ✅ Supported Features
- Authentication (Google Sign-In, Apple Sign-In)
- File picker (documents, images)
- Image picker (gallery)
- Firebase services (Firestore, Storage, Functions)
- All reflection features
- CPD tracking
- Learning loops
- Export to PDF

### ⚠️ Limited/Unsupported Features
- **Voice recording**: Not available on web (shows error message)
- **Camera access**: Limited (uses file picker instead)
- **Push notifications**: Limited support (web notifications available but less reliable)
- **Offline mode**: Limited (Firestore offline persistence works but app may not fully work offline)

## Deployment URLs

After deployment, the app will be available at:
- **Primary**: `https://mindclon-dev.web.app`
- **Custom domain** (if configured): `https://yourdomain.com`

## Next Steps After Deployment

1. **Custom Domain** (optional)
   - Add custom domain in Firebase Console
   - Update DNS records
   - Configure SSL certificate

2. **Analytics** (optional)
   - Enable Firebase Analytics for web
   - Track user engagement

3. **SEO Optimization** (optional)
   - Add meta tags for search engines
   - Create sitemap.xml
   - Add structured data

4. **Performance Optimization** (optional)
   - Enable CDN caching
   - Optimize asset loading
   - Implement lazy loading

## Cost Implications

Firebase Hosting:
- **Free tier**: 10 GB storage, 360 MB/day transfer
- **Blaze plan**: Pay-as-you-go ($0.026/GB storage, $0.15/GB transfer)
- **Estimated cost**: ~$0-5/month for typical usage

## Security Considerations

1. **CORS**: Firebase Hosting automatically handles CORS
2. **HTTPS**: Automatically enabled by Firebase
3. **Authentication**: Same Firebase Auth as mobile apps
4. **API Keys**: Web API keys are public (Firebase handles security via rules)

## Testing Checklist

- [ ] App loads in browser
- [ ] Google Sign-In works
- [ ] Apple Sign-In works (if configured)
- [ ] Can create reflection
- [ ] Can upload document/photo
- [ ] Can edit reflection
- [ ] Can create CPD entry
- [ ] Can generate learning loop
- [ ] Can export to PDF
- [ ] Voice recording shows appropriate error
- [ ] Responsive design works on mobile browsers
- [ ] PWA install prompt appears (if enabled)

