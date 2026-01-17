import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'src/config/firebase_options.dart';
import 'src/app.dart';
import 'src/providers/auth/auth_provider.dart';
import 'src/services/notification_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService.showNotification(message);
}

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  await NotificationService.initialize();

  // Create provider container
  final container = ProviderContainer();

  // Check and restore auth status before running app
  await container.read(authProvider.notifier).checkAuthStatus();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: PremisaveApp(scaffoldMessengerKey: scaffoldMessengerKey),
    ),
  );
}