import 'package:flutter/material.dart'
    hide
        Router; //Need to hide Router to avoid conflict with our generated router...
import 'package:security_control/router.gr.dart';
import 'package:security_control/services/navigation_service.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:security_control/theme.dart';

// No UI building will be done here
// Only set the routes, navigation, themes etc.

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // Needed to avoid error with servicesbinding...
  await setupUrgentServices(); // Setup services needed immediately at login
  setupLocator(); // Setup non-critical services asynchronously
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      iconColor: Colors.grey,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: getAppTheme(context, false),
        darkTheme: getAppTheme(context, true),
        navigatorKey: locator<NavigationService>().navigatorKey,
        initialRoute: Routes.loginPage,
        onGenerateRoute: Router().onGenerateRoute,
      ),
    );
  }
}
