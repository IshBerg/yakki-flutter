/// API Service - Communication with yakki-intel server
///
/// Uses Flutter-specific endpoints to avoid interference with Android client.
/// Main endpoint: POST /api/v1/flutter/dispatch

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Server URL - change for production
  static const String _baseUrl = 'http://localhost:8080';
  static const String _flutterEndpoint = '/api/v1/flutter/dispatch';
  static const String _healthEndpoint = '/api/v1/flutter/health';

  /// Check server health
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_healthEndpoint'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Main dispatch method - routes all actions through Flutter endpoint
  static Future<ApiResponse> dispatch(String action, Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_flutterEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': action,
          'payload': payload,
          'client_version': '1.0.0',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: data['success'] ?? false,
          data: data['data'],
          error: data['error'],
        );
      } else {
        return ApiResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Network error: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLOZE DRILLS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate cloze questions
  static Future<ApiResponse> generateClozeQuestions({
    required String library,
    required String level,
    int count = 5,
  }) async {
    return dispatch('cloze.generate', {
      'library': library,
      'level': level,
      'count': count,
    });
  }

  /// Validate cloze answer
  static Future<ApiResponse> validateClozeAnswer({
    required String answer,
    required String correct,
  }) async {
    return dispatch('cloze.validate', {
      'answer': answer,
      'correct': correct,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SNIPER MODE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get L1 interference patterns
  static Future<ApiResponse> getSniperPatterns({
    required String l1Source,
    int count = 5,
  }) async {
    return dispatch('sniper.get_patterns', {
      'l1_source': l1Source,
      'count': count,
    });
  }

  /// Validate sniper answer
  static Future<ApiResponse> validateSniperAnswer({
    required bool userChoice,
    required bool actualIsError,
  }) async {
    return dispatch('sniper.validate', {
      'is_error': userChoice,
      'actual_is_error': actualIsError,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCRAMBLER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate scrambler exercise
  static Future<ApiResponse> generateScramblerExercise({
    required String level,
    required String tense,
  }) async {
    return dispatch('scrambler.generate', {
      'level': level,
      'tense': tense,
    });
  }

  /// Validate scrambler answer
  static Future<ApiResponse> validateScramblerAnswer({
    required String userSentence,
    required String original,
  }) async {
    return dispatch('scrambler.validate', {
      'user_sentence': userSentence,
      'original': original,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTEL READER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generate reading mission
  static Future<ApiResponse> generateIntelMission({
    required String level,
    required String topic,
  }) async {
    return dispatch('intel.generate_mission', {
      'level': level,
      'topic': topic,
    });
  }

  /// Validate reading answer
  static Future<ApiResponse> validateIntelAnswer({
    required int answerIndex,
    required int correctIndex,
  }) async {
    return dispatch('intel.validate_answer', {
      'answer_index': answerIndex,
      'correct_index': correctIndex,
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // USER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sync user data
  static Future<ApiResponse> syncUser(String userId) async {
    return dispatch('user.sync', {
      'user_id': userId,
    });
  }

  /// Update user progress
  static Future<ApiResponse> updateProgress({
    required String userId,
    required int xpEarned,
  }) async {
    return dispatch('user.progress', {
      'user_id': userId,
      'xp_earned': xpEarned,
    });
  }
}

/// API Response wrapper
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, data: $data, error: $error)';
  }
}
