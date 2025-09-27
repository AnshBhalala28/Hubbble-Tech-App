import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/check_inernet_connecty.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/custom_snack_bar.dart';
import 'package:wavee/comman/error_dialog.dart';
import 'package:wavee/comman/store_local.dart';

import '../comman/custom_batan.dart';
import 'Authcation/Provider/authcation_provider.dart';
import 'Authcation/View/loginscreen.dart';
import 'homePage/View/homenewpage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    getdataAndUpdateFCM();
    _requestLocationPermission();
    getdata();
    super.initState();
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
                color: Colors.white.withOpacity(.2),
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
                          fontFamily: AppConstants.manrope,
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
        title: "FCM Error",
        message: "Unable to fetch FCM token",
        backgoundColor: Colors.red,
        ColorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["fcm_token"] = fcmToken;
    log("datadatadata$data");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AuthProvider().updateFCM(data);
          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
