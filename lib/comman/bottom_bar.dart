import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Add%20to%20Cart/view/add_to_cart_view.dart';
import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
import 'package:wavee/Screen/homePage/Model/chat_show_count_modal.dart';
import 'package:wavee/Screen/homePage/Provider/homescreen_provider.dart';
import 'package:wavee/comman/check_inernet_connecty.dart';
import 'package:wavee/comman/const.dart';

import '../Screen/homePage/View/homenewpage.dart';
import 'colors.dart';

class BottomBar extends StatefulWidget {
  int? selected;

  BottomBar({super.key, this.selected});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> with WidgetsBindingObserver {
  int chatCount = 0;
  bool isLoading = false;
  Timer? timer;
  DateTime? lastCallTime;
  bool isPausedForRateLimit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // startPolling();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // notificationap();
      ChatShowCount();
    });
  }

  void startPolling() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isPausedForRateLimit) {
        ChatShowCount();
        log(
          "isPausedForRateLimitisPausedForRateLimitisPausedForRateLimitisPausedForRateLimit",
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // startPolling();
    } else if (state == AppLifecycleState.paused) {
      timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      height: Platform.isAndroid ? 10.h : 12.h,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            svgIconPath: AppConstants.home,
            label: "Home",
            index: 1,
            onTap: () => Get.offAll(() => HomePage(selected: 1, userName: "")),
          ),
          _buildNavItem(
            svgIconPath: AppConstants.community,
            label: "Community",
            index: 2,
            onTap: () => Get.offAll(() => CommunityScreen(selected: 2)),
          ),
          _buildNavItemWithBadge(
            svgIconPath: AppConstants.chat1,
            label: "Chat",
            index: 3,
            badgeCount: chatCount,
            onTap: () => Get.offAll(() => ChatScreen(selected: 3)),
          ),
          _buildNavItem(
            svgIconPath: AppConstants.cart,
            label: "My Cart",
            index: 4,
            onTap:
                () => Get.offAll(
                  () => AddToCartView(selected: 4, fromBottomBar: true),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String svgIconPath,
    required String label,
    required int index,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.selected != index) {
          setState(() => widget.selected = index);
          onTap();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgIconPath,
            height: 22.sp,
            width: 22.sp,
            color: widget.selected == index ? AppColors.maincolor : Colors.grey,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  widget.selected == index ? AppColors.maincolor : Colors.grey,
              fontSize: 14.5.sp,
              fontFamily:
                  widget.selected == index
                      ? AppConstants.manropeBold
                      : AppConstants.manrope,
            ),
          ),
          SizedBox(height: 0.4.h),
          Container(
            height: 0.4.h,
            width: 11.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color:
                  widget.selected == index
                      ? AppColors.maincolor
                      : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemWithBadge({
    required String svgIconPath,
    required String label,
    required int index,
    required int badgeCount,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.selected != index) {
          setState(() => widget.selected = index);
          onTap();
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgIconPath,
                height: 22.sp,
                width: 22.sp,
                color:
                    widget.selected == index
                        ? AppColors.maincolor
                        : Colors.grey,
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      widget.selected == index
                          ? AppColors.maincolor
                          : Colors.grey,
                  fontSize: 14.5.sp,
                  fontFamily:
                      widget.selected == index
                          ? AppConstants.manropeBold
                          : AppConstants.manrope,
                ),
              ),
              SizedBox(height: 0.4.h),
              Container(
                height: 0.4.h,
                width: 11.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color:
                      widget.selected == index
                          ? AppColors.maincolor
                          : Colors.transparent,
                ),
              ),
            ],
          ),
          if (badgeCount > 0)
            Positioned(
              top: 1.5.h,
              right: 0.2.w,
              // left: 1.w,
              child: Container(
                padding: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                  color:
                      widget.selected == index
                          ? AppColors.maincolor
                          : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5.sp),
                ),
                constraints: BoxConstraints(minWidth: 18.sp, minHeight: 18.sp),
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> ChatShowCount1() async {
    if (lastCallTime != null &&
        DateTime.now().difference(lastCallTime!) < const Duration(seconds: 3)) {
      return;
    }
    lastCallTime = DateTime.now();

    bool internet = await checkInternet();
    if (!internet) return;

    try {
      final Map<String, String> data = {
        "sender_id": "1",
        "receiver_id": loginModel?.data?.user?.id.toString() ?? "",
      };

      var response = await HomeProvider().chatCountApi(data);
      chatShowCountModal = ChatShowCountModal.fromJson(response.data);

      if (mounted &&
          response.statusCode == 200 &&
          chatShowCountModal?.status == 200) {
        if (chatCount != (chatShowCountModal?.data ?? 0)) {
          setState(() {
            chatCount = chatShowCountModal?.data ?? 0;
          });
        }
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429) {
        log("⚠️ Rate limit hit — pausing 10 sec...");
        log("⚠️ Bottom Bar Erroor...");
        isPausedForRateLimit = true;

        // Pause polling for 10 seconds when API blocks
        Future.delayed(const Duration(seconds: 10), () {
          isPausedForRateLimit = false;
        });
      } else {
        log("⚠️ Chat count fetch failed: $e");
      }
    }
  }

  ChatShowCount() async {
    final Map<String, String> bodyData = {};
    bodyData['sender_id'] = '1';
    bodyData['receiver_id'] = loginModel?.data?.user?.id.toString() ?? "";
    print("dentalchatdata ${bodyData}");
    checkInternet().then((internet) async {
      if (internet) {
        HomeProvider().chatCountApi(bodyData).then((response) async {
          chatShowCountModal = ChatShowCountModal.fromJson(response.data);
          if (response.statusCode == 200) {
            print("Notification Count data ${response.data}");
            if (mounted) {
              setState(() {
                isLoading = false;
                chatCount = chatShowCountModal?.data ?? 0;
              });
            }
            ;
          }
          if (response.statusCode == 404 || response.statusCode == 429) {
            chatShowCountModal = ChatShowCountModal.fromJson(response.data);
            print("Notification Count data ${response.data}");

            if (mounted) {
              setState(() {
                isLoading = false;
                chatCount = chatShowCountModal?.data ?? 0;
              });
            }
          } else if (response.statusCode == 401) {
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
        });
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        // showCustomErrorSnackbar(
        //   title: 'Internet Error',
        //   message: 'Internet Required',
        // );
      }
    });
  }
}
