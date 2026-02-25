import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize notification service and request permissions
  Future<void> initialize() async {
    // Request permission for iOS and Android 13+
    await requestPermission();

    // Configure foreground notification presentation options (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token (with delay for iOS APNs token)
    await getToken();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background but opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Request notification permissions for iOS and Android 13+
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final isAuthorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint(
      'Notification permission status: ${settings.authorizationStatus}',
    );

    return isAuthorized;
  }

  /// Get FCM token for this device
  Future<String?> getToken() async {
    String? token;

    try {
      if (kIsWeb) {
        // For web, you need to pass your VAPID key
        token = await _messaging.getToken(
          vapidKey:
              'BP5Tszyqtm5LIduinDsX1ofZLH0H5rOQLCEl6zr0CTwe0geHul7kKcCqChK6ustNmxgMZK4GLzK7m7LMflrhSzw',
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // On iOS, wait for APNs token first
        String? apnsToken = await _messaging.getAPNSToken();

        // If APNs token not available yet, wait and retry
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _messaging.getAPNSToken();
        }

        if (apnsToken != null) {
          token = await _messaging.getToken();
        } else {
          debugPrint(
            'APNs token not available. FCM token will be fetched later.',
          );
          // Set up listener for when token becomes available
          _messaging.onTokenRefresh.listen((newToken) {
            debugPrint('FCM Token received: $newToken');
            // TODO: Send token to your backend
          });
          return null;
        }
      } else {
        // Android
        token = await _messaging.getToken();
      }

      debugPrint('FCM Token: $token');

      // TODO: Send this token to your backend server to send push notifications
      // await _sendTokenToServer(token);

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        // TODO: Update token on your backend server
        // _sendTokenToServer(newToken);
      });
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }

    return token;
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // TODO: Show a local notification or in-app notification
    // You can use flutter_local_notifications package for this
  }

  /// Handle notification tap (when app is opened from notification)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    debugPrint('Data: ${message.data}');

    // TODO: Navigate to specific screen based on notification data
    // Example:
    // if (message.data['type'] == 'chat') {
    //   navigateToChat(message.data['chatId']);
    // }
  }

  /// Subscribe to a topic for group notifications
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}
