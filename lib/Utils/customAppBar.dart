import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart'; // Ensure this path matches your project

import 'colors.dart';
import 'const.dart';

class TitleBar extends StatelessWidget {
  final String? title;
  final Callback? drawerCallback;
  final Callback? back;
  final Icon? backicn;
  final Color? clr;
  final bool isBackEnabled;
  final bool isSideMenu;

  const TitleBar({
    super.key,
    required this.title,
    required this.drawerCallback,
    this.back,
    this.backicn,
    this.clr,
    this.isBackEnabled = true,
    this.isSideMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Access Theme Logic
    final themeController = context.watch<ThemeController>();
    final isDark = themeController.isDark;

    // 2. Define Dynamic Colors
    final Color titleColor =
        isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

    final Color backgroundColor =
        isDark ? Colors.transparent : Colors.transparent;
    // final Color titleColor = isDark ? Colors.white : Colors.black;

    // Back Button Circle Background
    final Color btnBgColor =
        isDark
            ? const Color(0xFFCFB583).withValues(alpha: 0.2)
            : const Color(0xFF4C5588).withValues(alpha: 0.15);

    // Back Icon Color
    final Color iconColor =
        isDark ? const Color(0xFFCFB583) : const Color(0xFF4C5588);

    // Header Color (for menu icon if needed)
    final Color headerColor =
        clr ?? (isDark ? Colors.white : AppColors.maincolor);

    return Container(
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- Back Button ---
          isBackEnabled
              ? InkWell(
                onTap:
                    back ??
                    () {
                      Get.back();
                    },
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  height: 10.w,
                  width: 10.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: btnBgColor, // Dynamic Background
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18.sp,
                    color: iconColor, // Dynamic Icon Color
                  ).paddingOnly(left: 2.w),
                ),
              )
              : SizedBox(width: 12.w, height: 12.w),

          // --- Title Text ---
          SizedBox(
            width: 70.w,
            child: Text(
              title.toString(),
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.manropeBold,
                fontSize: 19.sp,
                color: titleColor, // Dynamic Text Color
              ),
            ),
          ),

          // --- Side Menu Icon ---
          isSideMenu
              ? _MenuIcon(route: drawerCallback, color: headerColor)
              : const SizedBox().paddingOnly(right: 10.w),
        ],
      ),
    );
  }
}

// Helper Widget for Menu Icon (Private)
class _MenuIcon extends StatelessWidget {
  final Callback? route;
  final Color? color;

  const _MenuIcon({required this.route, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: route,
      borderRadius: BorderRadius.circular(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.4.h,
            width: 6.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0.5.h),
            height: 0.4.h,
            width: 8.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          Container(
            height: 0.4.h,
            width: 6.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ],
      ),
    );
  }
}
