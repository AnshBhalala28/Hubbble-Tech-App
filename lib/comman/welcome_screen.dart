import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/store_local.dart';

import '../Screen/Authcation/View/loginscreen.dart';
import '../Screen/HomeNewPage/View/homenewpage.dart';
import 'custom_batan.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // TextEditingController _email = TextEditingController();
  // TextEditingController _firstname = TextEditingController();
  // TextEditingController _lastname = TextEditingController();
  // final _formKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    _requestLocationPermission();
    getdata();
    super.initState();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print('Location permission is permanently denied');
      return;
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      print('Location permission granted');
    }
  }

  getdata() async {
    loginModel = await SaveDataLocal.getDataFromLocal();
  }

  route() async {
    await getdata();
    print("Role==>> ${loginModel?.data?.user?.id}");
    print("Role==>> ${loginModel?.data?.token}");

    if (loginModel == null) {
      await Get.offAll(LoginScreen(), transition: Transition.fade);
    } else {
      await Get.offAll(
        HomeNewPage(selected: 1, userName: ""),
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
                        'Wavee.ai',
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
}
