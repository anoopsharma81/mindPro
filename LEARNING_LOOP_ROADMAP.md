# Learning Loop - Visual Roadmap

## 🗺️ Feature Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     LEARNING LOOP SYSTEM                     │
│          Transform Reflections into Learning Engines         │
└─────────────────────────────────────────────────────────────┘

                    EXISTING REFLECTION
                           ↓
                    ┌──────────────┐
                    │  "Difficult  │
                    │  ataxia case"│
                    │              │
                    │ What: ...    │
                    │ So What: ... │
                    │ Now What: ...│
                    └──────┬───────┘
                           ↓
              [Generate Learning Loop Button]
                           ↓
                    ┌──────────────┐
                    │   Backend    │
                    │   OpenAI     │
                    │   GPT-4o     │
                    └──────┬───────┘
                           ↓
                    ┌──────────────────────┐
                    │   LEARNING LOOP      │
                    │   (7 Sections)       │
                    ├──────────────────────┤
                    │ 🔓 Gate              │
                    │ 👁️ Observation       │
                    │ 🧩 Encoding          │
                    │ 🎯 Prediction        │
                    │ 📊 Feedback          │
                    │ 🧠 Bias              │
                    │ ✅ Update Rule       │
                    └──────┬───────────────┘
                           ↓
                  ┌────────┴────────┐
                  │                 │
           Save to Firestore   Display in UI
                  │                 │
                  ↓                 ↓
         learning_loops/    LearningLoopPage
         {year}/items/              │
                                    ↓
                          ┌─────────────────┐
                          │ View, Edit,     │
                          │ Track Progress  │
                          └─────────────────┘
```

---

## 📅 6-Week Implementation Timeline

```
WEEK 1: Backend Foundation
├─ Day 1-2: Add API endpoint
│  └─ /api/learning-loop/generate
├─ Day 3-4: Test with curl/Postman
│  └─ Verify JSON response
└─ Day 5: Error handling & logging

WEEK 2: Data Layer
├─ Day 6-7: Create Flutter models
│  ├─ LearningLoop class
│  └─ TransferEvent class
├─ Day 8-9: Create repository
│  └─ LearningLoopRepository
└─ Day 10: Firestore integration
   ├─ Create collection
   └─ Update security rules

WEEK 3: Core UI
├─ Day 11-12: Main page structure
│  └─ LearningLoopPage scaffold
├─ Day 13-15: Section widgets
│  ├─ GateSection
│  ├─ ObservationSection
│  ├─ EncodingSection
│  └─ ... (4 more sections)
└─ Day 16-17: Edit mode
   └─ Make sections editable

WEEK 4: Integration
├─ Day 18-19: Navigation
│  └─ Link from ReflectionEditPage
├─ Day 20-21: API integration
│  └─ Connect UI to backend
└─ Day 22-24: Polish & bug fixes
   └─ Error handling, loading states

WEEK 5: Enhancement
├─ Day 25-27: List page (optional)
│  └─ Browse all learning loops
├─ Day 28-30: Prediction tracking
│  └─ Hit/Miss buttons
└─ Day 31: Basic analytics
   └─ Count loops, accuracy rate

WEEK 6: Launch
├─ Day 32-34: Testing
│  ├─ Unit tests
│  ├─ Integration tests
│  └─ User testing
├─ Day 35-36: Documentation
│  └─ User guide, developer docs
└─ Day 37-40: Deploy & monitor
   ├─ Deploy backend
   ├─ Deploy Firestore rules
   ├─ Release app update
   └─ User onboarding
