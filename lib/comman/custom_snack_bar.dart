import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavee/comman/colors.dart';

showSnackBar({
  void Function(GetSnackBar)? ontap,
  required String title,
  required String message,
  backgoundColor,
  ColorText,
  IconColor,
  IconName,
}) {
  return Get.snackbar(
    title, // title
    message, // message
    backgroundColor: backgoundColor ?? AppColors.maincolor,
    colorText: ColorText ?? Colors.white,
    icon: Icon(IconName ?? Icons.error, color: IconColor ?? Colors.white),
    onTap: ontap,
    shouldIconPulse: true,
    barBlur: 10,

    isDismissible: true,
    duration: const Duration(seconds: 2),
  );
}
