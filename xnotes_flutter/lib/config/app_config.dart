import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:xnotes_flutter/utils/error_handler/error_handler.dart';

/// Singleton configuration manager for the app
class AppConfig {
  AppConfig._({
    required this.apiUrl,
  });

  static AppConfig? _instance;
  static const String _tag = 'AppConfig';

  final String? apiUrl;

  /// Returns the singleton instance of AppConfig
  ///
  /// Throws [StateError] if not initialized. Call [initialize()] first.
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppConfig not initialized. Call AppConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initializes AppConfig singleton
  ///
  /// This is called automatically during app initialization.
  /// Returns the instance for convenience.
  static Future<AppConfig> initialize() async {
    if (_instance != null) {
      ErrorHandler.log('AppConfig already initialized', tag: _tag);
      return _instance!;
    }

    return ErrorHandler.handle(
          tag: _tag,
          operationName: 'AppConfig initialization',
          operation: () async {
            final config = await _loadJsonConfig();
            final String? apiUrl = config['apiUrl'];
            _instance = AppConfig._(apiUrl: apiUrl);
            ErrorHandler.log(
              'AppConfig initialized with apiUrl: $apiUrl',
              tag: _tag,
            );
            return _instance!;
          },
          shouldRethrow: true,
        )
        as Future<AppConfig>;
  }

  /// Checks if AppConfig has been initialized
  static bool get isInitialized => _instance != null;

  /// Resets the singleton instance
  static void reset() {
    _instance = null;
    ErrorHandler.log('AppConfig reset', tag: _tag);
  }

  /// Loads configuration from assets/config.json
  static Future<Map<String, dynamic>> _loadJsonConfig() async =>
      await ErrorHandler.handle(
        tag: _tag,
        operationName: 'Load config.json',
        operation: () async {
          final data = await rootBundle.loadString('assets/config.json');
          return jsonDecode(data) as Map<String, dynamic>;
        },
        onError: (error, stackTrace) {
          // Fallback on error
        },
        shouldRethrow: false,
      ) ??
      {'apiUrl': 'http://localhost:8083/'};

  @override
  String toString() => 'AppConfig(apiUrl: $apiUrl)';
}
