import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/const.dart';

InkWell batan({
  required String? title,
  required Callback? route,
  required Color? color,
  required Color? fontcolor,
  required double? height,
  required double? width,
  required double? fontsize,
  IconData? iconData,
  iconData1,
  FontWeight? fontWeight,
  double? iconsize,
  iconsize1,
  radius,
  String fontFamily = AppConstants.manrope,
}) {
  return InkWell(
    onTap: route,
    child: Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? 300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(visible: iconData != null, child: SizedBox(width: 2.w)),
          if (iconData != null)
            Icon(iconData, color: fontcolor, size: iconsize),
          if (iconData != null) SizedBox(width: 2.w),
          Text(
            title.toString(),
            style: TextStyle(
              fontFamily: fontFamily,
              color: fontcolor,
              fontWeight: fontWeight,
              letterSpacing: 1,
              fontSize: fontsize,
            ),
          ),
          if (iconData1 != null) SizedBox(width: 2.w),
          if (iconData1 != null)
            Icon(iconData1, color: fontcolor, size: iconsize1),
          if (iconData != null) SizedBox(width: 3.w),
        ],
      ),
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
