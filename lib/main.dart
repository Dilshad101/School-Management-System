import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:school_management_system/core/theme/light_theme.dart';
import 'package:school_management_system/core/utils/notification_service.dart';
import 'package:school_management_system/core/utils/providers.dart';
import 'package:school_management_system/firebase_options.dart';

import 'core/router/app_router.dart';
import 'core/utils/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service and request permissions
  final notificationService = NotificationService();
  await notificationService.initialize();

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
    return MultiBlocProvider(
      providers: providers,
      child: MaterialApp.router(
        title: 'Waad',
        debugShowCheckedModeBanner: false,
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
        theme: lightTheme,
        routerConfig: locator<NavigationService>().router,
      ),
    );
  }
}
