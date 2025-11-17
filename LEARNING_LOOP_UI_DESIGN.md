# Learning Loop - UI Design Specification

## 🎨 Design System

### Color Palette

Each section has a distinct color for easy visual identification:

```
🔓 GATE                  → Teal/Cyan (#26A69A)
👁️ OBSERVATION & ACTION  → Blue (#2196F3)
🧩 ENCODING             → Purple (#9C27B0)
🎯 PREDICTION           → Orange (#FF9800)
📊 FEEDBACK             → Green (#4CAF50)
🧠 BIAS REFLECTION      → Red/Pink (#E91E63)
✅ UPDATE RULE          → Indigo (#3F51B5)
```

### Typography

- Section Headers: **Bold, 16-18px**
- Field Labels: **Semi-bold, 12px, Grey[600]**
- Content Text: **Regular, 14px**
- Metadata: **Regular, 12px, Grey[500]**

### Spacing

- Section padding: 16px
- Between sections: 12px
- Between fields: 8-12px
- Icon-to-text: 8px

---

## 📱 Main Learning Loop Page

### Layout Structure

```
┌─────────────────────────────────────────────────┐
│  ← Learning Loop                          ︙     │ AppBar
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐   │ Link to
│  │ 📄 Difficult ataxia case                │   │ Reflection
│  │ Source reflection              →        │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🔓 GATE - Emotional State                │   │ Section 1
│  │ ─────────────────────────────────────   │   │
│  │ Focus Level         ████████░░ 3/3      │   │
│  │ Emotional Tone      ██████░░░░ +2       │   │
│  │ Emotional Intensity ████░░░░░░ 2/3      │   │
│  │                                          │   │
│  │ Context: Complex case requiring...      │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 👁️ OBSERVATION & ACTION                  │   │ Section 2
│  │ ─────────────────────────────────────   │   │
│  │ Key Observations:                        │   │
│  │ • Patient presented with progressive... │   │
│  │ • MRI showed cerebellar atrophy        │   │
│  │ • Family history positive               │   │
│  │                                          │   │
│  │ Clinical Action:                         │   │
│  │ Ordered genetic testing panel for SCAs  │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🧩 ENCODING - Pattern Recognition        │   │ Section 3
│  │ ─────────────────────────────────────   │   │
│  │ Pattern Identified:                      │   │
│  │ Hereditary cerebellar ataxia workup     │   │
│  │                                          │   │
│  │ Links to Prior Knowledge:                │   │
│  │ → Similar case 6 months ago             │   │
│  │ → Genetic ataxias lecture at conference │   │
│  │                                          │   │
│  │ Tags:                                    │   │
│  │ #ataxia #neurology #genetics #SCA       │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🎯 PREDICTION - Hypothesis               │   │ Section 4
│  │ ─────────────────────────────────────   │   │
│  │ Hypothesis:                              │   │
│  │ SCA type 2 or 3 based on presentation   │   │
│  │                                          │   │
│  │ Confidence: 70%                          │   │
│  │ ███████░░░                               │   │
│  │                                          │   │
│  │ Expected Key Features:                   │   │
│  │ • Slow saccadic eye movements           │   │
│  │ • Peripheral neuropathy                 │   │
│  │                                          │   │
│  │ Confidence Bucket: 70%                   │   │
│  │ (For calibration tracking)               │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 📊 FEEDBACK - Outcome                    │   │ Section 5
│  │ ─────────────────────────────────────   │   │
│  │ Actual Outcome:                          │   │
│  │ Confirmed SCA type 3 on genetic testing │   │
│  │                                          │   │
│  │ Error Signal:                            │   │
│  │ Correct diagnosis, good clinical        │   │
│  │ reasoning pathway                        │   │
│  │                                          │   │
│  │ Was prediction correct?                  │   │
│  │ [✓ Yes, Hit]  [ No, Miss ]              │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🧠 BIAS REFLECTION - Cognitive Biases    │   │ Section 6
│  │ ─────────────────────────────────────   │   │
│  │ Biases Identified:                       │   │
│  │ 🏷 availability   🏷 anchoring            │   │
│  │                                          │   │
│  │ Counter Strategies:                      │   │
│  │ • Consider full differential before...  │   │
│  │ • Use structured diagnostic framework   │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ ✅ UPDATE RULE - Learning Integration    │   │ Section 7
│  │ ─────────────────────────────────────   │   │
│  │ If-Then Rule:                            │   │
│  │ IF progressive ataxia + family history   │   │
│  │ THEN order genetic testing early in     │   │
│  │ diagnostic workup                        │   │
│  │                                          │   │
│  │ Micro-Practice (Next 48h):               │   │
│  │ Review SCA classification system and... │   │
│  │                                          │   │
│  │ Spaced Repetition Schedule:              │   │
│  │ 🗓 2 days → 7 days → 30 days → 90 days   │   │
│  │                                          │   │
│  │ Next Review: In 2 days (Nov 13)         │   │
│  │ [🔔 Remind Me]                           │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 📈 TRANSFER EVENTS                       │   │ Optional
│  │ ─────────────────────────────────────   │   │
│  │ Nov 15, 2025                             │   │
│  │ Applied diagnostic framework to new...  │   │
│  │                                          │   │
│  │ [+ Add Transfer Event]                   │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 🎯 Section Widget Components

### 1. GateSection

```
┌─────────────────────────────────────────┐
│ 🔓 GATE - Emotional State                │
│ ─────────────────────────────────────   │
│                                          │
│ Focus Level                              │
│ ████████░░ 3/3                           │
│ Highly Focused                           │
│                                          │
│ Emotional Tone                           │
│ ██████░░░░ +2                            │
│ Positive                                 │
│                                          │
│ Emotional Intensity                      │
│ ████░░░░░░ 2/3                           │
│ Moderate                                 │
│                                          │
│ Context                                  │
│ Complex case requiring careful analysis  │
│ and systematic approach                  │
└─────────────────────────────────────────┘
```

**Key Features**:
- Progress bars for quantitative metrics
- Label interpretation below each bar
- Optional context note in grey

---

### 2. ObservationSection

```
┌─────────────────────────────────────────┐
│ 👁️ OBSERVATION & ACTION                  │
│ ─────────────────────────────────────   │
│                                          │
│ Key Observations                         │
│ • Patient presented with progressive    │
│   ataxia over 18 months                 │
│ • MRI showed cerebellar atrophy         │
│ • Family history positive for ataxia    │
│ • No sensory loss or sphincter issues   │
│                                          │
│ Clinical Action Taken                    │
│ Ordered comprehensive genetic testing   │
│ panel for spinocerebellar ataxias       │
└─────────────────────────────────────────┘
```

**Key Features**:
- Bullet list for observations (1-4 items)
- Highlighted action section
- Clear visual separation

---

### 3. EncodingSection

```
┌─────────────────────────────────────────┐
│ 🧩 ENCODING - Pattern Recognition        │
│ ─────────────────────────────────────   │
│                                          │
│ Pattern Identified                       │
│ 🎯 Hereditary cerebellar ataxia workup  │
│                                          │
│ Links to Prior Knowledge                 │
│ 🔗 Similar case 6 months ago            │
│ 🔗 Genetic ataxias lecture              │
│                                          │
│ Memory Tags                              │
│ #ataxia #neurology #genetics            │
│ #cerebellum #SCA #movement-disorder     │
└─────────────────────────────────────────┘
```

**Key Features**:
- Large pattern name (most important)
- Link icons for prior knowledge
- Chip-style tags (tappable for filtering)

---

### 4. PredictionSection

```
┌─────────────────────────────────────────┐
│ 🎯 PREDICTION - Hypothesis               │
│ ─────────────────────────────────────   │
│                                          │
│ Hypothesis                               │
│ SCA type 2 or 3 based on clinical       │
│ presentation and imaging findings       │
│                                          │
│ Confidence Level                         │
│ ███████░░░ 70%                           │
│                                          │
│ Expected Key Features                    │
│ ✓ Slow saccadic eye movements           │
│ ✓ Peripheral neuropathy signs           │
│ ✓ Positive family history               │
│                                          │
│ Calibration Bucket: 70%                  │
│ (Used for tracking prediction accuracy) │
└─────────────────────────────────────────┘
```

**Key Features**:
- Prominent confidence bar (orange theme)
- Checklist of expected discriminators
- Subtle calibration bucket note

---

### 5. FeedbackSection

```
┌─────────────────────────────────────────┐
│ 📊 FEEDBACK - Outcome Comparison         │
│ ─────────────────────────────────────   │
│                                          │
│ Actual Outcome                           │
│ ✅ Confirmed SCA type 3 on genetic      │
│ testing. Patient referred to neurology  │
│ for ongoing management.                  │
│                                          │
│ Error Signal (Prediction vs Reality)     │
│ Correct diagnosis. Good systematic      │
│ clinical reasoning approach.             │
│                                          │
│ Was your prediction correct?             │
│ ┌──────────┐  ┌──────────┐              │
│ │ ✓ Hit    │  │   Miss   │              │
│ └──────────┘  └──────────┘              │
│   (Selected)    (Not selected)           │
└─────────────────────────────────────────┘
```

**Key Features**:
- Green checkmark for successful prediction
- Binary buttons for tracking accuracy
- Error signal helps identify learning gaps

---

### 6. BiasSection

```
┌─────────────────────────────────────────┐
│ 🧠 BIAS REFLECTION - Cognitive Biases    │
│ ─────────────────────────────────────   │
│                                          │
│ Cognitive Biases Identified              │
│ ┌──────────────┐  ┌──────────────┐      │
│ │ 🏷 availability│  │ 🏷 anchoring  │      │
│ └──────────────┘  └──────────────┘      │
│                                          │
│ Counter Strategies                       │
│ 💡 Consider full differential diagnosis │
│    before anchoring to first hypothesis │
│                                          │
│ 💡 Use structured diagnostic framework  │
│    (INPUT→PATTERN→ANALYSIS→BIAS→OUTPUT)│
│                                          │
│ 💡 Seek disconfirming evidence actively │
└─────────────────────────────────────────┘
```

**Key Features**:
- Tag chips for biases (red/pink theme)
- Light bulb icons for counter-strategies
- Educational tone

---

### 7. UpdateRuleSection

```
┌─────────────────────────────────────────┐
│ ✅ UPDATE RULE - Learning Integration    │
│ ─────────────────────────────────────   │
│                                          │
│ If-Then Learning Rule                    │
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓    │
│ ┃ IF progressive ataxia + positive  ┃    │
│ ┃ family history                    ┃    │
│ ┃                                   ┃    │
│ ┃ THEN order genetic testing early  ┃    │
│ ┃ in diagnostic workup              ┃    │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛    │
│                                          │
│ Micro-Practice (Next 48 hours)           │
│ 📝 Review SCA classification system     │
│    and diagnostic criteria              │
│                                          │
│ Spaced Repetition Schedule               │
│ ┌────┐  ┌────┐  ┌────┐  ┌────┐         │
│ │ 2d │→ │ 7d │→ │30d │→ │90d │         │
│ └────┘  └────┘  └────┘  └────┘         │
│                                          │
│ 🔔 Next Review: Nov 13, 2025 (2 days)   │
│ [Remind Me] [Mark as Reviewed]           │
└─────────────────────────────────────────┘
```

**Key Features**:
- Boxed if-then rule (easy to scan)
- Immediate practice task
- Visual timeline for spaced repetition
- Notification controls

---

## 🔄 States & Interactions

### Loading State (Generating)

```
┌─────────────────────────────────────────┐
│  ← Learning Loop                         │
├─────────────────────────────────────────┤
│                                          │
│              ⚡️                          │
│         ⟲  Generating...                 │
│                                          │
│     Creating your Learning Loop with AI  │
│     This may take 10-15 seconds          │
│                                          │
│     ████████████████░░░░░░ 75%          │
│                                          │
└─────────────────────────────────────────┘
```

---

### Empty State (No Learning Loop Yet)

```
┌─────────────────────────────────────────┐
│  ← Learning Loop                         │
├─────────────────────────────────────────┤
│                                          │
│                                          │
│              🧠                          │
│                                          │
│     No Learning Loop yet                 │
│                                          │
│     Transform this reflection into a     │
│     structured learning experience using │
│     cognitive science principles         │
│                                          │
│     ┌──────────────────────┐             │
│     │ ✨ Generate with AI │             │
│     └──────────────────────┘             │
│                                          │
│     [Learn More About Learning Loops]    │
│                                          │
└─────────────────────────────────────────┘
```

---

### Edit Mode

All sections get:
- Edit icon (pencil) in top-right
- Text fields become editable
- Save/Cancel buttons at bottom

```
┌─────────────────────────────────────────┐
│ 🎯 PREDICTION - Hypothesis          ✏️  │
│ ─────────────────────────────────────   │
│                                          │
│ Hypothesis                               │
│ ┌────────────────────────────────────┐  │
│ │ SCA type 2 or 3 based on...       │  │ ← Editable
│ └────────────────────────────────────┘  │
│                                          │
│ Confidence Level                         │
│ ━━━━━○━━━━ 70%                          │ ← Slider
│                                          │
│ [Cancel] [Save Changes]                  │
└─────────────────────────────────────────┘
```

---

## 📊 Learning Loops List Page

### Overview Dashboard

```
┌─────────────────────────────────────────┐
│  Learning Loops                     +    │
├─────────────────────────────────────────┤
│                                          │
│  📊 Your Analytics                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐│
│  │    24    │ │   78%    │ │    12    ││
│  │  Loops   │ │ Hit Rate │ │Transfers ││
│  └──────────┘ └──────────┘ └──────────┘│
│                                          │
│  ⏰ Reviews Due                          │
│  3 learning loops need review this week  │
│  [View Reviews]                          │
│                                          │
│  🔍 [Search loops...]                    │
│  [All ▼] [Hits Only] [Misses Only]       │
│                                          │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │ 🧩 Acute stroke protocol        │    │
│  │ ✓ Prediction Hit • 2 Transfers  │    │
│  │ 🗓 Next review: 2 days          │    │
│  │ #stroke #neurology #acute       │    │
│  └─────────────────────────────────┘    │
│                                          │
│  ┌─────────────────────────────────┐    │
│  │ 🧩 Sepsis recognition           │    │
│  │ ✗ Prediction Miss • 1 Transfer  │    │
│  │ 🗓 Next review: Tomorrow        │    │
│  │ #sepsis #emergency #ICU         │    │
│  └─────────────────────────────────┘    │
│                                          │
│  ┌─────────────────────────────────┐    │
│  │ 🧩 Hereditary cerebellar ataxia │    │
│  │ ✓ Prediction Hit • 0 Transfers  │    │
│  │ 🗓 Next review: 5 days          │    │
│  │ #ataxia #neurology #genetics    │    │
│  └─────────────────────────────────┘    │
│                                          │
└─────────────────────────────────────────┘
```

---

## 🎨 Interactive Elements

### Progress Bars

```dart
LinearProgressIndicator(
  value: 0.7, // 70%
  backgroundColor: Colors.grey[200],
  valueColor: AlwaysStoppedAnimation(Colors.orange),
  minHeight: 8,
)
```

### Confidence Slider (Edit Mode)

```dart
Slider(
  value: 70,
  min: 0,
  max: 100,
  divisions: 20,
  label: '70%',
  onChanged: (value) => setState(() => confidence = value),
)
```

### Tag Chips

```dart
Chip(
  label: Text('#ataxia'),
  backgroundColor: Colors.purple[100],
  labelStyle: TextStyle(color: Colors.purple[900]),
  onTap: () => _filterByTag('ataxia'),
)
```

### Prediction Outcome Buttons

```dart
Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        icon: Icon(Icons.check_circle, color: Colors.green),
        label: Text('Hit'),
        style: predictionHit == true 
          ? ElevatedButton.styleFrom(backgroundColor: Colors.green)
          : null,
        onPressed: () => _recordOutcome(true),
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: OutlinedButton.icon(
        icon: Icon(Icons.cancel, color: Colors.red),
        label: Text('Miss'),
        style: predictionHit == false
          ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
          : null,
        onPressed: () => _recordOutcome(false),
      ),
    ),
  ],
)
```

---

## 📱 Responsive Design

### Mobile (< 600px)
- Full-width cards
- Stacked layout
- Single column

### Tablet (600-900px)
- Cards with margins
- Some sections side-by-side (e.g., Gate metrics)

### Desktop (> 900px)
- Max width: 800px, centered
- Two-column layout for some sections
- More spacing

---

## ♿ Accessibility

### Screen Reader Support
- Semantic HTML/Flutter widgets
- Proper labels for all interactive elements
- ARIA roles where needed

### Keyboard Navigation
- Tab through sections
- Enter to expand/collapse
- Space to select buttons

### Color Contrast
- All text meets WCAG AA standards (4.5:1)
- Interactive elements have focus indicators

### Font Scaling
- Supports system font scaling
- Layout adapts to larger text sizes

---

## 🎬 Animations

### Section Expansion
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  height: isExpanded ? expandedHeight : collapsedHeight,
)
```

