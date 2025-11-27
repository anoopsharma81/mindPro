import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metanoia Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().substring(0, 10)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              'Data Controller',
              'Metanoia is a reflective practice tool for NHS clinicians. '
              'You (the user) are the data controller for your personal reflections and CPD records. '
              'We act as a data processor to store and manage your data securely.',
            ),
            
            _buildSection(
              context,
              'What Data We Collect',
              '• Your name and GMC number\n'
              '• Your reflections (What/So What/Now What)\n'
              '• Your CPD activities (title, hours, dates, notes)\n'
              '• Year configurations (specialty, organisation, appraiser details)\n'
              '• Quality scores and ratings (if using AI features)\n'
              '• Authentication data (email, encrypted password)',
            ),
            
            _buildSection(
              context,
              'What We DO NOT Collect',
              '• Patient names or identifiers\n'
              '• NHS numbers or hospital numbers\n'
              '• Patient contact details\n'
              '• Clinical records or patient data\n'
              '• Location tracking\n'
              '• Device information beyond authentication',
            ),
            
            _buildSection(
              context,
              'How We Use Your Data',
              '• To provide the appraisal portfolio service\n'
              '• To generate exports for NHS appraisal\n'
              '• To improve reflection quality (AI features, if used)\n'
              '• To sync across your devices\n'
              '• To maintain backup and recovery capabilities',
            ),
            
            _buildSection(
              context,
              'Data Storage & Security',
              '• Data stored in Google Cloud Firestore (UK/EU region)\n'
              '• Encrypted in transit (TLS 1.3) and at rest\n'
              '• Backed up automatically with 30-day retention\n'
              '• Access controlled by Firebase Authentication\n'
              '• Per-user data isolation enforced by security rules',
            ),
            
            _buildSection(
              context,
              'Data Sharing',
              'We DO NOT share your data with third parties, except:\n'
              '• Google Cloud Platform (infrastructure provider)\n'
              '• OpenAI (if using AI improvement features - prompts only, no identifiers)\n\n'
              'Your reflections and CPD data are NEVER shared with:\n'
              '• Your employer or Trust\n'
              '• The GMC\n'
              '• Other users\n'
              '• Marketing or analytics platforms',
            ),
            
            _buildSection(
              context,
              'Your Rights (GDPR)',
              '• Right to access your data (via Export)\n'
              '• Right to rectification (edit anytime)\n'
              '• Right to erasure (delete account in Settings)\n'
              '• Right to data portability (export to markdown)\n'
              '• Right to object (opt out of analytics)\n'
              '• Right to withdraw consent (delete account)',
            ),
            
            _buildSection(
              context,
              'Data Retention',
              '• Active data: Retained while you have an account\n'
              '• Deleted data: Removed immediately from active database\n'
              '• Backups: Retained for 30 days then automatically deleted\n'
              '• Account deletion: All data removed within 30 days',
            ),
            
            _buildSection(
              context,
              'NHS Information Governance',
              '• Designed for NHS IG compliance\n'
              '• PHI detection warnings to prevent data breaches\n'
              '• No patient identifiers in reflections\n'
              '• DSPT-ready data handling\n'
              '• Audit trail for data access (coming soon)',
            ),
            
            _buildSection(
              context,
              'Cookies & Analytics',
              '• Essential cookies only for authentication\n'
              '• No tracking cookies\n'
              '• Anonymous analytics (opt-in)\n'
              '• Crash reports (opt-in, anonymized)\n'
              '• No third-party advertising',
            ),
            
            _buildSection(
              context,
              'Changes to This Policy',
              'We may update this policy to reflect changes in data protection law '
              'or our practices. We will notify you of significant changes via email '
              'or in-app notification.',
            ),
            
            _buildSection(
              context,
              'Contact & Data Protection Officer',
              'For data protection queries:\n'
              '• Email: privacy@metanoia.app\n'
              '• Data Protection Officer: [To be appointed]\n'
              '• ICO Registration: [To be completed]',
            ),
            
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Data, Your Control',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You have complete control over your data. You can export, '
                      'edit, or delete your information at any time. Metanoia is '
                      'designed to support your professional development while '
                      'respecting your privacy and NHS information governance requirements.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}





