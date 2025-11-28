import 'package:dio/dio.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/http_client.dart';
import '../core/env.dart';
import '../core/logger.dart';

/// API service for backend communication
class ApiService {
  final Dio _dio = HttpClient.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west2',
  );
  
  /// Self-play reflection improvement
  /// POST /api/reflection/selfplay
  Future<Map<String, dynamic>> runSelfPlay({
    required String year,
    required String title,
    required String context,
    int iterations = 3,
  }) async {
    if (Env.useFirebaseFunctions) {
      // Use Firebase Callable Function
      try {
        final callable = _functions.httpsCallable(
          'selfPlay',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 300), // 5 minutes for AI processing
          ),
        );
        final result = await callable.call({
          'year': year,
          'title': title,
          'context': context,
          'iterations': iterations,
        });
        return result.data as Map<String, dynamic>;
      } on FirebaseFunctionsException catch (e, stack) {
        // Extract error details more thoroughly
        String errorDetailsStr = '';
        String actualErrorMessage = e.message ?? '';
        
        // Try to extract details - it might be a Map, String, or other type
        if (e.details != null) {
          if (e.details is Map) {
            errorDetailsStr = (e.details as Map).toString();
            // Try to extract 'details' or 'message' from the map
            final detailsMap = e.details as Map;
            if (detailsMap.containsKey('details') && detailsMap['details'] != null) {
              errorDetailsStr = detailsMap['details'].toString();
            } else if (detailsMap.containsKey('message') && detailsMap['message'] != null) {
              actualErrorMessage = detailsMap['message'].toString();
            } else {
              // Convert entire map to readable string
              errorDetailsStr = detailsMap.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n');
            }
          } else {
            errorDetailsStr = e.details.toString();
          }
        }
        
        // Combine error message and details
        final fullErrorText = [
          if (actualErrorMessage.isNotEmpty) actualErrorMessage,
          if (errorDetailsStr.isNotEmpty && errorDetailsStr != actualErrorMessage) errorDetailsStr,
        ].join('\n').toLowerCase();
        
        // Log detailed error information for debugging
        Logger.error(
          'Firebase Function selfPlay failed',
          'Code: ${e.code}\n'
          'Message: ${e.message ?? "N/A"}\n'
          'Details: $errorDetailsStr',
          stack,
        );
        
        // Provide specific error messages based on error code
        String errorMessage;
        switch (e.code) {
          case 'unauthenticated':
            errorMessage = 'Authentication required.\n\n'
                'Please log in again and try.';
            break;
          case 'permission-denied':
            errorMessage = 'Permission denied.\n\n'
                'You don\'t have permission to use this feature.';
            break;
          case 'invalid-argument':
            errorMessage = 'Invalid request.\n\n'
                '${actualErrorMessage.isNotEmpty ? actualErrorMessage : 'Please check your input and try again.'}';
            break;
          case 'not-found':
            errorMessage = 'Firebase Cloud Function not found.\n\n'
                'The selfPlay function may not be deployed.\n\n'
                'Please check:\n'
                '1. Firebase Console → Functions → Verify selfPlay is deployed\n'
                '2. Run: firebase deploy --only functions:selfPlay\n'
                '3. Check the function name matches exactly (case-sensitive)';
            break;
          case 'internal':
            // Check for specific error patterns in details
            String specificIssue = '';
            String diagnosticInfo = '';
            
            if (fullErrorText.contains('openai_api_key') || 
                fullErrorText.contains('api key') ||
                fullErrorText.contains('api_key') ||
                fullErrorText.contains('secret')) {
              specificIssue = '⚠️  Likely cause: Missing or invalid OpenAI API key.';
              diagnosticInfo = '\n\nThe Firebase Function needs OPENAI_API_KEY configured in Firebase Secrets.\n\n'
                  'To fix:\n'
                  '1. Set the secret: firebase functions:secrets:set OPENAI_API_KEY\n'
                  '2. Redeploy the function: firebase deploy --only functions:selfPlay\n'
                  '3. Verify: firebase functions:secrets:access OPENAI_API_KEY';
            } else if (fullErrorText.contains('timeout') ||
                       fullErrorText.contains('deadline') ||
                       fullErrorText.contains('exceeded')) {
              specificIssue = '⚠️  Likely cause: Function timeout.';
              diagnosticInfo = '\n\nThe AI processing took too long (max 300 seconds).\n\n'
                  'Try:\n'
                  '• Reducing the number of iterations\n'
                  '• Shortening the reflection text\n'
                  '• Checking function logs for more details';
            } else if (fullErrorText.contains('quota') ||
                       fullErrorText.contains('rate limit') ||
                       fullErrorText.contains('billing')) {
              specificIssue = '⚠️  Likely cause: OpenAI API quota or rate limit exceeded.';
              diagnosticInfo = '\n\nPlease check your OpenAI account:\n'
                  '• Usage dashboard: https://platform.openai.com/usage\n'
                  '• Billing settings: https://platform.openai.com/account/billing\n'
                  '• Try again later if rate limited';
            } else if (fullErrorText.contains('not found') ||
                       fullErrorText.contains('undefined')) {
              specificIssue = '⚠️  Likely cause: Function not properly deployed or configured.';
              diagnosticInfo = '\n\nThe selfPlay function may not exist or be misconfigured.\n\n'
                  'Check:\n'
                  '1. Firebase Console → Functions\n'
                  '2. Verify selfPlay function exists and is deployed\n'
                  '3. Check function logs for deployment errors';
            }
            
            // Check if error message is just a generic error code
            final isGenericMessage = actualErrorMessage.toUpperCase() == 'INTERNAL' ||
                actualErrorMessage.toLowerCase() == 'internal' ||
                actualErrorMessage.toLowerCase() == 'internal server error' ||
                actualErrorMessage.isEmpty ||
                actualErrorMessage.toLowerCase() == 'self-play failed';
            
            // Build comprehensive error message
            final buffer = StringBuffer('AI Reflection Improvement failed.\n\n');
            
            if (specificIssue.isNotEmpty) {
              buffer.writeln(specificIssue);
              if (diagnosticInfo.isNotEmpty) {
                buffer.writeln(diagnosticInfo);
              }
            } else if (!isGenericMessage && actualErrorMessage.isNotEmpty) {
              // Show the actual error message if it's meaningful
              buffer.writeln('Error from server:');
              buffer.writeln('\n$actualErrorMessage');
            } else {
              // Generic error with no specific details
              buffer.writeln('The Firebase Function encountered an internal error.');
              buffer.writeln('\nThe function may not be properly configured or deployed.');
            }
            
            // If we have error details that might be helpful, include them
            if (errorDetailsStr.isNotEmpty && 
                errorDetailsStr != actualErrorMessage &&
                !errorDetailsStr.toLowerCase().contains('internal') &&
                !isGenericMessage) {
              buffer.writeln('\nAdditional details:');
              buffer.writeln(errorDetailsStr.length > 200 
                  ? '${errorDetailsStr.substring(0, 200)}...' 
                  : errorDetailsStr);
            }
            
            buffer.writeln('\n${List.filled(40, '─').join()}');
            buffer.writeln('\nMost likely causes:');
            buffer.writeln('1. ❌ Function not deployed');
            buffer.writeln('   → Check: Firebase Console → Functions → Verify selfPlay exists');
            buffer.writeln('   → Deploy: firebase deploy --only functions:selfPlay');
            buffer.writeln('');
            buffer.writeln('2. 🔑 Missing OpenAI API key');
            buffer.writeln('   → Set: firebase functions:secrets:set OPENAI_API_KEY');
            buffer.writeln('   → Verify: firebase functions:secrets:access OPENAI_API_KEY');
            buffer.writeln('   → Then redeploy: firebase deploy --only functions:selfPlay');
            buffer.writeln('');
            buffer.writeln('3. ⏱️  Function timeout or quota exceeded');
            buffer.writeln('   → Check logs: firebase functions:log --only selfPlay');
            buffer.writeln('   → Check OpenAI usage: https://platform.openai.com/usage');
            buffer.writeln('');
            buffer.writeln('4. 🔧 Function configuration issue');
            buffer.writeln('   → Verify function exists in: functions/src/apiFunctions.ts');
            buffer.writeln('   → Check region matches: europe-west2');
            buffer.writeln('   → Review function logs in Firebase Console');
            
            errorMessage = buffer.toString();
            break;
          case 'unavailable':
            errorMessage = 'Firebase Cloud Function unavailable.\n\n'
                'The service is temporarily unavailable.\n\n'
                'Please try again in a few moments.';
            break;
          default:
            final buffer = StringBuffer('AI Reflection Improvement failed.\n\n');
            buffer.writeln('Error code: ${e.code}');
            if (actualErrorMessage.isNotEmpty) {
              buffer.writeln('Message: $actualErrorMessage');
            }
            if (errorDetailsStr.isNotEmpty && errorDetailsStr != actualErrorMessage) {
              buffer.writeln('\nDetails: $errorDetailsStr');
            }
            buffer.writeln('\nPlease check Firebase Console → Functions → selfPlay for more information.');
            errorMessage = buffer.toString();
        }
        
        throw Exception(errorMessage);
      } catch (e, stack) {
        // Catch any other exceptions from Firebase Functions
        Logger.error('Self-play Firebase Function call failed', e, stack);
        rethrow;
      }
    }
    
    // Fallback to HTTP backend (only if not using Firebase Functions)
    try {
      final backendUrl = Env.apiBaseUrl != 'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/api'
          ? Env.apiBaseUrl
          : 'http://localhost:3001/api';
      
      final dioWithLongTimeout = Dio(BaseOptions(
        baseUrl: backendUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 300),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
      
      dioWithLongTimeout.interceptors.addAll(_dio.interceptors);
      
      final response = await dioWithLongTimeout.post(
        '/reflection/selfplay',
        data: {
          'year': year,
          'title': title,
          'context': context,
          'iterations': iterations,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e, stack) {
      Logger.error('Self-play HTTP backend call failed', e, stack);
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('connection') || errorStr.contains('connection error') || 
          errorStr.contains('connection refused') || errorStr.contains('404')) {
        throw Exception(
          'Backend server is not running or unreachable.\n\n'
          'To fix this, start the backend server:\n'
          'cd backend && npm start'
        );
      }
      
      rethrow;
    }
  }
  
  /// Submit reflection rating for reinforcement learning
  /// POST /api/reflection/reinforce
  Future<Map<String, dynamic>> reinforceReflection({
    required String year,
    required String rid,
    required int rating,
  }) async {
    try {
      if (Env.useFirebaseFunctions) {
        final callable = _functions.httpsCallable('reinforce');
        final result = await callable.call({
          'year': year,
          'rid': rid,
          'rating': rating,
        });
        return result.data as Map<String, dynamic>;
      } else {
        final response = await _dio.post(
          '/reflection/reinforce',
          data: {
            'year': year,
            'rid': rid,
            'rating': rating,
          },
        );
        return response.data as Map<String, dynamic>;
      }
    } catch (e, stack) {
      Logger.error('Reinforce API call failed', e, stack);
      rethrow;
    }
  }
  
  /// Auto-tag CPD entry
  /// POST /api/cpd
  Future<Map<String, dynamic>> autoTagCpd({
    required String year,
    required String title,
    required String summary,
    required double hours,
    required DateTime date,
  }) async {
    try {
      if (Env.useFirebaseFunctions) {
        final callable = _functions.httpsCallable('autoTagCpd');
        final result = await callable.call({
          'year': year,
          'title': title,
          'summary': summary,
          'hours': hours,
          'date': date.toIso8601String(),
        });
        return result.data as Map<String, dynamic>;
      } else {
        final response = await _dio.post(
          '/cpd',
          data: {
            'year': year,
            'title': title,
            'summary': summary,
            'hours': hours,
            'date': date.toIso8601String(),
          },
        );
        return response.data as Map<String, dynamic>;
      }
    } catch (e, stack) {
      Logger.error('CPD auto-tag API call failed', e, stack);
      rethrow;
    }
  }
  
  /// Export appraisal pack (DOCX/PDF)
  /// POST /api/export
  Future<Map<String, dynamic>> exportAppraisalPack({
    required String year,
    required bool includeProfile,
    required bool includeReflections,
    required bool includeCpd,
    String format = 'DOCX',
  }) async {
    try {
      final response = await _dio.post(
        '/export',
        data: {
          'year': year,
          'sections': {
            'profile': includeProfile,
            'reflections': includeReflections,
            'cpd': includeCpd,
          },
          'format': format,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e, stack) {
      Logger.error('Export API call failed', e, stack);
      rethrow;
    }
  }
  
  /// Get export status
  /// GET /api/export/{exportId}
  Future<Map<String, dynamic>> getExportStatus(String exportId) async {
    try {
      final response = await _dio.get('/export/$exportId');
      return response.data as Map<String, dynamic>;
    } catch (e, stack) {
      Logger.error('Get export status failed', e, stack);
      rethrow;
    }
  }
  
  /// Extract reflection from document/photo
  /// POST /api/extract
  Future<Map<String, dynamic>> extractFromDocument({
    required String photoUrl,
    required String source,
    String? mimeType,
  }) async {
    try {
      if (Env.useFirebaseFunctions) {
        final callable = _functions.httpsCallable('extract');
        final result = await callable.call({
          'photoUrl': photoUrl,
          'source': source,
          'mimeType': mimeType,
        });
        return result.data as Map<String, dynamic>;
      } else {
        final response = await _dio.post(
          '/extract',
          data: {
            'photoUrl': photoUrl,
            'source': source,
            'mimeType': mimeType,
          },
        );
        return response.data as Map<String, dynamic>;
      }
    } catch (e, stack) {
      Logger.error('Extract API call failed', e, stack);
      rethrow;
    }
  }
  
  /// Transcribe audio using Whisper API
  /// POST /api/reflections/transcribe
  Future<Map<String, dynamic>> transcribeAudio({
    required String audioUrl,
  }) async {
    try {
      if (Env.useFirebaseFunctions) {
        final callable = _functions.httpsCallable('transcribeAudio');
        final result = await callable.call({
          'audioUrl': audioUrl,
        });
        return result.data as Map<String, dynamic>;
      } else {
        final response = await _dio.post(
          '/reflections/transcribe',
          data: {
            'audioUrl': audioUrl,
          },
        );
        return response.data as Map<String, dynamic>;
      }
    } catch (e, stack) {
      Logger.error('Transcribe audio API call failed', e, stack);
      rethrow;
    }
  }
  
  /// Structure transcription into reflection format
  /// POST /api/reflections/structure
  Future<Map<String, dynamic>> structureTranscription({
    required String transcription,
  }) async {
    Logger.info('structureTranscription called with input length: ${transcription.length}');
    Logger.info('Input text preview: "${transcription.length > 100 ? '${transcription.substring(0, 100)}...' : transcription}"');
    
    if (Env.useFirebaseFunctions) {
      // Use Firebase Callable Function
      try {
        Logger.info('Using Firebase Function structureTranscription');
        final callable = _functions.httpsCallable(
          'structureTranscription',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 300), // 5 minutes for AI processing
          ),
        );
        Logger.info('Calling Firebase function with transcription: "$transcription"');
        final result = await callable.call({
          'transcription': transcription,
        });
        Logger.info('Firebase function returned: ${result.data}');
        return result.data as Map<String, dynamic>;
      } on FirebaseFunctionsException catch (e, stack) {
        // Extract error details more thoroughly
        String errorDetailsStr = '';
        String actualErrorMessage = e.message ?? '';
        
        // Try to extract details - it might be a Map, String, or other type
        if (e.details != null) {
          if (e.details is Map) {
            errorDetailsStr = (e.details as Map).toString();
            // Try to extract 'details' or 'message' from the map
            final detailsMap = e.details as Map;
            if (detailsMap.containsKey('details') && detailsMap['details'] != null) {
              errorDetailsStr = detailsMap['details'].toString();
            } else if (detailsMap.containsKey('message') && detailsMap['message'] != null) {
              actualErrorMessage = detailsMap['message'].toString();
            } else {
              // Convert entire map to readable string
              errorDetailsStr = detailsMap.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n');
            }
          } else {
            errorDetailsStr = e.details.toString();
          }
        }
        
        // Combine error message and details
        final fullErrorText = [
          if (actualErrorMessage.isNotEmpty) actualErrorMessage,
          if (errorDetailsStr.isNotEmpty && errorDetailsStr != actualErrorMessage) errorDetailsStr,
        ].join('\n').toLowerCase();
        
        // Log detailed error information for debugging
        Logger.error(
          'Firebase Function structureTranscription failed',
          'Code: ${e.code}\n'
          'Message: ${e.message ?? "N/A"}\n'
          'Details: $errorDetailsStr',
          stack,
        );
        
        // Provide specific error messages based on error code
        String errorMessage;
        switch (e.code) {
          case 'unauthenticated':
            errorMessage = 'Authentication required.\n\n'
                'Please log in again and try.';
            break;
          case 'permission-denied':
            errorMessage = 'Permission denied.\n\n'
                'You don\'t have permission to use this feature.';
            break;
          case 'invalid-argument':
            errorMessage = 'Invalid request.\n\n'
                '${actualErrorMessage.isNotEmpty ? actualErrorMessage : 'Please check your input and try again.'}';
            break;
          case 'not-found':
            errorMessage = 'Firebase Cloud Function not found.\n\n'
                'The structureTranscription function may not be deployed.\n\n'
                'Please check:\n'
                '1. Firebase Console → Functions → Verify structureTranscription is deployed\n'
                '2. Run: firebase deploy --only functions:structureTranscription\n'
                '3. Check the function name matches exactly (case-sensitive)';
            break;
          case 'internal':
            // Check for specific error patterns in details
            String specificIssue = '';
            String diagnosticInfo = '';
            
            if (fullErrorText.contains('openai_api_key') || 
                fullErrorText.contains('api key') ||
                fullErrorText.contains('api_key') ||
                fullErrorText.contains('secret')) {
              specificIssue = '⚠️  Likely cause: Missing or invalid OpenAI API key.';
              diagnosticInfo = '\n\nThe Firebase Function needs OPENAI_API_KEY configured in Firebase Secrets.\n\n'
                  'To fix:\n'
                  '1. Set the secret: firebase functions:secrets:set OPENAI_API_KEY\n'
                  '2. Redeploy the function: firebase deploy --only functions:structureTranscription\n'
                  '3. Verify: firebase functions:secrets:access OPENAI_API_KEY';
            } else if (fullErrorText.contains('timeout') ||
                       fullErrorText.contains('deadline') ||
                       fullErrorText.contains('exceeded')) {
              specificIssue = '⚠️  Likely cause: Function timeout.';
              diagnosticInfo = '\n\nThe AI processing took too long (max 300 seconds).\n\n'
                  'Try:\n'
                  '• Shortening the transcription text\n'
                  '• Checking function logs for more details';
            } else if (fullErrorText.contains('quota') ||
                       fullErrorText.contains('rate limit') ||
                       fullErrorText.contains('billing')) {
              specificIssue = '⚠️  Likely cause: OpenAI API quota or rate limit exceeded.';
              diagnosticInfo = '\n\nPlease check your OpenAI account:\n'
                  '• Usage dashboard: https://platform.openai.com/usage\n'
                  '• Billing settings: https://platform.openai.com/account/billing\n'
                  '• Try again later if rate limited';
            } else if (fullErrorText.contains('not found') ||
                       fullErrorText.contains('undefined')) {
              specificIssue = '⚠️  Likely cause: Function not properly deployed or configured.';
              diagnosticInfo = '\n\nThe structureTranscription function may not exist or be misconfigured.\n\n'
                  'Check:\n'
                  '1. Firebase Console → Functions\n'
                  '2. Verify structureTranscription function exists and is deployed\n'
                  '3. Check function logs for deployment errors';
            }
            
            // Check if error message is just a generic error code
            final isGenericMessage = actualErrorMessage.toUpperCase() == 'INTERNAL' ||
                actualErrorMessage.toLowerCase() == 'internal' ||
                actualErrorMessage.toLowerCase() == 'internal server error' ||
                actualErrorMessage.isEmpty ||
                actualErrorMessage.toLowerCase() == 'structuring failed';
            
            // Build comprehensive error message
            final buffer = StringBuffer('Failed to structure transcription.\n\n');
            
            if (specificIssue.isNotEmpty) {
              buffer.writeln(specificIssue);
              if (diagnosticInfo.isNotEmpty) {
                buffer.writeln(diagnosticInfo);
              }
            } else if (!isGenericMessage && actualErrorMessage.isNotEmpty) {
              // Show the actual error message if it's meaningful
              buffer.writeln('Error from server:');
              buffer.writeln('\n$actualErrorMessage');
            } else {
              // Generic error with no specific details
              buffer.writeln('The Firebase Function encountered an internal error.');
              buffer.writeln('\nThe function may not be properly configured or deployed.');
            }
            
            // If we have error details that might be helpful, include them
            if (errorDetailsStr.isNotEmpty && 
                errorDetailsStr != actualErrorMessage &&
                !errorDetailsStr.toLowerCase().contains('internal') &&
                !isGenericMessage) {
              buffer.writeln('\nAdditional details:');
              buffer.writeln(errorDetailsStr.length > 200 
                  ? '${errorDetailsStr.substring(0, 200)}...' 
                  : errorDetailsStr);
            }
            
            buffer.writeln('\n${List.filled(40, '─').join()}');
            buffer.writeln('\nMost likely causes:');
            buffer.writeln('1. ❌ Function not deployed or needs redeploy');
            buffer.writeln('   → Check: Firebase Console → Functions → Verify structureTranscription exists');
            buffer.writeln('   → Deploy: firebase deploy --only functions:structureTranscription');
            buffer.writeln('');
            buffer.writeln('2. 🔑 Missing or invalid OpenAI API key');
            buffer.writeln('   → Set: firebase functions:secrets:set OPENAI_API_KEY');
            buffer.writeln('   → Verify: firebase functions:secrets:access OPENAI_API_KEY');
            buffer.writeln('   → Then redeploy: firebase deploy --only functions:structureTranscription');
            buffer.writeln('');
            buffer.writeln('3. ⏱️  Function timeout or quota exceeded');
            buffer.writeln('   → Check logs: firebase functions:log --only structureTranscription');
            buffer.writeln('   → Check OpenAI usage: https://platform.openai.com/usage');
            
            errorMessage = buffer.toString();
            break;
          case 'unavailable':
            errorMessage = 'Firebase Cloud Function unavailable.\n\n'
                'The service is temporarily unavailable.\n\n'
                'Please try again in a few moments.';
            break;
          default:
            final buffer = StringBuffer('Failed to structure transcription.\n\n');
            buffer.writeln('Error code: ${e.code}');
            if (actualErrorMessage.isNotEmpty) {
              buffer.writeln('Message: $actualErrorMessage');
            }
            if (errorDetailsStr.isNotEmpty && errorDetailsStr != actualErrorMessage) {
              buffer.writeln('\nDetails: $errorDetailsStr');
            }
            buffer.writeln('\nPlease check Firebase Console → Functions → structureTranscription for more information.');
            errorMessage = buffer.toString();
        }
        
        throw Exception(errorMessage);
      } catch (e, stack) {
        // Catch any other exceptions from Firebase Functions
        Logger.error('Structure transcription Firebase Function call failed', e, stack);
        rethrow;
      }
    }
    
    // Fallback to HTTP backend (only if not using Firebase Functions)
    try {
      Logger.info('Using HTTP backend for structureTranscription');
      Logger.info('POST /reflections/structure with transcription: "$transcription"');
      final response = await _dio.post(
        '/reflections/structure',
        data: {
          'transcription': transcription,
        },
      );
      Logger.info('HTTP backend returned: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e, stack) {
      Logger.error('Structure transcription HTTP backend call failed', e, stack);
      rethrow;
    }
  }
  
  /// Generate Metanoia reflection from raw case notes
  /// POST /api/metanoia/generate
  Future<Map<String, dynamic>> generateMetanoiaReflection({
    required String caseNotes,
    String? domain,
  }) async {
    Logger.info('generateMetanoiaReflection called with input length: ${caseNotes.length}');
    
    if (Env.useFirebaseFunctions) {
      // Use Firebase Callable Function
      try {
        Logger.info('Using Firebase Function generateMetanoiaReflection');
        final callable = _functions.httpsCallable(
          'generateMetanoiaReflection',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 300), // 5 minutes for AI processing
          ),
        );
        Logger.info('Calling Firebase function with case notes');
        final result = await callable.call({
          'caseNotes': caseNotes,
          if (domain != null) 'domain': domain,
        });
        Logger.info('Firebase function returned Metanoia reflection');
        return result.data as Map<String, dynamic>;
      } on FirebaseFunctionsException catch (e, stack) {
        // Extract error details more thoroughly
        String errorDetailsStr = '';
        String actualErrorMessage = e.message ?? '';
        
        // Try to extract details - it might be a Map, String, or other type
        if (e.details != null) {
          if (e.details is Map) {
            errorDetailsStr = (e.details as Map).toString();
            // Try to extract 'details' or 'message' from the map
            final detailsMap = e.details as Map;
            if (detailsMap.containsKey('details') && detailsMap['details'] != null) {
              errorDetailsStr = detailsMap['details'].toString();
            } else if (detailsMap.containsKey('message') && detailsMap['message'] != null) {
              actualErrorMessage = detailsMap['message'].toString();
            } else {
              // Convert entire map to readable string
              errorDetailsStr = detailsMap.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n');
            }
          } else {
            errorDetailsStr = e.details.toString();
          }
        }
        
        // Combine error message and details
        final fullErrorText = [
          if (actualErrorMessage.isNotEmpty) actualErrorMessage,
          if (errorDetailsStr.isNotEmpty && errorDetailsStr != actualErrorMessage) errorDetailsStr,
        ].join('\n').toLowerCase();
        
        // Log detailed error information for debugging
        Logger.error(
          'Firebase Function generateMetanoiaReflection failed',
          'Code: ${e.code}\n'
          'Message: ${e.message ?? "N/A"}\n'
          'Details: $errorDetailsStr',
          stack,
        );
        
        // Provide specific error messages based on error code
        String errorMessage;
        switch (e.code) {
          case 'unauthenticated':
            errorMessage = 'Authentication required.\n\n'
                'Please log in again and try.';
            break;
          case 'permission-denied':
            errorMessage = 'Permission denied.\n\n'
                'You don\'t have permission to use this feature.';
            break;
          case 'invalid-argument':
            errorMessage = 'Invalid request.\n\n'
                '${actualErrorMessage.isNotEmpty ? actualErrorMessage : 'Please check your input and try again.'}';
            break;
          case 'not-found':
            errorMessage = 'Firebase Cloud Function not found.\n\n'
                'The generateMetanoiaReflection function may not be deployed.\n\n'
                'Please check:\n'
                '1. Firebase Console → Functions → Verify generateMetanoiaReflection is deployed\n'
                '2. Run: firebase deploy --only functions:generateMetanoiaReflection\n'
                '3. Check the function name matches exactly (case-sensitive)';
            break;
          case 'internal':
            // Check for specific error patterns in details
            String specificIssue = '';
            String diagnosticInfo = '';
            
            if (fullErrorText.contains('openai_api_key') || 
                fullErrorText.contains('api key') ||
                fullErrorText.contains('api_key') ||
                fullErrorText.contains('secret')) {
              specificIssue = '⚠️  Likely cause: Missing or invalid OpenAI API key.';
              diagnosticInfo = '\n\nThe Firebase Function needs OPENAI_API_KEY configured in Firebase Secrets.\n\n'
                  'To fix:\n'
                  '1. Set the secret: firebase functions:secrets:set OPENAI_API_KEY\n'
                  '2. Redeploy the function: firebase deploy --only functions:generateMetanoiaReflection\n'
                  '3. Verify: firebase functions:secrets:access OPENAI_API_KEY';
            } else if (fullErrorText.contains('timeout') ||
                       fullErrorText.contains('deadline') ||
                       fullErrorText.contains('exceeded')) {
              specificIssue = '⚠️  Likely cause: Function timeout.';
              diagnosticInfo = '\n\nThe AI processing took too long (max 300 seconds).\n\n'
                  'Try:\n'
                  '• Shortening the case notes\n'
                  '• Checking function logs for more details';
            } else if (fullErrorText.contains('quota') ||
                       fullErrorText.contains('rate limit') ||
                       fullErrorText.contains('billing')) {
              specificIssue = '⚠️  Likely cause: OpenAI API quota or rate limit exceeded.';
              diagnosticInfo = '\n\nPlease check your OpenAI account:\n'
                  '• Usage dashboard: https://platform.openai.com/usage\n'
                  '• Billing settings: https://platform.openai.com/account/billing\n'
                  '• Try again later if rate limited';
            } else if (fullErrorText.contains('not found') ||
                       fullErrorText.contains('undefined')) {
              specificIssue = '⚠️  Likely cause: Function not properly deployed or configured.';
              diagnosticInfo = '\n\nThe generateMetanoiaReflection function may not exist or be misconfigured.\n\n'
                  'Check:\n'
                  '1. Firebase Console → Functions\n'
                  '2. Verify generateMetanoiaReflection function exists and is deployed\n'
                  '3. Check function logs for deployment errors';
            }
            
            // Check if error message is just a generic error code
            final isGenericMessage = actualErrorMessage.toUpperCase() == 'INTERNAL' ||
                actualErrorMessage.toLowerCase() == 'internal' ||
                actualErrorMessage.toLowerCase() == 'internal server error' ||
                actualErrorMessage.isEmpty ||
                actualErrorMessage.toLowerCase() == 'metanoia generation failed';
            
            // Build comprehensive error message
            final buffer = StringBuffer('Failed to generate Metanoia reflection.\n\n');
            
            if (specificIssue.isNotEmpty) {
              buffer.writeln(specificIssue);
              if (diagnosticInfo.isNotEmpty) {
                buffer.writeln(diagnosticInfo);
              }
            } else if (!isGenericMessage && actualErrorMessage.isNotEmpty) {
              // Show the actual error message if it's meaningful
              buffer.writeln('Error from server:');
              buffer.writeln('\n$actualErrorMessage');
            } else {
              // Generic error with no specific details
              buffer.writeln('The Firebase Function encountered an internal error.');
              buffer.writeln('\nThe function may not be properly configured or deployed.');
            }
            
            // If we have error details that might be helpful, include them
            if (errorDetailsStr.isNotEmpty && 
                errorDetailsStr != actualErrorMessage &&
                !errorDetailsStr.toLowerCase().contains('internal') &&
                !isGenericMessage) {
              buffer.writeln('\nAdditional details:');
              buffer.writeln(errorDetailsStr.length > 200 
                  ? '${errorDetailsStr.substring(0, 200)}...' 
                  : errorDetailsStr);
            }
            
            buffer.writeln('\n${List.filled(40, '─').join()}');
            buffer.writeln('\nMost likely causes:');
            buffer.writeln('1. ❌ Function not deployed or needs redeploy');
            buffer.writeln('   → Check: Firebase Console → Functions → Verify generateMetanoiaReflection exists');
            buffer.writeln('   → Deploy: firebase deploy --only functions:generateMetanoiaReflection');
            buffer.writeln('');
            buffer.writeln('2. 🔑 Missing or invalid OpenAI API key');
            buffer.writeln('   → Set: firebase functions:secrets:set OPENAI_API_KEY');
            buffer.writeln('   → Verify: firebase functions:secrets:access OPENAI_API_KEY');
            buffer.writeln('   → Then redeploy: firebase deploy --only functions:generateMetanoiaReflection');
            buffer.writeln('');
            buffer.writeln('3. ⏱️  Function timeout or quota exceeded');
            buffer.writeln('   → Check logs: firebase functions:log --only generateMetanoiaReflection');
            buffer.writeln('   → Check OpenAI usage: https://platform.openai.com/usage');
            
            errorMessage = buffer.toString();
            break;
          case 'unavailable':
            errorMessage = 'Firebase Cloud Function unavailable.\n\n'
                'The service is temporarily unavailable.\n\n'
                'Please try again in a few moments.';
            break;
          default:
            final buffer = StringBuffer('Failed to generate Metanoia reflection.\n\n');
            buffer.writeln('Error code: ${e.code}');
            if (actualErrorMessage.isNotEmpty) {
              buffer.writeln('Message: $actualErrorMessage');
            }
            if (errorDetailsStr.isNotEmpty && errorDetailsStr != actualErrorMessage) {
              buffer.writeln('\nDetails: $errorDetailsStr');
            }
            buffer.writeln('\nPlease check Firebase Console → Functions → generateMetanoiaReflection for more information.');
            errorMessage = buffer.toString();
        }
        
        throw Exception(errorMessage);
      } catch (e, stack) {
        // Catch any other exceptions from Firebase Functions
        Logger.error('Generate Metanoia reflection Firebase Function call failed', e, stack);
        rethrow;
      }
    }
    
    // Fallback to HTTP backend (only if not using Firebase Functions)
    try {
      Logger.info('Using HTTP backend for generateMetanoiaReflection');
      final response = await _dio.post(
        '/metanoia/generate',
        data: {
          'caseNotes': caseNotes,
          if (domain != null) 'domain': domain,
        },
      );
      Logger.info('HTTP backend returned Metanoia reflection');
      return response.data as Map<String, dynamic>;
    } catch (e, stack) {
      Logger.error('Generate Metanoia reflection HTTP backend call failed', e, stack);
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('connection') || errorStr.contains('connection error') || 
          errorStr.contains('connection refused') || errorStr.contains('404')) {
        throw Exception(
          'Backend server is not running or unreachable.\n\n'
          'To fix this, start the backend server:\n'
          'cd backend && npm start'
        );
      }
      
      rethrow;
    }
  }
}