```

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         FRONTEND (Flutter)                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌───────────────────────────────────────────────────┐     │
│  │              Presentation Layer                    │     │
│  ├───────────────────────────────────────────────────┤     │
│  │  • ReflectionEditPage (updated)                    │     │
│  │  • LearningLoopPage (new)                          │     │
│  │  • LearningLoopsListPage (new, optional)           │     │
│  │  • 7 Section Widgets (new)                         │     │
│  └───────────────────────────────────────────────────┘     │
│                           ↕                                  │
│  ┌───────────────────────────────────────────────────┐     │
│  │                Data Layer                          │     │
│  ├───────────────────────────────────────────────────┤     │
│  │  • LearningLoop model (new)                        │     │
│  │  • LearningLoopRepository (new)                    │     │
│  │  • ApiService (updated)                            │     │
│  └───────────────────────────────────────────────────┘     │
│                           ↕                                  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                     BACKEND (Node.js)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  POST /api/learning-loop/generate                           │
│  ├─ Load prompts from files                                 │
│  ├─ Call OpenAI GPT-4o                                      │
│  ├─ Parse JSON response                                     │
│  └─ Return learning loop data                               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                    OPENAI API (GPT-4o)                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Input: Clinical text from reflection                       │
│  Prompts: learning_loop_system.txt + user.txt               │
│  Output: JSON with 7-step learning loop                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                   FIRESTORE DATABASE                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  reflections/{year}/items/{id}                              │
│  ├─ title, what, soWhat, nowWhat, ...                       │
│  └─ learningLoopId (new field)                              │
│                                                              │
│  learning_loops/{year}/items/{id}  ← NEW COLLECTION         │
│  ├─ reflectionId (link back)                                │
│  ├─ gate: { attention, emotion, ... }                       │
│  ├─ observationAction: { observations[], action }           │
│  ├─ encoding: { pattern, links[], tags[] }                  │
│  ├─ prediction: { hypothesis, confidence, ... }             │
│  ├─ feedback: { outcome, errorSignal }                      │
│  ├─ reflectionBias: { biases[], counterMoves[] }            │
│  ├─ updateRule: { ifThen, microRep, spacedPlan[] }          │
│  └─ outcomes: { predictionHit, transferEvents[], ... }      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 MVP Feature Set

```
┌─────────────────────────────────────────────────────────────┐
│                    MVP FEATURES (Week 1-4)                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ✅ MUST HAVE                                                │
│  ├─ Generate Learning Loop from reflection (AI)             │
│  ├─ Display all 7 sections in beautiful UI                  │
│  ├─ Edit any section (refine AI content)                    │
│  ├─ Save to Firestore (persist data)                        │
│  ├─ Link to/from parent reflection                          │
│  └─ Basic error handling                                    │
│                                                              │
│  🎨 NICE TO HAVE (Week 5-6)                                  │
│  ├─ Browse all learning loops (list page)                   │
│  ├─ Search & filter loops                                   │
│  ├─ Track prediction outcomes (hit/miss)                    │
│  ├─ Spaced repetition reminders                             │
│  └─ Basic analytics dashboard                               │
│                                                              │
│  🔮 FUTURE ENHANCEMENTS (Post-Launch)                        │
│  ├─ Advanced analytics (calibration charts)                 │
│  ├─ Transfer event tracking                                 │
│  ├─ Export to PDF                                           │
│  ├─ Share with colleagues                                   │
│  └─ Team learning features                                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 UI Component Hierarchy

```
LearningLoopPage
│
├─ AppBar
│  ├─ Title: "Learning Loop"
│  ├─ Back button
│  └─ Edit button
│
├─ Header Card
│  └─ Link to parent reflection
│
├─ GateSection
│  ├─ Attention progress bar
│  ├─ Emotion valence bar
│  ├─ Emotion arousal bar
│  └─ Context note
│
├─ ObservationSection
│  ├─ Observations list (bullets)
│  └─ Action text
│
├─ EncodingSection
│  ├─ Pattern name (large)
│  ├─ Prior knowledge links
│  └─ Tag chips
│
├─ PredictionSection
│  ├─ Hypothesis text
│  ├─ Confidence bar
│  ├─ Discriminators list
│  └─ Confidence bucket
│
├─ FeedbackSection
│  ├─ Outcome text
│  ├─ Error signal
│  └─ Hit/Miss buttons
│
├─ BiasSection
│  ├─ Bias tag chips
│  └─ Counter-moves list
│
├─ UpdateRuleSection
│  ├─ If-then rule (boxed)
│  ├─ Micro-practice task
│  ├─ Spaced repetition timeline
│  └─ Next review date
│
└─ TransferEventsSection (optional)
   ├─ List of transfer events
   └─ Add new event button
```

