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

/// Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Background ma notification show karvi
  if (message.data['sender_token'] != myDeviceToken) {
    _showAwesomeNotification(message);
  }
}

/// Show notification if allowed
void _showAwesomeNotification(RemoteMessage message) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) return;

  String? title = message.notification?.title ?? message.data['title'] ?? '';
  String? body = message.notification?.body ?? message.data['body'] ?? '';

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

  // Initialize Awesome Notifications
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

  // Request notification permission
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
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

    FirebaseMessaging.instance.getToken().then((token) {
      myDeviceToken = token;
    });

    /// Foreground ma notification **show nathi karvi**
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("Foreground message received: ${message.data}");
      // 🔴 NO _showAwesomeNotification() here
      // If you want, show a custom snackbar / dialog instead
    });

    /// Background / terminated ma notification tap thi app open thay
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Message opened app: ${message.data}");
    });

    checkInitialMessage();
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null &&
        initialMessage.data['sender_token'] != myDeviceToken) {
      // Terminated state ma notification show karvi
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
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
