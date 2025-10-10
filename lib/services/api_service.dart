import 'package:dio/dio.dart';
import '../core/http_client.dart';
import '../core/logger.dart';

/// API service for backend communication
class ApiService {
  final Dio _dio = HttpClient.instance;
  
  /// Self-play reflection improvement
  /// POST /api/reflection/selfplay
  Future<Map<String, dynamic>> runSelfPlay({
    required String year,
    required String title,
    required String context,
    int iterations = 3,
  }) async {
    try {
      final response = await _dio.post(
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
      Logger.error('Self-play API call failed', e, stack);
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
      final response = await _dio.post(
        '/reflection/reinforce',
        data: {
          'year': year,
          'rid': rid,
          'rating': rating,
        },
      );
      return response.data as Map<String, dynamic>;
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
}


