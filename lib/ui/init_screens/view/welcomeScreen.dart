import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/ui/init_screens/view/onboardScreens.dart';
import 'package:wavee/utils/checkInternetConnection.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customBatan.dart';
import 'package:wavee/utils/storeUserData.dart';

import '../../authentication/provider/authenticationProvider.dart';
import '../../home_screen/view/homePage.dart';

const Color kGlowColor = Color(0x627C5836);
const Color kParticleColor = Color(0xFFE8D4A2);
const Color kBackgroundColor = Color(0xFF0A0A0A);

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _entranceController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _entranceFade;
  late Animation<double> _entranceScale;

  // State for loading
  bool _isLoading = false;

  // Particles
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _bootstrapApp();
  }

  void _initAnimations() {
    // 1. Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // 2. Particle System setup
    for (int i = 0; i < 25; i++) {
      _particles.add(_createParticle());
    }

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // 3. Entrance Animation
    _entranceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _entranceScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // --- INITIALIZATION LOGIC ---

  Future<void> _bootstrapApp() async {
    await _freshInstallGuardIOS();
    await _requestLocationPermission();
    await _refreshUserDataAndFCM();
  }

  Future<void> _freshInstallGuardIOS() async {
    if (!Platform.isIOS) return;

    final prefs = await SharedPreferences.getInstance();
    const kFreshFlag = 'has_launched_once';

    if (prefs.containsKey(kFreshFlag)) return;

    try {
      const storage = FlutterSecureStorage();
      await storage.deleteAll(
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );
      await SaveDataLocal.clearUserData();
      log("🍏 Fresh iOS install detected: Keychain cleared.");
    } catch (e) {
      log("Error clearing iOS keychain: $e");
    } finally {
      await prefs.setBool(kFreshFlag, true);
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      log("Location Permission Status: $permission");
    } catch (e) {
      log("Location permission error: $e");
    }
  }

  Future<void> _refreshUserDataAndFCM() async {
    loginModel = await SaveDataLocal.getDataFromLocal();
    if (loginModel != null && mounted) {
      await _updateFCM();
    }
  }

  Future<void> _updateFCM() async {
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      log("No internet - Skipping FCM update");
      return;
    }

    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        log("FCM Token is null");
        return;
      }

      final Map<String, String> data = {
        "user_id": loginModel?.data?.user?.id.toString() ?? "",
        "fcm_token": fcmToken,
      };

      await AuthProvider().updateFCM(data);
      log("FCM Token Updated Successfully");
    } catch (e) {
      log("Error updating FCM: $e");
    }
  }

  // --- NAVIGATION LOGIC ---

  Future<void> _handleEnterApp() async {
    // 1. Set Loading State
    setState(() {
      _isLoading = true;
    });

    // 2. Ensure we have the latest data before deciding route
    await _refreshUserDataAndFCM();

    // Artificial delay if needed to show the text, remove if not needed
    // await Future.delayed(Duration(seconds: 1));

    if (!mounted) return;

    if (loginModel == null) {
      Get.offAll(() => const OnboardingScreens(), transition: Transition.fade);
      if (mounted) {
        await handleDataClear(context);
      }
    } else {
      Get.offAll(
        () => HomePage(selected: 1, userName: ""),
        transition: Transition.fade,
      );
    }
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // LAYER 1: Background Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    random: _random,
                    animationValue: _particleController.value,
                  ),
                );
              },
            ),
          ),

          // LAYER 2: Logo + Glow
          Center(
            child: FadeTransition(
              opacity: _entranceFade,
              child: ScaleTransition(
                scale: _entranceScale,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return _buildLogoWithGlow();
                  },
                ),
              ),
            ),
          ),

          // LAYER 3: Custom Button OR Loader
          Positioned(
            bottom: 6.h,
            left: 5.w,
            right: 5.w,
            child: FadeTransition(
              opacity: _entranceFade,
              child:
                  _isLoading
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 22.sp,
                            width: 22.sp,
                            child: const CircularProgressIndicator(
                              color: kParticleColor,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          Text(
                            "Setting things up...",
                            style: TextStyle(
                              color: kParticleColor,
                              fontSize: 16.sp,
                              fontFamily: AppConstants.manrope,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                      : batan(
                        title: 'Enter Account',
                        route: _handleEnterApp,
                        color: kParticleColor,
                        fontcolor: AppColors.blackColor,
                        height: 6.h,
                        width: 80.w,
                        fontsize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                        iconData: Icons.login_rounded,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoWithGlow() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow Effect
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: kGlowColor.withOpacity(0.5),
                blurRadius: 90 + (_pulseAnimation.value * 10),
                spreadRadius: 2 + (_pulseAnimation.value * 5),
              ),
              BoxShadow(
                color: kGlowColor.withOpacity(0.15),
                blurRadius: 60 + (_pulseAnimation.value * 150),
                spreadRadius: 80 + (_pulseAnimation.value * 20),
              ),
            ],
          ),
        ),
        // Logo Image
        SizedBox(
          width: 40.w,
          height: 10.h,
          child: Image.asset(
            'assets/initLogo.png',
            fit: BoxFit.contain,
            errorBuilder:
                (c, o, s) =>
                    const Icon(Icons.waves, color: kGlowColor, size: 50),
          ),
        ),
      ],
    );
  }

  // --- PARTICLE SYSTEM ---

  Particle _createParticle() {
    return Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 2.0 + 0.5,
      speed: _random.nextDouble() * 0.002 + 0.001,
      opacity: _random.nextDouble() * 0.5 + 0.2,
    );
  }
}

// --- PARTICLE HELPERS ---

class Particle {
  double x, y, size, speed, opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Random random;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.random,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      particle.y -= particle.speed;

      if (particle.y < -0.1) {
        particle.y = 1.1;
        particle.x = random.nextDouble();
      }

      paint.color = kParticleColor.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true;
  }
}
