import 'package:flutter/material.dart';

/// Reflection templates to guide users and reduce blank page anxiety
class ReflectionTemplate {
  final String id;
  final String title;
  final String description;
  final String whatPrompt;
  final String soWhatPrompt;
  final String nowWhatPrompt;
  final List<int> suggestedDomains;
  final IconData icon;

  const ReflectionTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.whatPrompt,
    required this.soWhatPrompt,
    required this.nowWhatPrompt,
    required this.suggestedDomains,
    required this.icon,
  });
}

/// Pre-built reflection templates
class ReflectionTemplates {
  static const List<ReflectionTemplate> templates = [
    ReflectionTemplate(
      id: 'critical-incident',
      title: 'Critical Incident',
      description: 'Reflect on a challenging clinical situation or near-miss',
      whatPrompt: 'Describe the critical incident: What happened? What were the circumstances? '
          'Who was involved? (Use "a patient" or age ranges, not names)',
      soWhatPrompt: 'What were the key issues? What could have gone differently? '
          'What did you learn about clinical safety, communication, or decision-making?',
      nowWhatPrompt: 'What specific changes will you make to your practice? '
          'What systems or processes need improvement? How will you ensure this doesn\'t happen again?',
      suggestedDomains: [1, 2], // Knowledge & Safety
      icon: Icons.warning_amber,
    ),
    ReflectionTemplate(
      id: 'learning-excellence',
      title: 'Learning from Excellence',
      description: 'Celebrate excellent practice and positive outcomes',
      whatPrompt: 'Describe what went really well: What excellent practice did you observe or deliver? '
          'What made it exceptional?',
      soWhatPrompt: 'Why was this excellent? What principles or skills made it successful? '
          'What can you learn from this positive experience?',
      nowWhatPrompt: 'How can you replicate this excellence consistently? '
          'How can you share this learning with colleagues? What will you continue doing?',
      suggestedDomains: [1, 3], // Knowledge & Communication
      icon: Icons.stars,
    ),
    ReflectionTemplate(
      id: 'difficult-conversation',
      title: 'Difficult Conversation',
      description: 'Reflect on challenging communication with patients or colleagues',
      whatPrompt: 'Describe the difficult conversation: Who was involved? '
          'What made it challenging? What was said?',
      soWhatPrompt: 'Why was it difficult? What communication skills were tested? '
          'What went well and what could have been better? How did emotions play a role?',
      nowWhatPrompt: 'What communication strategies will you use next time? '
          'What training or support might help? How will you prepare for similar situations?',
      suggestedDomains: [3, 4], // Communication & Trust
      icon: Icons.forum,
    ),
    ReflectionTemplate(
      id: 'multidisciplinary',
      title: 'Multidisciplinary Learning',
      description: 'Reflect on teamwork and collaboration',
      whatPrompt: 'Describe the multidisciplinary situation: Who was involved? '
          'What were you trying to achieve together? What happened?',
      soWhatPrompt: 'How did different professionals contribute? What worked well in the teamwork? '
          'What could have been better? What did you learn from other disciplines?',
      nowWhatPrompt: 'How will you improve collaboration? What role will you take in MDT discussions? '
          'How can you better utilize team expertise?',
      suggestedDomains: [3], // Communication & Teamwork
      icon: Icons.groups,
    ),
    ReflectionTemplate(
      id: 'clinical-decision',
      title: 'Complex Clinical Decision',
      description: 'Reflect on difficult diagnostic or treatment decisions',
      whatPrompt: 'Describe the clinical scenario and the decision you faced: '
          'What were the options? What evidence or guidelines did you consider?',
      soWhatPrompt: 'What made this decision complex? What factors did you weigh? '
          'How did you involve the patient? What uncertainties remained?',
      nowWhatPrompt: 'What will you do differently in similar situations? '
          'What knowledge gaps will you address? How will you manage uncertainty better?',
      suggestedDomains: [1, 2], // Knowledge & Safety
      icon: Icons.psychology,
    ),
    ReflectionTemplate(
      id: 'feedback-received',
      title: 'Feedback Received',
      description: 'Reflect on feedback from appraisals, MSF, or colleagues',
      whatPrompt: 'Describe the feedback you received: Who gave it? What was the context? '
          'What specific points were made?',
      soWhatPrompt: 'How did the feedback make you feel? What patterns emerge? '
          'What strengths were identified? What areas for development?',
      nowWhatPrompt: 'What specific actions will you take based on this feedback? '
          'What support do you need? How will you measure progress?',
      suggestedDomains: [1, 4], // Knowledge & Maintaining Trust
      icon: Icons.feedback,
    ),
    ReflectionTemplate(
      id: 'teaching-moment',
      title: 'Teaching or Mentoring',
      description: 'Reflect on teaching medical students, trainees, or colleagues',
      whatPrompt: 'Describe the teaching situation: Who did you teach? What was the topic? '
          'What teaching methods did you use?',
      soWhatPrompt: 'How effective was your teaching? What did the learner take away? '
          'What did YOU learn from the teaching experience?',
      nowWhatPrompt: 'How will you improve your teaching? What new teaching methods will you try? '
          'How can you create more teaching opportunities?',
      suggestedDomains: [1, 3], // Knowledge & Communication
      icon: Icons.school,
    ),
    ReflectionTemplate(
      id: 'patient-complaint',
      title: 'Patient Concern or Complaint',
      description: 'Reflect on patient feedback, concerns, or formal complaints',
      whatPrompt: 'Describe the patient concern: What was the issue? How did it arise? '
          'What was the patient\'s perspective?',
      soWhatPrompt: 'What caused this concern? What can you learn from the patient\'s experience? '
          'What systemic issues contributed? How did you respond?',
      nowWhatPrompt: 'What will you change in your practice? How will you prevent similar concerns? '
          'How can you improve patient-centered care?',
      suggestedDomains: [3, 4], // Communication & Trust
      icon: Icons.report_problem,
    ),
    ReflectionTemplate(
      id: 'personal-wellness',
      title: 'Personal Wellbeing',
      description: 'Reflect on work-life balance, burnout, or self-care',
      whatPrompt: 'Describe a situation affecting your wellbeing: What happened? '
          'How did work impact your personal life or vice versa?',
      soWhatPrompt: 'How did this affect you emotionally and professionally? '
          'What warning signs did you notice? What support helped or could have helped?',
      nowWhatPrompt: 'What boundaries will you set? What self-care practices will you adopt? '
          'Who can you turn to for support? How will you monitor your wellbeing?',
      suggestedDomains: [1, 4], // Knowledge & Maintaining Trust
      icon: Icons.self_improvement,
    ),
    ReflectionTemplate(
      id: 'blank',
      title: 'Blank Reflection',
      description: 'Start from scratch with no template',
      whatPrompt: '',
      soWhatPrompt: '',
      nowWhatPrompt: '',
      suggestedDomains: [],
      icon: Icons.edit_note,
    ),
  ];

  static ReflectionTemplate? getById(String id) {
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Dialog to select a reflection template
class TemplatePickerDialog extends StatelessWidget {
  const TemplatePickerDialog({super.key});

  static Future<ReflectionTemplate?> show(BuildContext context) {
    return showDialog<ReflectionTemplate>(
      context: context,
      builder: (context) => const TemplatePickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a Template',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Start with a guided framework',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: ReflectionTemplates.templates.length,
                itemBuilder: (context, index) {
                  final template = ReflectionTemplates.templates[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Icon(
                        template.icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      title: Text(
                        template.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(template.description),
                      onTap: () => Navigator.of(context).pop(template),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

