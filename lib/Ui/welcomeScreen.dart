import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../Utils/checkInternetConnection.dart';
import '../Utils/colors.dart';
import '../Utils/const.dart';
import '../Utils/customBatan.dart';
import '../Utils/customSnackBars.dart';
import '../Utils/errorDialog.dart';
import '../Utils/storeUserData.dart';
import 'Authentication/View/loginscreen.dart';
import 'Authentication/provider/authenticationProvider.dart';
import 'HomeScreen/View/homePage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // ✅ NEW: Runs once after a fresh iOS install. Clears Keychain so no auto-login.
  Future<void> _freshInstallGuardIOS() async {
    if (!Platform.isIOS) return;

    final prefs = await SharedPreferences.getInstance();
    const kFreshFlag = 'has_launched_once';
    final hasLaunched = prefs.getBool(kFreshFlag) ?? false;
    if (hasLaunched) return;

    try {
      const storage = FlutterSecureStorage();
      await storage.deleteAll(
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
          // accessGroup: 'YOUR_ACCESS_GROUP_IF_USED',
        ),
      );
    } catch (e) {
      log("Keychain clear error: $e");
    }

    // If you cache auth locally (Hive/SharedPrefs), clear that too.
    try {
      // If your SaveDataLocal has a clear method, call it:
      await SaveDataLocal.clearUserData(); // <-- keep if available; else ignore if not
    } catch (_) {}

    await prefs.setBool(kFreshFlag, true);
    log("🍏 Fresh iOS install detected → Keychain (secure storage) cleared.");
  }

  @override
  void initState() {
    super.initState();
    // ✅ Ensure wipe happens before we read cached login
    _bootstrap();
  }

  // ✅ Keep your order, just make it awaitable so fresh-install wipe completes first
  Future<void> _bootstrap() async {
    await _freshInstallGuardIOS();
    await getdataAndUpdateFCM();
    await _requestLocationPermission();
    await getdata();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {}
  }

  getdata() async {
    loginModel = await SaveDataLocal.getDataFromLocal();
  }

  route() async {
    await getdata();

    if (loginModel == null) {
      await Get.offAll(const LoginScreen(), transition: Transition.fade);
    } else {
      await Get.offAll(
        HomePage(selected: 1, userName: ""),
        transition: Transition.fade,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: Stack(
            children: [
              Container(
                height: 100.h,
                width: 100.w,
                color: Colors.white.withValues(alpha: .2),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 37.h),
                    Center(
                      child: Text(
                        'Wavee Ai',
                        style: TextStyle(
                          letterSpacing: 1,
                          color: AppColors.black,
                          fontSize: 35.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Center(
                      child: Text(
                        'A smarter, more connected, residential future',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 1,
                          color: AppColors.black,
                          fontSize: 19.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppConstants.manropeBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 6.0.h),
                  child: batan(
                    title: "My Account",
                    route: route,
                    radius: 4.0.w,
                    color: AppColors.black,
                    fontcolor: AppColors.white,
                    height: 6.h,
                    width: Get.width * .90,
                    fontsize: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isLoading = false;

  Future<void> getdataAndUpdateFCM() async {
    loginModel = await SaveDataLocal.getDataFromLocal();

    if (loginModel != null) {
      updateFCM1();
    }
  }

  void updateFCM1() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      showSnackBar(
        context: context,
        title: "FCM Error",
        message: "Unable to fetch FCM token",
        backgoundColor: Colors.red,
        ColorText: Colors.white,
      );
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["fcm_token"] = fcmToken;

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AuthProvider().updateFCM(data);
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
