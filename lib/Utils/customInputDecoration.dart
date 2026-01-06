import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';
import 'const.dart';

InputDecoration inputDecoration({
  required String hintText,
  bool isDark = false,
  String? errortext,
  Widget? searchIcon,
  Widget? ico,
  Color? cr,
}) {
  // થીમ મુજબ કલર લોજિક
  final Color fillColor = isDark ? const Color(0xFF252525) : Colors.white;
  final Color borderColor =
      isDark ? const Color(0xFF404040) : AppColors.maincolor;
  final Color hintColor =
      cr ?? (isDark ? Colors.grey[500]! : Colors.grey[400]!);

  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 4.w),
    suffixIcon: ico,
    suffixIconConstraints: BoxConstraints(maxHeight: 5.h),
    errorText: errortext,
    hintText: hintText,
    prefixIcon: searchIcon,

    errorStyle: TextStyle(
      fontFamily: AppConstants.manrope,
      color: Colors.red,
      fontWeight: FontWeight.normal,
      fontSize: 12.sp,
      letterSpacing: 0.5,
    ),
    hintStyle: TextStyle(
      fontFamily: AppConstants.manrope,
      color: hintColor,
      fontWeight: FontWeight.normal,
      fontSize: 14.sp,
      letterSpacing: 0.5,
    ),

    fillColor: fillColor,
    filled: true,

    // Borders
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: isDark ? Colors.white10 : Colors.pink.withOpacity(0.1),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
      borderRadius: BorderRadius.circular(30),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: isDark ? const Color(0xFF00C853) : AppColors.maincolor,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: borderColor, width: 1),
      borderRadius: BorderRadius.circular(30),
    ),
  );
}
