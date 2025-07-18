
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'Screen/Authcation/Model/login_model.dart';
import 'Screen/welcome_screen.dart';
import 'comman/colors.dart';
import 'firebase_options.dart';


String? myDeviceToken;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log("🔧 Handling background message: ${message.messageId}");

  if (message.data['sender_token'] != myDeviceToken) {
    _showAwesomeNotification(message);
  }
}

void _showAwesomeNotification(RemoteMessage message) {
  String? title = message.notification?.title ?? message.data['title'] ?? '';
  String? body = message.notification?.body ?? message.data['body'] ?? '';

  log("🔔 Showing Awesome Notification - Title: $title, Body: $body");

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      channelKey: 'basic_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.Default,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Used for basic notifications',
        defaultColor: AppColors.maincolor,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ],
    debug: true,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: true,
    carPlay: true,
    criticalAlert: true,
    provisional: false,
  );
  log('🔔 Notification permission status: ${settings.authorizationStatus}');
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    log('✅ User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    log('🟡 User granted provisional permission');
  } else {
    log('❌ User declined or has not accepted permission');
  }
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    log('🛑 Awesome Notifications permission not granted. Requesting...');
    AwesomeNotifications().requestPermissionToSendNotifications();
  } else {
    log('✅ Awesome Notifications permission granted');
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final LoginModel? loginModel;

  const MyApp({super.key, this.loginModel});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Get device token
    FirebaseMessaging.instance.getToken().then((token) {
      myDeviceToken = token;
      log("📱 Device Token: $token");
    });

    // Handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📩 Foreground message received: ${message.notification?.title}');
      log('📦 Data: ${message.data}');

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        if (message.data['sender_token'] != myDeviceToken && message.notification == null) {
          _showAwesomeNotification(message);
        }
      } else {
        if (message.data['sender_token'] != myDeviceToken) {
          _showAwesomeNotification(message);
        }
      }
    });

    // Handle background notification click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("🟢 Notification tapped from background: ${message.notification?.title}");
    });
    checkInitialMessage();
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null &&
        initialMessage.data['sender_token'] != myDeviceToken) {
      log("🔵 App opened from terminated via notification: ${initialMessage.notification?.title}");
      _showAwesomeNotification(initialMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wavee Ai',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: WelcomeScreen(),
        );
      },
    );
  }
}
// rm -rf pubspec.lock
// flutter clean
// flutter pub get
// cd ios
// pod deintegrate
// rm -rf podfile.lock
// rm -rf pods
// pod init
// pod setup
// pod install
// pod update
// pod repo update
// cd ..
// flutter run --release