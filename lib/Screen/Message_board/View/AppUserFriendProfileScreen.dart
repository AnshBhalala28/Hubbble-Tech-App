import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../../Message_screen/Model/RemoveFriendModel.dart';
import '../../Message_screen/Provider/messagescreen_provider.dart';
import '../Model/ResidentAppUserprofileModel.dart';
import '../Provider/messsage_board_provider.dart';
import 'messageboard.dart';

class AppUserFriendProfileScreen extends StatefulWidget {
  final String? id;

  const AppUserFriendProfileScreen({super.key, this.id});

  @override
  State<AppUserFriendProfileScreen> createState() =>
      _AppUserFriendProfileScreenState();
}

class _AppUserFriendProfileScreenState
    extends State<AppUserFriendProfileScreen> {
  bool isSending = false;

  @override
  void initState() {
    super.initState();
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
            decoration: BoxDecoration(),
            child: Icon(Icons.arrow_back, color: Colors.black87, size: 22.sp),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.blue.shade100, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 35.sp,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (residentappuserprofileModel
                                          ?.data?.user?.profile !=
                                      null &&
                                  residentappuserprofileModel!
                                      .data!.user!.profile!.isNotEmpty)
                              ? CachedNetworkImageProvider(
                                  residentappuserprofileModel!
                                      .data!.user!.profile!)
                              : const AssetImage("assets/images/bg.jpg")
                                  as ImageProvider<Object>,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "${residentappuserprofileModel?.data?.user?.name?.firstName} ${residentappuserprofileModel?.data?.user?.name?.lastName}",
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
                        Divider(),
                        buildProfileDetailItem(Icons.email_outlined, "Email",
                            residentappuserprofileModel?.data?.user?.email),
                        buildProfileDetailItem(
                            Icons.phone_outlined,
                            "Phone",
                            (residentappuserprofileModel?.data?.user?.mobileNo)
                                .toString()),
                        buildProfileDetailItem(
                            Icons.calendar_today_outlined,
                            "Date of Birth",
                            residentappuserprofileModel
                                ?.data?.user?.dateOfBirth),
                        buildProfileDetailItem(
                            Icons.location_on_outlined,
                            "Address",
                            residentappuserprofileModel
                                ?.data?.user?.address?.address),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Align(
                  child: batan(
                    title: "Remove From Friend",
                    route: () {
                      showDeleteConfirmation(context);
                    },
                    radius: 4.0.w,
                    color: AppColors.maincolor,
                    fontcolor: Colors.white,
                    height: 5.5.h,
                    width: 70.w,
                    fontsize: 15.5.sp,
                    iconData1: Icons.delete_forever,
                  ),
                ),
              ],
            ),
            if (isSending)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Center(child: Loader()),
                ),
              ),
          ],
        ),
      ),
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(
                  "Remove Friend",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Are you sure you want to delete this Friend?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 20),
                Divider(thickness: 1),
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
                      VerticalDivider(thickness: 1),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            removefriendapi();
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

  Widget buildProfileDetailItem(IconData icon, String title, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade700,
              size: 17.sp,
            ),
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
    );
  }

  removefriendapi() async {
    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response =
              await MessageProvider().removefriend((widget.id).toString());

          if (response.statusCode == 200) {
            removefriendModel =
                RemoveFriendModel.fromJson(json.decode(response.body));

            setState(() {
              isSending = false;
            });

            print("friend delete : ${response.body}");
            print("friend delete id : ${widget.id}");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Friend deleted successfully!"),
                backgroundColor: AppColors.maincolor,
              ),
            );

            Get.to(Messageboard(), arguments: {
              "selectedCategory": 1,
              "selectedLocalSubCategory": 1,
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

          print("error: ${e.toString()}");
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

  userpersonalinfoapi() async {
    setState(() {
      isSending = true;
    });
    final Map<String, String> data = {
      'id': (widget.id).toString(),
    };
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response =
              await MessageBoardProvider().AppFrienduserpersonalinfo(data);
          if (response.statusCode == 200) {
            residentappuserprofileModel = ResidentAppUserprofileModel.fromJson(
                json.decode(response.body));
            print("Datafriend na  ave che  : ${response.body}");
            print("Datafriend na ave che id : ${widget.id}");
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
          print("error: ${e.toString()}");
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
