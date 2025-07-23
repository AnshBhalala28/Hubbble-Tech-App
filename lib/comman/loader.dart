import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'colors.dart';

Widget Loader() {
  return Center(
    child: Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 9.h,
        width: 18.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: SizedBox(
            height: 4.5.h,
            width: 4.5.h,
            child: CircularProgressIndicator(color: AppColors.maincolor),
          ),
        ),
      ),
    ),
  );
}
