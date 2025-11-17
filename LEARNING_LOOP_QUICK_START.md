# Learning Loop - Quick Start Guide

## 🎯 What is the Learning Loop?

The **Metanoia Learning Loop v1.1** is a scientifically-grounded framework that transforms reflections into structured learning experiences based on cognitive science principles.

### Why Learning Loop vs Traditional Reflection?

| Traditional "What? So What? Now What?" | Learning Loop |
|----------------------------------------|---------------|
| ✓ Simple, easy to start | ✓✓ Science-backed framework |
| ~ General reflection | ✓✓ Explicit pattern recognition |
| ~ No prediction tracking | ✓✓ Confidence calibration |
| ~ Limited bias awareness | ✓✓ Systematic bias identification |
| ~ No retention strategy | ✓✓ Built-in spaced repetition |
| ~ No outcome tracking | ✓✓ Tracks prediction accuracy |

**Both frameworks will coexist** - users can use either or both!

---

## 🏗️ The 7-Step Framework

```
1. 🔓 GATE → How focused/emotional were you?
2. 👁️ OBSERVATION & ACTION → What did you see & do?
3. 🧩 ENCODING → What pattern is this?
4. 🎯 PREDICTION → What did you predict? (with confidence)
5. 📊 FEEDBACK → What actually happened?
6. 🧠 BIAS REFLECTION → What biases affected you?
7. ✅ UPDATE RULE → What's your learning rule?
```

---

## 🚀 MVP Feature Set

### Must-Have (Week 1-4)

**Backend**:
- [ ] API endpoint `/api/learning-loop/generate`
- [ ] Load prompts from files
- [ ] Return JSON following schema

**Frontend**:
- [ ] `LearningLoop` data model
- [ ] `LearningLoopRepository` for Firestore
- [ ] `LearningLoopPage` (view & edit)
- [ ] Button in `ReflectionEditPage` to generate/view loop
- [ ] Basic navigation

**Core Workflow**:
```
User creates reflection
  → Click "Learning Loop" button
  → AI generates Learning Loop
  → User reviews & edits
  → Save to Firestore
  → Link to reflection
```

### Nice-to-Have (Week 5-6)

- [ ] `LearningLoopsListPage` (browse all loops)
- [ ] Spaced repetition reminders
- [ ] Track prediction outcomes
- [ ] Transfer event logging
- [ ] Basic analytics

### Future Enhancements

- Advanced analytics dashboard
- Calibration training
- Export to PDF
- Sharing with colleagues

---

## 📂 File Structure

```
lib/
├── features/
│   ├── reflections/
│   │   ├── data/
│   │   │   ├── reflection.dart (UPDATE: add learningLoopId)
│   │   │   └── reflection_repository.dart
│   │   └── presentation/
│   │       └── reflection_edit_page.dart (UPDATE: add button)
│   │
│   └── learning_loops/               ← NEW FEATURE
│       ├── data/
│       │   ├── learning_loop.dart    ← NEW: Data model
│       │   └── learning_loop_repository.dart ← NEW: Firestore ops
│       ├── presentation/
│       │   ├── learning_loop_page.dart       ← NEW: Main UI
│       │   ├── learning_loops_list_page.dart ← NEW: Browse all
│       │   └── widgets/
│       │       ├── gate_section.dart         ← NEW: Section widgets
│       │       ├── observation_section.dart
│       │       ├── encoding_section.dart
│       │       ├── prediction_section.dart
│       │       ├── feedback_section.dart
│       │       ├── bias_section.dart
│       │       └── update_rule_section.dart
│       └── services/
│           └── learning_loop_service.dart    ← NEW: API calls
│
├── services/
│   └── api_service.dart (UPDATE: add generateLearningLoop method)
│
└── router.dart (UPDATE: add routes)

backend/
├── prompts/
│   ├── learning_loop_system.txt ✅ EXISTS
│   └── learning_loop_user.txt   ✅ EXISTS
│
└── server.js (UPDATE: add endpoint)
```

---

## 🔧 Implementation Checklist

### Phase 1: Backend (Day 1-2)

```javascript
// backend/server.js

// Add this endpoint
app.post('/api/learning-loop/generate', async (req, res) => {
  const { clinical_text } = req.body;
  
  const systemPrompt = fs.readFileSync('./prompts/learning_loop_system.txt', 'utf8');
  const userPrompt = fs.readFileSync('./prompts/learning_loop_user.txt', 'utf8')
    .replace('{{clinical_text}}', clinical_text);
  
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ],
    response_format: { type: 'json_object' },
    temperature: 0.7
  });
  
  return res.json({
    success: true,
    learning_loop: JSON.parse(completion.choices[0].message.content)
  });
});
```

