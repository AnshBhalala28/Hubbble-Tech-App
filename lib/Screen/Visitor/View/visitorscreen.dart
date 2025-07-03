import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
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
      latestVisitorModal = null;
      log("aamaro mofr3erewr${latestVisitorModal}");
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
                    child: CircularProgressIndicator(
                      color: AppColors.maincolor,
                    ),
                  ).paddingOnly(top: 25.h)
                : latestVisitorModal?.data?.length == null ||
                        latestVisitorModal?.data?.length == 0 ||
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
                          padding: EdgeInsets.zero,
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
                                      color: Colors.grey.shade100, width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Checked In: ${formatCheckInDateTime(visitor?.checkInDate, visitor?.checkInTime)}",
                                        style: TextStyle(
                                          fontSize: 16.5.sp,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      visitor?.checkOutDate == null
                                          ? SizedBox()
                                          : Text(
                                              "Checked Out: ${formatCheckInDateTime(visitor?.checkOutDate, visitor?.checkOutTime)}",
                                              style: TextStyle(
                                                fontSize: 16.5.sp,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                      SizedBox(height: 0.5.h),
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
                                      visitor?.isContractors == null
                                          ? SizedBox()
                                          : SizedBox(height: 0.5.h),
                                      visitor?.isContractors == null
                                          ? SizedBox()
                                          : Row(
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
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ],
                                            ),
                                      SizedBox(height: 0.5.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.vpn_key,
                                            size: 22,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            (visitor?.keyLog != null &&
                                                    int.tryParse(
                                                            visitor!.keyLog ??
                                                                "") !=
                                                        null)
                                                ? (int.parse(
                                                            visitor!.keyLog!) >=
                                                        0
                                                    ? "Key: Yes"
                                                    : "Key: No")
                                                : "Key: No",
                                            style: TextStyle(
                                              fontSize: 16.5.sp,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                        ],
                                      ),
                                      visitor?.inNote  == null||  visitor?.inNote  == ''
                                          ? SizedBox()
                                          : Row(
                                        children: [
                                          Icon(
                                            Icons.note,
                                            size: 22,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            "Note:  ${visitor?.inNote ?? ""} ",
                                            style: TextStyle(
                                              fontSize: 16.5.sp,
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                              AppConstants.manrope,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 0.5.h),
                                      visitor?.reason?.reason==null||visitor?.reason?.reason==''?SizedBox():       Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.help_outline,
                                            size: 22,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(width: 2.w),
                                          Expanded(
                                            child: ReadMoreText(
                                              "Reason:  ${visitor?.reason?.reason ?? ""}",
                                              trimLines: 2,
                                              colorClickableText: Colors.blue,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: ' Read More',
                                              trimExpandedText: ' Read Less',
                                              style: TextStyle(
                                                fontSize: 16.5.sp,
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
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
      // floatingActionButton: isLoading
      //     ? Container()
      //     : FloatingActionButton.extended(
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(900)),
      //         backgroundColor: Colors.white,
      //         onPressed: () {
      //           Get.to(() => ChatBotScreen());
      //         },
      //         icon: Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
      //         label: Text(
      //           "Ai Concierge",
      //           style: TextStyle(
      //               color: Colors.black,
      //               fontWeight: FontWeight.w600,
      //               fontSize: 16.sp,
      //               fontFamily: AppConstants.manrope),
      //         ),
      //       ),
    );
  }

  String formatCheckInDateTime(String? date, String? time) {
    if (date == null || date.isEmpty || time == null || time.isEmpty) {
      return "N/A";
    }

    try {
      DateTime dateTime = DateTime.parse("$date $time");

      String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
      String formattedTime = DateFormat('hh:mm a').format(dateTime);

      return "$formattedDate, $formattedTime";
    } catch (e) {
      return "Invalid Date";
    }
  }

  void LatestVisitorApi() {
    final Map<String, String> data = {};

    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";

    if (widget.latestVisitor == null || widget.latestVisitor!.isEmpty) {
      data["lestesh_visitor"] = "lestesh_visitor";
    }

    log(" $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().VisitorShowCount(data);
          latestVisitorModal =
              LatestVisitorModal.fromJson(jsonDecode(response.body));

          if (response.statusCode == 200) {
            log("${response.body}");
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
          log("error  $stackTrace");
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
