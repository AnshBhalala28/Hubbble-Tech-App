import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/Screen/Booking/View/book_amenities.dart';
import 'package:wavee/Screen/Booking/View/booking_screen.dart';
import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
import 'package:wavee/Screen/Event/View/event_screen.dart';
import 'package:wavee/Screen/Manintenance/View/maintenance_view.dart';
import 'package:wavee/Screen/Parcel/parcel_Screen_View/parcel_View.dart';
import 'package:wavee/Screen/Visitor/View/visitorscreen.dart';
import 'package:wavee/Screen/homePage/Model/parcel_show_count.dart';
import 'package:wavee/Screen/homePage/Model/visitor_show_count_model.dart';
import 'package:wavee/Screen/homePage/Provider/homescreen_provider.dart';
import 'package:wavee/Screen/messageBoard/Model/Localpost_model.dart';
import 'package:wavee/Screen/messageBoard/View/messageboard.dart';
import 'package:wavee/Screen/orderScreen/View/order_screen_view.dart';
import 'package:wavee/Screen/viewProfile/View/Mybuilding_Screen.dart';
import 'package:wavee/Screen/viewProfile/View/viewprofile.dart';
import 'package:wavee/Screen/waveePet/provider/waveePetProvider.dart';
import 'package:wavee/comman/bottom_bar.dart';
import 'package:wavee/comman/check_inernet_connecty.dart';
import 'package:wavee/comman/error_dialog.dart';
import 'package:wavee/comman/loader.dart';
import 'package:wavee/comman/store_local.dart';

import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/custom_snack_bar.dart';
import '../../../comman/input_decoration.dart';
import '../../Authcation/Provider/authcation_provider.dart';
import '../../Booking/View/event_booking_screen.dart';
import '../../messageBoard/Model/Add_Post_Model.dart';
import '../../messageBoard/Provider/messsage_board_provider.dart';
import '../Model/chat_show_count_modal.dart';
import '../Model/message_board_modal.dart';

class HomePage extends StatefulWidget {
  int? selected;
  final String userName;

