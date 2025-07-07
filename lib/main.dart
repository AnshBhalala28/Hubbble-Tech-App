
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Authcation/Provider/authcation_provider.dart';

import 'package:wavee/Screen/Community Screen/Community Screen/Provider/community_provider.dart';
import 'package:wavee/Screen/Message_board/Provider/messsage_board_provider.dart';
import 'package:wavee/Screen/NotiFicationPage/Provider/notificationprovider.dart';
import 'package:wavee/Screen/Parcel/Provider/parcel_provider.dart';

import 'Screen/Authcation/Model/login_model.dart';
import 'Screen/HomeNewPage/Provider/homescreen_provider.dart';
import 'Screen/ViewProfile/Provider/profile_provider.dart';
import 'Screen/welcome_screen.dart';
import 'comman/colors.dart';
import 'comman/store_local.dart';
import 'firebase_options.dart';
// import 'firebase_options.dart';
String? myDeviceToken;

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['sender_token'] != myDeviceToken) {
    _showAwesomeNotification(message);
  }
}

// Show notification manually
void _showAwesomeNotification(RemoteMessage message) {
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

  // prefs = await SharedPreferences.getInstance();

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

  // Request notification permission
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('🔔 Notification permission granted');
  } else {
    print('❌ Notification permission denied');
  }

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   // Request permission for iOS
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//
//   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//     print('User granted permission');
//   } else {
//     print('User declined or has not accepted permission');
//   }
//
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   LoginModel? loginModel = await SaveDataLocal.getDataFromLocal();
//   // await LocationService().requestLocationPermission();
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => ParcelProvider()),
//         ChangeNotifierProvider(create: (_) => CommunityProvider()),
//         ChangeNotifierProvider(create: (_) => ProfileProvider()),
//         ChangeNotifierProvider(create: (_) => HomeProvider()),
//         ChangeNotifierProvider(create: (_) => NotificationProvider()),
//         ChangeNotifierProvider(create: (_) => MessageBoardProvider()),
//       ],
//       child: MyApp(loginModel: loginModel),
//     ),
//   );
// }

class MyApp extends StatefulWidget {
  final LoginModel? loginModel;

  const MyApp({super.key, this.loginModel});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();

    // Get Device Token
    FirebaseMessaging.instance.getToken().then((token) {
      myDeviceToken = token;
      print("📱 Device Token: $token");
    });

    // Foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Avoid duplicate notification on iOS when system displays it
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

    // Background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🟢 Notification tapped in background: ${message.notification?.title}");
    });

    // Terminated state notification
    checkInitialMessage();
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null &&
        initialMessage.data['sender_token'] != myDeviceToken) {
      print("🔵 App opened from terminated state via notification: ${initialMessage.notification?.title}");
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


