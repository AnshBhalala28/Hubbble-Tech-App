import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/const.dart';

import 'colors.dart';

InputDecoration inputDecoration({
  required String hintText,
  String? errortext,
  Widget? searchIcon,
  Widget? ico,
  Color? cr,
}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 0.80.h, horizontal: 4.w),
    suffixIcon: ico,
    suffixIconConstraints: BoxConstraints(
      maxHeight: 5.h,
    ),
    errorText: errortext,
    hintText: hintText,
    prefixIcon: searchIcon,
    errorStyle: TextStyle(
      fontFamily: AppConstants.manrope,
      color: Colors.red,
      fontWeight: FontWeight.normal,
      fontSize: 15.sp,
      letterSpacing: 1,
    ),
    hintStyle: TextStyle(
        fontFamily: AppConstants.manrope,
        color: cr,
        fontWeight: FontWeight.normal,
        fontSize: 15.sp,
        letterSpacing: 1),
    fillColor: Colors.white,
    filled: true,
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink.withOpacity(0.1), width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.maincolor, width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.maincolor, width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.maincolor, width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
  );
}
