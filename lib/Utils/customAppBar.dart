import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';
import 'const.dart';

Container TitleBar({
  required String? title,
  required Callback? drawerCallback,
  Callback? back,
  Icon? backicn,
  Color? clr,
  bool isBackEnabled = true,
  bool isSideMenu = false,
}) {
  Color headerColor = clr ?? AppColors.maincolor;
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isBackEnabled
            ? InkWell(
              onTap:
                  back ??
                  () {
                    Get.back();
                  },
              child: Container(
                height: 12.w,
                width: 12.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: AppColors.maincolor,
                ),
                child: Icon(Icons.arrow_back, size: 20.sp, color: Colors.white),
              ),
            )
            : SizedBox(width: 12.w, height: 12.w),
        SizedBox(
          width: 72.w,
          child: Text(
            title.toString(),
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
              fontSize: 19.sp,
              color: Colors.black,
            ),
          ),
        ),
        isSideMenu
            ? MenuIcon(route: drawerCallback, color: headerColor)
            : const SizedBox().paddingOnly(right: 10.w),
      ],
    ),
  );
}

InkWell MenuIcon({required Callback? route, required Color? color}) {
  return InkWell(
    onTap: route,
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
