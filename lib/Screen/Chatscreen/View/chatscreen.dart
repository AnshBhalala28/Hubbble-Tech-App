import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Chatscreen/Model/Chatstorymodal.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/StoryView.dart';
import 'package:wavee/Screen/ViewProfile/Model/profile_model.dart';
import 'package:wavee/comman/bottom_bar.dart';
import 'package:wavee/comman/const.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/error_dialog.dart';
import '../../Message_screen/View/messageScreen.dart';
import '../../ViewProfile/Provider/profile_provider.dart';
import '../Model/chat_screen_model.dart';
import '../Provider/chat_screen_provider.dart';

class ChatScreen extends StatefulWidget {
  int? selected;
  int? selectedIndex;

  ChatScreen({super.key, this.selected, this.selectedIndex = 0});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> categories = [
    {"title": "Concierge"},
    {"title": "Business"},
  ];

  String AppLat = '';
  String AppLon = '';
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isLoading = true;
  ChatModel? chatModel;
  final GlobalKey<ScaffoldState> _scaffoldKey_messageboard =
      GlobalKey<ScaffoldState>();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        print("Location services are disabled.");
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          print("Location permission denied.");
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        print("Location permissions are permanently denied.");
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        AppLat = position.latitude.toString();
        AppLon = position.longitude.toString();
        print(
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}",
        );
      });
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(dateTime).toLocal();
      DateTime now = DateTime.now();

      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime dateToCompare = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      if (dateToCompare == today) {
        return "Today";
      } else if (dateToCompare == yesterday) {
        return "Yesterday";
      } else {
        return DateFormat("dd-MM-yyyy").format(parsedDate);
      }
    } catch (e) {
      return "Offline";
    }
  }

  String formatLastOnline(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";

    try {
      DateTime parsedDate = DateTime.parse(dateTime).toLocal();
      DateTime now = DateTime.now();

      Duration diff = now.difference(parsedDate);

      if (diff.inMinutes < 1) {
        return "Just now";
      } else if (diff.inMinutes < 60) {
        return "Last Online ${diff.inMinutes} minutes ago";
      } else if (diff.inHours < 24) {
        return "Last Online ${diff.inHours} hours ago";
      } else {
        DateTime today = DateTime(now.year, now.month, now.day);
        DateTime yesterday = today.subtract(const Duration(days: 1));
        DateTime dateToCompare = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );

        if (dateToCompare == today) {
          return "Today at ${DateFormat('hh:mm a').format(parsedDate)}";
        } else if (dateToCompare == yesterday) {
          return "Yesterday at ${DateFormat('hh:mm a').format(parsedDate)}";
        } else {
          return "Last Online \n${DateFormat("dd - MM - yyyy hh:mm a").format(parsedDate)}";
        }
      }
    } catch (e) {
      return "Offline";
    }
  }

  Timer? _timer;
  Offset _cartButtonPosition = Offset.zero;
  int cartCount = cartDetailsModel?.data?.length ?? 0;

  @override
  void initState() {
    super.initState();

    GetProfile();

    ChatApi();
    log('loginModel?.data?.user?.id ${loginModel?.data?.user?.id}');

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _getCurrentLocation().then((value) {
        ChatApi();
      });
    });
    _getCurrentLocation().then((value) {
      StoryApi();
    });
  }

  String selectedValue = 'Concierge';

  final List<String> options = ['Concierge', 'Businesses'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Bottom_bar(selected: 3),
      body: Container(
        width: double.infinity,
        height: Get.height,
        decoration: BoxDecoration(
          color: Color(0xfff0f0f0),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(45),
            topLeft: Radius.circular(45),
          ),
          border: Border.all(color: Color(0xffdfe0e6), width: 1),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 7.h, left: 5.5.w, right: 5.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "$selectedValue Chat",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: AppConstants.manrope,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 35.w,
                      height: 5.h,
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedValue,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                          style: TextStyle(
                            fontFamily: AppConstants.manrope,
                            fontSize: 12.sp,
                            color: Colors.black,
                          ),
                          items:
                              options.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 1.2.h,
                                    ),
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        color:
                                            value == 'Select option'
                                                ? Colors.grey
                                                : Colors.black,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                Container(
                  height: 0.6.h,
                  width: 18.w,
                  decoration: BoxDecoration(
                    color: AppColors.blackColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 3.h),
                if (selectedValue == "Businesses") ...[
                  chatStories?.data?.length == 0
                      ? SizedBox()
                      : Text(
                        "Business Spotlight",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: AppConstants.manrope,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  chatStories?.data?.length == 0
                      ? SizedBox()
                      : SizedBox(height: 1.h),
                  chatStories?.data?.length == 0
                      ? SizedBox()
                      : SizedBox(
                        height: 17.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: chatStories?.data?.length,
                          itemBuilder: (context, index) {
                            final item = chatStories?.data?[index];
                            return item?.posts?.isEmpty == true
                                ? Container()
                                : InkWell(
                                  onTap: () {
                                    if (item?.posts?.isNotEmpty == true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => StoryViewerScreen(
                                                userId:
                                                    chatStories
                                                        ?.data?[index]
                                                        .id ??
                                                    0,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 23.w,
                                    margin: EdgeInsets.only(right: 4.w),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: item?.logo ?? '',
                                            height: 9.h,
                                            width: 9.h,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            AppColors
                                                                .blackColor,
                                                      ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Image.asset(
                                                  'assets/images/waveeLogoShort.png',
                                                  height: 9.h,
                                                  width: 9.h,
                                                  fit: BoxFit.cover,
                                                ),
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          item?.businessName ?? '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                          },
                        ),
                      ),
                  chatStories?.data?.length == 0
                      ? SizedBox()
                      : SizedBox(height: 1.h),
                  chatStories?.data?.length == 0
                      ? SizedBox()
                      : Container(
                        height: 0.14,
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.batanColor),
                      ),
                  SizedBox(height: 2.h),
                  if (chatModel?.data?.businessUsers == null ||
                      chatModel?.data?.businessUsers == "" ||
                      chatModel?.data?.businessUsers == 0)
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.maincolor,
                      ),
                    ).paddingOnly(bottom: 2.h)
                  else ...[
                    Builder(
                      builder: (context) {
                        List businessUsersList =
                            chatModel?.data?.businessUsers ?? [];

                        List filteredList =
                            businessUsersList.where((user) {
                              String businessName =
                                  user.business?.businessName?.toLowerCase() ??
                                  "";
                              String lastMessage =
                                  user.lastMessage?.toLowerCase() ?? "";
                              String searchQueryLower =
                                  searchQuery.toLowerCase();
                              return searchQuery.isEmpty ||
                                  businessName.contains(searchQueryLower) ||
                                  lastMessage.contains(searchQueryLower);
                            }).toList();

                        if (filteredList.isEmpty) {
                          return Center(
                            child: Text(
                              "No Chats found",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (var i = 0; i < filteredList.length; i++)
                              Builder(
                                builder: (context) {
                                  var user = filteredList[i];
                                  String displayName =
                                      user.business?.businessName ??
                                      "Unknown Business";
                                  return InkWell(
                                    onTap: () {
                                      Get.to(
                                        MessageScreen(
                                          chatName: displayName,
                                          image: user.business?.logo,
                                          conciergeID: user.id.toString() ?? '',
                                          type: "business",
                                          chatStatus:
                                              user.business?.chatStatus ?? 0,
                                        ),
                                      );
                                      log(
                                        "Tapped Business User ID: ${user.id.toString() ?? ''}",
                                      );
                                      log(
                                        "Tapped Business User ID ${user.business?.chatStatus ?? 0}",
                                      );
                                      ChatApi();
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                            bottom: 1.5.h,
                                          ),
                                          padding: EdgeInsets.all(2.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 0.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      user.business?.logo
                                                          ?.toString() ??
                                                      "",
                                                  placeholder:
                                                      (context, url) =>
                                                          CircleAvatar(
                                                            radius: 24,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey
                                                                    .shade300,
                                                          ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Image.asset(
                                                        'assets/images/appLogo.png',
                                                        height: 9.h,
                                                        width: 9.h,
                                                        fit: BoxFit.cover,
                                                      ),
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(width: 3.w),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  user.isOnline ==
                                                                          "online"
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .red,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              border: Border.all(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                width: 1.5,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 1.w),
                                                          user.isOnline ==
                                                                  "online"
                                                              ? Text(
                                                                user.isOnline ??
                                                                    "Offline",
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                ),
                                                              )
                                                              : Text(
                                                                formatLastOnline(
                                                                  user?.lastOnlineAt
                                                                          .toString() ??
                                                                      "",
                                                                ),
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                ),
                                                              ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    displayName,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      color: Color(0XFF000000),
                                                    ),
                                                  ),
                                                  SizedBox(height: 0.5.h),
                                                  SizedBox(
                                                    width: 60.w,
                                                    child: Text(
                                                      user.lastMessage ??
                                                          'No message available',
                                                      // overflow:
                                                      //     TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                        color: Colors.grey,
                                                        fontSize: 15.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 2.w),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          right: 2.w,
                                          top: 1.5.h,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    _formatTime(
                                                      user?.lastOnlineAt
                                                              .toString() ??
                                                          "",
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color: Color(0xFF000000),
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    size: 15.sp,
                                                  ),
                                                ],
                                              ),
                                              if (user.unreadCount != 0)
                                                CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor:
                                                      AppColors.maincolor,
                                                  child: Center(
                                                    child: Text(
                                                      user.unreadCount
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                        fontSize: 14.sp,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
                if (selectedValue != "Businesses") ...[
                  Container(
                    padding: EdgeInsets.zero,
                    child:
                        isLoading
                            ? Container(
                              margin: EdgeInsets.only(top: 20.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.maincolor,
                                ),
                              ),
                            )
                            : chatModel?.data?.concierges?.isEmpty ?? true
                            ? Container(
                              child: Center(
                                child: Text(
                                  "No Concierges Available",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ),
                            )
                            : Builder(
                              builder: (context) {
                                List conciergeList =
                                    chatModel?.data?.concierges ?? [];

                                List filteredList =
                                    conciergeList.where((concierge) {
                                      return searchQuery.isEmpty ||
                                          (concierge.firstName
                                                  ?.toLowerCase()
                                                  .contains(
                                                    searchQuery.toLowerCase(),
                                                  ) ??
                                              false) ||
                                          (concierge.lastName
                                                  ?.toLowerCase()
                                                  .contains(
                                                    searchQuery.toLowerCase(),
                                                  ) ??
                                              false);
                                    }).toList();

                                if (filteredList.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No Concierge found",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ).paddingOnly(top: 20.h);
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    var concierge = filteredList[index];

                                    return GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          MessageScreen(
                                            chatName:
                                                "${concierge.firstName ?? ''} ${concierge.lastName ?? ''}",
                                            image: concierge.conciergeImage,
                                            conciergeID:
                                                concierge.id.toString() ?? '',
                                            type: "concierge",
                                            address:
                                                concierge.address ??
                                                'Not Available',
                                            phone:
                                                concierge.phoneNumber ??
                                                'Not Available',
                                            dob:
                                                concierge.dateOfBirth ??
                                                'Not Available',
                                            email:
                                                concierge.email ??
                                                'Not Available',
                                          ),
                                        );
                                        log(
                                          "Tapped Concierge ID: ${concierge.id.toString() ?? ''}",
                                        );
                                        ChatApi();
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                              bottom: 1.5.h,
                                            ),
                                            padding: EdgeInsets.all(2.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 0.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        concierge.conciergeImage
                                                            ?.toString() ??
                                                        "",
                                                    placeholder:
                                                        (context, url) =>
                                                            CircleAvatar(
                                                              radius: 24,
                                                              backgroundColor:
                                                                  Colors
                                                                      .grey
                                                                      .shade300,
                                                            ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Image.asset(
                                                          'assets/images/appLogo.png',
                                                          height: 9.h,
                                                          width: 9.h,
                                                          fit: BoxFit.cover,
                                                        ),
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(width: 3.w),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    //  Row(
                                                    //   children: [
                                                    //     Container(
                                                    //       width: 10,
                                                    //       height: 10,
                                                    //       decoration: BoxDecoration(
                                                    //         color: concierge?.livestatus == "Active" ? Colors.green : Colors.red,
                                                    //         shape: BoxShape.circle,
                                                    //         border: Border.all(color: Colors.white, width: 1.5),
                                                    //       ),
                                                    //     ),
                                                    //     SizedBox(width: 1.w),
                                                    //     Text(
                                                    //       concierge?.livestatus == "Active" ? "Online" : "Offline",
                                                    //       style: TextStyle(
                                                    //         fontSize: 14.sp,
                                                    //         fontWeight: FontWeight.bold,
                                                    //         fontFamily: AppConstants.manrope,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    Row(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 10,
                                                              height: 10,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    concierge.livestatus ==
                                                                            "Active"
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                                border: Border.all(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  width: 1.5,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 1.w,
                                                            ),
                                                            concierge.livestatus ==
                                                                    "Active"
                                                                ? Text(
                                                                  // user.isOnline ??
                                                                  //     "Offline",
                                                                  concierge.livestatus ==
                                                                          "Active"
                                                                      ? "Online"
                                                                      : "Offline",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                  ),
                                                                )
                                                                : Text(
                                                                  formatLastOnline(
                                                                    concierge
                                                                            ?.lastMessageTime
                                                                            .toString() ??
                                                                        "",
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                  ),
                                                                ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),

                                                    Text(
                                                      "${concierge.firstName ?? ""} ${concierge.lastName ?? ""}",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                        color: Color(
                                                          0XFF000000,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 0.5.h),
                                                    SizedBox(
                                                      width: 60.w,
                                                      child: Text(
                                                        concierge.lastMessage ??
                                                            'No message available',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                          color: Colors.grey,
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: 2.w),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: 2.w,
                                            top: 1.5.h,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      _formatTime(
                                                        concierge
                                                            .lastMessageTime,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        color: Color(
                                                          0xFF000000,
                                                        ),
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      size: 15.sp,
                                                    ),
                                                  ],
                                                ),
                                                concierge.unreadCount == 0
                                                    ? Container(
                                                      height: 1,
                                                      width: 1,
                                                    )
                                                    : CircleAvatar(
                                                      radius: 13,
                                                      backgroundColor:
                                                          AppColors.maincolor,
                                                      child: ClipOval(
                                                        child: Center(
                                                          child: Text(
                                                            concierge
                                                                .unreadCount
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ).marginOnly(bottom: 1.h),
                                    );
                                  },
                                );
                              },
                            ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ).paddingOnly(top: 8.h),
    );
  }

  void GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? '',
    };
    print("RegisterApi : ${data}");
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

  void ChatApi() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await ChatProvider().chatApi(
            loginModel?.data?.user?.id.toString() ?? "",
            AppLon,
            AppLat,
          );

          if (mounted) {
            setState(() {
              chatModel = ChatModel.fromJson(response.data);
              isLoading = false;
            });
          }

          if (response.statusCode == 200) {
            print("User Profile: ${profileModel?.data?.user?.profile}");
          } else {
            log("Error with status code: ${response.statusCode}");
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          log("Exception: $e");
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  Future<void> StoryApi() async {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "latitude": AppLat,
      "longitude": AppLon,
    };

    log("API Request: $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await ChatProvider().chatStoryApi(data);
          chatStories = ChatStoryModal.fromJson(response.data);
          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e, stackTrace) {
          log("Geeting Error ${stackTrace}");
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
}
