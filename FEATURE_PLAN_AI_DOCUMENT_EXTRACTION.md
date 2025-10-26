# Feature Plan: AI Document/Photo Extraction for Reflections

**Smart Reflection Creation from Documents & Photos**

---

## 🎯 Feature Overview

### What
Allow users to create reflections by:
1. **Upload a document** (PDF, Word, text file)
2. **Upload a photo** from gallery
3. **Take a photo** with camera

Then:
- AI extracts relevant information
- AI generates a draft reflection using the "What, So What, Now What" framework
- User reviews, edits, and saves/discards

### Why
- **Faster reflection creation**: Turn existing notes/photos into structured reflections
- **Lower barrier to entry**: Don't start from blank page
- **Capture moments**: Photo of teaching session → instant reflection
- **Convert existing content**: Old notes/emails → structured reflections
- **Mobile-friendly**: Quick capture on the go

### Value Proposition
**"Turn any moment into a reflection in 30 seconds"**

---

## 📱 User Flow

### Current Flow (Manual)
```
Reflections → New → Type everything manually → Save
⏱️ Time: 10-15 minutes
😓 Effort: High (blank page syndrome)
```

### New Flow (AI-Assisted)
```
Reflections → New → "Create from..." button
  ↓
Choose: [📷 Take Photo] [🖼️ Gallery] [📄 Document]
  ↓
Capture/select content
  ↓
[AI Processing...] ⏳ 5-10 seconds
  ↓
Review AI-generated reflection
  - What happened?
  - So what? (Analysis)
  - Now what? (Action)
  - Suggested tags
  - Suggested GMC domains
  ↓
[Edit] [Save] [Discard]
  ↓
Saved reflection ready for AI improvement!

⏱️ Time: 30-60 seconds
🎉 Effort: Low (guided process)
```

---

## 🎨 UI/UX Design

### 1. New Reflection Entry Point

**Reflections List Page:**
```
Current FAB:
[+] → New reflection

New Design:
[+] → Bottom sheet with options:
  ┌─────────────────────────────────────┐
  │  Create Reflection                  │
  ├─────────────────────────────────────┤
  │  ✨ From Document/Photo (AI)        │
  │  ✏️  From Scratch                   │
  └─────────────────────────────────────┘
```

### 2. Document/Photo Selector

**After clicking "From Document/Photo":**
```
┌─────────────────────────────────────────────┐
│  How do you want to capture this?          │
├─────────────────────────────────────────────┤
│  📷  Take Photo                            │
│      Capture a moment, note, or activity   │
│                                             │
│  🖼️  Choose from Gallery                   │
│      Select existing photo                 │
│                                             │
│  📄  Upload Document                       │
│      PDF, Word, or text file               │
└─────────────────────────────────────────────┘
```

### 3. AI Processing Screen

**While AI extracts and generates:**
```
┌─────────────────────────────────────────────┐
│          [Sparkle animation ✨]             │
│                                             │
│     AI is analyzing your content...         │
│                                             │
│  [Progress indicator]                       │
│                                             │
│  • Extracting key information              │
│  • Identifying learning moments            │
│  • Structuring reflection                  │
│  • Suggesting GMC domains                  │
│                                             │
│  This usually takes 5-10 seconds            │
└─────────────────────────────────────────────┘
```

### 4. Review & Edit Screen

**AI-generated draft:**
```
┌─────────────────────────────────────────────┐
│  ← Review AI Draft                     [?]  │
├─────────────────────────────────────────────┤
│  💡 AI-Generated Reflection                 │
│                                             │
│  Title: [Extracted title]                  │
│                                             │
│  📝 What happened?                          │
│  [AI-extracted description of event]       │
│  [Editable text field]                     │
│                                             │
│  🤔 So what? (Analysis)                     │
│  [AI-generated analysis/insight]           │
│  [Editable text field]                     │
│                                             │
│  🎯 Now what? (Action)                      │
│  [AI-generated action plan]                │
│  [Editable text field]                     │
│                                             │
│  🏷️ Suggested Tags:                        │
│  [Tag1] [Tag2] [Tag3] [+ Add]             │
│                                             │
│  🎨 Suggested GMC Domains:                  │
│  [Domain 1] [Domain 2]                     │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 💡 Tip: Review and edit as needed    │ │
│  │ The AI made a first draft for you!   │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [Discard]         [Save]                  │
└─────────────────────────────────────────────┘
```

