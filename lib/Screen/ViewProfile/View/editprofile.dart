import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/input_decoration.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController fullName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 27.sp,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: AssetImage('assets/images/waveeLogoShort.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 2.sp,
                        child: CircleAvatar(
                          radius: 12.sp,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.camera_alt,
                              size: 15.sp, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Parves Ahamad",
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "@parvesahamad",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    cursorColor: AppColors.black,
                    controller: fullName,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration(hintText: 'Full Name'),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    cursorColor: AppColors.black,
                    controller: phoneNumber,
                    keyboardType: TextInputType.phone,
                    decoration: inputDecoration(hintText: 'Phone Number'),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    cursorColor: AppColors.black,
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDecoration(hintText: 'Email'),
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.sp)),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Save",
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manrope),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