**Test**:
```bash
curl -X POST http://localhost:3001/api/learning-loop/generate \
  -H "Content-Type: application/json" \
  -d '{"clinical_text":"Patient with ataxia..."}'
```

---

### Phase 2: Data Models (Day 3-4)

**Create**: `lib/features/learning_loops/data/learning_loop.dart`

```dart
class LearningLoop {
  final String id;
  final String reflectionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Gate
  final int attentionLevel;       // 0-3
  final int emotionValence;       // -3 to +3
  final int emotionArousal;       // 0-3
  final String? contextNote;
  
  // Observation & Action
  final List<String> observations;
  final String? action;
  
  // Encoding
  final String patternName;
  final List<String> priorKnowledgeLinks;
  final List<String> chunkTags;
  
  // Prediction
  final String hypothesis;
  final int probabilityPercent;   // 0-100
  final List<String> discriminators;
  final int confidenceBucket;     // 50, 70, 85, 95
  
  // Feedback
  final String outcome;
  final String? errorSignal;
  
  // Bias Reflection
  final List<String> biases;
  final List<String> counterMoves;
  
  // Update Rule
  final String ifThenRule;
  final String? microRep48h;
  final List<int> spacedPlanDays;
  
  // Outcomes (tracked over time)
  final bool? predictionHit;
  final DateTime? retentionCheckDue;
  final List<TransferEvent>? transferEvents;
  
  LearningLoop({
    required this.id,
    required this.reflectionId,
    required this.createdAt,
    required this.updatedAt,
    required this.attentionLevel,
    required this.emotionValence,
    required this.emotionArousal,
    this.contextNote,
    required this.observations,
    this.action,
    required this.patternName,
    this.priorKnowledgeLinks = const [],
    this.chunkTags = const [],
    required this.hypothesis,
    required this.probabilityPercent,
    this.discriminators = const [],
    required this.confidenceBucket,
    required this.outcome,
    this.errorSignal,
    this.biases = const [],
    this.counterMoves = const [],
    required this.ifThenRule,
    this.microRep48h,
    this.spacedPlanDays = const [],
    this.predictionHit,
    this.retentionCheckDue,
    this.transferEvents,
  });
  
  // Add: toJson(), fromJson(), copyWith()
}

class TransferEvent {
  final DateTime date;
  final String context;
  
  TransferEvent({required this.date, required this.context});
  
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'context': context,
  };
  
  static TransferEvent fromJson(Map<String, dynamic> j) => TransferEvent(
    date: DateTime.parse(j['date'] as String),
    context: j['context'] as String,
  );
}
```

**Create**: `lib/features/learning_loops/data/learning_loop_repository.dart`

```dart
class LearningLoopRepository {
  final FirestoreService _firestore = FirestoreService();
  final String? year;
  
  LearningLoopRepository({this.year});
  
  String get _year => year ?? DateTime.now().year.toString();
  
  CollectionReference get _collection => 
    _firestore.db.collection('learning_loops/$_year/items');
  
  Future<LearningLoop?> getByReflectionId(String reflectionId) async {
    final snapshot = await _collection
      .where('reflectionId', isEqualTo: reflectionId)
      .limit(1)
      .get();
    
    if (snapshot.docs.isEmpty) return null;
    return LearningLoop.fromJson(snapshot.docs.first.data());
  }
  
  Future<LearningLoop> save(LearningLoop loop) async {
    await _collection.doc(loop.id).set(loop.toJson());
    return loop;
  }
  
  Future<List<LearningLoop>> list() async {
    final snapshot = await _collection
      .orderBy('createdAt', descending: true)
      .get();
    
    return snapshot.docs
      .map((doc) => LearningLoop.fromJson(doc.data()))
      .toList();
  }
}

// Provider
final learningLoopRepositoryProvider = Provider<LearningLoopRepository>((ref) {
  return LearningLoopRepository();
});
```

---

### Phase 3: API Service (Day 5)

**Update**: `lib/services/api_service.dart`

