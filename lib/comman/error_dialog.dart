import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

buildErrorDialog(
  BuildContext context,
  String title,
  String contant, {
  VoidCallback? callback,
  String? buttonname,
}) {
  Widget okButton = GestureDetector(
    child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        // color: primary
      ),
      child: Center(
        child: Text(
          buttonname ?? 'OK',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            fontFamily: AppConstants.manrope,
            color: AppColors.maincolor,
          ),
        ),
      ),
    ),
    onTap: () {
      // if (callback == null) {
      Get.back();
      // } else {

      // }
    },
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 73.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 3.h),
              (title != "")
                  ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppConstants.manrope,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                    ],
                  )
                  : Container(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      contant,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: AppConstants.manrope,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Divider(height: 1.0, color: Colors.grey),
              SizedBox(height: 2.h),
              okButton,
              SizedBox(height: 2.h),
            ],
          ),
        ),
      );
    },
  );
}

optionalDialog(
  BuildContext context,
  String title,
  String contant,
  VoidCallback? callback, {
  String? buttonname,
}) {
  Widget YesButton = GestureDetector(
    onTap:
        // if (callback == null) {
        callback,
    child: Container(
      alignment: Alignment.center,
      width: 30.w,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        // color: primary
      ),
      child: Center(
        child: Text(
          buttonname ?? 'Yes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.green,
            fontFamily: AppConstants.manrope,
          ),
        ),
      ),
    ),

    // } else {

    // }
  );
  Widget NoButton = GestureDetector(
    child: Container(
      alignment: Alignment.center,
      width: 30.w,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
        // color: primary
      ),
      child: Center(
        child: Text(
          buttonname ?? 'No',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.redColor,
            fontFamily: AppConstants.manrope,
          ),
        ),
      ),
    ),
    onTap: () {
      Get.back();
    },
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.maincolor,
        child: Container(
          width: 73.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 3.h),
              (title != "")
                  ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: AppColors.black,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                    ],
                  )
                  : Container(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      contant,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Divider(height: 1.0, color: Colors.grey),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  YesButton,
                  SizedBox(
                    height: 6.h,
                    child: VerticalDivider(color: Colors.grey),
                  ),
                  NoButton,
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
