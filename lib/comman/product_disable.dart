import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/custom_button.dart';

showOnlineOrderDisabledDialog({
  required BuildContext context,
  required String businessName,
  required bool isProduct,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 12,
          backgroundColor: Colors.white,
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.maincolor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.maincolor,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Online Orders Paused",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: AppConstants.manrope,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "$businessName has not activated online orders.\nOrders cannot currently be placed for ${isProduct ? 'products' : 'services'}.",
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      color: Colors.black54,
                      height: 1.5,
                      fontFamily: AppConstants.manrope,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  batan(
                    title: "OK",
                    route: () {
                      Get.back();
                    },
                    color: AppColors.maincolor,
                    fontcolor: Colors.white,
                    height: 5.h,
                    fontsize: 17.sp,
                    radius: 12.0,
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}

ShowAddCart({
  required BuildContext context,
  required String businessName,
  required bool isProduct,
  required VoidCallback onContinue,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 12,
          backgroundColor: Colors.white,
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.maincolor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.maincolor,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    businessName,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: AppConstants.manrope,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "You are about to create a new basket.All previous items will be removed.",
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      color: Colors.black54,
                      height: 1.5,
                      fontFamily: AppConstants.manrope,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: batan(
                          title: "Cancel",
                          route: () {
                            Get.back();
                          },
                          width: double.infinity,
                          color: Colors.white,
                          fontcolor: Colors.black,
                          height: 5.h,
                          fontsize: 16.sp,
                          radius: 12.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: batan(
                          title: "Continue",
                          route: () {
                            Get.back();
                            onContinue();
                          },
                          width: double.infinity,
                          color: AppColors.maincolor,
                          fontcolor: Colors.white,
                          height: 5.h,
                          fontsize: 16.sp,
                          radius: 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