---

## 🔄 User Flow Diagram

```
┌─────────────────────┐
│   User opens app    │
└──────────┬──────────┘
           ↓
┌─────────────────────┐
│ Goes to Reflections │
└──────────┬──────────┘
           ↓
┌─────────────────────────────┐
│ Opens existing reflection   │
│ "Difficult ataxia case"     │
└──────────┬──────────────────┘
           ↓
┌─────────────────────────────┐
│ Sees [Learning Loop] button │
│ (in AppBar or as FAB)       │
└──────────┬──────────────────┘
           ↓
    ┌──────┴──────┐
    │ Click it?   │
    └──────┬──────┘
           ↓
    ┌──────┴──────────────────────────┐
    │ Two scenarios:                  │
    │                                 │
    │ A. No loop exists               │
    │    → Show "Generate?" dialog    │
    │    → User clicks Generate       │
    │    → Loading (10-15s)           │
    │    → Display generated loop     │
    │                                 │
    │ B. Loop already exists          │
    │    → Directly open loop page    │
    │                                 │
    └─────────┬───────────────────────┘
              ↓
    ┌─────────────────────────┐
    │ LearningLoopPage opens  │
    │ Shows all 7 sections    │
    └─────────┬───────────────┘
              ↓
    ┌─────────┴───────────┐
    │ User can:           │
    │ • Read sections     │
    │ • Click Edit        │
    │ • Modify content    │
    │ • Mark prediction   │
    │ • Add transfers     │
    │ • Navigate back     │
    └─────────────────────┘
```

---

## 📊 Data Flow Diagram

```
USER ACTION                 SYSTEM RESPONSE
═══════════════════════════════════════════

[Click Generate]
    ↓
UI: Show loading
    ↓
API Call: POST /api/learning-loop/generate
    {
      clinical_text: "Patient with ataxia..."
    }
    ↓
Backend: Load prompts
    ├─ learning_loop_system.txt
    └─ learning_loop_user.txt
    ↓
Backend: Call OpenAI GPT-4o
    {
      model: "gpt-4o",
      messages: [system, user],
      response_format: { type: "json_object" }
    }
    ↓
OpenAI: Process (~10-15 seconds)
    ↓
OpenAI: Return JSON
    {
      gate: {...},
      observation_action: {...},
      encoding: {...},
      prediction: {...},
      feedback: {...},
      reflection_bias: {...},
      update_rule: {...}
    }
    ↓
Backend: Parse & validate JSON
    ↓
Backend: Return to Flutter
    ↓
Flutter: Create LearningLoop object
    ↓
Flutter: Save to Firestore
    firestore.collection('learning_loops/2025/items')
      .doc(loopId)
      .set(loopData)
    ↓
Flutter: Update reflection
    reflection.learningLoopId = loopId
    ↓
Flutter: Navigate to LearningLoopPage
    ↓
UI: Display 7 sections
    ↓
User: Reviews content
```

---

## 🎓 The 7-Step Framework