  HomePage({super.key, this.selected, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? fullName;
  int sel = 0;
  bool isLoading = false;
  bool isRegistration = false;
  int parcelCount = 0;
  int visitorCount = 0;
  int chatCount = 0;
  int notificationCount = 0;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isSending = false;
  final addPostFormkey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _title = TextEditingController();
  List<XFile> _images = [];

  // Background API Management
  Timer? _pollingTimer;
  bool _isApiCallInProgress = false;
  final Duration _pollingInterval = const Duration(seconds: 30);
  final Map<String, DateTime> _lastApiCallTimes = {};
  final Duration _apiCooldown = const Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    getdataloginData();
    MessageBoardApi();
    localpostapi();
    updateFCM1();

    // Start background polling for counts
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Initial call
    _fetchAllCounts();

    // Set up periodic polling
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      _fetchAllCounts();
    });
  }

  Future<void> _fetchAllCounts() async {
    if (_isApiCallInProgress) return;

    _isApiCallInProgress = true;

    try {
      await Future.wait([
        _fetchVisitorCount(),
        _fetchParcelCount(),
        _fetchChatCount(),
      ], eagerError: false); // Continue even if one fails
    } catch (e) {
      log("Error in background count fetching: $e");
    } finally {
      _isApiCallInProgress = false;
    }
  }

  bool _canMakeApiCall(String apiName) {
    final lastCall = _lastApiCallTimes[apiName];
    if (lastCall == null) return true;

    return DateTime.now().difference(lastCall) > _apiCooldown;
  }

  void _updateLastCallTime(String apiName) {
    _lastApiCallTimes[apiName] = DateTime.now();
  }

  Future<void> _fetchVisitorCount() async {
    if (!_canMakeApiCall('visitor')) return;

    try {
      final Map<String, String> data = {
        "user_id": loginModel?.data?.user?.id.toString() ?? "",
        "count": "visitor",
      };
      log("_fetchVisitorCount_fetchVisitorCount  $data");

      final response = await HomeProvider().visitorShowCountApi(data);
      visitorShowCountModel = VisitorShowCountModel.fromJson(response.data);

      if (response.statusCode == 200 && visitorShowCountModel?.status == 200) {
        if (mounted) {
          setState(() {
            visitorCount = visitorShowCountModel?.data ?? 0;
          });
        }
      }
      _updateLastCallTime('visitor');
    } catch (e) {
      log("Visitor count API error: $e");
    }
  }

  Future<void> _fetchParcelCount() async {
    if (!_canMakeApiCall('parcel')) return;

    try {
      final Map<String, String> data = {
        "user_id": loginModel?.data?.user?.id.toString() ?? "",
        "type": "count",
      };
      log("_fetchParcelCount_fetchParcelCount$data");

      final response = await HomeProvider().parcelShowCountApi(data);
      parcelShowCountModel = ParcelShowCountModel.fromJson(response.data);

      if (response.statusCode == 200 && parcelShowCountModel?.status == 200) {
        if (mounted) {
          setState(() {
            parcelCount = parcelShowCountModel?.data ?? 0;
          });
        }
      }
      _updateLastCallTime('parcel');
    } catch (e) {
      log("Parcel count API error: $e");
    }
  }

  Future<void> _fetchChatCount() async {
    if (!_canMakeApiCall('chat')) return;

    try {
      final Map<String, String> data = {
        "sender_id": "1",
        "receiver_id": loginModel?.data?.user?.id.toString() ?? "",
      };
      log("_fetchChatCount_fetchChatCount$data");

      final response = await HomeProvider().chatCountApi(data);
      chatShowCountModal = ChatShowCountModal.fromJson(response.data);

      if (response.statusCode == 200 && chatShowCountModal?.status == 200) {
        if (mounted && chatCount != (chatShowCountModal?.data ?? 0)) {
          setState(() {
            chatCount = chatShowCountModal?.data ?? 0;
          });
        }
      }
      _updateLastCallTime('chat');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 429) {
          log("⚠️ Chat count rate limited - applying cooldown");
          _lastApiCallTimes['chat'] = DateTime.now().add(const Duration(seconds: 30));
        }
      }
      log("Chat count API error: $e");
    }
  }

  // Keep original method names for compatibility
  void VisitorShowCount() {
    _fetchVisitorCount();
  }

  void ParcelShowCount() {
    _fetchParcelCount();

  }

  Future<void> ChatShowCount() async {
    await _fetchChatCount();
  }

  String formatPostDate(String? createdAt) {
    if (createdAt == null) return "";
    tz.initializeTimeZones();
    final ukTimeZone = tz.getLocation('Europe/London');
    final utcDate = DateTime.parse(createdAt);
    final postDateUk = tz.TZDateTime.from(utcDate, ukTimeZone);
    final nowUk = tz.TZDateTime.now(ukTimeZone);
    final postDateDay = DateTime(
      postDateUk.year,
      postDateUk.month,
      postDateUk.day,
    );
    final nowDay = DateTime(nowUk.year, nowUk.month, nowUk.day);

    final difference = nowDay.difference(postDateDay).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Yesterday";
    } else {
      return "$difference days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldkeyHome = GlobalKey<ScaffoldState>();
    return Scaffold(
      bottomNavigationBar: BottomBar(selected: 1),
      backgroundColor: AppColors.white,
      body: isLoading
          ? Loader()
          : Stack(
        children: [
          Positioned(
            top: 8.h,
            bottom: 10,
            right: 0,
            left: 0.w,
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 222,
                    width: 222,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/images/homescreen_map1.png",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Wavee Ai",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 22.sp,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 2.h),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Stack(
                          children: [
                            Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () {
                                  Get.to(ChatScreen(selected: 3));
                                },
                                child: Container(
                                  height: 17.h,
                                  width: 28.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.blackColor,
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 7.h,
                                        width: 15.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          color: AppColors.white,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            AppConstants.chat,
                                            height: 4.5.h,
                                            width: 4.5.h,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        "Chat",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                          AppConstants.manrope,
                                          color: AppColors.white,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 5,
                              top: 0.3.h,
                              child: Container(
                                alignment: Alignment.center,
                                height: 7.w,
                                width: 7.w,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  "$chatCount",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColors.black,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () {
                                  Get.to(const VisitorScreen());
                                },
                                child: Container(
                                  height: 17.h,
                                  width: 28.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.blackColor,
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 7.h,
                                        width: 15.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          color: AppColors.white,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            AppConstants.visitor,
                                            height: 4.5.h,
                                            width: 4.5.h,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        "Visitors",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                          AppConstants.manrope,
                                          color: AppColors.white,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 5,
                              top: 0.3.h,
                              child: Container(
                                alignment: Alignment.center,
                                height: 7.w,
                                width: 7.w,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  "$visitorCount",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColors.black,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () {
                                  Get.to(const ParcelScreen());
                                },
                                child: Container(
                                  height: 17.h,
                                  width: 28.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.blackColor,
                                    borderRadius: BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 7.h,
                                        width: 15.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          color: AppColors.white,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            AppConstants.parcel,
                                            height: 4.5.h,
                                            width: 4.5.h,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        "Parcels",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                          AppConstants.manrope,
                                          color: AppColors.white,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 5,
                              top: 0.3.h,
                              child: Container(
                                alignment: Alignment.center,
                                height: 7.w,
                                width: 7.w,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  "$parcelCount",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: AppColors.black,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 5.h,
            left: 0,
            right: 0,
            bottom: 0.h,
            child: DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.34,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(45),
                      topLeft: Radius.circular(45),
                    ),
                    color: Colors.white,
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(45),
                              topLeft: Radius.circular(45),
                              bottomLeft: Radius.circular(45),
                              bottomRight: Radius.circular(45),
                            ),
                            color: AppColors.bottomSheetBG,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  height: 1.h,
                                  width: 20.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xf0D9D9D9),
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                ).paddingOnly(top: 2.h, bottom: 2.h),
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Building Message Board",
                                    style: TextStyle(
                                      color: AppColors.black,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19.sp,
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ).paddingOnly(bottom: 1.h),
                              messageBoardModal?.data != null &&
                                  messageBoardModal!
                                      .data!
                                      .isNotEmpty
                                  ? Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.offWhite,
                                  borderRadius:
                                  BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors
                                              .bottomSheetBG,
                                          borderRadius:
                                          BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(
                                            12.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl:
                                                    messageBoardModal
                                                        ?.data?[0]
                                                        .user
                                                        ?.conciergeImage ??
                                                        "",
                                                    imageBuilder: (
                                                        context,
                                                        imageProvider,
                                                        ) =>
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration:
                                                          BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            image:
                                                            DecorationImage(
                                                              image:
                                                              imageProvider,
                                                              fit: BoxFit
                                                                  .cover,
                                                            ),
                                                          ),
                                                        ),
                                                    placeholder: (
                                                        context,
                                                        url,
                                                        ) =>
                                                    const SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: Center(
                                                        child:
                                                        CircularProgressIndicator(
                                                          strokeWidth:
                                                          2,
                                                        ),
                                                      ),
                                                    ),
                                                    errorWidget: (
                                                        context,
                                                        url,
                                                        error,
                                                        ) =>
                                                    const Icon(
                                                      Icons.error,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 2.w,
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            "${messageBoardModal?.data?[0].user?.firstName ?? ""} ${messageBoardModal?.data?[0].user?.lastName ?? ""}",
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            style:
                                                            TextStyle(
                                                              fontFamily:
                                                              AppConstants.manropeBold,
                                                              fontSize:
                                                              15.sp,
                                                              fontWeight:
                                                              FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 1.w,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            "• ${formatPostDate(messageBoardModal?.data?[0].createdAt)}",
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            style:
                                                            TextStyle(
                                                              fontSize:
                                                              14.sp,
                                                              color:
                                                              Colors.grey,
                                                              fontFamily:
                                                              AppConstants.manropeBold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 0.5.h,
                                              ),
                                              Text(
                                                messageBoardModal
                                                    ?.data?[0]
                                                    .title ??
                                                    "Join us at The Crumpets Cafe!",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.black,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                  fontFamily:
                                                  AppConstants
                                                      .manropeBold,
                                                ),
                                              ),
                                              Text(
                                                messageBoardModal
                                                    ?.data?[0]
                                                    .text ??
                                                    "",
                                                maxLines: 5,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  color: Colors.black,
                                                  fontFamily:
                                                  AppConstants
                                                      .AlbertSansLight,
                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).paddingOnly(bottom: 1.h)
                                  : Center(
                                child: Text(
                                  "No messages found.",
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    color: Colors.grey,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ).paddingOnly(
                                  top: 15.h,
                                  bottom: 10.h,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(() => Messageboard());
                                },
                                child: Center(
                                  child: Container(
                                    height: 4.h,
                                    width: 45.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(15),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        4.0,
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            AppConstants.messageBoard,
                                            width: 20,
                                            height: 20,
                                          ).paddingOnly(
                                            left: 9.w,
                                            right: 2.w,
                                          ),
                                          const Text(
                                            "View All",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFamily:
                                              AppConstants.manrope,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).paddingOnly(bottom: 1.h),
                                ),
                              ),
                            ],
                          ).paddingOnly(left: 5.w, right: 5.w),
                        ),
                        Text(
                          "My Home",
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: AppConstants.manrope,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                        Container(
                          height: 0.6.h,
                          width: 18.w,
                          decoration: BoxDecoration(
                            color: AppColors.blackColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w),
                        Text(
                          "Explore your building, submit maintenance requests and make bookings.",
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: AppConstants.AlbertSansLight,
                            fontWeight: FontWeight.w200,
                            fontSize: 16.sp,
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                        Row(
                          children: [
                            Expanded(
                              child: homeCard(
                                iconName: AppConstants.building,
                                name: "Building",
                                onTap: () {
                                  Get.to(
                                    MyBuilding_Screen(
                                      id: loginModel?.data?.user?.id,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: homeCard(
                                iconName: AppConstants.maintance,
                                name: "Maintenance",
                                onTap: () {
                                  Get.to(const MaintenanceScreen());
                                },
                              ),
                            ),
                          ],
                        ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                        Row(
                          children: [
                            Expanded(
                              child: homeCard(
                                iconName: AppConstants.amenities,
                                name: "Amenities",
                                onTap: () {
                                  Get.to(const BookAmenities_Screen());
                                },
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: homeCard(
                                iconName: AppConstants.booking,
                                name: "My Bookings",
                                onTap: () {
                                  Get.to(const BookingScreen());
                                },
                              ),
                            ),
                          ],
                        ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                        Container(
                          height: 0.1.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xf0e3e3e3),
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                        Text(
                          "Business Overview",
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: AppConstants.manrope,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                        Container(
                          height: 0.6.h,
                          width: 18.w,
                          decoration: BoxDecoration(
                            color: AppColors.blackColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w),
                        Row(
                          children: [
                            Expanded(
                              child: homeCard(
                                iconName: AppConstants.myOrder,
                                name: "My Orders",
                                onTap: () {
                                  Get.to(Order_Screen());
                                },
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: homeCard(
                                iconName: AppConstants.shopping,
                                name: "Shopping",
                                onTap: () {
                                  Get.to(CommunityScreen());
                                },
                              ),
                            ),
                          ],
                        ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                        Row(
                          children: [
                            Expanded(
                              child: homeCard(
                                iconName: AppConstants.events,
                                name: "Events",
                                onTap: () {
                                  Get.to(
                                    EventScreen(
                                      userId: loginModel?.data?.user?.id
                                          .toString() ??
                                          "",
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: homeCard(
                                iconName: AppConstants.eventBooking,
                                name: "Event Booking",
                                onTap: () {
                                  Get.to(const EventbookingScreen());
                                },
                              ),
                            ),
                          ],
                        ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                        Container(
                          height: 0.1.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xf0e3e3e3),
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                        Text(
                          "Information",
                          style: TextStyle(
                            color: AppColors.black,
                            fontFamily: AppConstants.manrope,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                        Container(
                          height: 0.6.h,
                          width: 18.w,
                          decoration: BoxDecoration(
                            color: AppColors.blackColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ).paddingOnly(left: 5.w, right: 5.w),
                        Row(
                          children: [
                            Expanded(
                              child: HomeProfileCard(
                                iconName: AppConstants.profile,
                                name: "Profile",
                                onTap: () {
                                  Get.to(
                                    ViewProfile(
                                      id: loginModel?.data?.user?.id ?? 0,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: HomeProfileCard(
                                iconName: AppConstants.Privacy,
                                name: "Privacy Policy",
                                onTap: () {
                                  launchPrivacyPolicyUrl();
                                },
                              ),
                            ),
                          ],
                        ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: HomeProfileCard(
                                iconName: AppConstants.terms,
                                name: "Terms & Conditions",
                                onTap: () {
                                  launchTermsUrl();
                                },
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: HomeProfileCard(
                                iconName: AppConstants.waveePet,
                                name: "Wavee Pet",
                                onTap: () {
                                  showWaveePet(context: context);
                                },
                              ),
                            ),
                          ],
                        ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (isSending)
            Container(
              color: Colors.black.withOpacity(0.3),
              child:  Center(child: Loader()),
            ),
          if (isRegistration)
            Container(
              color: Colors.black.withOpacity(0.3),
              child:  Center(child: Loader()),
            ),
        ],
      ),
    );
  }

  void launchTermsUrl() async {
    final Uri url = Uri.parse("https://wavee.ai/legal/terms-of-service");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void launchPrivacyPolicyUrl() async {
    final Uri url = Uri.parse("https://wavee.ai/legal/privacy-security");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void launchStore() async {
    final Uri url = Uri.parse(
      Platform.isIOS
          ? 'https://apps.apple.com/in/app/wavee-pet/id6746203457'
          : 'https://play.google.com/store/apps/details?id=com.pets.wavee',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget homeCard({
    required String iconName,
    required String name,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 12.h,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFfafafa),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconName,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 25.w,
                    child: Text(
                      name,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.normal,
                        fontFamily: AppConstants.manropeBold,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 20.sp, color: Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget HomeProfileCard({
    required String iconName,
    required String name,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 9.5.h,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFfafafa),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconName,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.normal,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  // Your existing methods for other functionality
  MessageBoardApi() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().messageBoardApi(data);
          messageBoardModal = MessageBoardModal.fromJson(response.data);

          if (response.statusCode == 200 && messageBoardModal?.status == 200) {
            setState(() {
              isLoading = false;
            });
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
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Widget commonLoader() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.maincolor),
      ),
    );
  }

  Future<void> _pickImages(Function setModalState) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      setModalState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  void addpostsheet(BuildContext parentContext, String userid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future.delayed(Duration.zero, () {
              if (isSending) {
                setModalState(() => isSending = false);
              }
            });

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: addPostFormkey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Add Post",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      const Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        cursorColor: AppColors.black,
                        controller: _title,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Title";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Title',
                          searchIcon: Icon(
                            Icons.contact_mail,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        cursorColor: AppColors.black,
                        controller: _descController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Description";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Description',
                          searchIcon: Icon(
                            Icons.contact_mail,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      batan(
                        title: "Choose Image",
                        route: () {
                          _pickImages(setModalState);
                        },
                        color: AppColors.maincolor,
                        fontcolor: Colors.white,
                        height: 5.h,
                        width: 50.w,
                        radius: 12.0,
                        iconData: Icons.image,
                        fontsize: 17.sp,
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      if (_images.isNotEmpty)
                        const Text(
                          "Selected Images",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (_images.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_images[index].path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: AppColors.maincolor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (addPostFormkey.currentState!.validate()) {
                              Addpostapi();
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(5),
                          child: Center(
                            child: Text(
                              "Add Post",
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void Addpostapi() {
    if (addPostFormkey.currentState!.validate()) {
      final Map<String, String> data = {
        'user_post_id': (loginModel?.data?.user?.id).toString(),
        'description': _descController.text.trim(),
        'title': _title.text.trim(),
      };
      setState(() {
        isSending = true;
      });
      checkInternet().then((internet) async {
        if (internet) {
          MessageBoardProvider()
              .addPostApiWithImages(bodyData: data, images: _images)
              .then((response) async {
            if (response.statusCode == 200) {
              add_Post_Model = Add_Post_Model.fromJson(response.data);
              _descController.clear();
              _images = [];
            } else if (response.statusCode == 429) {
            } else {}
            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          });
        } else {
          setState(() {
            isSending = false;
          });
          buildErrorDialog(context, 'Error', "Internet Required");
        }
      });
    }
  }

  localpostapi() {
    final Map<String, String> data = {
      'residentType': "residents",
      'user_id': loginModel?.data?.user?.id.toString() ?? '',
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await MessageBoardProvider().localPostApi(data);
          if (response.statusCode == 200) {
            localpost_model = Localpost_model.fromJson(response.data);

            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else if (response.statusCode == 429 || response.statusCode == 500) {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void updateFCM1() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken == null) {
      showSnackBar(
        title: "FCM Error",
        message: "Unable to fetch FCM token",
        backgoundColor: Colors.red,
        ColorText: Colors.white,
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["fcm_token"] = fcmToken;

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AuthProvider().updateFCM(data);
          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
            });
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

  Future<void> showWaveePet({required BuildContext context}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.maincolor.withOpacity(0.2),
                  child: Icon(
                    Icons.pets,
                    color: AppColors.maincolor,
                    size: 25.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Wavee Pet",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Do you want to create an account on Wavee Pets?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black54,
                    fontFamily: AppConstants.manrope,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "No",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maincolor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          SignupApi();
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
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
    );
  }

  Future<void> launchAppOrStore() async {
    const String customScheme = "wavee://home";
    const String playStoreUrl = "https://play.google.com/store/apps/details?id=com.pets.wavee&hl=en_IN";
    const String appStoreUrl = "https://apps.apple.com/in/app/wavee-pet/id6746203457";

    try {
      if (Platform.isAndroid) {
        final Uri appUri = Uri.parse(customScheme);
        final Uri playUri = Uri.parse(playStoreUrl);

        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(playUri, mode: LaunchMode.externalApplication);
        }
      } else if (Platform.isIOS) {
        final Uri appUri = Uri.parse(customScheme);
        final Uri storeUri = Uri.parse(appStoreUrl);

        if (await canLaunchUrl(appUri)) {
          await launchUrl(appUri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(storeUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (Platform.isAndroid) {
        await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
      } else if (Platform.isIOS) {
        await launchUrl(Uri.parse(appStoreUrl), mode: LaunchMode.externalApplication);
      }
    }
  }

  getdataloginData() async {
    Map<String, String?> credentials =
    await SaveDataLocal.getEmailAndPassword();
    String? savedEmail = credentials['email'];
    String? savedPassword = credentials['password'];
    String? savedName = credentials['name'];
    print('Saved Email: $savedEmail');
    print('Saved Password: $savedPassword');
    print('Saved Password: $savedName');
  }

  Future<void> SignupApi() async {
    String? savedEmail = await SaveDataLocal.getEmail();
    String? savedPassword = await SaveDataLocal.getPassword();
    final Map<String, String> data = {
      'name': loginModel?.data?.user?.fullName ?? "",
      'email': savedEmail.toString(),
      'password': savedPassword.toString(),
      'role': '4',
    };

    setState(() {
      isRegistration = true;
    });
    log("datadatadatadatadatadatadata$data");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await AuthProvider1().SignUpApi(data);

          Map<String, dynamic> responseData;
          try {
            responseData = jsonDecode(response.body);

            int apiStatus = responseData['status'] ?? 0;
            String apiMessage = responseData['message'] ?? "Unknown error";

            if (response.statusCode == 200 && apiStatus == 200) {
              showSnackBar(
                title: "SignUp",
                message:
                "Registration Successful \nYou can now login to Wavee Pets using your credentials.",
                backgoundColor: AppColors.maincolor,
                ColorText: AppColors.white,
                IconColor: AppColors.white,
                IconName: Icons.check_circle,
              );
              await Future.delayed(const Duration(seconds: 3));

              launchAppOrStore();
            } else {
              if (responseData.containsKey('data') &&
                  responseData['data'] is Map) {
                Map<String, dynamic> errorData = responseData['data'];

                String errorMessage = apiMessage;
                if (errorData.containsKey('email') &&
                    errorData['email'] is List &&
                    errorData['email'].isNotEmpty) {
                  errorMessage = errorData['email'][0];
                } else if (errorData.containsKey('name') &&
                    errorData['name'] is List &&
                    errorData['name'].isNotEmpty) {
                  errorMessage = errorData['name'][0];
                } else if (errorData.containsKey('password') &&
                    errorData['password'] is List &&
                    errorData['password'].isNotEmpty) {
                  errorMessage = errorData['password'][0];
                }

                showSnackBar(
                  title: "Sorry",
                  message: errorMessage,
                  backgoundColor: AppColors.maincolor,
                  ColorText: AppColors.white,
                );
              } else {
                showSnackBar(
                  title: "Sorry",
                  message: apiMessage,
                  backgoundColor: AppColors.redColor,
                  ColorText: AppColors.white,
                );
              }
            }
          } catch (jsonError) {
            showSnackBar(
              title: "Sorry",
              message: "Invalid response from server. Please try again.",
              backgoundColor: AppColors.redColor,
              ColorText: AppColors.white,
            );
          }
        } catch (e) {
          if (e.toString().contains("No Internet connection")) {
            showSnackBar(
              title: "Sorry",
              message: "No internet connection. Please check your network.",
              backgoundColor: Colors.red.shade400,
              ColorText: Colors.white,
            );
          } else {
            showSnackBar(
              title: "Sorry",
              message: "Registration failed. Please try again.",
              backgoundColor: Colors.red.shade400,
              ColorText: Colors.white,
            );
          }
        } finally {
          setState(() {
            isRegistration = false;
          });
        }
      } else {
        setState(() {
          isRegistration = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}