# Learning Loop Feature - Implementation Plan

## 📋 Overview

**Goal**: Link all reflections to a Learning Loop on a new dedicated page, providing a scientifically-grounded framework for deliberate practice and metacognitive improvement.

**Current State**:
- ✅ Learning Loop prompts exist in backend (`learning_loop_system.txt`, `learning_loop_user.txt`)
- ✅ Reflections use "What? So what? Now what?" framework
- ❌ No UI for Learning Loop
- ❌ No data model for Learning Loop in Flutter
- ❌ No connection between Reflections and Learning Loops

---

## 🎯 Learning Loop Framework (Metanoia v1.1)

The Learning Loop is a 7-step cognitive science-based framework:

1. **GATE** - Emotional and attentional state during learning
2. **OBSERVATION & ACTION** - Key observations and clinical decisions
3. **ENCODING** - Pattern recognition and knowledge linking
4. **PREDICTION** - Hypothesis formation with confidence calibration
5. **FEEDBACK** - Outcome comparison and error detection
6. **REFLECTION ON BIAS** - Cognitive bias identification
7. **UPDATE RULE** - Actionable learning with spaced repetition

---

## 🏗️ Architecture Design

### 1. Data Model

#### New Flutter Model: `LearningLoop`

```dart
class LearningLoop {
  final String id;
  final String reflectionId;  // Link to parent reflection
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Gate - Emotional & Attentional State
  final int attentionLevel;        // 0-3 (0=distracted, 3=highly focused)
  final int emotionValence;        // -3 to +3 (negative to positive)
  final int emotionArousal;        // 0-3 (calm to intense)
  final String? contextNote;       // Brief context description
  
  // Observation & Action
  final List<String> observations; // 1-4 key observations
  final String? action;            // Clinical action taken
  
  // Encoding - Pattern Recognition
  final String patternName;        // Clinical pattern identified
  final List<String> priorKnowledgeLinks;  // 0-3 connections
  final List<String> chunkTags;    // 0-8 memory retrieval tags
  
  // Prediction - Hypothesis Formation
  final String hypothesis;         // What was predicted
  final int probabilityPercent;    // 0-100 confidence
  final List<String> discriminators; // 0-3 expected features
  final int confidenceBucket;      // 50, 70, 85, or 95
  
  // Feedback - Outcome Comparison
  final String outcome;            // What actually happened
  final String? errorSignal;       // Prediction vs reality difference
  
  // Reflection on Bias
  final List<String> biases;       // 0-5 cognitive biases identified
  final List<String> counterMoves; // 0-3 strategies to counter biases
  
  // Update Rule - Actionable Learning
  final String ifThenRule;         // If-then learning rule
  final String? microRep48h;       // Practice task within 48 hours
  final List<int> spacedPlanDays;  // Review schedule [2, 7, 30, 90]
  
  // Outcomes (Read-only, tracked over time)
  final bool? predictionHit;       // Was prediction correct?
  final DateTime? retentionCheckDue;
  final List<TransferEvent> transferEvents;
  final double? retentionScore;    // 0-100
  final int? transferCount;
}

class TransferEvent {
  final DateTime date;
  final String context;
}
```

#### Update `Reflection` Model

Add field to link to Learning Loop:
```dart
class Reflection {
  // ... existing fields ...
  final String? learningLoopId;  // NEW: Link to Learning Loop
}
```

---

### 2. Repository Layer

#### New: `LearningLoopRepository`

```dart
class LearningLoopRepository {
  final FirestoreService _firestore;
  
  // Get learning loop for a reflection
  Future<LearningLoop?> getByReflectionId(String reflectionId);
  
  // Create learning loop from AI
  Future<LearningLoop> createFromReflection(String reflectionId);
  
  // Update learning loop manually
  Future<void> update(LearningLoop loop);
  
  // Delete learning loop
  Future<void> delete(String id);
  
  // List all learning loops
  Future<List<LearningLoop>> list();
  
  // Track outcome (was prediction correct?)
  Future<void> recordPredictionOutcome(String id, bool wasCorrect);
  
  // Add transfer event (used learning in new context)
  Future<void> addTransferEvent(String id, DateTime date, String context);
  
  // Get upcoming reviews (spaced repetition)
  Future<List<LearningLoop>> getUpcomingReviews();
}
```