---

## 🔧 Technical Implementation

### Phase 1: Frontend Setup (Week 1)
**Dependencies:**
```yaml
dependencies:
  image_picker: ^1.0.4        # Already added ✅
  file_picker: ^6.1.1          # For document selection
  path_provider: ^2.1.1        # Already added ✅
  permission_handler: ^11.0.1  # Already added ✅
```

**New Files:**
1. `lib/services/document_extraction_service.dart`
   - Handle file upload to backend
   - Call AI extraction API
   - Parse AI response

2. `lib/features/reflections/presentation/reflection_from_document_page.dart`
   - Document/photo selection UI
   - AI processing screen
   - Review/edit draft UI

3. `lib/features/reflections/presentation/widgets/document_source_selector.dart`
   - Bottom sheet for source selection

4. `lib/features/reflections/presentation/widgets/ai_processing_indicator.dart`
   - Animated processing screen

5. `lib/features/reflections/presentation/widgets/ai_draft_review.dart`
   - Review and edit AI-generated content

### Phase 2: Backend AI Service (Week 2)

**Endpoint: `POST /api/reflections/extract`**

**Request:**
```json
{
  "userId": "firebase_user_id",
  "source": "photo|document",
  "content": "base64_encoded_content" | "text_content",
  "mimeType": "image/jpeg|application/pdf|text/plain"
}
```

**AI Processing Pipeline:**
1. **Document → Text**:
   - Images: OCR (Tesseract or Google Cloud Vision)
   - PDFs: PDF text extraction
   - Photos: OCR + scene description (GPT-4 Vision)

2. **Text → Structured Reflection**:
   - Prompt: "Extract a medical reflection using What/So What/Now What framework"
   - OpenAI GPT-4 or Claude with structured output

3. **Auto-tagging & Domain Classification**:
   - Identify key themes
   - Match to GMC domains
   - Generate relevant tags

**Response:**
```json
{
  "success": true,
  "reflection": {
    "title": "Extracted title",
    "what": "What happened description",
    "soWhat": "Analysis and learning",
    "nowWhat": "Action plan",
    "tags": ["communication", "patient-safety"],
    "suggestedDomains": [1, 3, 4],
    "confidence": 0.85
  },
  "metadata": {
    "processingTime": 8.5,
    "extractedText": "Original text for reference"
  }
}
```

### Phase 3: AI Model & Prompts (Week 2)

**OCR Options:**
1. **Google Cloud Vision API** (Recommended)
   - High accuracy for handwritten notes
   - Scene understanding
   - Text detection in images
   - Cost: $1.50/1000 images

2. **Tesseract** (Free alternative)
   - Open source
   - Lower accuracy
   - No scene understanding

**Extraction Prompt:**
```
You are an AI assistant helping NHS doctors create structured reflections.

Input: Text extracted from a document/photo about a medical experience.

Task: Create a structured reflection using the "What, So What, Now What" framework.

Guidelines:
1. What: Describe the event/experience objectively
2. So What: Analyze what was learned, implications, feelings
3. Now What: Identify concrete action steps
4. Keep medical terminology accurate
5. Be supportive and constructive
6. Extract 3-5 relevant tags
7. Suggest relevant GMC domains

GMC Domains:
1. Knowledge, skills, performance
2. Safety and quality
3. Communication, partnership, teamwork
4. Maintaining trust

Output as JSON:
{
  "title": "Brief title (5-8 words)",
  "what": "Objective description (50-100 words)",
  "soWhat": "Analysis and learning (50-100 words)",
  "nowWhat": "Action plan (30-50 words, bullet points)",
  "tags": ["tag1", "tag2", "tag3"],
  "suggestedDomains": [1, 3]
}

Input text:
{extracted_text}
```

