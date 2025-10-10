import 'package:flutter/material.dart';

/// Help tooltip icon that shows detailed information
class HelpTooltip extends StatelessWidget {
  final String message;
  final IconData icon;
  final double size;
  
  const HelpTooltip({
    super.key,
    required this.message,
    this.icon = Icons.help_outline,
    this.size = 20,
  });
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
      preferBelow: false,
      child: Icon(
        icon,
        size: size,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
      ),
    );
  }
  
  /// Show detailed help dialog
  static Future<void> showHelpDialog(
    BuildContext context, {
    required String title,
    required String content,
    List<String>? tips,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.help,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content),
              if (tips != null && tips.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tips:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Help button that opens detailed help dialog
class HelpButton extends StatelessWidget {
  final String title;
  final String content;
  final List<String>? tips;
  
  const HelpButton({
    super.key,
    required this.title,
    required this.content,
    this.tips,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: 'Help',
      onPressed: () => HelpTooltip.showHelpDialog(
        context,
        title: title,
        content: content,
        tips: tips,
      ),
    );
  }
}