```
┌────────────────────────────────────────────────────────────┐
│                   LEARNING LOOP v1.1                        │
│            Cognitive Science-Based Framework                │
└────────────────────────────────────────────────────────────┘

1️⃣  🔓 GATE - Emotional & Attentional State
    ├─ Attention (0-3): How focused?
    ├─ Emotion Valence (-3 to +3): Negative → Positive
    ├─ Emotion Arousal (0-3): Calm → Intense
    └─ Context Note: Brief description
    
    💡 Why? Emotions affect memory formation

────────────────────────────────────────────

2️⃣  👁️ OBSERVATION & ACTION
    ├─ Observations (1-4): What did you notice?
    └─ Action: What did you do?
    
    💡 Why? Explicit observation sharpens perception

────────────────────────────────────────────

3️⃣  🧩 ENCODING - Pattern Recognition
    ├─ Pattern Name: What clinical pattern is this?
    ├─ Prior Knowledge Links: How does it connect?
    └─ Tags: Memory retrieval cues
    
    💡 Why? Patterns enable transfer to new contexts

────────────────────────────────────────────

4️⃣  🎯 PREDICTION - Hypothesis Formation
    ├─ Hypothesis: What did you predict?
    ├─ Confidence (0-100%): How sure were you?
    ├─ Discriminators: What would confirm it?
    └─ Confidence Bucket: For calibration tracking
    
    💡 Why? Predictions create measurable feedback

────────────────────────────────────────────

5️⃣  📊 FEEDBACK - Outcome Comparison
    ├─ Outcome: What actually happened?
    └─ Error Signal: Prediction vs reality
    
    💡 Why? Error signals drive learning

────────────────────────────────────────────

6️⃣  🧠 BIAS REFLECTION - Cognitive Biases
    ├─ Biases: Which cognitive traps occurred?
    │  (anchoring, availability, confirmation, etc.)
    └─ Counter-moves: How to avoid next time?
    
    💡 Why? Awareness is the first step to debiasing

────────────────────────────────────────────

7️⃣  ✅ UPDATE RULE - Learning Integration
    ├─ If-Then Rule: Actionable learning rule
    ├─ Micro-Practice: Task within 48 hours
    └─ Spaced Repetition: 2d → 7d → 30d → 90d
    
    💡 Why? Spaced practice optimizes retention

────────────────────────────────────────────

             ⭐ RESULT: DEEP LEARNING ⭐
```

---

## 📈 Success Metrics Dashboard

```
┌────────────────────────────────────────────────────────────┐
│               LEARNING LOOP ANALYTICS                       │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 ADOPTION                                                │
│  ├─ Learning Loops Created: 24                             │
│  ├─ % Reflections with Loops: 65%                          │
│  └─ Avg Loops per User/Month: 4.2                          │
│                                                             │
│  🎯 PREDICTION ACCURACY                                      │
│  ├─ Overall Hit Rate: 78%                                  │
│  ├─ Confidence Calibration:                                │
│  │  50% bucket → 52% actual (good!)                        │
│  │  70% bucket → 68% actual (good!)                        │
│  │  85% bucket → 81% actual (slightly over)                │
│  │  95% bucket → 92% actual (over-confident)               │
│  └─ Trend: Improving over time ↗                           │
│                                                             │
│  🧠 BIAS AWARENESS                                           │
│  ├─ Most Common Biases:                                    │
│  │  1. Availability (45%)                                  │
│  │  2. Anchoring (38%)                                     │
│  │  3. Confirmation (28%)                                  │
│  └─ Bias Identification Rate: +120% (vs 3 months ago)      │
│                                                             │
│  📈 TRANSFER SUCCESS                                         │
│  ├─ Total Transfer Events: 12                              │
│  ├─ Avg per Loop: 0.5                                      │
│  └─ Most Transferable: "Sepsis recognition" (3 events)     │
│                                                             │
│  ⏰ SPACED REPETITION                                        │
│  ├─ Review Completion Rate: 82%                            │
│  ├─ Reviews Due This Week: 3                               │
│  └─ Avg Review Quality: 4.3/5                              │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start Commands

### Backend Setup
```bash
cd backend

# 1. Ensure prompts are in place
ls prompts/learning_loop_*.txt

# 2. Add endpoint to server.js
# (See LEARNING_LOOP_QUICK_START.md for code)

# 3. Start server
node server.js

# 4. Test endpoint
curl -X POST http://localhost:3001/api/learning-loop/generate \
  -H "Content-Type: application/json" \
  -d '{"clinical_text":"Patient with ataxia..."}'
```

### Flutter Setup
```bash
cd lib/features