**GPT-4 Vision Prompt** (for photos):
```
You are analyzing a photo for an NHS doctor's reflection app.

1. Describe what you see in the photo
2. Identify any text (handwritten notes, whiteboard, etc.)
3. Infer the context (teaching, patient interaction, study, etc.)
4. Extract key learning moments

Then create a structured reflection...
[Same structure as above]
```

---

## 📊 Database Schema Updates

**Add to Reflection Model:**
```dart
class Reflection {
  // ... existing fields ...
  
  // New fields for AI extraction
  final String? sourceType;        // "photo", "document", "manual"
  final String? extractedText;     // Original extracted text
  final String? sourceUrl;         // Firebase Storage URL of original
  final double? aiConfidence;      // 0.0-1.0 confidence score
  final bool isAiGenerated;        // True if created from extraction
  final DateTime? extractedAt;     // When extraction happened
}
```

**Firestore Structure:**
```
/users/{userId}/reflections/{reflectionId}
  - ... existing fields ...
  - sourceType: "photo"
  - extractedText: "Original text..."
  - sourceUrl: "gs://bucket/path/to/image.jpg"
  - aiConfidence: 0.85
  - isAiGenerated: true
  - extractedAt: Timestamp
```

---

## 🔐 Security & Privacy

### Privacy Considerations
1. **PHI Detection**: Run PHI detector on extracted text BEFORE saving
2. **Consent**: Show user extracted text before processing
3. **Storage**: Store original images in Firebase Storage (user's private bucket)
4. **Deletion**: When reflection deleted, also delete source image/document
5. **Audit Trail**: Log AI extraction events for NHS compliance

### Permissions
```dart
// iOS: Info.plist
<key>NSCameraUsageDescription</key>
<string>Take photos of notes to create reflections</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Choose photos to create reflections</string>

// Android: AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## 💰 Cost Analysis

### AI Processing Costs (per extraction)

**Option 1: GPT-4 Vision (Recommended)**
- OCR + Understanding: ~$0.01-0.02/image
- Text → Reflection: ~$0.005-0.01/extraction
- **Total: ~$0.015-0.03/extraction**

**Option 2: Google Cloud Vision + GPT-3.5**
- Google Vision: ~$0.0015/image
- GPT-3.5 Turbo: ~$0.002/extraction
- **Total: ~$0.0035/extraction**

**Option 3: Tesseract + Claude Haiku (Cheapest)**
- Tesseract: Free
- Claude Haiku: ~$0.0025/extraction
- **Total: ~$0.0025/extraction**

### Monthly Estimates
```
Scenario: 1000 users, average 4 extractions/user/month
= 4000 extractions/month

Option 1 (GPT-4 Vision): $60-120/month
Option 2 (GCV + GPT-3.5): $14/month
Option 3 (Tesseract + Haiku): $10/month
```

**Recommendation**: Start with Option 2, upgrade to Option 1 for premium users

---

## 🎯 Success Metrics

### KPIs
1. **Adoption Rate**: % users who try AI extraction
2. **Completion Rate**: % who save (vs discard) AI draft
3. **Edit Rate**: How much do users edit AI draft?
4. **Time Saved**: Time to create reflection (baseline vs AI)
5. **User Satisfaction**: NPS for AI extraction feature

### Targets (Month 1)
- [ ] 60%+ of users try AI extraction
- [ ] 70%+ save AI-generated reflections
- [ ] <30% major edits (shows AI quality is good)
- [ ] 5-10 min → 1-2 min (time saved)
- [ ] 4.5+/5 satisfaction rating

---

## 🚀 Implementation Phases

### Phase 1: MVP (2 weeks)
**Goal**: Basic photo → reflection

✅ **Week 1: Frontend**
- [ ] Add "Create from..." button to reflections list
- [ ] Implement document/photo selector bottom sheet
- [ ] Build AI processing screen with animation
- [ ] Create review/edit draft screen
- [ ] Add image_picker and file_picker dependencies
- [ ] Handle permissions properly

✅ **Week 2: Backend + Integration**
- [ ] Set up Firebase Storage for images
- [ ] Build backend extraction endpoint
- [ ] Integrate Google Cloud Vision API (OCR)
- [ ] Connect GPT-3.5 for reflection generation
- [ ] Add PHI detection to extracted text
- [ ] Test end-to-end flow
- [ ] Add error handling

### Phase 2: Enhancement (1 week)
**Goal**: Document support + better AI

✅ **Week 3**
- [ ] Add PDF/Word document support
- [ ] Upgrade to GPT-4 Vision for photos
- [ ] Add confidence scoring
- [ ] Show "areas of uncertainty" to user
- [ ] Add batch processing (multiple photos)
- [ ] Improve prompt engineering for medical context
- [ ] Add examples for few-shot learning

### Phase 3: Polish (1 week)
**Goal**: Production-ready

✅ **Week 4**
- [ ] Add loading states and error messages
- [ ] Implement retry mechanism
- [ ] Add "Save original image" toggle
- [ ] Create onboarding tutorial for feature
- [ ] Add analytics tracking
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Documentation

### Phase 4: Advanced (Future)
**Goal**: Power features

🔮 **Future Enhancements**
- [ ] Real-time OCR preview (show text as scanning)
- [ ] Multi-page document support
- [ ] Voice note → reflection (speech-to-text)
- [ ] Email forwarding (email → reflection)
- [ ] Calendar event → reflection
- [ ] Bulk import (multiple documents at once)
- [ ] Handwriting recognition optimization
- [ ] Offline OCR (on-device)

---

## 🎓 Example Use Cases

### Use Case 1: Ward Round Reflection
**Scenario**: Doctor takes photo of handwritten notes after ward round

**Input**: Photo of notepad with:
```
Ward Round - 15/10/2024
- Patient JD, sepsis management
- Initially missed signs, caught by nurse
- Need better obs monitoring
```

**AI Output**:
```json
{
  "title": "Learning from Near Miss in Sepsis Care",
  "what": "During ward rounds, I reviewed a patient with early sepsis. I initially missed subtle signs of deterioration, but the nursing staff identified them through regular observations. This prevented a potential serious deterioration.",
  "soWhat": "This experience highlighted the critical importance of regular observations and the value of teamwork. I realized I was focusing too heavily on obvious clinical signs and not systematically reviewing all parameters. The nursing staff's vigilance was crucial.",
  "nowWhat": "I will implement a systematic approach to reviewing all vital signs on every ward round. I'll also ensure better communication with nursing staff about any concerns. I'll attend the next sepsis training session to refresh my knowledge.",
  "tags": ["patient-safety", "teamwork", "sepsis", "learning-from-mistakes"],
  "suggestedDomains": [2, 3]
}
```

### Use Case 2: Teaching Session Whiteboard
**Scenario**: Doctor photographs whiteboard after teaching session

**Input**: Photo of whiteboard with diagrams about ECG interpretation

**AI Output**:
```json
{
  "title": "Teaching ECG Interpretation to Medical Students",
  "what": "I delivered a 30-minute teaching session on ECG interpretation to a group of Year 4 medical students. I used whiteboard diagrams to explain the electrical conduction system and common abnormalities.",
  "soWhat": "The session went well, with good engagement. However, I noticed some students struggled with the pace. This made me realize I need to check understanding more frequently during teaching. The visual diagrams were effective.",
  "nowWhat": "For future teaching sessions, I'll incorporate more interactive questioning and pauses. I'll also create handouts with blank diagrams for students to fill in. I should attend the 'Teaching Skills' workshop next month.",
  "tags": ["teaching", "ecg", "medical-education", "communication"],
  "suggestedDomains": [1, 3]
}
```

### Use Case 3: Difficult Conversation Notes
**Scenario**: Upload Word document with notes about difficult patient conversation

**AI Output**: Structured reflection about communication, empathy, breaking bad news, etc.

### Use Case 4: Conference Certificate + Notes
**Scenario**: Photo of conference certificate + written notes

**AI Output**: CPD entry + reflection on key learnings

---

## 🎨 UI Components Mockup

### Component Hierarchy
```
ReflectionsListPage
  └─ FloatingActionButton (+)
       └─ CreateReflectionBottomSheet
            ├─ "From Document/Photo" (AI) ✨
            │   └─ DocumentSourceSelector
            │        ├─ Take Photo 📷
            │        ├─ Gallery 🖼️
            │        └─ Document 📄
            │            └─ ImagePicker / FilePicker
            │                 └─ AiProcessingScreen
            │                      └─ AiDraftReviewPage
            │                           ├─ EditableFields
            │                           ├─ SuggestedTags
            │                           ├─ SuggestedDomains
            │                           └─ [Save] [Discard]
            │
            └─ "From Scratch" ✏️
                 └─ ReflectionEditPage (existing)
```

---

## 🧪 Testing Strategy

### Unit Tests
- [ ] Document extraction service
- [ ] AI response parsing
- [ ] PHI detection on extracted text
- [ ] Tag and domain suggestion logic

### Integration Tests
- [ ] Photo capture → AI extraction → save flow
- [ ] Gallery selection → AI extraction → save flow
- [ ] Document upload → AI extraction → save flow
- [ ] Error handling (API failure, no text found, etc.)

### User Testing
- [ ] 5 doctors test photo extraction
- [ ] 5 doctors test document extraction
- [ ] Measure time to create reflection
- [ ] Collect feedback on AI quality
- [ ] Test with various document types

### Edge Cases
- [ ] Blurry photo
- [ ] Handwritten notes (poor handwriting)
- [ ] No text in image
- [ ] Very long document (>5 pages)
- [ ] Document with PHI
- [ ] Non-medical content
- [ ] Multiple languages

---

## 📖 User Documentation

### Help Text
**"Create Reflection from Document/Photo"**
```
Transform your notes, photos, or documents into structured reflections!

✨ How it works:
1. Capture or upload your content
2. AI extracts key information
3. AI generates a draft reflection
4. You review and edit
5. Save your polished reflection

💡 Best results with:
• Photos of handwritten notes
• Whiteboard diagrams
• Teaching materials
• Patient notes (anonymized)
• Conference certificates

⏱️ Creates a draft in 10 seconds!

⚠️ Always review AI-generated content and remove any identifiable patient information.
```

### Onboarding Tutorial
Add new step to onboarding:
```
Step 7: Smart Reflection Creation

"Capture moments on the go! 📷

Take a photo of your notes or upload a document, and AI will create a structured reflection for you.

Perfect for busy doctors who want to reflect quickly."

[Try it] [Skip]
```

---

## 🎯 Marketing Messaging

### Feature Announcement
**"Introducing: Instant Reflections from Photos & Documents ✨"**

Transform any learning moment into a polished reflection in 30 seconds:

✅ Photo your handwritten notes → AI creates reflection  
✅ Upload a document → AI extracts key insights  
✅ Capture a teaching moment → AI structures your learning  

No more blank page syndrome. No more 15-minute typing sessions.

Just capture, review, and save.

**The fastest way to turn experiences into reflections.**

### Value Props by Persona
**Busy FY1/FY2**:
- "Create reflections during lunch break, not at midnight"
- "Photo your ward round notes → instant reflection"

**Registrars/Consultants**:
- "Convert teaching sessions into evidence for portfolio"
- "Transform conference notes into structured CPD"

**Portfolio Builders**:
- "Never lose a reflection opportunity again"
- "Capture moments in real-time, structure later"

---

## 🚦 Risk Assessment

### Technical Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OCR accuracy low | High | Medium | Use Google Cloud Vision, add manual edit |
| AI generates poor reflection | High | Medium | Show confidence score, allow full editing |
| API costs too high | Medium | Low | Rate limiting, premium tier for unlimited |
| Slow processing (>10s) | Medium | Low | Optimize prompts, use GPT-3.5 Turbo |
| PHI leaked in extraction | High | Low | PHI detector + user review required |

### User Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Users don't review AI output | High | Medium | Require explicit "Review & Save" step |
| Over-reliance on AI | Medium | Medium | Encourage editing, show as "draft" |
| Wrong context inferred | Low | Medium | Allow complete re-writing |
| Frustration with errors | Low | High | Clear error messages, easy retry |

### Privacy Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| PHI in photos uploaded | High | High | PHI detector + warning modal |
| Images stored insecurely | High | Low | Firebase Storage with strict rules |
| AI provider sees PHI | High | Low | Anonymize before sending to AI |

**Overall Risk**: **MEDIUM** - Manageable with proper mitigations

---

## 💡 Competitive Analysis

### Similar Features in Market
1. **Notion AI**: Extract action items from notes
2. **Google Lens**: Extract text from images
3. **Evernote**: Handwriting recognition
4. **Reflect**: AI-powered note summarization

### Our Differentiation
✅ **Medical Context**: Understands NHS/GMC requirements  
✅ **Structured Output**: What/So What/Now What framework  
✅ **Domain Tagging**: Auto-suggests GMC domains  
✅ **PHI Protection**: Built-in PHI detection  
✅ **Appraisal-Ready**: Outputs MAG-compliant reflections  

**Unique Value**: Only AI that creates NHS appraisal-ready reflections from photos/documents

---

## 🎊 Launch Checklist

### Pre-Launch
- [ ] Backend API deployed and tested
- [ ] Frontend UI completed
- [ ] Permissions working on iOS/Android
- [ ] PHI detection integrated
- [ ] Error handling robust
- [ ] Analytics tracking added
- [ ] Documentation written
- [ ] Beta testing with 10 users
- [ ] Pricing model decided

### Launch
- [ ] Feature flag enabled
- [ ] Announcement email sent
- [ ] In-app tutorial shown
- [ ] Marketing materials ready
- [ ] Support team briefed
- [ ] Monitor error rates
- [ ] Track adoption metrics

### Post-Launch (Week 1)
- [ ] Review user feedback
- [ ] Fix critical bugs
- [ ] Optimize prompts based on results
- [ ] Adjust rate limits if needed
- [ ] Create case studies
- [ ] Iterate on UI based on usage

---

## 📈 Future Roadmap

### Short Term (1-3 months)
- [ ] Multi-photo support (photo series)
- [ ] Voice note → reflection
- [ ] Email forwarding integration

### Medium Term (3-6 months)
- [ ] Real-time OCR preview
- [ ] Batch processing
- [ ] Handwriting model fine-tuning
- [ ] Offline OCR (on-device)

### Long Term (6-12 months)
- [ ] Calendar integration (events → reflections)
- [ ] Smart Watch capture
- [ ] AR capture (point at whiteboard)
- [ ] Collaborative reflections
- [ ] AI video analysis (teaching sessions)

---

## 🎯 Success Definition

### This feature is successful if:
1. **60%+ of active users** try AI extraction within first month
2. **70%+ of AI drafts** are saved (not discarded)
3. **Average reflection creation time** drops from 10min → 2min
4. **User satisfaction** ≥ 4.5/5 for feature
5. **"AI extraction"** mentioned in positive reviews
6. **Premium conversion** increases by 10-15% (AI as selling point)

### Early Indicators (Week 1):
- [ ] 100+ extractions performed
- [ ] <5% error rate
- [ ] Positive feedback in pilot group
- [ ] No PHI incidents
- [ ] Processing time <10 seconds

---

**This feature transforms Metanoia from "another reflection app" to "the smartest way to create NHS reflections"!** 🚀✨



