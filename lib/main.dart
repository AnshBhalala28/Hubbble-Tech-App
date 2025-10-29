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

  if (message.data['sender_token'] != myDeviceToken) {
    _showAwesomeNotification(message);
  }
}

void _showAwesomeNotification(RemoteMessage message) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    return;
  }

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
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic Notifications',
      channelDescription: 'Used for basic notifications',
      defaultColor: AppColors.maincolor,
      ledColor: Colors.white,
      importance: NotificationImportance.High,
      channelShowBadge: true,

    ),
  ], debug: true);
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

  switch (settings.authorizationStatus) {
    case AuthorizationStatus.authorized:
      break;
    case AuthorizationStatus.provisional:
      break;
    case AuthorizationStatus.denied:
    case AuthorizationStatus.notDetermined:
      break;
  }
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
  } else {}
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data['sender_token'] != myDeviceToken) {
        _showAwesomeNotification(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    checkInitialMessage();
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null &&
        initialMessage.data['sender_token'] != myDeviceToken) {
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
            // scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

            useMaterial3: true,
          ),
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
