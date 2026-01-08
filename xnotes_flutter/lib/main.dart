import 'package:flutter/material.dart';
import 'package:xnotes_flutter/core/config/app_config.dart';
import 'package:xnotes_flutter/domain/server/server_communication.dart';
import 'package:xnotes_flutter/core/utils/error_handler/error_handler.dart';

/// Initialize all app dependencies
Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ErrorHandler.handleWithTimeout<void>(
    tag: 'main',
    operationName: 'App initialization',
    timeout: const Duration(seconds: 30),
    operation: () => ErrorHandler.handle(
      tag: 'main',
      operationName: 'Parallel initialization',
      operation: () => Future.wait([
        AppConfig.initialize(),              // Initialize first (no dependencies)
        ServerCommunication.initialize(),    // Then server (depends on AppConfig)
      ]),
      shouldRethrow: true,
    ),
  );
}

void main() async {
  await ErrorHandler.handle<void>(
    tag: 'main',
    operationName: 'App initialization and startup',
    operation: () async {
      await _initializeApp();

      runApp(const MyApp());

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ErrorHandler.log('App rendered successfully', tag: 'main');
      });
    },
    onError: (error, stackTrace) {
      final errorCategory = (error as dynamic).category ?? 'unknown';
      final isRetryable = (error as dynamic).isRetryable ?? true;
      
      ErrorHandler.log(
        'Fatal error - app cannot start',
        tag: 'main',
        error: error,
        stackTrace: stackTrace,
      );
      
      ErrorHandler.log(
        'Error details: category=$errorCategory, retryable=$isRetryable',
        tag: 'main',
      );
      
      runApp(const _ErrorApp());
    },
    shouldRethrow: false,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XNotes',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const _HomeScreen(),
    );
  }

  /// Build theme with Material 3 support
  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
        foregroundColor: isDark ? Colors.white : Colors.white,
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ServerCommunication.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('XNotes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to XNotes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isAuthenticated ? '✓ Connected' : '○ Connecting...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isAuthenticated ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback UI when app fails to initialize
class _ErrorApp extends StatelessWidget {
  const _ErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red[100],
                ),
                padding: const EdgeInsets.all(24),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[800],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Initialization Failed',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Unable to connect to server. Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ErrorHandler.log(
                    'Retry initialization requested',
                    tag: 'main',
                  );
                  // TODO: Implement retry: Navigator pop or restart app
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
