import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/custom_button.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../Model/UserPersonalInfoModel.dart';
import '../Provider/messagescreen_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String? id;

  const UserProfileScreen({super.key, this.id});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isSending = true;
    });
    userpersonalinfoapi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'View Profile',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: AppConstants.manrope,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(1.w),
            decoration: const BoxDecoration(),
            child: Icon(Icons.arrow_back, color: Colors.black87, size: 22.sp),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body:
          isSending
              ? Loader()
              : Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 35.sp,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                                (userpersonalInfoModel?.data?.conciergeImage !=
                                            null &&
                                        userpersonalInfoModel!
                                            .data!
                                            .conciergeImage!
                                            .isNotEmpty)
                                    ? CachedNetworkImageProvider(
                                      userpersonalInfoModel!
                                          .data!
                                          .conciergeImage!,
                                    )
                                    : const AssetImage("assets/images/bg.jpg")
                                        as ImageProvider<Object>,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "${userpersonalInfoModel?.data?.firstName} ${userpersonalInfoModel?.data?.lastName}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: AppConstants.manrope,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 1.h),
                            child: Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: AppConstants.manrope,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Divider(),
                          buildProfileDetailItem(
                            Icons.email_outlined,
                            "Email",
                            userpersonalInfoModel?.data?.email,
                            () {},
                          ),
                          buildProfileDetailItem(
                            Icons.phone_outlined,
                            "Phone",
                            userpersonalInfoModel?.data?.phoneNumber,
                            () {
                              final phone =
                                  userpersonalInfoModel?.data?.phoneNumber;
                              if (phone != null &&
                                  phone.toString().isNotEmpty) {
                                final telUrl = Uri.parse(
                                  "tel:${phone.toString()}",
                                );
                                launchUrl(
                                  telUrl,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                          // buildProfileDetailItem(
                          //     Icons.calendar_today_outlined,
                          //     "Date of Birth",
                          //     userpersonalInfoModel?.data?.dateOfBirth),
                          // buildProfileDetailItem(Icons.person, "Gender",
                          //     userpersonalInfoModel?.data?.gender),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                  // batan(
                  //   title: "Block",
                  //   route: () {
                  //     showBlockUserDialog(context, supportUrl);
                  //   },
                  //   color: AppColors.maincolor,
                  //   fontcolor: AppColors.white,
                  //   height: 5.h,
                  //   fontsize: 18.sp,
                  //   radius: 12.0,
                  // ).paddingOnly(left: 4.4.w, right: 4.4.w, top: 2.h),
                  SizedBox(height: 3.h),
                ],
              ),
    );
  }

  final String supportUrl = "https://www.wavee.ai/help-center";

  void showBlockUserDialog(BuildContext context, String supportUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                width: 73.w,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 2.h),
                    Text(
                      "Block User",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      'Are you sure you want to block this user?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey.shade800,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    isLoading
                        ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: const CircularProgressIndicator(
                            color: AppColors.maincolor,
                          ),
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                child: batan(
                                  title: "No",
                                  width: 30.w,
                                  route: () {
                                    Navigator.of(context).pop();
                                  },
                                  color: AppColors.white,
                                  fontcolor: Colors.black,
                                  height: 5.h,
                                  fontsize: 16.sp,
                                  radius: 12.0,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                child: batan(
                                  title: "Yes",
                                  route: () async {
                                    setState(() => isLoading = true);

                                    final Uri url = Uri.parse(supportUrl);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Could not launch URL"),
                                        ),
                                      );
                                    }

                                    setState(() => isLoading = false);
                                    Navigator.of(context).pop();
                                  },
                                  color: AppColors.maincolor,
                                  fontcolor: Colors.white,
                                  height: 5.h,
                                  fontsize: 16.sp,
                                  radius: 12.0,
                                  width: 30.w,
                                ),
                              ),
                            ),
                          ],
                        ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Remove Friend",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Are you sure you want to delete this Friend?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "No",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(thickness: 1),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            "Yes",
                            style: TextStyle(
                              color: AppColors.maincolor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProfileDetailItem(
    IconData icon,
    String title,
    String? value,
    VoidCallback ontap,
  ) {
    return InkWell(
      onTap: ontap,

      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 17.sp),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: AppConstants.manrope,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    value ?? "N/A",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontFamily: AppConstants.manrope,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  userpersonalinfoapi() async {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageProvider().userPersonalInfo(
            (widget.id).toString(),
          );
          if (response.statusCode == 200) {
            userpersonalInfoModel = UserPersonalInfoModel.fromJson(
              response.data,
            );

            setState(() {
              isSending = false;
            });
          } else {
            setState(() {
              isSending = false;
            });

            buildErrorDialog(context, 'Error', "Failed to delete group");
          }
        } catch (e) {
          setState(() {
            isSending = false;
          });

          buildErrorDialog(context, 'Error', "Something went wrong");
        }
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