### Loading Spinner
- Indeterminate progress indicator
- Subtle pulse animation on "Generating..." text

### Success Confirmation
- Checkmark animation on save
- Snackbar with success message

---

## 🔔 Notification Design

### Review Reminder

```
┌─────────────────────────────────────┐
│ 🧠 Metanoia                          │
│                                      │
│ Learning Review Due                  │
│ Review: Acute stroke protocol        │
│                                      │
│ Tap to open Learning Loop            │
└─────────────────────────────────────┘
```

---

## 📐 Design Tokens

### Border Radius
- Cards: 12px
- Buttons: 8px
- Chips: 16px (fully rounded)

### Shadows
- Cards: elevation 2
- FAB: elevation 6
- Modal sheets: elevation 16

### Font Weights
- Headers: 700 (Bold)
- Section titles: 600 (Semi-bold)
- Body text: 400 (Regular)
- Metadata: 400 (Regular, smaller size)

---

## 🎯 Design Principles

1. **Clarity First**: Each section is clearly labeled and visually distinct
2. **Scannable**: Use visual hierarchy, icons, and spacing for easy scanning
3. **Educational**: Tooltips and help text explain concepts
4. **Progressive Disclosure**: Start with summary, expand for details
5. **Feedback-Rich**: Immediate visual feedback on all interactions
6. **Accessibility**: WCAG AA compliant, keyboard navigable
7. **Consistent**: Follows Material Design 3 guidelines

---

**Ready to implement? Start with the section widgets and build up!**