```dart
class ApiService {
  // ... existing methods ...
  
  Future<Map<String, dynamic>> generateLearningLoop(String reflectionId) async {
    // Get reflection
    final reflection = await reflectionRepo.get(reflectionId);
    if (reflection == null) {
      throw Exception('Reflection not found');
    }
    
    // Construct clinical text
    final clinicalText = '''
Title: ${reflection.title}

What happened:
${reflection.what}

Analysis and reflection:
${reflection.soWhat}

Action plan:
${reflection.nowWhat}
${reflection.tags.isNotEmpty ? '\nTags: ${reflection.tags.join(', ')}' : ''}
''';
    
    // Call backend
    final response = await http.post(
      Uri.parse('$baseUrl/api/learning-loop/generate'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'clinical_text': clinicalText,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to generate learning loop: ${response.body}');
    }
    
    final data = jsonDecode(response.body);
    return data['learning_loop'] as Map<String, dynamic>;
  }
}
```

---

### Phase 4: Core UI (Day 6-10)

**Create**: `lib/features/learning_loops/presentation/learning_loop_page.dart`

```dart
class LearningLoopPage extends ConsumerStatefulWidget {
  final String reflectionId;
  final String? learningLoopId;
  
  const LearningLoopPage({
    super.key,
    required this.reflectionId,
    this.learningLoopId,
  });
  
  @override
  ConsumerState<LearningLoopPage> createState() => _LearningLoopPageState();
}

class _LearningLoopPageState extends ConsumerState<LearningLoopPage> {
  LearningLoop? _loop;
  Reflection? _reflection;
  bool _isLoading = false;
  bool _isGenerating = false;
  
  @override
  void initState() {
    super.initState();
    _load();
  }
  
  Future<void> _load() async {
    setState(() => _isLoading = true);
    
    // Load reflection
    final reflectionRepo = ref.read(reflectionRepositoryProvider);
    _reflection = await reflectionRepo.get(widget.reflectionId);
    
    // Load existing loop or check if one exists
    final loopRepo = ref.read(learningLoopRepositoryProvider);
    if (widget.learningLoopId != null) {
      // Load by ID
      // _loop = await loopRepo.get(widget.learningLoopId);
    } else {
      // Check if loop exists for this reflection
      _loop = await loopRepo.getByReflectionId(widget.reflectionId);
    }
    
    setState(() => _isLoading = false);
    
    // If no loop exists, offer to generate
    if (_loop == null) {
      _showGenerateDialog();
    }
  }
  
  Future<void> _generate() async {
    setState(() => _isGenerating = true);
    
    try {
      // Call API to generate
      final apiService = ref.read(apiServiceProvider);
      final loopJson = await apiService.generateLearningLoop(widget.reflectionId);
      
      // Convert to LearningLoop object
      final loop = LearningLoop.fromJson({
        'id': const Uuid().v4(),
        'reflectionId': widget.reflectionId,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        ...loopJson,
      });
      
      // Save to Firestore
      final loopRepo = ref.read(learningLoopRepositoryProvider);
      await loopRepo.save(loop);
      
      // Update reflection with learningLoopId
      final reflectionRepo = ref.read(reflectionRepositoryProvider);
      await reflectionRepo.update(
        _reflection!.copyWith(learningLoopId: loop.id)
      );
      
      setState(() {
        _loop = loop;
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Learning Loop generated!')),
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  void _showGenerateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Learning Loop'),
        content: const Text(
          'Would you like to generate a Learning Loop for this reflection? '
          'This will use AI to structure your learning using cognitive science principles.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _generate();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Loop')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_isGenerating) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Loop')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Generating Learning Loop...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('This may take 10-15 seconds'),
            ],
          ),
        ),
      );
    }
    
    if (_loop == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learning Loop')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No Learning Loop yet'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate with AI'),
                onPressed: _generate,
              ),
            ],
          ),
        ),
      );
    }
    
    // Display the learning loop
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Loop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _enableEditMode(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Link to parent reflection
            Card(
              child: ListTile(
                leading: const Icon(Icons.description),
                title: Text(_reflection?.title ?? 'Reflection'),
                subtitle: const Text('Source reflection'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.go('/reflections/${widget.reflectionId}'),
              ),
            ),
            const SizedBox(height: 16),
            
            // GATE Section
            GateSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // OBSERVATION & ACTION Section
            ObservationSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // ENCODING Section
            EncodingSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // PREDICTION Section
            PredictionSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // FEEDBACK Section
            FeedbackSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // BIAS Section
            BiasSection(loop: _loop!),
            const SizedBox(height: 12),
            
            // UPDATE RULE Section
            UpdateRuleSection(loop: _loop!),
          ],
        ),
      ),
    );
  }
}
```

---

### Phase 5: Navigation (Day 11)

**Update**: `lib/router.dart`

