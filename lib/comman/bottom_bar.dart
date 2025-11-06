// import 'dart:async';
// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wavee/Screen/Add%20to%20Cart/view/add_to_cart_view.dart';
// import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
// import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
// import 'package:wavee/Screen/homePage/Model/chat_show_count_modal.dart';
// import 'package:wavee/Screen/homePage/Provider/homescreen_provider.dart';
// import 'package:wavee/comman/check_inernet_connecty.dart';
// import 'package:wavee/comman/const.dart';
//
// import '../Screen/homePage/View/homenewpage.dart';
// import 'colors.dart';
//
// class BottomBar extends StatefulWidget {
//   int? selected;
//
//   BottomBar({super.key, this.selected});
//
//   @override
//   State<BottomBar> createState() => _BottomBarState();
// }
//
// class _BottomBarState extends State<BottomBar> with WidgetsBindingObserver, RouteAware {
//   int chatCount = 0;
//   bool isLoading = false;
//   Timer? _timer;
//   bool _isTimerActive = false;
//   DateTime? _lastApiCallTime;
//   bool _isPausedForRateLimit = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeTimer();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _setupRouteObserver();
//   }
//
//   void _setupRouteObserver() {
//   }
//
//   @override
//   void didPush() {
//     _resumeTimer();
//   }
//
//   @override
//   void didPopNext() {
//     // Called when returning to this route from another route
//     _resumeTimer();
//   }
//
//   @override
//   void didPushNext() {
//     // Called when a new route is pushed over this one
//     _pauseTimer();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     print('BottomBar AppLifecycleState: $state');
//     switch (state) {
//       case AppLifecycleState.resumed:
//         _resumeTimer();
//         break;
//       case AppLifecycleState.paused:
//       case AppLifecycleState.inactive:
//         _pauseTimer();
//         break;
//       case AppLifecycleState.detached:
//         _stopTimer();
//         break;
//       case AppLifecycleState.hidden:
//         // TODO: Handle this case.
//         throw UnimplementedError();
//     }
//   }
//
//   void _initializeTimer() {
//     // Start with immediate data fetch
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ChatShowCount();
//       _startTimer();
//     });
//   }
//
//   void _startTimer() {
//     if (_isTimerActive) return;
//
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (mounted && _isTimerActive && !_isPausedForRateLimit) {
//         _fetchChatCount();
//       }
//     });
//     _isTimerActive = true;
//     print('BottomBar Timer started');
//   }
//
//   void _stopTimer() {
//     _timer?.cancel();
//     _timer = null;
//     _isTimerActive = false;
//     print('BottomBar Timer stopped');
//   }
//
//   void _pauseTimer() {
//     if (_isTimerActive) {
//       _isTimerActive = false;
//       print('BottomBar Timer paused');
//     }
//   }
//
//   void _resumeTimer() {
//     if (!_isTimerActive) {
//       _isTimerActive = true;
//       print('BottomBar Timer resumed');
//
//       // Immediately fetch fresh data when resuming
//       if (mounted && !_isPausedForRateLimit) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _fetchChatCount();
//         });
//       }
//     }
//   }
//
//   void _fetchChatCount() {
//     if (_shouldThrottle()) return;
//
//     ChatShowCount();
//   }
//
//   bool _shouldThrottle() {
//     final now = DateTime.now();
//
//     // If we're paused for rate limiting, check if we can resume
//     if (_isPausedForRateLimit) {
//       if (_lastApiCallTime != null &&
//           now.difference(_lastApiCallTime!).inSeconds > 60) {
//         _isPausedForRateLimit = false;
//         print('BottomBar Rate limit pause ended, resuming API calls');
//         return false;
//       }
//       return true;
//     }
//
//     // Normal throttling - don't call if less than 2 seconds passed
//     if (_lastApiCallTime != null &&
//         now.difference(_lastApiCallTime!).inSeconds < 2) {
//       return true;
//     }
//
//     _lastApiCallTime = now;
//     return false;
//   }
//
//   void _handleRateLimit() {
//     if (!_isPausedForRateLimit) {
//       _isPausedForRateLimit = true;
//       _lastApiCallTime = DateTime.now();
//       print('BottomBar Rate limit detected, pausing API calls for 60 seconds');
//
//       // Schedule automatic resume after 60 seconds
//       Timer(const Duration(seconds: 60), () {
//         if (mounted) {
//           _isPausedForRateLimit = false;
//           print('BottomBar Rate limit pause ended automatically');
//         }
//       });
//     }
//   }
//
//   void _navigateToScreen(Widget screen) {
//     _pauseTimer(); // Pause when navigating away
//     Get.offAll(() => screen)?.then((_) {
//       // Timer will be resumed when the screen that contains this BottomBar becomes active again
//       // The RouteAware callbacks will handle this automatically
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white,
//       ),
//       height: Platform.isAndroid ? 10.h : 12.h,
//       width: MediaQuery.of(context).size.width,
//       margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavItem(
//             svgIconPath: AppConstants.home,
//             label: "Home",
//             index: 1,
//             onTap: () => _navigateToScreen(HomePage(selected: 1, userName: "")),
//           ),
//           _buildNavItem(
//             svgIconPath: AppConstants.community,
//             label: "Community",
//             index: 2,
//             onTap: () => _navigateToScreen(CommunityScreen(selected: 2)),
//           ),
//           _buildNavItemWithBadge(
//             svgIconPath: AppConstants.chat1,
//             label: "Chat",
//             index: 3,
//             badgeCount: chatCount,
//             onTap: () => _navigateToScreen(ChatScreen(selected: 3)),
//           ),
//           _buildNavItem(
//             svgIconPath: AppConstants.cart,
//             label: "My Cart",
//             index: 4,
//             onTap: () => _navigateToScreen(AddToCartView(selected: 4, fromBottomBar: true)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItem({
//     required String svgIconPath,
//     required String label,
//     required int index,
//     required Function() onTap,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         if (widget.selected != index) {
//           setState(() => widget.selected = index);
//           onTap();
//         }
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset(
//             svgIconPath,
//             height: 22.sp,
//             width: 22.sp,
//             color: widget.selected == index ? AppColors.maincolor : Colors.grey,
//           ),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: widget.selected == index ? AppColors.maincolor : Colors.grey,
//               fontSize: 14.5.sp,
//               fontFamily: widget.selected == index
//                   ? AppConstants.manropeBold
//                   : AppConstants.manrope,
//             ),
//           ),
//           SizedBox(height: 0.4.h),
//           Container(
//             height: 0.4.h,
//             width: 11.w,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(100),
//               color: widget.selected == index
//                   ? AppColors.maincolor
//                   : Colors.transparent,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNavItemWithBadge({
//     required String svgIconPath,
//     required String label,
//     required int index,
//     required int badgeCount,
//     required Function() onTap,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         if (widget.selected != index) {
//           setState(() => widget.selected = index);
//           onTap();
//         }
//       },
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SvgPicture.asset(
//                 svgIconPath,
//                 height: 22.sp,
//                 width: 22.sp,
//                 color: widget.selected == index ? AppColors.maincolor : Colors.grey,
//               ),
//               Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: widget.selected == index ? AppColors.maincolor : Colors.grey,
//                   fontSize: 14.5.sp,
//                   fontFamily: widget.selected == index
//                       ? AppConstants.manropeBold
//                       : AppConstants.manrope,
//                 ),
//               ),
//               SizedBox(height: 0.4.h),
//               Container(
//                 height: 0.4.h,
//                 width: 11.w,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(100),
//                   color: widget.selected == index
//                       ? AppColors.maincolor
//                       : Colors.transparent,
//                 ),
//               ),
//             ],
//           ),
//           if (badgeCount > 0)
//             Positioned(
//               top: 1.5.h,
//               right: 0.2.w,
//               child: Container(
//                 padding: EdgeInsets.all(4.sp),
//                 decoration: BoxDecoration(
//                   color: widget.selected == index ? AppColors.maincolor : Colors.grey,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 1.5.sp),
//                 ),
//                 constraints: BoxConstraints(minWidth: 18.sp, minHeight: 18.sp),
//                 child: Text(
//                   badgeCount > 99 ? '99+' : badgeCount.toString(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   ChatShowCount() async {
//     if (_isPausedForRateLimit) return;
//
//     final Map<String, String> bodyData = {};
//     bodyData['sender_id'] = '1';
//     bodyData['receiver_id'] = loginModel?.data?.user?.id.toString() ?? "";
//     print("BottomBar ChatCount data: $bodyData");
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         HomeProvider().chatCountApi(bodyData).then((response) async {
//           if (response.statusCode == 429) {
//             _handleRateLimit();
//             return;
//           }
//
//           if (response.statusCode == 200) {
//             chatShowCountModal = ChatShowCountModal.fromJson(response.data);
//             print("BottomBar ChatCount response: ${response.data}");
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//                 chatCount = chatShowCountModal?.data ?? 0;
//               });
//             }
//           } else if (response.statusCode == 404 || response.statusCode == 429) {
//             chatShowCountModal = ChatShowCountModal.fromJson(response.data);
//             print("BottomBar ChatCount error response: ${response.data}");
//
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//                 chatCount = chatShowCountModal?.data ?? 0;
//               });
//             }
//
//             if (response.statusCode == 429) {
//               _handleRateLimit();
//             }
//           } else if (response.statusCode == 401) {
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//               });
//             }
//           } else {
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//               });
//             }
//           }
//         }).catchError((error) {
//           print('BottomBar ChatCount error: $error');
//           if (error is DioException && error.response?.statusCode == 429) {
//             _handleRateLimit();
//           }
//         });
//       } else {
//         if (mounted) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _stopTimer();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
// }
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Add%20to%20Cart/view/add_to_cart_view.dart';
import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
import 'package:wavee/comman/check_inernet_connecty.dart';
import 'package:wavee/comman/const.dart';

import '../Screen/homePage/View/homenewpage.dart';
import 'colors.dart';

class BottomBar extends StatefulWidget {
  final int? selected;
  final int? chatCount;
  final VoidCallback? onChatCountUpdate;

  const BottomBar({
    super.key,
    this.selected,
    this.chatCount = 0,
    this.onChatCountUpdate,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _chatCount = 0;

  @override
  void initState() {
    super.initState();
    _chatCount = widget.chatCount ?? 0;
  }

  @override
  void didUpdateWidget(covariant BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chatCount != oldWidget.chatCount) {
      setState(() {
        _chatCount = widget.chatCount ?? 0;
      });
    }
  }

  void _navigateToScreen(Widget screen) {
    Get.offAll(() => screen);
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
            onTap: () => _navigateToScreen(HomePage(selected: 1, userName: "")),
          ),
          _buildNavItem(
            svgIconPath: AppConstants.community,
            label: "Community",
            index: 2,
            onTap: () => _navigateToScreen(CommunityScreen(selected: 2)),
          ),
          _buildNavItemWithBadge(
            svgIconPath: AppConstants.chat1,
            label: "Chat",
            index: 3,
            badgeCount: _chatCount,
            onTap: () => _navigateToScreen(ChatScreen(selected: 3)),
          ),
          _buildNavItem(
            svgIconPath: AppConstants.cart,
            label: "My Cart",
            index: 4,
            onTap: () => _navigateToScreen(AddToCartView(selected: 4, fromBottomBar: true,isAmend: false)),
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
              color: widget.selected == index ? AppColors.maincolor : Colors.grey,
              fontSize: 14.5.sp,
              fontFamily: widget.selected == index
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
              color: widget.selected == index
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
                color: widget.selected == index ? AppColors.maincolor : Colors.grey,
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.selected == index ? AppColors.maincolor : Colors.grey,
                  fontSize: 14.5.sp,
                  fontFamily: widget.selected == index
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
                  color: widget.selected == index
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
              child: Container(
                padding: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                  color: widget.selected == index ? AppColors.maincolor : Colors.grey,
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
}