---

### 3. API Service Layer

#### Extend `ApiService`

```dart
// New method in ApiService
Future<Map<String, dynamic>> generateLearningLoop(String reflectionId) async {
  final reflection = await reflectionRepo.get(reflectionId);
  
  // Construct clinical text from reflection
  final clinicalText = '''
Title: ${reflection.title}

What happened:
${reflection.what}

Analysis:
${reflection.soWhat}

Action plan:
${reflection.nowWhat}
''';
  
  // Call backend API
  final response = await http.post(
    Uri.parse('$baseUrl/api/learning-loop/generate'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'clinical_text': clinicalText}),
  );
  
  return jsonDecode(response.body);
}
```

---

### 4. Backend API Endpoint

#### New endpoint: `/api/learning-loop/generate`

```javascript
// backend/server.js

app.post('/api/learning-loop/generate', async (req, res) => {
  const { clinical_text } = req.body;
  
  // Load prompts
  const systemPrompt = fs.readFileSync('./prompts/learning_loop_system.txt', 'utf8');
  const userPrompt = fs.readFileSync('./prompts/learning_loop_user.txt', 'utf8')
    .replace('{{clinical_text}}', clinical_text);
  
  // Call OpenAI
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o',  // Use GPT-4o for better reasoning
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ],
    response_format: { type: 'json_object' },
    temperature: 0.7
  });
  
  const learningLoop = JSON.parse(completion.choices[0].message.content);
  
  return res.json({
    success: true,
    learning_loop: learningLoop
  });
});
```

---

### 5. UI Components

#### 5.1. New Page: `LearningLoopPage`

**Purpose**: Display Learning Loop for a specific reflection

**Location**: `lib/features/reflections/presentation/learning_loop_page.dart`

**Features**:
- Display all 7 sections of Learning Loop
- Beautiful card-based UI with icons for each section
- Edit mode to refine AI-generated content
- Link back to parent reflection
- Mark prediction outcome (correct/incorrect)
- Add transfer events
- View spaced repetition schedule

**UI Sections**:

```
┌─────────────────────────────────────┐
│  🧠 Learning Loop                   │
│  From: [Reflection Title]           │
├─────────────────────────────────────┤
│                                     │
│  🔓 GATE - Emotional State          │
│  ├─ Focus: ●●●○ (3/3)              │
│  ├─ Emotion: +2 (Positive)          │
│  └─ Intensity: ●●○○ (2/3)          │
│  Note: "Challenging case but..."    │
│                                     │
│  👁️ OBSERVATIONS & ACTION           │
│  • Observation 1                    │
│  • Observation 2                    │
│  Action: "Ordered CT scan..."       │
│                                     │
│  🧩 ENCODING - Pattern              │
│  Pattern: "Acute stroke protocol"   │
│  Links: [Prior knowledge...]        │
│  Tags: #stroke #neurology #acute    │
│                                     │
│  🎯 PREDICTION                      │
│  Hypothesis: "Ischaemic stroke..."  │
│  Confidence: 85% ████████░░         │
│  Expected: [Key features...]        │
│                                     │
│  📊 FEEDBACK                        │
│  Outcome: "Confirmed on imaging..." │
│  Error: "None - prediction correct" │
│  [✓ Prediction Hit] [✗ Prediction Miss]
│                                     │
│  🧠 BIAS REFLECTION                 │
│  Biases: #anchoring #availability   │
│  Counter: [Strategies...]           │
│                                     │
│  ✅ UPDATE RULE                     │
│  If-Then: "If acute onset..."       │
│  Practice: "Review stroke protocol" │
│  Schedule: 2d • 7d • 30d • 90d      │
│  [Next Review: 2 days]              │
│                                     │
│  📈 TRANSFER EVENTS                 │
│  • 2025-11-15: Applied to new case  │
│  • [+ Add Transfer Event]           │
│                                     │
└─────────────────────────────────────┘
```

#### 5.2. New Component: `LearningLoopCard`

**Purpose**: Preview Learning Loop in reflection list

