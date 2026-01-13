import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/appTheme.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Ui/InitScreens/view/welcomeScreen.dart';

import 'Ui/Authentication/modal/login_model.dart';
import 'Utils/chatCounter.dart';
import 'Utils/colors.dart';
import 'Utils/storeUserData.dart';
import 'firebase_options.dart';

String? myDeviceToken;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.notification == null) {
    _showAwesomeNotification(message, "Background (Data Only)");
  } else {
    log(
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
    log("Keychain clear error: $e");
  }

  await AwesomeNotifications().resetGlobalBadge();
  await prefs.setBool(flag, true);
}

void _showAwesomeNotification(RemoteMessage message, String source) async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
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
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _showAwesomeNotification(message, "Foreground");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

    checkInitialMessage();
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return Sizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wavee Ai',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
