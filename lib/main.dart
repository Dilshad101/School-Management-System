import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'core/router/app_router.dart';
import 'core/utils/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await setupDependency();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TaxHi',
      debugShowCheckedModeBanner: false,
      // theme: lightTheme,
      builder: (context, child) {
        final toastBuilder = FToastBuilder();
        final built = toastBuilder(context, child);

        // LOCK text size for the whole app (set to 1.0)
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: built,
        );
      },
      routerConfig: locator<NavigationService>().router,
    );
  }
}
