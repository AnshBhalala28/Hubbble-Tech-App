import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Ui/ChatScreen/modal/ChatStoryModal.dart';
import 'package:wavee/Ui/ChatScreen/modal/chatScreenModel.dart';
import 'package:wavee/Utils/themeButton.dart';

import '../../../Utils/bottomBar.dart';
import '../../../Utils/chatCounter.dart';
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../../CommunityScreen/view/storyView.dart';
import '../../HomeScreen/View/homePage.dart' hide LiveIndicator;
import '../../ViewProfile/modal/profile_model.dart';
import '../../messageScreen/View/messageScreen.dart';
import '../../viewProfile/Provider/profileProvider.dart';
import '../Provider/chatScreenProvider.dart';
import '../../../Utils/liveIndicator.dart';


class ChatScreen extends StatefulWidget {
  int? selected;
  int? selectedIndex;

  ChatScreen({super.key, this.selected, this.selectedIndex = 0});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        AppLat = position.latitude.toString();
        AppLon = position.longitude.toString();
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

      // સમય ફોર્મેટ કરવા માટે (દા.ત. 18:38)
      String timeStr = DateFormat("HH:mm").format(parsedDate);

      if (dateToCompare == today) {
        return timeStr; // આજે હોય તો ફક્ત સમય બતાવો
      } else if (dateToCompare == yesterday) {
        return "Yesterday";
      } else {
        // જૂની તારીખ હોય તો તારીખ બતાવો
        return DateFormat("dd-MM-yyyy").format(parsedDate);
      }
    } catch (e) {
      return "";
    }
  }

  Future<void> _initFirstLoad() async {
    setState(() {
      isLoading = true;
    });

    // 1. પહેલા location લો
    await _getCurrentLocation();

    // 2. પછી APIs call કરો
    await GetProfile();
    await StoryApi();
    await ChatApi();

    // 3. પછી timer start કરો
    _startTimer();
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
        return "Offline";
      } else if (diff.inHours < 24) {
        return "Offline";
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
          return "Offline";
        } else {
          return "Offline";
        }
      }
    } catch (e) {
      return "Offline";
    }
  }

  Timer? _timer;
  final GlobalCountsController countsController = Get.find();

  @override
  void initState() {
    super.initState();
    // ChatApi();
    // WidgetsBinding.instance.addObserver(this);
    // ChatApi();
    // initializeData();
    _initFirstLoad(); // 👈 new function
  }

  void initializeData() {
    _startTimer();
    GetProfile();
    StoryApi();
    ChatApi();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        ChatApi(); // હવે location already છે
      }
    });
  }

  void _restartTimer() {
    if (_timer == null || !_timer!.isActive) {
      _startTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground
      _restartTimer();
      ChatApi();
    } else if (state == AppLifecycleState.paused) {
      // App went to background
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  String selectedValue = 'Concierge';

  final List<String> options = ['Concierge', 'Businesses'];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => HomePage(selected: 1, userName: ''));
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
        bottomNavigationBar: Obx(
          () => BottomBar(
            selected: 3,
            chatCount: countsController.chatCount.value,
          ),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Text(
                  "$selectedValue Chat",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: AppConstants.manropeBold,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const ThemeToggleButton().paddingOnly(bottom: 2.h),
              ],
            ),
            SizedBox(height: 2.h),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      theme.isDark ? const Color(0xFF242424) : AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  // --- Box Shadow Implementation ---
                  boxShadow: [
                    BoxShadow(
                      color:
                          theme.isDark
                              ? Colors.black.withValues(
                                alpha: 0.5,
                              ) // Deeper shadow for dark mode
                              : Colors.grey.withValues(
                                alpha: 0.2,
                              ), // Soft shadow for light mode
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 4), // Moves shadow downwards
                    ),
                  ],
                  // ---------------------------------
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          selectedValue == "Concierge"
                              ? "${chatModel?.data?.concierges?.length.toString() ?? "0"} Contacts"
                              : "${chatModel?.data?.businessUsers?.length.toString() ?? "0"} Contacts",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: AppConstants.manrope,
                            color: theme.isDark ? Colors.grey : AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 35.w,
                          height: 5.h,
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            color:
                                theme.isDark
                                    ? Color(0xf035332F)
                                    : AppColors.lightText.withValues(alpha: .2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color:
                                  theme.isDark
                                      ? AppColors.batanColor
                                      : AppColors.lightText.withValues(
                                        alpha: .2,
                                      ),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor:
                                  theme.isDark
                                      ? const Color(0xFF333333)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              value: selectedValue,
                              isExpanded: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color:
                                    theme.isDark
                                        ? AppColors.batanColor
                                        : AppColors.lightText,
                              ),
                              style: TextStyle(
                                fontFamily: AppConstants.manrope,
                                fontSize: 12.sp,
                                color:
                                    theme.isDark
                                        ? AppColors.batanColor
                                        : AppColors.lightText,
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
                                                theme.isDark
                                                    ? Color(0xf0CBB880)
                                                    : AppColors.lightText,
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
                                log("dropdwon ma apui call thay che ");
                                ChatApi();
                              },
                            ),
                          ),
                        ),
                      ],
                    ).paddingOnly(left: 6.w, right: 6.w, top: 4.h, bottom: 2.h),
                    Container(
                      height: 0.2.h,
                      decoration: BoxDecoration(
                        color:
                            theme.isDark
                                ? Colors.white10
                                : Colors.grey.shade100,
                      ),
                    ),

                    if (selectedValue == "Businesses") ...[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              chatStories?.data?.length == 0 ||
                                      chatStories?.data?.length == null
                                  ? const SizedBox()
                                  : Text(
                                    "Business Spotlight",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontFamily: AppConstants.manropeBold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).paddingOnly(left: 2.w, top: 2.h),
                              chatStories?.data?.length == 0 ||
                                      chatStories?.data?.length == null
                                  ? const SizedBox()
                                  : Container(
                                    height: 0.5.h,
                                    width: 15.w,
                                    decoration: BoxDecoration(
                                      color:
                                          theme.isDark
                                              ? Color(0xf0CBB880)
                                              : AppColors.lightText,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                  ).paddingOnly(left: 2.w),
                              chatStories?.data?.length == 0 ||
                                      chatStories?.data?.length == null
                                  ? const SizedBox()
                                  : SizedBox(height: 1.h),
                              chatStories?.data?.length == 0 ||
                                      chatStories?.data?.length == null
                                  ? const SizedBox()
                                  : SizedBox(
                                    height: 17.h,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: chatStories?.data?.length,
                                      itemBuilder: (context, index) {
                                        final item = chatStories?.data?[index];
                                        return item?.posts?.isEmpty == true
                                            ? Container()
                                            : InkWell(
                                              onTap: () {
                                                if (item?.posts?.isNotEmpty ==
                                                    true) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            _,
                                                          ) => StoryViewerScreen(
                                                            userId:
                                                                chatStories
                                                                    ?.data?[index]
                                                                    .id ??
                                                                0,
                                                          ),
                                                    ),
                                                  ).then((value) {
                                                    _restartTimer();
                                                  });
                                                }
                                              },
                                              child: Container(
                                                width: 23.w,
                                                margin: EdgeInsets.only(
                                                  right: 4.w,
                                                ),
                                                child: Column(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            item?.logo ?? '',
                                                        height: 9.h,
                                                        width: 9.h,
                                                        fit: BoxFit.contain,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => const Center(
                                                              child: CircularProgressIndicator(
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
                                                              fit:
                                                                  BoxFit
                                                                      .contain,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 1.h),
                                                    Text(
                                                      item?.businessName ?? '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontFamily:
                                                            AppConstants
                                                                .manropeBold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                      },
                                    ),
                                  ),
                              chatStories?.data?.length == 0 ||
                                      chatStories?.data?.length == null
                                  ? const SizedBox()
                                  : SizedBox(height: 1.h),
                              chatStories?.data?.length == 0 ||
                                      chatStories?.data?.length == null
                                  ? const SizedBox()
                                  : Container(
                                    height: 0.14,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: AppColors.batanColor,
                                    ),
                                  ),
                              SizedBox(height: 2.h),
                              if (chatModel?.data?.businessUsers == null ||
                                  chatModel?.data?.businessUsers == "" ||
                                  chatModel?.data?.businessUsers == 0)
                                Center(child: Loader()).paddingOnly(bottom: 2.h)
                              else ...[
                                Builder(
                                  builder: (context) {
                                    List businessUsersList =
                                        chatModel?.data?.businessUsers ?? [];

                                    List filteredList =
                                        businessUsersList.where((user) {
                                          String businessName =
                                              user.business?.businessName
                                                  ?.toLowerCase() ??
                                              "";
                                          String lastMessage =
                                              user.lastMessage?.toLowerCase() ??
                                              "";
                                          String searchQueryLower =
                                              searchQuery.toLowerCase();
                                          return searchQuery.isEmpty ||
                                              businessName.contains(
                                                searchQueryLower,
                                              ) ||
                                              lastMessage.contains(
                                                searchQueryLower,
                                              );
                                        }).toList();

                                    if (filteredList.isEmpty) {
                                      return Center(
                                        child: Text(
                                          "No Chats Found",
                                          style: TextStyle(
                                            fontSize: 16.8.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontFamily:
                                                AppConstants.manropeBold,
                                          ),
                                        ),
                                      ).paddingOnly(top: 25.h);
                                    }
                                    return Column(
                                      children: [
                                        for (
                                          var i = 0;
                                          i < filteredList.length;
                                          i++
                                        )
                                          Builder(
                                            builder: (context) {
                                              var user = filteredList[i];
                                              String displayName =
                                                  user.business?.businessName ??
                                                  "Unknown Business";

                                              return GestureDetector(
                                                onTap: () {
                                                  _timer?.cancel();
                                                  Get.to(
                                                    MessageScreen(
                                                      chatName: displayName,
                                                      image:
                                                          user.business?.logo,
                                                      conciergeID:
                                                          user.id.toString() ??
                                                          '',
                                                      type: "business",
                                                      chatStatus:
                                                          user
                                                              .business
                                                              ?.chatStatus ??
                                                          0,
                                                      businessID:
                                                          user.business?.id
                                                              .toString() ??
                                                          "",
                                                    ),
                                                  )?.then((value) {
                                                    _restartTimer();
                                                    ChatApi();
                                                    StoryApi();
                                                    setState(() {});
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    bottom: 2.h,
                                                    left: 4.w,
                                                    right: 4.w,
                                                  ),
                                                  padding: EdgeInsets.all(4.w),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.isDark
                                                            ? const Color(
                                                              0xFF242424,
                                                            )
                                                            : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          25,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          theme.isDark
                                                              ? Color(
                                                                0xf0313131,
                                                              )
                                                              : Colors.grey
                                                                  .withValues(
                                                                    alpha: 0.2,
                                                                  ),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.03,
                                                            ),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      // --- બિઝનેસ લોગો અને ઓનલાઇન સ્ટેટસ ---
                                                      Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  30,
                                                                ),
                                                            child: CachedNetworkImage(
                                                              imageUrl:
                                                                  user
                                                                      .business
                                                                      ?.logo ??
                                                                  "",
                                                              height: 56,
                                                              width: 56,
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  (
                                                                    context,
                                                                    url,
                                                                  ) => Container(
                                                                    height: 56,
                                                                    width: 56,
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade100,
                                                                    child: const Center(
                                                                      child:
                                                                          CupertinoActivityIndicator(),
                                                                    ),
                                                                  ),
                                                              errorWidget:
                                                                  (
                                                                    context,
                                                                    url,
                                                                    error,
                                                                  ) => Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          12,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                      border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color:
                                                                            theme.isDark
                                                                                ? const Color(
                                                                                  0xFFCBB880,
                                                                                )
                                                                                : AppColors.lightText.withValues(
                                                                                  alpha:
                                                                                      .2,
                                                                                ),
                                                                      ),
                                                                    ),
                                                                    child: Image.asset(
                                                                      "assets/images/Applogo_remove_background.png",
                                                                      // fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            right: 1,
                                                            bottom: 1,
                                                            child:
                                                                user.isOnline ==
                                                                        "online"
                                                                    ? const LiveIndicator()
                                                                    : Container(
                                                                      height:
                                                                          13,
                                                                      width: 13,
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            Colors.grey,
                                                                        shape:
                                                                            BoxShape.circle,
                                                                        border: Border.all(
                                                                          color:
                                                                              theme.isDark
                                                                                  ? const Color(
                                                                                    0xFF2E2E2E,
                                                                                  )
                                                                                  : Colors.white,
                                                                          width:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(width: 4.w),

                                                      // --- નામ, સમય અને છેલ્લો મેસેજ ---
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    displayName,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          16.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          AppConstants
                                                                              .manropeBold,

                                                                      color:
                                                                          theme.isDark
                                                                              ? Colors.white
                                                                              : Colors.black,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _formatTime(
                                                                    user.lastMessageTime
                                                                        ?.toString(),
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13.sp,
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade500,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 0.5.h,
                                                            ),

                                                            // --- બિઝનેસ કેટેગરી બેજ ---
                                                            Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        2.5.w,
                                                                    vertical:
                                                                        0.9.h,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    theme.isDark
                                                                        ? Colors.white.withValues(
                                                                          alpha:
                                                                              0.05,
                                                                        )
                                                                        : const Color(
                                                                          0xFFF0F4FF,
                                                                        ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      15,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                "Business",
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                  color:
                                                                      theme.isDark
                                                                          ? const Color(
                                                                            0xFFCBB880,
                                                                          )
                                                                          : const Color(
                                                                            0xFF4A78FF,
                                                                          ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 0.8.h,
                                                            ),

                                                            Text(
                                                              user.lastMessage ??
                                                                  'No messages available',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    13.5.sp,
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade500,
                                                                fontFamily:
                                                                    AppConstants
                                                                        .manrope,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      // --- એરો આઇકોન અને અનરીડ કાઉન્ટ ---
                                                      SizedBox(width: 2.w),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios_rounded,
                                                            size: 14.sp,
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade400,
                                                          ),
                                                          if (user.unreadCount !=
                                                                  null &&
                                                              user.unreadCount !=
                                                                  0)
                                                            Container(
                                                              margin:
                                                                  EdgeInsets.only(
                                                                    top: 1.h,
                                                                  ),
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    6,
                                                                  ),
                                                              decoration: const BoxDecoration(
                                                                color:
                                                                    AppColors
                                                                        .maincolor,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                              child: Text(
                                                                user.unreadCount
                                                                    .toString(),
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (selectedValue != "Businesses") ...[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.zero,
                            child:
                                isLoading
                                    ? Container(
                                      margin: EdgeInsets.only(top: 20.h),
                                      child: Center(child: Loader()),
                                    )
                                    : chatModel?.data?.concierges?.isEmpty ??
                                        true
                                    ? Center(
                                      child: Text(
                                        "No Concierges Available",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontFamily: AppConstants.manropeBold,
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
                                                            searchQuery
                                                                .toLowerCase(),
                                                          ) ??
                                                      false) ||
                                                  (concierge.lastName
                                                          ?.toLowerCase()
                                                          .contains(
                                                            searchQuery
                                                                .toLowerCase(),
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
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                          ).paddingOnly(top: 20.h);
                                        }

                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemCount: filteredList.length,
                                          itemBuilder: (context, index) {
                                            var concierge = filteredList[index];
                                            return GestureDetector(
                                              onTap: () {
                                                _timer?.cancel();
                                                Get.to(
                                                  MessageScreen(
                                                    chatName:
                                                        "${concierge.firstName ?? ''} ${concierge.lastName ?? ''}",
                                                    image:
                                                        concierge
                                                            .conciergeImage,
                                                    conciergeID:
                                                        concierge.id
                                                            .toString() ??
                                                        '',
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
                                                )?.then((value) {
                                                  _restartTimer();
                                                  ChatApi();
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4.w),
                                                decoration: BoxDecoration(
                                                  color:
                                                      theme.isDark
                                                          ? const Color(
                                                            0xFF242424,
                                                          )
                                                          : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  border: Border.all(
                                                    color:
                                                        theme.isDark
                                                            ? Color(0xf0313131)
                                                            : Colors.grey
                                                                .withValues(
                                                                  alpha: 0.2,
                                                                ),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.03,
                                                          ),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // --- પ્રોફાઇલ પિક્ચર અને ઓનલાઇન સ્ટેટસ ---
                                                    Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                30,
                                                              ),
                                                          child: CachedNetworkImage(
                                                            imageUrl:
                                                                concierge
                                                                    .conciergeImage ??
                                                                "",
                                                            height: 56,
                                                            width: 56,
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Container(
                                                                  height: 56,
                                                                  width: 56,
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade100,
                                                                  child: const Center(
                                                                    child:
                                                                        CupertinoActivityIndicator(),
                                                                  ),
                                                                ),
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  error,
                                                                ) => Container(
                                                                  height: 56,
                                                                  width: 56,
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade200,
                                                                  child: const Icon(
                                                                    Icons
                                                                        .person,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 1,
                                                          bottom: 1,
                                                          child:
                                                              concierge.livestatus ==
                                                                      "Active"
                                                                  ? LiveIndicator()
                                                                  : Container(
                                                                    height: 13,
                                                                    width: 13,
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          Colors
                                                                              .grey,
                                                                      shape:
                                                                          BoxShape
                                                                              .circle,
                                                                      border: Border.all(
                                                                        color:
                                                                            theme.isDark
                                                                                ? const Color(
                                                                                  0xFF2E2E2E,
                                                                                )
                                                                                : Colors.white,
                                                                        width:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(width: 4.w),

                                                    // --- નામ, સમય, કેટેગરી અને મેસેજ ---
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                "${concierge.firstName ?? ""} ${concierge.lastName ?? ""}",
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manropeBold,
                                                                  color:
                                                                      theme.isDark
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              Text(
                                                                _formatTime(
                                                                  concierge
                                                                      ?.lastMessageTime
                                                                      .toString(),
                                                                ),
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  color:
                                                                      Colors
                                                                          .grey
                                                                          .shade500,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 0.5.h,
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      2.5.w,
                                                                  vertical:
                                                                      0.9.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  theme.isDark
                                                                      ? Colors
                                                                          .white
                                                                          .withValues(
                                                                            alpha:
                                                                                0.05,
                                                                          )
                                                                      : const Color(
                                                                        0xFFF0F4FF,
                                                                      ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    15,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              "Personal Concierge",
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                fontFamily:
                                                                    AppConstants
                                                                        .manrope,
                                                                color:
                                                                    theme.isDark
                                                                        ? const Color(
                                                                          0xFFCBB880,
                                                                        )
                                                                        : const Color(
                                                                          0xFF4A78FF,
                                                                        ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 0.8.h,
                                                          ),
                                                          Text(
                                                            concierge
                                                                    .lastMessage ??
                                                                'No messages available',
                                                            style: TextStyle(
                                                              fontSize: 13.5.sp,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade500,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // --- જમણી બાજુનો એરો અને અનરીડ કાઉન્ટ ---
                                                    SizedBox(width: 2.w),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          size: 14.sp,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade400,
                                                        ),
                                                        // Unread Count Logic
                                                        if (concierge
                                                                    .unreadCount !=
                                                                null &&
                                                            concierge
                                                                    .unreadCount! >
                                                                0)
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                  top: 1.h,
                                                                ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  theme.isDark
                                                                      ? const Color(
                                                                        0xFFCBB880,
                                                                      )
                                                                      : AppColors
                                                                          .maincolor,
                                                              // લાલ અથવા તમારો થીમ કલર
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                            constraints:
                                                                BoxConstraints(
                                                                  minWidth:
                                                                      18.sp,
                                                                  minHeight:
                                                                      18.sp,
                                                                ),
                                                            child: Center(
                                                              child: Text(
                                                                concierge
                                                                    .unreadCount
                                                                    .toString(),
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ).paddingOnly(
                                              left: 3.w,
                                              right: 3.w,
                                              top: 2.h,
                                            );
                                          },
                                        );
                                      },
                                    ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ).paddingOnly(top: 5.h, left: 4.w, right: 4.w),
      ),
    );
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

  ChatApi() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await ChatProvider().chatApi(
            loginModel?.data?.user?.id.toString() ?? "",
            AppLon,
            AppLat,
          );
          chatModel = ChatModel.fromJson(response.data);

          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }

          if (response.statusCode == 200) {
            chatModel = ChatModel.fromJson(response.data);

            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  Future<void> StoryApi() async {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "latitude": AppLat,
      "longitude": AppLon,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await ChatProvider().chatStoryApi(data);
          chatStories = ChatStoryModal.fromJson(response.data);
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            setState(() {
              isLoading = false;
            });
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
}

