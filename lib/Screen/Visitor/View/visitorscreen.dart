import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/Custom_AppBar.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/error_dialog.dart';
import '../../HomeNewPage/Provider/homescreen_provider.dart';
import '../../open_ai_chatbot/view/open_ai_screen.dart';
import '../Model/latest_visitor_modal/latest_visitor_modal.dart';

class VisitorScreen extends StatefulWidget {
  String? latestVisitor;

  VisitorScreen({super.key, this.latestVisitor});

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey_parcel =
      GlobalKey<ScaffoldState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });
    LatestVisitorApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      key: _scaffoldKey_parcel,
      drawer: const SideMenu(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            TitleBar(
              back: () {
                Get.back();
              },
              title: 'Visitors',
              drawerCallback: () {
                _scaffoldKey_parcel.currentState?.openDrawer();
              },
            ),
            SizedBox(height: 1.5.h),
            isLoading
                ? Center(
                  child: CircularProgressIndicator(color: AppColors.maincolor),
                ).paddingOnly(top: 25.h)
                : latestVisitorModal?.data == null ||
                    latestVisitorModal!.data!.isEmpty
                ? Center(
                  child: Text(
                    "No Visitors Available",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontFamily: AppConstants.manrope,
                    ),
                  ).paddingOnly(top: 35.h),
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: latestVisitorModal?.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      var visitor = latestVisitorModal?.data?[index];
                      return Material(
                        elevation: 0.5,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade100,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          // margin: EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //Checked In
                                Text(
                                  "Checked In: ${visitor?.checkInDate ?? ""} ${visitor?.checkInTime ?? "N/A"}",
                                  style: TextStyle(
                                    fontSize: 16.5.sp,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                //Checked Out
                                visitor?.checkOutDate == null
                                    ? SizedBox()
                                    : Text(
                                      "Checked Out: ${visitor?.checkOutDate ?? ""} ${visitor?.checkOutTime ?? ""}",
                                      style: TextStyle(
                                        fontSize: 16.5.sp,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                SizedBox(height: 0.5.h),
                                //Visitor Name
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 22,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "Name:  ${visitor?.visitorName.toString().capitalizeFirst ?? ''}",
                                      style: TextStyle(
                                        fontSize: 16.5.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 0.5.h),
                                //Visitor Type
                                Row(
                                  children: [
                                    Icon(
                                      Icons.badge,
                                      size: 22,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "Type:  ${visitor?.isContractors ?? ""} ",
                                      style: TextStyle(
                                        fontSize: 16.5.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppConstants.manrope,
                                        // color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 0.5.h),
                                //key
                                Row(
                                  children: [
                                    Icon(
                                      Icons.vpn_key,
                                      size: 22,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 2.w),
                                    // Text(
                                    //   "Key:  ${ visitor?.keyLog ?? ""} ",
                                    //   style: TextStyle(
                                    //     fontSize: 16.5.sp,
                                    //     fontWeight: FontWeight.w500,
                                    //     fontFamily: AppConstants.manrope,
                                    //     // color: Colors.grey.shade600,
                                    //   ),
                                    // ),
                                    Text(
                                      (visitor?.keyLog != null &&
                                              int.tryParse(
                                                    visitor!.keyLog ?? "",
                                                  ) !=
                                                  null)
                                          ? (int.parse(visitor!.keyLog!) >= 0
                                              ? "Key: Yes"
                                              : "Key: No") // Yes for positive, No for negative
                                          : "Key: No",
                                      // Default to "No" if null or invalid
                                      style: TextStyle(
                                        fontSize: 16.5.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 0.5.h),
                                //reason
                                Row(
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      size: 22,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "Reason:  ${visitor?.reason?.reason ?? ""} ",
                                      style: TextStyle(
                                        fontSize: 16.5.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppConstants.manrope,
                                        // color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 0.5.h),
                              ],
                            ),
                          ),
                        ),
                      ).paddingOnly(bottom: 10);
                    },
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton:
          isLoading
              ? Container()
              : FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(900),
                ),
                backgroundColor: Colors.white,
                onPressed: () {
                  Get.to(() => const ChatBotScreen());
                },
                icon: Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
                label: Text(
                  "Ai Concierge",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ),
    );
  }

  void LatestVisitorApi() {
    final Map<String, String> data = {};

    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";

    // ✅ Check if latestVisitor is empty before adding the parameter
    if (widget.latestVisitor == null || widget.latestVisitor!.isEmpty) {
      data["lestesh_visitor"] = "lestesh_visitor";
    }

    log("Visitor Data jay che visitor scrren na  $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().VisitorShowCount(data);
          latestVisitorModal = LatestVisitorModal.fromJson(
            jsonDecode(response.body),
          );

          if (response.statusCode == 200) {
            log("data ave chee ${response.body}");
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
          }
        } catch (e, stackTrace) {
          setState(() {
            isLoading = false;
          });
          log("error avve che data mathi $stackTrace");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
