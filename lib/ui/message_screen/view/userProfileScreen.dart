import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/ui/message_screen/modal/UserPersonalInfoModel.dart';
import 'package:wavee/utils/customAppBar.dart';

import '../../../utils/checkInternetConnection.dart';
import '../../../utils/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/customBatan.dart';
import '../../../utils/errorDialog.dart';
import '../../../utils/loader.dart';
import '../provider/messageScreenProvider.dart';

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
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    final Color blueColor = const Color(0xFF5A6385);

    final Color iconColor = isDark ? const Color(0xf0B8A780) : blueColor;
    final Color subtitleColor =
        isDark ? Colors.grey.shade500 : Colors.grey.shade600;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xf01A1A1A) : const Color(0xFFF0F2F5),

      body:
          isSending
              ? const Loader()
              : Column(
                children: [
                  SizedBox(height: 6.h),
                  TitleBar(title: "View Profile", drawerCallback: () {}),
                  SizedBox(
                    width: double.infinity,
                    // decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            // border: Border.all(
                            //   color: Colors.blue.shade100,
                            //   width: 2,
                            // ),
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
                                    : const AssetImage(
                                          "assets/images/Applogo_remove_background.png",
                                        )
                                        as ImageProvider<Object>,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "${userpersonalInfoModel?.data?.firstName} ${userpersonalInfoModel?.data?.lastName}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: AppConstants.manropeBold,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: AppConstants.manrope,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : Colors.black87,
                          ),
                        ),

                        SizedBox(height: 1.h),

                        buildSingleInfoCard(
                          ontap: () {},
                          icon: Icons.email_outlined,

                          label: "EMAIL",
                          value:
                              userpersonalInfoModel?.data?.email.toString() ??
                              "N/A",
                          iconBg:
                              theme.isDark
                                  ? const Color(0xf036342F)
                                  : const Color(0xf0E9EAEF),

                          iconColor: iconColor,
                          labelColor: subtitleColor,
                          valueColor: titleColor,
                          cardColor:
                              theme.isDark
                                  ? const Color(0xf0252525)
                                  : Colors.white,
                          isDark: isDark,
                        ),
                        SizedBox(height: 1.h),
                        buildSingleInfoCard(
                          ontap: () {
                            final phone =
                                userpersonalInfoModel?.data?.phoneNumber;
                            if (phone != null && phone.toString().isNotEmpty) {
                              final telUrl = Uri.parse(
                                "tel:${phone.toString()}",
                              );
                              launchUrl(
                                telUrl,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: Icons.phone,

                          label: "PHONE",
                          value:
                              userpersonalInfoModel?.data?.phoneNumber
                                  .toString() ??
                              "N/A",
                          iconBg:
                              theme.isDark
                                  ? const Color(0xf036342F)
                                  : const Color(0xf0E9EAEF),

                          iconColor: iconColor,
                          labelColor: subtitleColor,
                          valueColor: titleColor,
                          cardColor:
                              theme.isDark
                                  ? const Color(0xf0252525)
                                  : Colors.white,
                          isDark: isDark,
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ), // batan(

                  SizedBox(height: 3.h),
                ],
              ).paddingOnly(left: 3.w, right: 3.w),
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
                color: AppColors.maincolor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.maincolor, size: 17.sp),
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
                      fontFamily: AppConstants.manropeBold,
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

  Widget infoCard(
    String label,
    String value,
    IconData icon,
    VoidCallback ontap,
  ) {
    return GestureDetector(
      onTap: ontap,
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.maincolor,
                ),
                child: Icon(icon, size: 18.sp, color: Colors.white),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppConstants.manrope,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Text(
                      value.isNotEmpty ? value : "—",
                      style: TextStyle(
                        fontFamily: AppConstants.manrope,
                        fontSize: 16.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).marginOnly(bottom: 1.h),
    );
  }

  Widget buildSingleInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
    required Color iconColor,
    required Color labelColor,
    required Color valueColor,
    required Color cardColor,
    required bool isDark,
    required VoidCallback ontap,
  }) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: iconBg),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.8.h),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 19.sp),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: labelColor,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                      fontFamily: AppConstants.manrope,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
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
