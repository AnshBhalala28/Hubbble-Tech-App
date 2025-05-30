import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
import 'package:wavee/Screen/HomeNewPage/Model/parcel_show_count.dart';
import 'package:wavee/Screen/HomeNewPage/Model/visitor_show_count_model.dart';
import 'package:wavee/Screen/HomeNewPage/Provider/homescreen_provider.dart';
import 'package:wavee/Screen/Message_board/View/messageboard.dart';
import 'package:wavee/Screen/NotiFicationPage/Provider/notificationprovider.dart';
import 'package:wavee/Screen/NotiFicationPage/View/notification_page.dart';
import 'package:wavee/Screen/Parcel/parcel_Screen_View/parcel_View.dart';
import 'package:wavee/Screen/ViewProfile/View/viewprofile.dart';
import 'package:wavee/Screen/Visitor/View/visitorscreen.dart';
import 'package:wavee/Screen/open_ai_chatbot/view/open_ai_screen.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/bottom_bar.dart';
import 'package:wavee/comman/check_inernet_connecty.dart';
import 'package:wavee/comman/error_dialog.dart';

import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../NotiFicationPage/Model/Notification_Model.dart';
import '../../ViewProfile/Model/profile_model.dart';
import '../../ViewProfile/Provider/profile_provider.dart';
import '../../Visitor/Model/latest_visitor_modal/latest_visitor_modal.dart';
import '../Model/chat_show_count_modal.dart';
import '../Model/message_board_modal.dart';

class HomeNewPage extends StatefulWidget {
  int? selected;
  final String userName;

  HomeNewPage({super.key, this.selected, required this.userName});

  @override
  State<HomeNewPage> createState() => _HomeNewPageState();
}