```dart
class LearningLoopCard extends StatelessWidget {
  final Reflection reflection;
  final LearningLoop? learningLoop;
  
  @override
  Widget build(BuildContext context) {
    if (learningLoop == null) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.psychology_outlined),
          title: Text('Generate Learning Loop'),
          subtitle: Text('AI-powered cognitive analysis'),
          trailing: Icon(Icons.arrow_forward),
          onTap: () => _generateLearningLoop(context),
        ),
      );
    }
    
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.psychology, color: Colors.purple),
            title: Text('Learning Loop'),
            subtitle: Text(learningLoop.patternName),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => _navigateToLearningLoop(context),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStat('Focus', learningLoop.attentionLevel, 3),
                _buildStat('Confidence', learningLoop.confidenceBucket, 100),
                _buildStat('Transfers', learningLoop.transferCount ?? 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 5.3. Update: `ReflectionEditPage`

Add button to generate/view Learning Loop:

```dart
// In ReflectionEditPage actions
FloatingActionButton.extended(
  icon: Icon(Icons.psychology),
  label: Text('Learning Loop'),
  onPressed: () => _navigateToLearningLoop(),
),
```

#### 5.4. New Widget: `SpacedRepetitionCalendar`

Display upcoming review schedule with calendar view

```dart
class SpacedRepetitionCalendar extends StatelessWidget {
  final List<int> spacedPlanDays;
  final DateTime createdAt;
  
  // Shows: Today -> 2d -> 7d -> 30d -> 90d
  // With visual timeline
}
```

---

### 6. Firestore Structure

#### Collection: `reflections/{year}/items/{reflectionId}`

```json
{
  "id": "reflection-123",
  "title": "Difficult ataxia case",
  "learningLoopId": "loop-456",  // NEW FIELD
  // ... other fields ...
}
```

#### New Collection: `learning_loops/{year}/items/{loopId}`

```json
{
  "id": "loop-456",
  "reflectionId": "reflection-123",
  "createdAt": "2025-11-11T10:00:00Z",
  "updatedAt": "2025-11-11T10:30:00Z",
  
  "gate": {
    "attentionLevel": 3,
    "emotionValence": 2,
    "emotionArousal": 2,
    "contextNote": "Complex case requiring careful analysis"
  },
  
  "observationAction": {
    "observations": [
      "Patient presented with progressive ataxia",
      "MRI showed cerebellar atrophy",
      "Family history positive"
    ],
    "action": "Ordered genetic testing panel"
  },
  
  "encoding": {
    "patternName": "Hereditary cerebellar ataxia workup",
    "priorKnowledgeLinks": [
      "Similar case 6 months ago",
      "Genetic ataxias lecture"
    ],
    "chunkTags": ["ataxia", "neurology", "genetics", "cerebellum"]
  },
  
  "prediction": {
    "hypothesis": "SCA type 2 or 3 based on presentation",
    "probabilityPercent": 70,
    "discriminators": [
      "Slow saccades",
      "Peripheral neuropathy"
    ],
    "confidenceBucket": 70
  },
  
  "feedback": {
    "outcome": "Confirmed SCA type 3 on genetic testing",
    "errorSignal": "Correct diagnosis, good clinical reasoning"
  },
  
  "reflectionBias": {
    "biases": ["availability"],
    "counterMoves": [
      "Consider full differential before anchoring",
      "Use structured diagnostic framework"
    ]
  },
  
  "updateRule": {
    "ifThenRule": "If progressive ataxia + family history, then genetic testing early",
    "microRep48h": "Review SCA classification system",
    "spacedPlanDays": [2, 7, 30, 90]
  },
  
  "outcomes": {
    "predictionHit": true,
    "retentionCheckDue": "2025-11-13",
    "transferEvents": [
      {
        "date": "2025-11-15",
        "context": "Applied diagnostic framework to new ataxia case"
      }
    ],
    "retentionScore": 85.0,
    "transferCount": 1
  }
}
```

---

### 7. Firestore Security Rules

```javascript
// firestore.rules

