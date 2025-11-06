import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'Screen/Authcation/Model/login_model.dart';
import 'Screen/welcome_screen.dart';
import 'comman/chat.dart';
import 'comman/colors.dart';
import 'firebase_options.dart';

String? myDeviceToken;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("===================================");
  print("✅ BACKGROUND/TERMINATED HANDLER CALLED");
  print("Message ID: ${message.messageId}");
  print("Data Payload: ${message.data}");
  print("Notification Payload: ${message.notification?.title}");
  print("===================================");

  _showAwesomeNotification(message, "Background");
}

void _showAwesomeNotification(RemoteMessage message, String source) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    print("Notification NOT Allowed by user.");
    return;
  }

  String? title = message.notification?.title ?? message.data['title'] ?? '';
  String? body = message.notification?.body ?? message.data['body'] ?? '';

  print("... [$source] Trying to show notification: '$title'");

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
  Get.put(GlobalCountsController());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: true,
    carPlay: true,
    criticalAlert: true,
    provisional: false,
  );
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

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
    setupFirebaseListeners();
  }

  Future<void> setupFirebaseListeners() async {
    myDeviceToken = await FirebaseMessaging.instance.getToken();
    print("===================================");
    print("📱 MY DEVICE TOKEN: $myDeviceToken");
    print("===================================");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("===================================");
      print("✅ FOREGROUND (onMessage) HANDLER CALLED");
      print("Data Payload: ${message.data}");
      print("Notification Payload: ${message.notification?.title}");

      print(
        "Checking: message.data['sender_token'] (${message.data['sender_token']}) != myDeviceToken ($myDeviceToken)",
      );
      print("🔥🔥🔥🔥");

      print("... Condition is TRUE (or commented). Showing notification.");
      _showAwesomeNotification(message, "Foreground");
      print("===================================");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("===================================");
      print("✅ APP OPENED FROM BACKGROUND (onMessageOpenedApp)");
      print("User clicked notification: ${message.messageId}");
      print("Data Payload: ${message.data}");
      print("===================================");
    });

    checkInitialMessage();
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print("===================================");
      print("✅ APP OPENED FROM TERMINATED (getInitialMessage)");
      print("Data Payload: ${initialMessage.data}");

      if (initialMessage.data['sender_token'] != myDeviceToken) {
        print("... Showing initial notification (from terminated).");
      } else {
        print("... Ignoring initial notification (sender is self).");
      }
      print("===================================");
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
