import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init(String? userToken) async {
    // Request permission (important for iOS/Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');
    
    if (token != null && userToken != null) {
       // We'll update the token later via provider if needed
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        NotificationService().showNotification(
          title: message.notification!.title ?? 'Notification',
          body: message.notification!.body ?? '',
        );
      }
    });

    // Handle background messages handled by system automatically
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