// Learning Loops - users can only access their own
match /learning_loops/{year}/items/{loopId} {
  allow read, write: if request.auth != null 
    && request.auth.uid == resource.data.userId;
  
  allow create: if request.auth != null
    && request.auth.uid == request.resource.data.userId;
}
```

---

### 8. Navigation & Routing

#### Update `router.dart`

```dart
// Add new routes
GoRoute(
  path: '/reflections/:reflectionId/learning-loop',
  builder: (c, s) => LearningLoopPage(
    reflectionId: s.pathParameters['reflectionId']!,
  ),
),

GoRoute(
  path: '/learning-loops',
  builder: (c, s) => const LearningLoopsListPage(),
),

GoRoute(
  path: '/learning-loops/:id',
  builder: (c, s) => LearningLoopDetailPage(
    id: s.pathParameters['id']!,
  ),
),
```

---

### 9. New Feature: Learning Loops List Page

**Purpose**: Browse all Learning Loops across all reflections

**Location**: `lib/features/learning_loops/learning_loops_list_page.dart`

**Features**:
- List all learning loops
- Filter by:
  - Pattern type
  - Cognitive biases
  - Prediction accuracy (hits vs misses)
  - Upcoming reviews
- Search by tags or pattern names
- Analytics dashboard:
  - Total learning loops created
  - Prediction accuracy rate
  - Most common biases
  - Transfer success rate
  - Spaced repetition adherence

**UI**:
```
┌─────────────────────────────────────┐
│  Learning Loops                     │
│  [Search] [Filter ▼]                │
├─────────────────────────────────────┤
│  📊 Analytics                       │
│  • 24 Learning Loops                │
│  • 78% Prediction Accuracy          │
│  • 3 Reviews Due This Week          │
├─────────────────────────────────────┤
│  [Loop Card 1]                      │
│  Pattern: Acute stroke protocol     │
│  ✓ Prediction Hit • 2 Transfers     │
│  Next Review: 2 days                │
├─────────────────────────────────────┤
│  [Loop Card 2]                      │
│  Pattern: Sepsis recognition        │
│  ✗ Prediction Miss • 1 Transfer     │
│  Next Review: Tomorrow              │
└─────────────────────────────────────┘
```

---

### 10. Dashboard Integration

#### Update `DashboardPage`

Add Learning Loop section:

```dart
// New dashboard card
Card(
  child: Column(
    children: [
      ListTile(
        leading: Icon(Icons.psychology, color: Colors.purple),
        title: Text('Learning Loops'),
        subtitle: Text('$loopCount loops • $reviewsDue reviews due'),
      ),
      ButtonBar(
        children: [
          TextButton(
            child: Text('VIEW ALL'),
            onPressed: () => context.go('/learning-loops'),
          ),
          TextButton(
            child: Text('DUE REVIEWS'),
            onPressed: () => _showDueReviews(),
          ),
        ],
      ),
    ],
  ),
)
```

---

### 11. Notifications & Reminders

#### Spaced Repetition Reminders

```dart
class LearningLoopNotificationService {
  // Schedule notifications for spaced repetition
  Future<void> scheduleReviewNotifications(LearningLoop loop) async {
    for (final days in loop.spacedPlanDays) {
      final reviewDate = loop.createdAt.add(Duration(days: days));
      
      await NotificationService.schedule(
        title: 'Learning Review Due',
        body: 'Review: ${loop.patternName}',
        scheduledDate: reviewDate,
        payload: 'learning-loop:${loop.id}',
      );
    }
  }
  
  // Get upcoming reviews
  Future<List<LearningLoop>> getUpcomingReviews({int daysAhead = 7}) async {
    final loops = await learningLoopRepo.list();
    final now = DateTime.now();
    
    return loops.where((loop) {
      if (loop.retentionCheckDue == null) return false;
      final diff = loop.retentionCheckDue!.difference(now);
      return diff.inDays >= 0 && diff.inDays <= daysAhead;
    }).toList();
  }
}
```

---

## 🎨 Design & UX Considerations

### Visual Design

1. **Color Scheme**:
   - Gate: 🔓 Teal/Cyan (emotional state)
   - Observation: 👁️ Blue (observation)
   - Encoding: 🧩 Purple (pattern recognition)
   - Prediction: 🎯 Orange (hypothesis)
   - Feedback: 📊 Green (outcome)
   - Bias: 🧠 Red (cognitive biases)
   - Update: ✅ Indigo (learning rule)

2. **Icons**:
   - Use consistent, recognizable icons for each section
   - Animated icons for interactive elements

3. **Layout**:
   - Card-based layout for easy scanning
   - Collapsible sections for deep information
   - Timeline view for spaced repetition

### User Flow

```
Reflection Edit Page
  └─> [Learning Loop Button]
      └─> Generate Learning Loop (AI processing)
          └─> Review & Edit Generated Loop
              └─> Save Learning Loop
                  └─> Set up Spaced Repetition Reminders
                      └─> Track Progress Over Time
