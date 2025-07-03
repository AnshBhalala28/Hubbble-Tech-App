import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Authcation/View/loginscreen.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/store_local.dart';

import '../comman/custom_batan.dart';
import 'HomeNewPage/View/homenewpage.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  bool _isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
    getdata();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isPermissionGranted = false;
      _showPermissionDialog(
        context,
        title: 'Location Disabled',
        message: 'To provide full functionality and show nearby building services, Wavee AI requires access to your location. You can enable location in Settings.',
        openSettings: true,
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // ✅ If already granted
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      if (!_isPermissionGranted) {
        setState(() {
          _isPermissionGranted = true;
        });
      }

      // ✅ Close dialog if open
      if (_isDialogVisible && Navigator.canPop(context)) {
        Navigator.of(context).pop();
        _isDialogVisible = false;
      }

      print('Location permission granted');
      return;
    }

    // ✅ Request permission only if not already granted
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        setState(() {
          _isPermissionGranted = true;
        });

        if (_isDialogVisible && Navigator.canPop(context)) {
          Navigator.of(context).pop();
          _isDialogVisible = false;
        }

        print('Location permission granted after request');
        return;
      }
    }

    // ❌ Denied forever
    if (permission == LocationPermission.deniedForever) {
      _isPermissionGranted = false;
      _showPermissionDialog(
        context,
        title: 'Permission Permanently Denied',
        message: 'To provide full functionality and show nearby building services, Wavee AI requires access to your location. You can enable location in Settings.',
        openSettings: true,
      );
      return;
    }

    // ❌ Still denied
    _isPermissionGranted = false;
    _showPermissionDialog(
      context,
      title: 'Permission Required',
      message: 'To provide full functionality and show nearby building services, Wavee AI requires access to your location. You can enable location in Settings.',
      openSettings: true,
    );
  }

  void _showPermissionDialog(BuildContext context,
      {required String title,
        required String message,
        bool openSettings = false}) {
    if (_isDialogVisible) return;

    _isDialogVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontFamily: AppConstants.manrope,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: AppConstants.manrope,
              fontSize: 16.sp,
            ),
          ),
          actions: [
            if (openSettings)
              batan(
                title: "Open Setting",
                route: () async {
                  Navigator.of(context).pop();
                  _isDialogVisible = false;
                  await Geolocator.openAppSettings();
                },
                color: AppColors.maincolor,
                fontcolor: AppColors.white,
                height: 5.h,
                width: double.infinity,
                fontsize: 18.sp,
                radius: 12.0,
              ),
          ],
        );
      },
    ).then((_) {
      _isDialogVisible = false;
    });
  }

  getdata() async {
    loginModel = await SaveDataLocal.getDataFromLocal();
  }

  route() async {
    await getdata();
    print("User ID: ${loginModel?.data?.user?.id}");
    print("Token: ${loginModel?.data?.token}");

    if (loginModel == null) {
      await Get.offAll(LoginScreen(), transition: Transition.fade);
    } else {
      await Get.offAll(
        HomePage(
          selected: 1,
          userName: "",
        ),
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
                    route: _isPermissionGranted
                        ? route
                        : () {
                      _showPermissionDialog(
                        context,
                        title: 'Permission Required',
                        message:
                        'Location permission is required to access your account. Please enable it from settings.',
                        openSettings: true,
                      );
                    },
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
}