```dart
// Add import
import 'features/learning_loops/presentation/learning_loop_page.dart';

// Add routes
GoRoute(
  path: '/reflections/:reflectionId/learning-loop',
  builder: (c, s) => LearningLoopPage(
    reflectionId: s.pathParameters['reflectionId']!,
  ),
),
```

**Update**: `lib/features/reflections/presentation/reflection_edit_page.dart`

```dart
// Add button in AppBar actions or as FAB
FloatingActionButton.extended(
  onPressed: () {
    context.go('/reflections/${widget.id}/learning-loop');
  },
  icon: const Icon(Icons.psychology),
  label: const Text('Learning Loop'),
  backgroundColor: Colors.purple,
)
```

---

### Phase 6: Firestore Setup (Day 12)

**Update**: `firestore.rules`

```javascript
match /learning_loops/{year}/items/{loopId} {
  allow read: if request.auth != null 
    && request.auth.uid == resource.data.userId;
  
  allow write: if request.auth != null
    && request.auth.uid == request.resource.data.userId;
}
```

**Deploy**:
```bash
firebase deploy --only firestore:rules
```

---

## 🎨 Section Widget Examples

### GateSection Widget

```dart
class GateSection extends StatelessWidget {
  final LearningLoop loop;
  
  const GateSection({super.key, required this.loop});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_open, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'GATE - Emotional State',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Attention Level
            _buildMetric(
              'Focus Level',
              loop.attentionLevel,
              3,
              ['Distracted', 'Moderate', 'Focused', 'Highly Focused'],
            ),
            const SizedBox(height: 12),
            
            // Emotion Valence
            _buildMetric(
              'Emotional Tone',
              loop.emotionValence + 3, // Shift to 0-6 for display
              6,
              ['Very Negative', 'Negative', 'Slightly Negative', 'Neutral', 
               'Slightly Positive', 'Positive', 'Very Positive'],
            ),
            const SizedBox(height: 12),
            
            // Emotion Arousal
            _buildMetric(
              'Emotional Intensity',
              loop.emotionArousal,
              3,
              ['Calm', 'Mild', 'Moderate', 'Intense'],
            ),
            
            if (loop.contextNote != null) ...[
              const SizedBox(height: 16),
              Text(
                'Context',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(loop.contextNote!),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetric(
    String label,
    int value,
    int max,
    List<String> labels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: value / max,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(Colors.teal),
              ),
            ),
            const SizedBox(width: 8),
            Text('$value/$max'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          labels[value],
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
```

---

## ✅ Testing Checklist

### Backend Testing
```bash
# Start backend
cd backend
node server.js

# Test endpoint
curl -X POST http://localhost:3001/api/learning-loop/generate \
  -H "Content-Type: application/json" \
  -d '{
    "clinical_text": "Patient presented with acute chest pain. ECG showed ST elevation. Administered aspirin and called cardiology. Patient went for urgent PCI. Good outcome."
  }'

# Should return JSON with all 7 sections
```

### Frontend Testing
1. Create a reflection
2. Click "Learning Loop" button
3. Wait for generation (10-15s)
4. Verify all 7 sections display correctly
5. Edit some fields
6. Save changes
7. Navigate away and back - data should persist
8. Check Firestore console - data should be there

---

## 📊 Success Metrics

### Week 1 (MVP)
- Backend endpoint working
- Can generate Learning Loop from reflection
- Can view Learning Loop in app
- Data saves to Firestore

### Week 2-3 (Core Features)
- Edit mode working
- All 7 sections display properly
- UI is intuitive
- No major bugs

### Week 4 (Beta)
- 5-10 users testing
- Feedback collected
- Bugs fixed
- Documentation complete

---

## 🐛 Common Issues & Solutions

### Issue: API timeout
**Solution**: Increase timeout to 30s for OpenAI calls

### Issue: JSON schema validation fails
**Solution**: Check prompts are returning valid JSON, add error handling

### Issue: Firestore permission denied
**Solution**: Check security rules include userId matching

### Issue: Learning Loop not linking to reflection
**Solution**: Verify learningLoopId is being saved to reflection

---

## 📚 Resources

- Full Plan: `LEARNING_LOOP_FEATURE_PLAN.md`
- Prompts: `backend/prompts/learning_loop_*.txt`
- API Docs: `backend/README.md`
- User Guide: (to be created) `LEARNING_LOOP_USER_GUIDE.md`

---

**Ready to start? Begin with Phase 1: Backend!**

```bash
cd backend
# Add the endpoint to server.js
# Test with curl
# Then move to Phase 2: Data models
```


