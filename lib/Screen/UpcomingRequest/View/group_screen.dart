import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../../ViewProfile/Model/profile_model.dart';
import '../../ViewProfile/Provider/profile_provider.dart';
import '../Model/get_my_new_request.dart';
import '../Model/my_request_model.dart';
import '../Provider/upcomeing_request_provider.dart';

class GroupRequestScreen extends StatefulWidget {
  const GroupRequestScreen({super.key});

  @override
  State<GroupRequestScreen> createState() => _GroupRequestScreenState();
}

class _GroupRequestScreenState extends State<GroupRequestScreen> {
  bool isLoading = false;
  bool isAction = false;
  List<String> categories = ['Request Sent', 'Group Request'];
  int selectedCategory = 0;

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat("dd-MM-yyyy").format(parsedDate);
    } catch (e) {
      return "N/A";
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });
    GetMyRequest();

    GetProfile();
    GetMyGroupApi();
  }

  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> requestPageKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: requestPageKey,
      drawer: SideMenu(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1.2.h, vertical: 1.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 4.h),
                  TitleBar(
                    title: "Groups",
                    drawerCallback: () {
                      requestPageKey.currentState?.openDrawer();
                    },
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: 6.h,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double itemWidth = (constraints.maxWidth - 9.w) / 2;

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              child: InkWell(
                                onTap: () {
                                  if (selectedCategory != index) {
                                    setState(() {
                                      selectedCategory = index;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 6.h,
                                  width: itemWidth,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey,
                                    ),
                                    color:
                                        selectedCategory == index
                                            ? AppColors.maincolor
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    child: Text(
                                      categories[index],
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color:
                                            selectedCategory == index
                                                ? Colors.white
                                                : Colors.black,
                                        fontFamily: AppConstants.manrope,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (selectedCategory == 0) ...[
                    SizedBox(height: 2.h),
                    isLoading
                        ? Loader().paddingOnly(top: 30.h)
                        : myRequestModel?.data?.requests?.length == 0 ||
                            myRequestModel?.data?.requests?.length == null
                        ? Center(
                          child: Text(
                            "No Request Avaiable",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).paddingOnly(top: 30.h)
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              myRequestModel?.data?.requests?.length ?? 0,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            var request =
                                myRequestModel?.data?.requests?[index];
                            return request?.appUserName == null
                                ? Center(
                                  child: Text(
                                    "No Request Avaiable",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ).paddingOnly(top: 30.h)
                                : Container(
                                  height: 13.h,
                                  margin: EdgeInsets.symmetric(vertical: 1.h),
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              request?.appUserName?.profile
                                                  ?.toString() ??
                                              "",
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) =>
                                                  CircularProgressIndicator(),
                                          errorWidget:
                                              (
                                                context,
                                                url,
                                                error,
                                              ) => Image.asset(
                                                "assets/images/waveeLogoShort.png",
                                                fit: BoxFit.cover,
                                                width: 80,
                                                height: 80,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${request?.appUserName?.firstName.toString() ?? ""} ${request?.appUserName?.lastName.toString() ?? ""}",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            "Requested At: ${formatDate(request?.createdAt.toString() ?? "")}",
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontFamily: AppConstants.manrope,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 1.h),
                                          Row(
                                            children: [
                                              SizedBox(width: 1.h),
                                              batan(
                                                title:
                                                    request?.status == "cancel"
                                                        ? "Request Cancelled"
                                                        : "Cancel Request",
                                                route: () {
                                                  log(
                                                    "Cancled id #${request?.id}",
                                                  );
                                                  request?.status == "cancel"
                                                      ? null
                                                      : RequestActionApi(
                                                        request?.id
                                                                .toString() ??
                                                            "",
                                                        "Cancel",
                                                      );
                                                },
                                                color: AppColors.maincolor,
                                                fontcolor: Colors.white,
                                                height: 5.h,
                                                width: 64.w,
                                                radius: 12.sp,
                                                fontsize: 16.sp,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                          },
                        ),
                  ],
                  SizedBox(height: 2.h),
                  if (selectedCategory == 1) ...[
                    myGroupRequestModel?.data?.length == 0 ||
                            myGroupRequestModel?.data?.length == null
                        ? Center(
                          child: Text(
                            "No Group Request Avaiable",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).paddingOnly(top: 20.h)
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: myGroupRequestModel?.data?.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            var request = myGroupRequestModel?.data?[index];
                            return Container(
                              height: 13.h,
                              margin: EdgeInsets.symmetric(vertical: 1.h),
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child:
                                        (request?.group?.images != null &&
                                                request!
                                                    .group!
                                                    .images!
                                                    .isNotEmpty)
                                            ? CachedNetworkImage(
                                              imageUrl: request!.group!.images!,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, url) =>
                                                      CircularProgressIndicator(),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Image.asset(
                                                    "assets/images/waveeLogoShort.png",
                                                    fit: BoxFit.cover,
                                                    width: 80,
                                                    height: 80,
                                                  ),
                                            )
                                            : Image.asset(
                                              "assets/images/waveeLogoShort.png",
                                              fit: BoxFit.cover,
                                              width: 80,
                                              height: 80,
                                            ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request?.group?.name.toString() ?? "",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        'Group Request at: ${formatDate(request?.createdAt)}',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Row(
                                        children: [
                                          batan(
                                            title: "Reject",
                                            route: () {
                                              RequestGroupActionApi(
                                                request?.id.toString() ?? "",
                                                "reject",
                                              );
                                            },
                                            color: AppColors.maincolor,
                                            fontcolor: Colors.white,
                                            height: 5.h,
                                            width: 32.w,
                                            radius: 12.sp,
                                            fontsize: 16.sp,
                                          ),
                                          SizedBox(width: 1.h),
                                          batan(
                                            title: "Accept",
                                            route: () {
                                              RequestGroupActionApi(
                                                request?.id.toString() ?? "",
                                                "accept",
                                              );
                                            },
                                            color: AppColors.maincolor,
                                            fontcolor: Colors.white,
                                            height: 5.h,
                                            width: 32.w,
                                            radius: 12.sp,
                                            fontsize: 16.sp,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  ],
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
          if (isAction)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
      // floatingActionButton: isLoading || selectedCategory != 0
      //     ? Container()
      //     : FloatingActionButton.extended(
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(900)),
      //         backgroundColor: Colors.white,
      //         onPressed: () {
      //           Get.to(() => const ChatBotScreen());
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

  GetMyRequest() {
    checkInternet().then((internet) async {
      if (internet) {
        MyRequestProvider()
            .myRequestApi(loginModel?.data?.user?.id.toString() ?? "")
            .then((response) async {
              myRequestModel = MyRequestModel.fromJson(response.data);
              if (response.statusCode == 200) {
                print(
                  "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}",
                );

                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
              }
            });
      } else {
        setState(() {
          isLoading = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  GetMyGroupApi() {
    checkInternet().then((internet) async {
      if (internet) {
        MyRequestProvider()
            .myGroupRequestApi(loginModel?.data?.user?.id.toString() ?? "")
            .then((response) async {
              myGroupRequestModel = MyGroupRequestModel.fromJson(response.data);
              if (response.statusCode == 200) {
                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
              }
            });
      } else {
        setState(() {
          isLoading = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  RequestActionApi(String id, action) {
    setState(() {
      isAction = true;
    });
    final Map<String, String> data = {"id": id, "action_type": action};

    checkInternet().then((internet) async {
      if (internet) {
        MyRequestProvider().myRequestActionApi(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isAction = false;
            });
            GetMyRequest();
          } else {
            setState(() {
              isAction = false;
            });
          }
        });
      } else {
        setState(() {
          isAction = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  RequestGroupActionApi(String id, action) {
    setState(() {
      isAction = true;
    });
    final Map<String, String> data = {"group_id": id, "action": action};

    checkInternet().then((internet) async {
      if (internet) {
        MyRequestProvider().myRequestGroupActionApi(data).then((
          response,
        ) async {
          if (response.statusCode == 200) {
            setState(() {
              isAction = false;
            });
            GetMyRequest();
            GetMyGroupApi();
          } else {
            setState(() {
              isAction = false;
            });
          }
        });
      } else {
        setState(() {
          isAction = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? '',
    };
    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          profileModel = ProfileModel.fromJson(response.data);
          if (response.statusCode == 200 && profileModel?.status == 200) {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
