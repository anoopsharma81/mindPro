import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Voice-to-text input widget for reflection fields
/// Allows users to dictate instead of typing
class VoiceInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? hint;
  final Function(String)? onChanged;

  const VoiceInputField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 5,
    this.hint,
    this.onChanged,
  });

  @override
  State<VoiceInputField> createState() => _VoiceInputFieldState();
}

class _VoiceInputFieldState extends State<VoiceInputField> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech error: ${error.errorMsg}')),
            );
          }
        },
      );
      setState(() {});
    } catch (e) {
      _isAvailable = false;
    }
  }

  Future<void> _startListening() async {
    // Check microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required for voice input'),
          ),
        );
      }
      return;
    }

    if (!_isAvailable) {
      await _initSpeech();
      if (!_isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition not available'),
            ),
          );
        }
        return;
      }
    }

    _lastWords = '';
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          // Append to existing text
          final currentText = widget.controller.text;
          if (currentText.isNotEmpty && !currentText.endsWith(' ')) {
            widget.controller.text = '$currentText $_lastWords';
          } else {
            widget.controller.text = currentText + _lastWords;
          }
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
          widget.onChanged?.call(widget.controller.text);
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );

    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (_isAvailable)
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
                onPressed: _isListening ? _stopListening : _startListening,
                tooltip: _isListening ? 'Stop recording' : 'Start voice input',
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            suffixIcon: _isListening
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
        ),
        if (_isListening)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Listening... Tap the mic to stop',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}

