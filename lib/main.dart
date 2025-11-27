import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'Ui/Authentication/modal/login_model.dart';
import 'Ui/welcomeScreen.dart';
import 'Utils/chatCounter.dart';
import 'Utils/colors.dart';
import 'Utils/storeUserData.dart';
import 'firebase_options.dart';

String? myDeviceToken;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("===================================");
  print("✅ BACKGROUND/TERMINATED HANDLER CALLED");
  print("===================================");

  print("FULL MESSAGE DATA: ${message.toMap().toString()}");
  print(message.data);

  if (message.notification == null) {
    _showAwesomeNotification(message, "Background (Data Only)");
  } else {
    print(
      "Firebase will show notification automatically (notification payload present)",
    );
  }
}

/// Runs only once after fresh iOS reinstall
Future<void> _handleFreshInstallIOS() async {
  if (!Platform.isIOS) return;

  final prefs = await SharedPreferences.getInstance();
  const flag = 'has_launched_once';

  final hasLaunchedBefore = prefs.getBool(flag) ?? false;
  if (hasLaunchedBefore) return;

  try {
    const storage = FlutterSecureStorage();
    await SaveDataLocal.clearUserData();
    await storage.deleteAll(
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  } catch (e) {
    print("Keychain clear error: $e");
  }

  await AwesomeNotifications().resetGlobalBadge();
  await prefs.setBool(flag, true);
}

void _showAwesomeNotification(RemoteMessage message, String source) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    print("Notifications not allowed by user.");
    return;
  }

  String? title = message.notification?.title ?? message.data['title'] ?? '';
  String? body = message.notification?.body ?? message.data['body'] ?? '';

  // Note: removed invalid 'playSound' parameter from NotificationContent
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      channelKey: 'basic_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.Default,
      autoDismissible: true,
      wakeUpScreen: true,
      category: NotificationCategory.Message,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _handleFreshInstallIOS();
  Get.put(GlobalCountsController());

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Awesome Notifications - no 'playSound' used here.
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic Notifications',
      channelDescription: 'Used for basic notifications',
      defaultColor: AppColors.maincolor,
      ledColor: Colors.white,
      importance: NotificationImportance.Max,
      // highest importance
      channelShowBadge: true,
      enableLights: true,
      enableVibration: true,
      vibrationPattern: lowVibrationPattern,
      // soundSource: null, // leave soundSource unset so system default is used
    ),
  ], debug: true);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
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
    if (Platform.isAndroid) setupFirebaseListeners();
  }

  Future<void> setupFirebaseListeners() async {
    myDeviceToken = await FirebaseMessaging.instance.getToken();
    print("📱 Device Token: $myDeviceToken");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("🔥 Foreground notification received: ${message.toMap()}");
      _showAwesomeNotification(message, "Foreground");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📂 App opened from notification: ${message.toMap()}");
    });

    checkInitialMessage();
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print("📂 App opened from terminated state: ${initialMessage.toMap()}");
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
