import 'package:flutter/material.dart';

/// Animated AI processing indicator screen
class AiProcessingIndicator extends StatefulWidget {
  final String message;
  final List<String> steps;

  const AiProcessingIndicator({
    super.key,
    this.message = 'AI is analyzing your content...',
    this.steps = const [
      'Extracting key information',
      'Identifying learning moments',
      'Structuring reflection',
      'Suggesting GMC domains',
    ],
  });

  @override
  State<AiProcessingIndicator> createState() => _AiProcessingIndicatorState();
}

class _AiProcessingIndicatorState extends State<AiProcessingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Cycle through steps
    _cycleSteps();
  }

  void _cycleSteps() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _currentStep = (_currentStep + 1) % widget.steps.length;
        });
        _cycleSteps();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated sparkle icon
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.blue.shade400,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade200,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Message
          Text(
            widget.message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Progress indicator
          const CircularProgressIndicator(),
          const SizedBox(height: 32),

          // Steps list
          ...List.generate(widget.steps.length, (index) {
            final isActive = index == _currentStep;
            final isPast = index < _currentStep;
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.purple.shade400
                          : (isPast ? Colors.green.shade400 : Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Icon(
                        isPast ? Icons.check : (isActive ? Icons.circle : Icons.circle_outlined),
                        size: isPast ? 16 : 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Text
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? Colors.purple.shade700
                            : (isPast ? Colors.green.shade700 : Colors.grey.shade600),
                      ),
                      child: Text(widget.steps[index]),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Time estimate
          Text(
            'This usually takes 5-10 seconds',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen AI processing overlay
class AiProcessingOverlay extends StatelessWidget {
  final String message;
  final List<String> steps;
  final VoidCallback? onCancel;

  const AiProcessingOverlay({
    super.key,
    this.message = 'AI is analyzing your content...',
    this.steps = const [
      'Extracting key information',
      'Identifying learning moments',
      'Structuring reflection',
      'Suggesting GMC domains',
    ],
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AiProcessingIndicator(
                message: message,
                steps: steps,
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