class _HomeNewPageState extends State<HomeNewPage> {
  // bool isloding = true;
  String? fullName;
  int sel = 0;
  bool isLoading = false;
  int parcelCount = 0;
  int visitorCount = 0;
  int chatCount = 0;
  int notificationCount = 0;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      getnotificationCount();
    });
    ParcelShowCount();
    VisitorShowCount();
    ChatShowCount();
    LatestVisitorApi();
    MessageBoardApi();
    GetProfile();

    print('Login modal ${loginModel?.data?.user?.name?.firstName ?? ""}');
  }

  @override
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey_home =
        GlobalKey<ScaffoldState>();

    return Scaffold(
      bottomNavigationBar: Bottom_bar(selected: 1),
      drawer: SideMenu(),
      key: _scaffoldKey_home,
      body: Container(
        color: Color(0xFFEFEBD8),
        //color: AppColors.bgcolor,
        child: SingleChildScrollView(
          // ✅ Wrap with SingleChildScrollView
          child: Column(
            children: [
              SizedBox(height: 0.5.h),
              Container(
                height: 12.h,
                color: Color(0xFFEFEBD8),
                //color: AppColors.bgcolor,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          _timer!.cancel();
                          _scaffoldKey_home.currentState?.openDrawer();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 0.4.h,
                                width: 6.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 0.5.h),
                                height: 0.4.h,
                                width: 9.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              Container(
                                height: 0.4.h,
                                width: 6.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "Wavee",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.maincolor,
                        ),
                      ),
                      Row(
                        children: [
                          _buildNotification(
                            Icons.notifications_none_outlined,
                            () {
                              _timer!.cancel();

                              Get.to(NotificationPage());
                            },
                            notificationCount: notificationCount,
                          ),
                          GestureDetector(
                            onTap: () {
                              _timer!.cancel();

                              Get.to(
                                ViewProfile(id: loginModel?.data?.user?.id),
                              );
                            },
                            child: Container(
                              height: 12.w,
                              width: 12.w,
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                shape: BoxShape.circle, // Circle shape added
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: Offset(
                                      0,
                                      3,
                                    ), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 6.w,
                                backgroundColor: Colors.transparent,
                                child:
                                    isLoading
                                        ? Center(
                                          child: commonLoader(),
                                        ) // loader 1
                                        : ClipOval(
                                          child:
                                              (profileModel
                                                              ?.data
                                                              ?.user
                                                              ?.profile ==
                                                          null ||
                                                      profileModel
                                                              ?.data
                                                              ?.user
                                                              ?.profile
                                                              ?.isEmpty ==
                                                          true)
                                                  ? Image.asset(
                                                    'assets/images/waveeLogoShort.png',
                                                    fit: BoxFit.cover,
                                                    width: 8.w,
                                                    height: 8.w,
                                                  )
                                                  : CachedNetworkImage(
                                                    imageUrl:
                                                        profileModel
                                                            ?.data
                                                            ?.user
                                                            ?.profile ??
                                                        '',
                                                    fit: BoxFit.cover,
                                                    width: 11.w,
                                                    height: 11.w,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => Center(
                                                          child: commonLoader(),
                                                        ),
                                                    // loader 2
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Image.asset(
                                                          'assets/images/waveeLogoShort.png',
                                                          fit: BoxFit.cover,
                                                          width: 8.w,
                                                          height: 8.w,
                                                        ),
                                                  ),
                                        ),
                              ),
                            ).paddingOnly(right: 2.w),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 10.h,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello!",
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 20.sp,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      Text(
                        "${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} ${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.sp,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height:
                    latestVisitorModal?.data?.length == null
                        ? MediaQuery.of(context).size.height * 0.7
                        : null,
                // height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  color: AppColors.maincolor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Icon Buttons Row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildIconTile(
                            "Parcels",
                            Icons.local_shipping,
                            () {
                              _timer!.cancel();

                              Get.to(ParcelScreen());
                            },
                            notificationCount: parcelCount,
                          ),
                          _buildIconTile(
                            "Visitors",
                            Icons.groups,
                            () {
                              _timer!.cancel();

                              Get.to(
                                VisitorScreen(latestVisitor: "lestesh_visitor"),
                              );
                            },
                            notificationCount: visitorCount,
                          ),
                          _buildIconTile("Chat", Icons.chat, () {
                            _timer!.cancel();

                            Get.to(ChatScreen());
                          }, notificationCount: chatCount),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // ✅ Latest Visitor
                    _buildPlaceholderBox(
                      title: "Latest Visitors",
                      onTap: () {
                        _timer!.cancel();

                        Get.to(VisitorScreen());
                      },
                    ),
                    SizedBox(height: 20),

                    _buildVisitorCard(),
                    SizedBox(height: 0.5.h),
                    _buildPlaceholderBox(
                      title: "Message Board",
                      onTap: () {
                        _timer!.cancel();

                        Get.to(Messageboard());
                      },
                    ),
                    SizedBox(height: 20),

                    _buildMessageCard(),
                  ],
                ),
              ),
            ],
          ),
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
                  _timer!.cancel();

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

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer!.cancel();
  }

  Widget _buildIconTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    int notificationCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 8.h,
                width: 15.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.maincolor, size: 27.sp),
              ),

              // Notification Badge Positioned Horizontally
              Positioned(
                top: -5, // Slightly down from the top
                right: -10, // Move more towards the right
                child: Container(
                  alignment: Alignment.center,
                  height: 3.h,
                  // Smaller size for better alignment
                  width: 4.h,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBox({
    required String title,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 6.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          // color: Color(0xFFB3A9D1),
          color: Colors.purple.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.manrope,
              ),
            ),
            Container(
              height: 4.h,
              width: 8.w,
              decoration: BoxDecoration(
                //   color: Color(0xFF6B5FA0),
                color: Colors.purple.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.black,
                size: 17.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification(
    IconData icon,
    VoidCallback onTap, {
    int notificationCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.5.h),
                    child: Icon(icon, color: AppColors.black, size: 23.sp),
                  ),
                ),
                // Notification Badge Positioned Horizontally
                Positioned(
                  top: 0, // Slightly down from the top
                  right: -8, // Move more towards the right
                  child: Container(
                    alignment: Alignment.center,
                    height: 2.5.h,
                    // Smaller size for better alignment
                    width: 3.h,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
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
    );
  }

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  Widget _buildVisitorCard() {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.white))
        : latestVisitorModal?.data == null || latestVisitorModal!.data!.isEmpty
        ? SizedBox(
          child: Center(
            child: Text(
              "No Visitors Available",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                fontFamily: AppConstants.manrope,
              ),
            ).paddingOnly(bottom: 6.h, top: 5.h),
          ),
        )
        : SizedBox(
          // height: 24.h,
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemCount:
                (latestVisitorModal?.data?.length ?? 0) > 2
                    ? 2
                    : latestVisitorModal?.data?.length ?? 0,
            itemBuilder: (context, index) {
              var visitor = latestVisitorModal?.data?[index];
              return Container(
                // height: 10.h,
                margin: EdgeInsets.only(bottom: 1.h),
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Visitor Name
                    Text(
                      visitor?.visitorName?.capitalizeFirst ?? "",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    // ✅ Visitor Phone & Check-In Time Row
                    Row(
                      children: [
                        Icon(Icons.phone, color: AppColors.maincolor),
                        SizedBox(width: 2.w),
                        Text(
                          visitor?.visitorPhone ?? "",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: AppConstants.manrope,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.timer,
                          color: AppColors.maincolor,
                          size: 15.sp,
                        ).paddingOnly(right: 1.w),
                        Text(
                          "${visitor?.checkInDate ?? ""} ${visitor?.checkInTime ?? ""}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
  }

  //
  // Widget _buildMessageCard() {
  //   return isLoading
  //       ? Center(
  //           child: CircularProgressIndicator(
  //             color: AppColors.white,
  //           ),
  //         )
  //       : SizedBox(
  //           height: 17.h, // ✅ Fixed height for horizontal scroll
  //           child: ListView.builder(
  //             scrollDirection: Axis.horizontal, // ✅ Enable horizontal scrolling
  //             itemCount: (messageBoardModal?.data?.length ?? 0) > 2
  //                 ? 2
  //                 : messageBoardModal?.data?.length ?? 0,
  //             padding: EdgeInsets.zero,
  //             itemBuilder: (context, index) {
  //               var message = messageBoardModal?.data?[index];
  //               int totalMessages = messageBoardModal?.data?.length ?? 0;
  //               return Container(
  //                 margin: EdgeInsets.only(right: 2.w),
  //                 padding: EdgeInsets.all(12),
  //                 width: (totalMessages == 1) ? 92.w : 85.w,
  //                 // ✅ Full width if only 1 message
  //                 decoration: BoxDecoration(
  //                   color: Colors.white, // ✅ White Background
  //                   borderRadius: BorderRadius.circular(15),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 5,
  //                       spreadRadius: 2,
  //                     ),
  //                   ],
  //                 ),
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // ✅ Image on the Left
  //                     ClipRRect(
  //                       borderRadius: BorderRadius.circular(10),
  //                       child: CachedNetworkImage(
  //                         imageUrl: (message?.file?.isNotEmpty == true)
  //                             ? message!.file![0]
  //                             : "",
  //                         fit: BoxFit.cover,
  //                         width: 20.w,
  //                         height: 20.h,
  //                         progressIndicatorBuilder: (context, url, progress) =>
  //                             Center(
  //                           child: CircularProgressIndicator(
  //                             color: AppColors.maincolor,
  //                           ),
  //                         ),
  //                         errorWidget: (context, url, error) => Image.network(
  //                           "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPwQOOsR9GZtqdjmrbJLzYGuY8XNpVuGd2vZxUNHJkgGg8aL6nIz2y5Sz7KSPc6yk4QDY&usqp=CAU",
  //                           fit: BoxFit.cover,
  //                           width: 20.w,
  //                           height: 10.h,
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(width: 3.w), // ✅ Spacing between Image & Text
  //                     // ✅ Message Content on the Right
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           // ✅ User Name
  //                           Text(
  //                             message?.user != null
  //                                 ? "${message!.user!.firstName ?? 'No Name'} ${message!.user!.lastName ?? ''}"
  //                                 : "Unknown User",
  //                             style: TextStyle(
  //                               fontSize: 17.sp,
  //                               fontWeight: FontWeight.bold,
  //                               fontFamily: AppConstants.manrope,
  //                               color: Colors.black,
  //                             ),
  //                           ),
  //                           SizedBox(height: 0.5.h),
  //                           Text(
  //                             "${message?.text ?? ''}",
  //                             maxLines: 3,
  //                             overflow: TextOverflow.ellipsis,
  //                             style: TextStyle(
  //                               fontSize: 16.sp,
  //                               fontFamily: AppConstants.manrope,
  //                               fontWeight: FontWeight.normal,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
  //                           SizedBox(height: 0.5.h),
  //                           // ✅ Date at Bottom Right
  //                           Align(
  //                             alignment: Alignment.bottomRight,
  //                             child: Text(
  //                               formatDateTime(message?.createdAt ?? ''),
  //                               style: TextStyle(
  //                                 fontSize: 15.sp,
  //                                 color: AppColors.black,
  //                                 fontFamily: AppConstants.manrope,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         );
  // }

  Widget _buildMessageCard() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.white));
    }

    if (messageBoardModal?.data == null || messageBoardModal!.data!.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 4.h),
        child: Center(
          child: Text(
            "No Messages Available",
            style: TextStyle(
              fontSize: 17.sp,
              fontFamily: AppConstants.manrope,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 18.5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount:
            (messageBoardModal?.data?.length ?? 0) > 2
                ? 2
                : messageBoardModal?.data?.length ?? 0,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          var message = messageBoardModal?.data?[index];
          int totalMessages = messageBoardModal?.data?.length ?? 0;
          return Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.all(12),
            width: (totalMessages == 1) ? 92.w : 85.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Image on the Left
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl:
                        (message?.file?.isNotEmpty == true)
                            ? message!.file![0]
                            : "",
                    fit: BoxFit.cover,
                    width: 20.w,
                    height: 20.h,
                    progressIndicatorBuilder:
                        (context, url, progress) => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.maincolor,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Image.network(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPwQOOsR9GZtqdjmrbJLzYGuY8XNpVuGd2vZxUNHJkgGg8aL6nIz2y5Sz7KSPc6yk4QDY&usqp=CAU",
                          fit: BoxFit.cover,
                          width: 20.w,
                          height: 10.h,
                        ),
                  ),
                ),
                SizedBox(width: 3.w),
                // ✅ Message Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message?.user != null
                            ? "${message!.user!.firstName ?? 'No Name'} ${message!.user!.lastName ?? ''}"
                            : "Unknown User",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppConstants.manrope,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "${message?.text ?? ''}",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: AppConstants.manrope,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          formatDateTime(message?.createdAt ?? ''),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.black,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void ParcelShowCount() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["type"] = "count";

    log("Delete account : $data");
    log("login Id is ${loginModel?.data?.user?.id}");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().ParcerShowCount(data);
          parcelShowCountModel = ParcelShowCountModel.fromJson(
            jsonDecode(response.body),
          );

          if (response.statusCode == 200 &&
              parcelShowCountModel?.status == 200) {
            log("data ave chee ${response.body}");

            setState(() {
              parcelCount = parcelShowCountModel?.data ?? 0;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void VisitorShowCount() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["count"] = "visitor";

    log("Visitor Data jay ce  $data");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().VisitorShowCount(data);
          visitorShowCountModel = VisitorShowCountModel.fromJson(
            jsonDecode(response.body),
          );

          if (response.statusCode == 200 &&
              visitorShowCountModel?.status == 200) {
            log("data ave chee ${response.body}");

            setState(() {
              visitorCount = visitorShowCountModel?.data ?? 0;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void ChatShowCount() {
    final Map<String, String> data = {};
    data["sender_id"] = "1";
    data["receiver_id"] = loginModel?.data?.user?.id.toString() ?? "";

    log("chat count data  $data");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().ChatShowCount(data);
          chatShowCountModal = ChatShowCountModal.fromJson(
            jsonDecode(response.body),
          );

          if (response.statusCode == 200 && chatShowCountModal?.status == 200) {
            log("data ave chee ${response.body}");

            setState(() {
              chatCount = chatShowCountModal?.data ?? 0;
              isLoading = false;
            });
            log("asdasdasdasd  ${chatCount}");
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
          }
        } catch (e) {
          if (mounted)
            setState(() {
              isLoading = false;
            });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  // void LatestVisitorApi() {
  //   final Map<String, String> data = {};
  //   data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
  //   data["lestesh_visitor"] = "lestesh_visitor";
  //
  //   log("Latest VIsitor data send $data");
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       try {
  //         var response = await HomeProvider().VisitorShowCount(data);
  //         latestVisitorModal =
  //             LatestVisitorModal.fromJson(jsonDecode(response.body));
  //         if (response.statusCode == 200 &&
  //             visitorShowCountModel?.status == 200) {
  //           log("Latest visitor data ave chee ${response.body}");
  //           setState(() {
  //             isLoading = false;
  //           });
  //         } else {
  //           setState(() {
  //             isLoading = false;
  //           });
  //           print({"Erorvfsdsdf${response.body}"});
  //         }
  //       } catch (e,stackTrace) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         print({"Error ave cjhee     $e}"});
  //         print({"Error ave cjhee     $stackTrace}"});
  //       }
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       log("errewfddddfs");
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }
  void LatestVisitorApi() async {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["lestesh_visitor"] = "lestesh_visitor";

    log("Latest Visitor data send $data");

    bool internet = await checkInternet();
    if (!internet) {
      setState(() {
        isLoading = false;
      });
      log("❌ No Internet Connection");
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      var response = await HomeProvider().LatestVisitor(data);

      if (response.statusCode == 200) {
        latestVisitorModal = LatestVisitorModal.fromJson(
          jsonDecode(response.body),
        );
        log("✅ Latest visitor data received: ${response.body}");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        log("❌ Failed response error ave che: ${response.statusCode}");
        log("❌ Response body: ${response.body}");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        // 422 Error Handle
        if (response.statusCode == 422) {
          buildErrorDialog(
            context,
            'Error',
            "Invalid Data Sent. Please Check Inputs.",
          );
        }
      }
    } catch (e, stackTrace) {
      log("❌ Exception occurred: $e");
      log("❌ StackTrace: $stackTrace");

      setState(() {
        isLoading = false;
      });

      // Error suppress, only log
      if (e.toString().contains("Failed to connect")) {
        log("❌ Server connection issue detected.");
      }
    }
  }

  MessageBoardApi() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    log("data jay chhe ${loginModel?.data?.user?.id.toString() ?? ""}");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().MessageBoardApi(data);
          messageBoardModal = MessageBoardModal.fromJson(
            jsonDecode(response.body),
          );

          if (response.statusCode == 200 && messageBoardModal?.status == 200) {
            log("message board api data ave cje${response.body}");

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
            log("Error ");
          }
        } catch (e) {
          log("Error $e");

          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? '',
    };
    print("RegisterApi : ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().ProfileApi(data).then((response) async {
          profileModel = ProfileModel.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200 && profileModel?.status == 200) {
            print("adfdsfsdf${response.body}");
            print(
              "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}",
            );
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            setState(() {
              isLoading = false;
            });
            log("Error");
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

  getnotificationCount() {
    // EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await NotificationProvider().NotificationApi(
            (loginModel?.data?.user?.id).toString(),
          );
          print("login user id : ${(loginModel?.data?.user?.id).toString()}");
          // EasyLoading.dismiss();
          if (response.statusCode == 200) {
            notificationmodel = NotificationModell.fromJson(
              json.decode(response.body),
            );
            print("Notification get: ${response.body}");
            setState(() {
              notificationCount = notificationmodel?.data?.totalCount ?? 0;
              isLoading = false;
            });
            print("notificationCount : ${notificationCount}");
          } else {
            log(" Failed response error ave che: ${response.statusCode}");
            log(" Response body: ${response.body}");
          }
        } catch (e) {
          //  EasyLoading.dismiss();
          log("Exception occurred: $e");
        }
      } else {
        //  EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Widget commonLoader() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.maincolor),
      ),
    );
  }
}
