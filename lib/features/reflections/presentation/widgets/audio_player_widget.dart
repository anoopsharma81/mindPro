import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

/// Audio player widget for playing voice recordings
class AudioPlayerWidget extends StatefulWidget {
  final String? audioPath;  // Local file path
  final String? audioUrl;   // Firebase Storage URL
  final int? duration;      // Duration in seconds (optional)
  
  const AudioPlayerWidget({
    super.key,
    this.audioPath,
    this.audioUrl,
    this.duration,
  }) : assert(audioPath != null || audioUrl != null, 'Must provide either audioPath or audioUrl');
  
  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _stateSubscription;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  Future<void> _initializePlayer() async {
    try {
      // Set up listeners
      _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
        setState(() => _currentPosition = position);
      });
      
      _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
        setState(() => _totalDuration = duration);
      });
      
      _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      });
      
      // If duration is provided, use it
      if (widget.duration != null) {
        setState(() {
          _totalDuration = Duration(seconds: widget.duration!);
        });
      }
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }
  
  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_currentPosition == _totalDuration && _totalDuration != Duration.zero) {
          // Restart if at the end
          await _audioPlayer.seek(Duration.zero);
        }
        
        if (widget.audioPath != null) {
          await _audioPlayer.play(DeviceFileSource(widget.audioPath!));
        } else if (widget.audioUrl != null) {
          await _audioPlayer.play(UrlSource(widget.audioUrl!));
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }
  
  Future<void> _seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Play/pause button and duration
          Row(
            children: [
              IconButton(
                onPressed: _playPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 48,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPlaying ? 'Playing...' : 'Voice Recording',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.mic, color: Colors.grey.shade400),
            ],
          ),
          
          // Progress bar
          if (_totalDuration != Duration.zero)
            Slider(
              value: _currentPosition.inSeconds.toDouble(),
              max: _totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                _seek(Duration(seconds: value.toInt()));
              },
              activeColor: Colors.red.shade700,
            ),
        ],
      ),
    );
  }
}

