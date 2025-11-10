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
  print("===================================");

  // આખું મેસેજ પ્રિન્ટ કરીએ
  print("FULL MESSAGE DATA: ${message.toMap().toString()}");

  print("--- DATA PAYLOAD ---");
  print(message.data);

  print("--- NOTIFICATION PAYLOAD ---");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("===================================");

  // **** આ છે ડબલ નોટિફિકેશન રોકવાનો લોજિક ****
  if (message.notification == null) {
    print(">>> 'notification' કી નથી (null છે).");
    print(">>> તેથી, _showAwesomeNotification ને કોલ કરું છું...");
    _showAwesomeNotification(message, "Background (Data-Only)");
  } else {
    print(">>> 'notification' કી હાજર છે.");
    print(">>> Firebase પોતે જ નોટિફિકેશન બતાવશે. હું કાંઈ નહીં કરુ");
  }

  print("✅ BACKGROUND HANDLER FINISHED");
  print("===================================");
}

void _showAwesomeNotification(RemoteMessage message, String source) async {
  print("--- _showAwesomeNotification (Source: $source) ---");

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    print(">>> Notification NOT Allowed by user. Exiting function.");
    return;
  }

  String? title = message.notification?.title ?? message.data['title'] ?? '';
  String? body = message.notification?.body ?? message.data['body'] ?? '';

  print(">>> Creating AwesomeNotification:");
  print(">>> Title: $title");
  print(">>> Body: $body");

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      channelKey: 'basic_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.Default,
    ),
  );
  print("--- _showAwesomeNotification FINISHED ---");
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
      print("FULL MESSAGE DATA: ${message.toMap().toString()}");
      print("===================================");

      _showAwesomeNotification(message, "Foreground");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("===================================");
      print("✅ APP OPENED FROM BACKGROUND (onMessageOpenedApp)");
      print("FULL MESSAGE DATA: ${message.toMap().toString()}");
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
      print("FULL MESSAGE DATA: ${initialMessage.toMap().toString()}");
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