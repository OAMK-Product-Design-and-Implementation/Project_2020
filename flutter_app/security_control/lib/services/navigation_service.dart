import 'package:flutter/cupertino.dart';

// Implementation from:
// https://medium.com/flutter-community/navigate-without-context-in-flutter-with-a-navigation-service-e6d76e880c1c

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }

  Future<dynamic> navigateToAndReplace(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }
}