# 1. Create directory structure
mkdir -p learning_loops/data
mkdir -p learning_loops/presentation/widgets

# 2. Create files
touch learning_loops/data/learning_loop.dart
touch learning_loops/data/learning_loop_repository.dart
touch learning_loops/presentation/learning_loop_page.dart

# 3. Create section widgets
cd learning_loops/presentation/widgets
touch gate_section.dart
touch observation_section.dart
touch encoding_section.dart
touch prediction_section.dart
touch feedback_section.dart
touch bias_section.dart
touch update_rule_section.dart
```

### Firestore Setup
```bash
# Update firestore.rules
vim firestore.rules

# Add:
# match /learning_loops/{year}/items/{loopId} {
#   allow read, write: if request.auth.uid == resource.data.userId;
# }

# Deploy
firebase deploy --only firestore:rules
```

---

## ✅ Implementation Checklist

```
PHASE 1: BACKEND FOUNDATION
├─ [ ] Add /api/learning-loop/generate endpoint
├─ [ ] Load prompts from files
├─ [ ] Call OpenAI GPT-4o
├─ [ ] Parse and validate JSON
└─ [ ] Test with curl

PHASE 2: DATA LAYER
├─ [ ] Create LearningLoop model
├─ [ ] Create TransferEvent model
├─ [ ] Create LearningLoopRepository
├─ [ ] Set up Firestore collection
├─ [ ] Update Firestore security rules
└─ [ ] Write unit tests

PHASE 3: CORE UI
├─ [ ] Create LearningLoopPage scaffold
├─ [ ] Build GateSection widget
├─ [ ] Build ObservationSection widget
├─ [ ] Build EncodingSection widget
├─ [ ] Build PredictionSection widget
├─ [ ] Build FeedbackSection widget
├─ [ ] Build BiasSection widget
├─ [ ] Build UpdateRuleSection widget
├─ [ ] Add loading states
├─ [ ] Add error handling
└─ [ ] Implement edit mode

PHASE 4: INTEGRATION
├─ [ ] Update router.dart (add routes)
├─ [ ] Update ReflectionEditPage (add button)
├─ [ ] Connect UI to API service
├─ [ ] Save to Firestore
├─ [ ] Link reflection ↔ learning loop
└─ [ ] Test end-to-end flow

PHASE 5: POLISH
├─ [ ] Design refinement
├─ [ ] Animations & transitions
├─ [ ] Accessibility improvements
├─ [ ] Performance optimization
└─ [ ] Bug fixes

PHASE 6: LAUNCH
├─ [ ] Unit tests
├─ [ ] Integration tests
├─ [ ] User acceptance testing
├─ [ ] Documentation
├─ [ ] Deploy backend
├─ [ ] Deploy Firestore rules
├─ [ ] Release app update
└─ [ ] Monitor usage & feedback
```

---

## 🎯 Next Steps

### Immediate (Today)
1. ✅ Review all planning documents
2. ⏭️ Discuss with team/stakeholders
3. ⏭️ Decide on MVP scope
4. ⏭️ Create project tickets
5. ⏭️ Set up development branch

### This Week
1. ⏭️ Backend: Add API endpoint
2. ⏭️ Backend: Test with sample data
3. ⏭️ Flutter: Create data models
4. ⏭️ Flutter: Create repository
5. ⏭️ Firestore: Set up collection & rules

### Week 2-3
1. ⏭️ Build UI components
2. ⏭️ Integrate with API
3. ⏭️ Test end-to-end
4. ⏭️ Iterate based on testing

### Week 4-6
1. ⏭️ Polish & refinement
2. ⏭️ User testing
3. ⏭️ Documentation
4. ⏭️ Launch! 🚀

---

**Start Building**: See `LEARNING_LOOP_QUICK_START.md` for code examples!

**Full Details**: See `LEARNING_LOOP_FEATURE_PLAN.md` for complete specs!

**Design Reference**: See `LEARNING_LOOP_UI_DESIGN.md` for UI mockups!


