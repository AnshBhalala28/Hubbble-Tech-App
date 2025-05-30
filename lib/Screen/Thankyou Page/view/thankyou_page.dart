import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/custom_batan.dart';

import '../../../comman/colors.dart';

class ThankYouPage extends StatefulWidget {
  const ThankYouPage({super.key});

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  String? orderNumber;
  String? collectionCode;

  @override
  void initState() {
    super.initState();
    orderNumber =
        "#ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    collectionCode = "${Random().nextInt(9999).toString().padLeft(4, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/images/sucess_lotie1.json',
                  height: 22.h,
                  repeat: false,
                ),

                SizedBox(height: 3.h),

                Text(
                  "Order Placed Successfully!",
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: AppConstants.manrope,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 2.h),
                Text(
                  "Order Number: $orderNumber",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppConstants.manrope,
                    color: Colors.black,
                  ),
                ),

                // SizedBox(height: 1.h),
                // Text(
                //   "Collection Code: $collectionCode",
                //   style: TextStyle(
                //     fontSize: 15.sp,
                //     fontWeight: FontWeight.w600,
                //     fontFamily: AppConstants.manrope,
                //     color: AppColors.maincolor,
                //   ),
                // ),
                SizedBox(height: 2.5.h),

                /// ℹ️ Message
                Text(
                  "Thanks for your order! It’s waiting for approval. We’ll notify you as soon as the business responds.",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey.shade700,
                    fontFamily: AppConstants.manrope,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 6.h),
                batan(
                  title: "Continue Shopping",
                  route: () {
                    Get.to(CommunityScreen());
                  },
                  color: AppColors.maincolor,
                  fontcolor: Colors.white,
                  height: 5.5.h,
                  fontsize: 17.sp,
                  width: double.infinity,
                  radius: 12.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
