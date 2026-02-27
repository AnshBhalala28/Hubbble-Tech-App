import 'dart:developer';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/appTheme.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/ui/init_screens/view/welcomeScreen.dart';
import 'firebase_options.dart';
import 'ui/authentication/modal/login_model.dart';
import 'utils/chatCounter.dart';
import 'utils/colors.dart';
import 'utils/storeUserData.dart';

void main() async {
  // 1. Ensure the Flutter engine is fully initialized
  WidgetsFlutterBinding.ensureInitialized();

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
  bool _initialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step A: Firebase with 10s timeout
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10));

      // Step B: Guarded .env loading
      try {
        await dotenv.load(fileName: ".env");
      } catch (e) {
        log("Environment load warning: $e");
      }

      await _handleFreshInstallIOS();
      Get.put(GlobalCountsController());

      // Step C: Notifications with 5s timeout
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic Notifications',
            channelDescription: 'Used for basic notifications',
            defaultColor: AppColors.maincolor,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
          ),
        ],
        debug: true,
      ).timeout(const Duration(seconds: 5));

      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      log("Initialization Error/Timeout: $e");
      if (mounted) {
        setState(() => _initError = "Startup took too long or failed: $e");
      }
    }
  }

  Future<void> _handleFreshInstallIOS() async {
    if (!Platform.isIOS) return;
    final prefs = await SharedPreferences.getInstance();

    // Check if this is the first time the app is launched
    if (prefs.getBool('has_launched_once') ?? false) return;

    try {
      const storage = FlutterSecureStorage();
      await SaveDataLocal.clearUserData();
      await storage.deleteAll(
        iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );
      await AwesomeNotifications().resetGlobalBadge();
      await prefs.setBool('has_launched_once', true);
      log("✅ Fresh install cleanup completed for iOS");
    } catch (e) {
      log("⚠️ Keychain/Secure Storage error: $e");
    }
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
          // Diagnostic Routing Logic:
          home: _initError != null
              ? _ErrorUI(error: _initError!) // Display startup error
              : (!_initialized
              ? const _LoadingUI() // Display spinner during init
              : const WelcomeScreen()), // Display main app
        );
      },
    );
  }
}

class _LoadingUI extends StatelessWidget {
  const _LoadingUI();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorUI extends StatelessWidget {
  final String error;
  const _ErrorUI({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                "App Startup Error",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // This is a simple way to trigger a "retry" by rebuilding the state
                  // In a real app, you might use an 'AppReset' controller
                },
                child: const Text("Try Again"),
              )
            ],
          ),
        ),
      ),
    );
  }
}