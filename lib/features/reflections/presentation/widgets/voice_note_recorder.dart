import 'package:flutter/material.dart';
import 'dart:async';

/// Voice note recorder widget with timer and controls
class VoiceNoteRecorder extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final bool isRecording;
  final int maxDurationSeconds;
  final String? liveTranscription; // Live transcription text
  final bool enableLiveTranscription; // Whether to show live transcription
  
  const VoiceNoteRecorder({
    super.key,
    required this.onStart,
    required this.onStop,
    required this.onCancel,
    required this.isRecording,
    this.maxDurationSeconds = 180, // 3 minutes
    this.liveTranscription,
    this.enableLiveTranscription = false,
  });
  
  @override
  State<VoiceNoteRecorder> createState() => _VoiceNoteRecorderState();
}

class _VoiceNoteRecorderState extends State<VoiceNoteRecorder>
    with SingleTickerProviderStateMixin {
  int _elapsedSeconds = 0;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void didUpdateWidget(VoiceNoteRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording && !oldWidget.isRecording) {
      _startTimer();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopTimer();
    }
  }
  
  void _startTimer() {
    _elapsedSeconds = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
      
      // Auto-stop at max duration
      if (_elapsedSeconds >= widget.maxDurationSeconds) {
        widget.onStop();
      }
    });
  }
  
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // Waveform animation
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isRecording ? _scaleAnimation.value : 1.0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isRecording
                      ? Colors.red.shade100
                      : Colors.grey.shade200,
                  boxShadow: widget.isRecording
                      ? [
                          BoxShadow(
                            color: Colors.red.shade200,
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  Icons.mic,
                  size: 60,
                  color: widget.isRecording ? Colors.red : Colors.grey,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        
        // Timer
        Text(
          '${_formatDuration(_elapsedSeconds)} / ${_formatDuration(widget.maxDurationSeconds)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
        ),
        const SizedBox(height: 16),
        
        // Recording status
        Text(
          widget.isRecording ? 'Recording...' : 'Ready to record',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: widget.isRecording ? Colors.red : Colors.grey,
              ),
        ),
        
        // Live transcription display
        if (widget.enableLiveTranscription && widget.isRecording && widget.liveTranscription != null)
          Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_fields, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Live Transcription',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.liveTranscription!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 48),
        
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel button
            if (widget.isRecording)
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close),
                iconSize: 32,
                tooltip: 'Cancel',
              ),
            const SizedBox(width: 32),
            
            // Record/Stop button
            GestureDetector(
              onTap: widget.isRecording ? widget.onStop : widget.onStart,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isRecording ? Colors.red : Colors.red.shade700,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.isRecording ? Icons.stop : Icons.mic,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 32),
            
            // Spacer for alignment
            if (widget.isRecording)
              const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 32),
        
        // Helpful tip
        if (!widget.isRecording)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Tap the microphone to start recording\nSpeak clearly near the microphone',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

