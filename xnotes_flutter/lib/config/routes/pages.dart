import 'package:flutter/material.dart';
import 'package:xnotes_flutter/config/routes/routes.dart';

class Pages {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.auth:
        return MaterialPageRoute(builder: (context) => const SizedBox());
      // case Routes.register : return MaterialPageRoute(builder: (context)=> RegisterScreen());
      case Routes.home:
        return MaterialPageRoute(builder: (context) => SizedBox());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return const Scaffold(
          body: Center(
            child: Text('Error Route'),
          ),
        );
      },
    );
  }
}
