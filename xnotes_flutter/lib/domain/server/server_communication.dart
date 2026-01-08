import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:xnotes_client/xnotes_client.dart';
import 'package:xnotes_flutter/core/config/app_config.dart';
import 'package:xnotes_flutter/core/utils/error_handler/error_handler.dart';

/// Manages server communication initialization and provides a singleton instance of the Serverpod client.
///
/// This class handles:
/// - Client initialization with proper configuration
/// - Environment-based URL management
/// - Connectivity monitoring
/// - Authentication session management
/// - Debug logging of connection status
///
/// Example usage:
/// ```dart
/// // Initialize on app startup
/// final client = await ServerCommunication.initialize();
///
/// // Or use the singleton getter
/// var client = ServerCommunication.instance;
/// ```
class ServerCommunication {
  ServerCommunication._();

  static Client? _instance;
  static const String _tag = 'ServerCommunication';

  /// Returns the singleton instance of the Serverpod client.
  ///
  /// Throws [StateError] if the client hasn't been initialized yet.
  static Client get instance {
    if (_instance == null) {
      throw StateError(
        'ServerCommunication not initialized. '
        'Call ServerCommunication.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initializes the Serverpod client with proper configuration.
  ///
  /// Returns the initialized [Client] instance, which is also stored as a singleton
  /// and can be accessed via the [instance] getter.
  static Future<Client> initialize() async {
    // Return existing instance if already initialized
    if (_instance != null) {
      ErrorHandler.log('Client already initialized', tag: _tag);
      return _instance!;
    }

    return ErrorHandler.handle(
          tag: _tag,
          operationName: 'ServerCommunication initialization',
          operation: () async {
            const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
            final config = AppConfig.instance;
            final serverUrl = serverUrlFromEnv.isEmpty
                ? config.apiUrl ?? 'http://localhost:8083/'
                : serverUrlFromEnv;

            ErrorHandler.log('Connecting to server: $serverUrl', tag: _tag);

            _instance = Client(serverUrl)
              ..connectivityMonitor = FlutterConnectivityMonitor()
              ..authSessionManager = FlutterAuthSessionManager();

            await _instance!.auth.initialize();

            ErrorHandler.log(
              'ServerCommunication initialized successfully',
              tag: _tag,
            );
            return _instance!;
          },
          shouldRethrow: true,
        )
        as Future<Client>;
  }

  /// Resets the singleton instance and clears any session data.
  ///
  /// Use this method for testing or when you need to reinitialize the connection.
  static Future<void> reset() async {
    ErrorHandler.handleAsync(
      tag: _tag,
      operationName: 'ServerCommunication reset',
      operation: () async {
        if (_instance != null) {
          _instance!.close();
        }
        _instance = null;
      },
      shouldRethrow: false,
    );
  }

  /// Checks if the client has been initialized.
  static bool get isInitialized => _instance != null;

  /// Gets the authentication status of the current session.
  ///
  /// Returns false if the client hasn't been initialized yet.
  static bool get isAuthenticated => _instance?.auth.isAuthenticated ?? false;
}
