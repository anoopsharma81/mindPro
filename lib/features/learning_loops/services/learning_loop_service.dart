import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logger.dart';
import '../../reflections/data/reflection.dart';
import '../../reflections/data/reflection_repository.dart';

class LearningLoopService {
  final String baseUrl;
  
  // Use Mac's IP address when running on physical device
  // Change back to 'http://localhost:3001' when running on simulator/web
  LearningLoopService({this.baseUrl = 'http://192.168.0.13:3001'});
  
  /// Generate Learning Loop from reflection
  Future<Map<String, dynamic>> generateFromReflection(Reflection reflection) async {
    try {
      Logger.info('Generating Learning Loop for reflection: ${reflection.id}');
      
      // Construct clinical text from reflection
      final clinicalText = '''
Title: ${reflection.title}

What happened:
${reflection.what}

Analysis and reflection:
${reflection.soWhat}

Action plan:
${reflection.nowWhat}

${reflection.tags.isNotEmpty ? 'Tags: ${reflection.tags.join(', ')}' : ''}
''';
      
      Logger.info('Clinical text: ${clinicalText.length} characters');
      
      // Call backend API
      final response = await http.post(
        Uri.parse('$baseUrl/api/learning-loop/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'clinical_text': clinicalText,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out after 30 seconds. The AI is taking longer than expected.');
        },
      );
      
      Logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to generate Learning Loop: ${errorBody['error'] ?? response.body}');
      }
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception('API returned success: false');
      }
      
      Logger.info('Learning Loop generated successfully');
      
      return data['learning_loop'] as Map<String, dynamic>;
    } catch (e, stack) {
      Logger.error('Failed to generate Learning Loop', e, stack);
      rethrow;
    }
  }
}

/// Provider for Learning Loop Service
final learningLoopServiceProvider = Provider<LearningLoopService>((ref) {
  // Use Mac's IP for physical device testing
  // In production, this would use the actual deployed backend URL
  return LearningLoopService(baseUrl: 'http://192.168.0.13:3001');
});

