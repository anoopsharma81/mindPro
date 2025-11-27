import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logger.dart';
import '../../../core/env.dart';
import '../../reflections/data/reflection.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LearningLoopService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west2',
  );
  
  final String? httpBaseUrl; // Only used if not using Firebase Functions
  
  LearningLoopService({this.httpBaseUrl});
  
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
      
      if (Env.useFirebaseFunctions) {
        // Use Firebase Callable Function
        try {
          final callable = _functions.httpsCallable(
            'generateLearningLoop',
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 300), // 5 minutes for AI processing
            ),
          );
          final result = await callable.call({
            'clinical_text': clinicalText,
          });
          final data = result.data as Map<String, dynamic>;
          
          if (data['success'] != true) {
            throw Exception('API returned success: false');
          }
          
          Logger.info('Learning Loop generated successfully');
          return data['learning_loop'] as Map<String, dynamic>;
        } on FirebaseFunctionsException catch (e, stack) {
          Logger.error(
            'Firebase Function generateLearningLoop failed',
            'Code: ${e.code}, Message: ${e.message}, Details: ${e.details}',
            stack,
          );
          
          String errorMessage;
          switch (e.code) {
            case 'unauthenticated':
              errorMessage = 'Authentication required. Please log in again and try.';
              break;
            case 'permission-denied':
              errorMessage = 'Permission denied. You don\'t have permission to use this feature.';
              break;
            case 'invalid-argument':
              errorMessage = 'Invalid request: ${e.message ?? 'Please check your input and try again.'}';
              break;
            case 'not-found':
              errorMessage = 'Firebase Cloud Function not found. The generateLearningLoop function may not be deployed.';
              break;
            case 'internal':
              errorMessage = 'Learning Loop generation failed.\n\n'
                  'The function encountered an internal error.\n\n'
                  'Common causes:\n'
                  '• Missing OpenAI API key in Firebase Secrets\n'
                  '• OpenAI API quota/rate limit exceeded\n'
                  '• Function timeout (AI processing took too long)\n\n'
                  'To debug:\n'
                  '1. Check Firebase Console → Functions → generateLearningLoop\n'
                  '2. View function logs: firebase functions:log --only generateLearningLoop\n'
                  '3. Verify secrets: firebase functions:secrets:access OPENAI_API_KEY';
              break;
            case 'unavailable':
              errorMessage = 'Firebase Cloud Function unavailable. Please try again later.';
              break;
            default:
              errorMessage = 'Learning Loop generation failed.\n\n'
                  'Error code: ${e.code}\n'
                  'Message: ${e.message ?? 'Unknown error'}';
          }
          
          throw Exception(errorMessage);
        } catch (e, stack) {
          Logger.error('Learning Loop Firebase Function call failed', e, stack);
          rethrow;
        }
      }
      
      // Fallback to HTTP backend
      final baseUrl = httpBaseUrl ?? 'http://192.168.0.13:3001';
      final response = await http.post(
        Uri.parse('$baseUrl/api/learning-loop/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'clinical_text': clinicalText,
        }),
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          throw Exception('Request timed out after 90 seconds. The AI is taking longer than expected. Please try again.');
        },
      );
      
      Logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
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
  return LearningLoopService();
});

