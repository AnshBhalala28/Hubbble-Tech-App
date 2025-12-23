// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import 'colors.dart';
//
// showSnackBar({
//   void Function(GetSnackBar)? ontap,
//   required String title,
//   required String message,
//   backgoundColor,
//   ColorText,
//   IconColor,
//   IconName,
// }) {
//   return Get.snackbar(
//     title,
//     message,
//     backgroundColor: backgoundColor ?? AppColors.maincolor,
//     colorText: ColorText ?? Colors.white,
//     icon: Icon(IconName ?? Icons.error, color: IconColor ?? Colors.white),
//     onTap: ontap,
//     shouldIconPulse: true,
//     barBlur: 10,
//     isDismissible: true,
//     duration: const Duration(seconds: 2),
//   );
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors.dart';

// showSnackBar({
//   void Function(GetSnackBar)? ontap,
//   required String title,
//   required String message,
//   backgoundColor,
//   ColorText,
//   IconColor,
//   IconName,
// }) {
//   return Get.snackbar(
//     title, // title
//     message, // message
//     backgroundColor: backgoundColor ?? AppColors.maincolor,
//     colorText: ColorText ?? Colors.white,
//     icon: Icon(IconName ?? Icons.error, color: IconColor ?? Colors.white),
//     onTap: ontap,
//     shouldIconPulse: true,
//     barBlur: 10,
//
//     isDismissible: true,
//     duration: const Duration(seconds: 2),
//   );
// }
void showSnackBar({
  required BuildContext context,
  void Function()? ontap,
  required String title,
  required String message,
  Color? backgoundColor,
  Color? ColorText,
  Color? IconColor,
  IconData? IconName,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgoundColor ?? AppColors.maincolor,
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          Icon(
            IconName ?? Icons.error,
            color: IconColor ?? Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ColorText ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: ColorText ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