```

### Onboarding

1. **First-time user**:
   - Show info dialog explaining Learning Loop
   - Highlight benefits: better retention, prediction calibration, bias awareness

2. **Tooltip guidance**:
   - Each section has help icon with explanation
   - Link to full Learning Loop documentation

---

## 📊 Analytics & Insights

### Personal Analytics Dashboard

Track and display:

1. **Prediction Calibration**:
   - Chart showing confidence vs actual accuracy
   - Identify over/under-confidence patterns

2. **Bias Patterns**:
   - Most frequent cognitive biases
   - Progress in bias awareness over time

3. **Transfer Success**:
   - How often learning is applied to new contexts
   - Most transferable patterns

4. **Spaced Repetition Adherence**:
   - Review completion rate
   - Optimal review timing

5. **Pattern Recognition**:
   - Most common clinical patterns
   - Pattern evolution over time

---

## 🚀 Implementation Phases

### Phase 1: Backend Foundation (Week 1)
- [ ] Create `/api/learning-loop/generate` endpoint
- [ ] Test with sample reflection data
- [ ] Validate JSON schema compliance
- [ ] Error handling and logging

### Phase 2: Data Layer (Week 1-2)
- [ ] Create `LearningLoop` model
- [ ] Create `LearningLoopRepository`
- [ ] Set up Firestore collections
- [ ] Update Firestore security rules
- [ ] Write unit tests for repository

### Phase 3: Core UI (Week 2-3)
- [ ] Create `LearningLoopPage`
- [ ] Build section widgets (Gate, Observation, Encoding, etc.)
- [ ] Implement edit mode
- [ ] Add generation loading state
- [ ] Navigation integration

### Phase 4: List & Discovery (Week 3)
- [ ] Create `LearningLoopsListPage`
- [ ] Add filtering and search
- [ ] Build `LearningLoopCard` preview
- [ ] Integrate with reflection list

### Phase 5: Spaced Repetition (Week 4)
- [ ] Implement notification scheduling
- [ ] Create review workflow
- [ ] Build calendar view
- [ ] Track review completion

### Phase 6: Analytics (Week 4-5)
- [ ] Build analytics dashboard
- [ ] Prediction calibration chart
- [ ] Bias pattern analysis
- [ ] Transfer tracking

### Phase 7: Polish & Testing (Week 5-6)
- [ ] UI/UX refinement
- [ ] Performance optimization
- [ ] Integration testing
- [ ] User acceptance testing
- [ ] Documentation

### Phase 8: Launch (Week 6)
- [ ] Deploy backend updates
- [ ] Deploy Firestore rules
- [ ] Release app update
- [ ] User onboarding
- [ ] Monitor adoption

---

## 📝 Testing Strategy

### Unit Tests
- `LearningLoop` model serialization/deserialization
- `LearningLoopRepository` CRUD operations
- Spaced repetition calculation logic

### Integration Tests
- End-to-end flow: Reflection → Generate Loop → Save → Review
- API endpoint with real OpenAI calls (mocked in CI)

### UI Tests
- Learning Loop page navigation
- Form validation
- Edit mode functionality

### User Testing
- Beta test with 5-10 doctors
- Gather feedback on:
  - Is Learning Loop framework clear?
  - Is UI intuitive?
  - Is spaced repetition helpful?
  - Are reminders timely?

---

## 📚 Documentation Updates

### User Documentation
- [ ] Update `USER_GUIDE.md` with Learning Loop section
- [ ] Create `LEARNING_LOOP_GUIDE.md` detailed guide
- [ ] Add in-app help tooltips
- [ ] Video tutorial (3-5 minutes)

### Developer Documentation
- [ ] Update `DOCUMENTATION_INDEX.md`
- [ ] Add API documentation for new endpoint
- [ ] Document data models
- [ ] Code architecture diagrams

---

## 🔮 Future Enhancements

### V1.1 (Post-Launch)
- Export Learning Loops to PDF
- Share Learning Loops with colleagues
- Learning Loop templates for common scenarios

### V1.2 (3 months)
- AI-suggested improvements based on patterns
- Peer review of Learning Loops
- Team analytics (aggregated insights)

### V2.0 (6 months)
- Machine learning for personalized spaced repetition
- Adaptive confidence calibration training
- Integration with CPD portfolio
- GMC domain mapping

---

## 💡 Key Success Metrics

### Adoption Metrics
- % of reflections with Learning Loops
- Learning Loops created per user per month
- Time to create first Learning Loop

### Engagement Metrics
- Review completion rate
- Transfer event logging rate
- Edit frequency (refinement)

### Learning Metrics
- Prediction accuracy improvement over time
- Confidence calibration improvement
- Bias awareness increase
- Transfer success rate

---

## 🎯 Definition of Done

### Feature Complete When:
- [✓] Users can generate Learning Loop from any reflection
- [✓] Learning Loop displays all 7 sections clearly
- [✓] Users can edit AI-generated content
- [✓] Spaced repetition reminders work reliably
- [✓] Users can track prediction outcomes
- [✓] Users can log transfer events
- [✓] Analytics dashboard shows key metrics
- [✓] Learning Loops sync across devices
- [✓] All tests pass (unit, integration, UI)
- [✓] Documentation complete
- [✓] User feedback positive (>4/5 rating)

---

## 📞 Support & Feedback

### During Beta:
- In-app feedback button on Learning Loop page
- Weekly check-ins with beta users
- Monitor analytics for drop-off points

### Post-Launch:
- FAQ section in settings
- Support email for questions
- Feature request form

---

## 🔐 Privacy & Security

### Data Protection:
- Learning Loops contain clinical data (PHI)
- Same security as reflections:
  - Encrypted at rest
  - Encrypted in transit
  - User-isolated (Firestore rules)
  - No cross-user visibility

### Compliance:
- GDPR compliant (user can delete all data)
- NHS data governance aligned
- Audit trail for data access

---

## 💰 Cost Estimation

### OpenAI API Costs:
- GPT-4o for Learning Loop generation
- Estimated ~2000 tokens per generation
- Cost: ~$0.02 per Learning Loop
- For 100 users × 10 loops/month = $20/month

### Firebase Costs:
- Firestore reads/writes
- Additional storage minimal
- Estimated: +$5-10/month

### Total: ~$25-30/month for 100 active users

---

## 📅 Timeline Summary

| Week | Focus | Deliverables |
|------|-------|--------------|
| 1 | Backend + Data | API endpoint, models, repository |
| 2-3 | Core UI | Learning Loop page, generation flow |
| 3 | Discovery | List page, search, filtering |
| 4 | Spaced Rep | Notifications, review workflow |
| 4-5 | Analytics | Dashboard, charts, insights |
| 5-6 | Polish | Testing, refinement, docs |
| 6 | Launch | Deploy, onboard, monitor |

**Total: 6 weeks to full launch**

---

## ✅ Next Steps (Immediate)

1. **Review this plan** with stakeholders
2. **Prioritize features** (MVP vs nice-to-have)
3. **Set up project tracking** (Jira/Trello/Linear)
4. **Create design mockups** (Figma)
5. **Start Phase 1** (Backend Foundation)

---

## 📖 References

- Cognitive Science Principles: Encoding, retrieval, spaced repetition
- GMC Domain Framework: Professional standards alignment
- Clinical Reasoning: Diagnostic frameworks, bias awareness
- Metacognition: Self-assessment, confidence calibration

---

**Document Version**: 1.0  
**Created**: 2025-11-11  
**Author**: AI Assistant  
**Status**: Planning Phase


