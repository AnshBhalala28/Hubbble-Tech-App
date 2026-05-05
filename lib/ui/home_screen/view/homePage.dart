import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/services/weatherModal.dart';
import 'package:wavee/services/weatherService.dart';
import 'package:wavee/ui/accommodation/view/viewAccommodation.dart';
import 'package:wavee/ui/booking/view/eventBookingScreen.dart';
import 'package:wavee/ui/booking/view/bookAmenities.dart';
import 'package:wavee/ui/booking/view/bookingScreen.dart';
import 'package:wavee/ui/community_screen/view/communityScreen.dart';
import 'package:wavee/ui/contracts/view/viewContracts.dart';
import 'package:wavee/ui/event/view/eventScreen.dart';
import 'package:wavee/ui/event_details/view/viewEventDetailsScreen.dart';
import 'package:wavee/ui/home_screen/modal/chatShowCountModal.dart';
import 'package:wavee/ui/home_screen/modal/messageBoardModal.dart';
import 'package:wavee/ui/home_screen/modal/parcelShowCount.dart';
import 'package:wavee/ui/home_screen/modal/visitorShowCountModel.dart';
import 'package:wavee/ui/maintenance/view/maintenanceView.dart';
import 'package:wavee/ui/message_board/modal/Localpost_model.dart';
import 'package:wavee/ui/my_meetings/view/myMeetingScreen.dart';
import 'package:wavee/ui/parcel/view/parcelViewScreen.dart';
import 'package:wavee/ui/view_profile/modal/profile_model.dart';
import 'package:wavee/ui/view_profile/view/viewProfile.dart';
import 'package:wavee/ui/visitor/view/visitorsScreen.dart';
import 'package:wavee/ui/authentication/modal/login_model.dart';
import 'package:wavee/ui/order_screen/view/orderScreenView.dart';
import 'package:wavee/ui/view_profile/view/myBuildingScreen.dart';
import 'package:wavee/utils/inAppWebView.dart';
import 'package:wavee/utils/loader.dart';
import 'package:wavee/utils/themeButton.dart';

import '../../../utils/bottomBar.dart';
import '../../../utils/checkInternetConnection.dart';
import '../../../utils/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/customBatan.dart';
import '../../../utils/customSnackBars.dart';
import '../../../utils/errorDialog.dart';
import '../../../utils/storeUserData.dart';
import '../../authentication/view/changePassword.dart';
import '../../authentication/provider/authenticationProvider.dart';
import '../../chat_screen/view/chatScreen.dart';
import '../../message_board/view/messageBoardScreen.dart';
import '../../visitor/provider/waveePetProvider.dart';
import '../../message_board/provider/messageBoardProvider.dart';
import '../../view_profile/provider/profileProvider.dart';
import '../provider/homescreenProvider.dart';

class HomePage extends StatefulWidget {
  int? selected;
  final String userName;

  HomePage({super.key, this.selected, required this.userName});

  static bool isPasswordDialogShown = false;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String? fullName;
  int sel = 0;
  bool isLoading = false;
  bool isRegistration = false;
  int parcelCount = 0;

  int visitorCount = 0;
  int _activeUpdateIndex = 0;
  int chatCount = 0;

  int notificationCount = 0;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isSending = false;
  final addPostFormkey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final List<XFile> _images = [];

  late AnimationController _shimmerController;

  String capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
        )
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
   // _fetchWeather();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDefaultPassword();
    });
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(); //
    // ----------------------------

    setState(() {
      isLoading = true;
    });
    loadUserData();
    VisitorShowCount();
    ParcelShowCount();
    ChatShowCount();
    GetProfile();
    MessageBoardApi();
    localpostapi();
    updateFCM1();

    _setupFirebaseMessagingListeners();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<void> loadUserData() async {
    var data = await SaveDataLocal.getDataFromLocal();

    if (mounted) {
      setState(() {
        loginModel = data;

        // --- LOGIC TO FIX THE NAME ---
        try {
          // 1. Get the weird string: "{\"first_name\":\"Jay\",\"last_name\":\"Jack\"}"
          String? rawNameData = loginModel?.data?.user?.name?.firstName;

          if (rawNameData != null && rawNameData.isNotEmpty) {
            // 2. Decode that string into a Map
            var nameMap = jsonDecode(rawNameData);

            // 3. Extract the real names
            String realFirstName = nameMap['first_name'] ?? "";
            String realLastName = nameMap['last_name'] ?? "";

            // 4. Combine them
            fullName = "$realFirstName ".trim();
          } else {
            fullName = "";
          }
        } catch (e) {
          // Fallback: If the backend fixes the bug and sends a normal name later
          fullName = loginModel?.data?.user?.name?.firstName ?? "User";
          print("Error parsing name: $e");
        }
        // -----------------------------
      });

      // Debug print
      print("FINAL FULL NAME: $fullName");
    }
  }

  Widget _buildShimmerGradientText() {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              // Controls the speed and angle of the shimmer
              begin: Alignment(-2.0 + (4.0 * _shimmerController.value), 0.0),
              end: Alignment(0.0 + (4.0 * _shimmerController.value), 0.0),
              colors:
                  isDark
                      ? [
                        const Color(0xf0E2DCCB),
                        const Color(0xFFFFE181),
                        const Color(0xf0E2DCCB),
                      ]
                      : [
                        const Color(0xFF4B5D8A),
                        const Color(0xFF6B80B6),
                        const Color(0xFF4B5D8A),
                      ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: Text(
            "${_getGreeting()}, $fullName",
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontFamily: AppConstants.manropeBold,
            ),
          ),
        );
      },
    );
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
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor:
          theme.isDark ? const Color(0xf0212121) : const Color(0xFFEDF0F3),
      body:
          isLoading
              ? const Loader()
              : Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildShimmerGradientText()),
                            SizedBox(width: 2.w),
                            const ThemeToggleButton(),
                          ],
                        ).paddingOnly(top: 1.h, bottom: 0.h),

                        Text(
                          DateFormat(
                            'EEEE, d MMMM',
                          ).format(DateTime.now()).toUpperCase(),
                          style: TextStyle(
                            // 5. Toggle between Gold (Dark) and LightText (Light)
                            color:
                                theme.isDark
                                    ? const Color(0xf0C5B288)
                                    : const Color(0xFF4B5D8A),
                            fontFamily: AppConstants.manrope,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.5,
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     Container(
                        //       height: 4.h,
                        //       decoration: BoxDecoration(
                        //         color:
                        //             theme.isDark
                        //                 ? AppColors.darkPillColor
                        //                 : AppColors.white,
                        //         borderRadius: BorderRadius.circular(25),
                        //
                        //         border: Border.all(
                        //           color:
                        //               theme.isDark
                        //                   ? AppColors.darkBorderColor
                        //                   : AppColors.lightText.withValues(
                        //                     alpha: 0.3,
                        //                   ),
                        //           width: 1,
                        //         ),
                        //         boxShadow:
                        //             theme.isDark
                        //                 ? []
                        //                 : [
                        //                   BoxShadow(
                        //                     color: AppColors.lightText
                        //                         .withValues(alpha: 0.15),
                        //                     spreadRadius: 0,
                        //                     blurRadius: 10,
                        //                     offset: const Offset(0, 5),
                        //                   ),
                        //                 ],
                        //       ),
                        //       padding: const EdgeInsets.all(5),
                        //       child: Row(
                        //         children: [
                        //           // Icon(
                        //           //   Icons.apartment,
                        //           //   color:
                        //           //       theme.isDark
                        //           //           ? Color(0xf0AC9D79)
                        //           //           : AppColors.lightText,
                        //           // ),
                        //           SvgPicture.asset(
                        //             AppConstants.aprtmentIcon,
                        //             width: 10.w,
                        //             color:
                        //                 theme.isDark
                        //                     ? const Color(0xf0AC9D79)
                        //                     : AppColors.lightText,
                        //           ),
                        //
                        //           SizedBox(width: 2.w),
                        //           Text(
                        //             capitalize(
                        //               profileModel
                        //                       ?.data
                        //                       ?.buildingDocument
                        //                       ?.buildingName ??
                        //                   "N/A",
                        //             ),
                        //             style: TextStyle(
                        //               color:
                        //                   theme.isDark
                        //                       ? const Color(0xf0BDBDBE)
                        //                       : AppColors.lightText,
                        //               fontFamily: AppConstants.manropeBold,
                        //               fontSize: 14.sp,
                        //             ),
                        //           ),
                        //         ],
                        //       ).paddingSymmetric(horizontal: 3.w),
                        //     ).paddingOnly(top: 2.h, left: 2.w, right: 2.w),
                        //     Container(
                        //       height: 4.h,
                        //       decoration: BoxDecoration(
                        //         color:
                        //             theme.isDark
                        //                 ? AppColors.darkPillColor
                        //                 : AppColors.white,
                        //         borderRadius: BorderRadius.circular(25),
                        //         border: Border.all(
                        //           color:
                        //               theme.isDark
                        //                   ? AppColors.darkBorderColor
                        //                   : AppColors.lightText.withValues(
                        //                     alpha: 0.3,
                        //                   ),
                        //           width: 1,
                        //         ),
                        //         boxShadow:
                        //             theme.isDark
                        //                 ? []
                        //                 : [
                        //                   BoxShadow(
                        //                     color: AppColors.lightText
                        //                         .withValues(alpha: 0.15),
                        //                     blurRadius: 10,
                        //                     offset: const Offset(0, 5),
                        //                   ),
                        //                 ],
                        //       ),
                        //       child: Row(
                        //         children: [
                        //           SvgPicture.asset(
                        //             getWeatherSvg(_weathermodel?.mainCondition),
                        //             width: getWeatherIconSize(
                        //               _weathermodel?.mainCondition,
                        //             ),
                        //             colorFilter: ColorFilter.mode(
                        //               theme.isDark
                        //                   ? const Color(0xffAC9D79)
                        //                   : AppColors.lightText,
                        //               BlendMode.srcIn,
                        //             ),
                        //           ),
                        //
                        //           SizedBox(width: 2.w),
                        //
                        //           /// 🌡 Temperature
                        //           Text(
                        //             _weathermodel == null
                        //                 ? "loading.."
                        //                 : "${_weathermodel!.temperature.round()}°C",
                        //             style: TextStyle(
                        //               color:
                        //                   theme.isDark
                        //                       ? const Color(0xf0BDBDBE)
                        //                       : AppColors.lightText,
                        //               fontFamily: AppConstants.manropeBold,
                        //               fontSize: 14.sp,
                        //             ),
                        //           ),
                        //         ],
                        //       ).paddingSymmetric(horizontal: 3.w),
                        //     ).paddingOnly(top: 2.h, left: 2.w),
                        //
                        //     // Container(
                        //     //   height: 4.h,
                        //     //   decoration: BoxDecoration(
                        //     //     color:
                        //     //         theme.isDark
                        //     //             ? AppColors.darkPillColor
                        //     //             : AppColors.white,
                        //     //     borderRadius: BorderRadius.circular(25),
                        //     //     border: Border.all(
                        //     //       color:
                        //     //           theme.isDark
                        //     //               ? AppColors.darkBorderColor
                        //     //               : AppColors.lightText.withValues(
                        //     //                 alpha: 0.3,
                        //     //               ),
                        //     //       width: 1,
                        //     //     ),
                        //     //     boxShadow:
                        //     //         theme.isDark
                        //     //             ? []
                        //     //             : [
                        //     //               BoxShadow(
                        //     //                 color: AppColors.lightText
                        //     //                     .withValues(alpha: 0.15),
                        //     //                 spreadRadius: 0,
                        //     //                 blurRadius: 10,
                        //     //                 offset: Offset(0, 5),
                        //     //               ),
                        //     //             ],
                        //     //   ),
                        //     //   child: Row(
                        //     //     children: [
                        //     //
                        //     //       SvgPicture.asset(AppConstants.light, width: 5.w,
                        //     //         color:
                        //     //         theme.isDark
                        //     //             ? Color(0xf0AC9D79)
                        //     //             : AppColors.lightText,
                        //     //       ),
                        //     //       SizedBox(width: 2.w),
                        //     //       Text(
                        //     //         (_weathermodel?.temperature.round() == null)
                        //     //             ? "loading.."
                        //     //             : "${_weathermodel?.temperature.round()}°C",
                        //     //         style: TextStyle(
                        //     //           color: theme.isDark
                        //     //               ? AppColors.creamTextColor
                        //     //               : AppColors.lightText,
                        //     //           fontFamily: AppConstants.manropeBold,
                        //     //           fontSize: 15.sp,
                        //     //         ),
                        //     //       ),
                        //     //
                        //     //     ],
                        //     //   ).paddingSymmetric(horizontal: 3.w),
                        //     // ).paddingOnly(top: 2.h, left: 2.w),
                        //   ],
                        // ),
                        parcelCount == 0
                            ? const SizedBox.shrink()
                            : Container(
                              margin: EdgeInsets.only(top: 2.h, bottom: 0.5.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.8.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors:
                                      theme.isDark
                                          ? [
                                            const Color(0xFF2C2C2C),
                                            const Color(0xFF1E1E1E),
                                          ]
                                          : [
                                            const Color(0xFFF8FAFF),
                                            Colors.white,
                                          ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color:
                                      theme.isDark
                                          ? const Color(
                                            0xFFCDBA81,
                                          ).withValues(alpha: 0.15)
                                          : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        theme.isDark
                                            ? Colors.black.withValues(
                                              alpha: 0.4,
                                            )
                                            : const Color(
                                              0xFFCFD9EF,
                                            ).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 5.5.h,
                                    width: 5.5.h,
                                    decoration: BoxDecoration(
                                      color:
                                          theme.isDark
                                              ? const Color(0xFF38362F)
                                              : const Color(0xFFE4E9F2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        AppConstants.parcel,
                                        height: 2.4.h,
                                        colorFilter: ColorFilter.mode(
                                          theme.isDark
                                              ? const Color(0xFFCDBA81)
                                              : const Color(0xFF5A6B8C),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "$parcelCount ${parcelCount == 1 ? 'parcel' : 'parcels'} ready for collection",
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                theme.isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1E293B),
                                            fontFamily:
                                                AppConstants.manropeBold,
                                          ),
                                        ),
                                        Text(
                                          "Waiting at concierge desk",
                                          style: TextStyle(
                                            color:
                                                theme.isDark
                                                    ? Colors.grey[400]
                                                    : const Color(0xFF64748B),
                                            fontSize: 11.5.sp,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Icon(
                                  //   Icons.chevron_right,
                                  //   color:
                                  //       theme.isDark
                                  //           ? const Color(0xFFCDBA81)
                                  //           : const Color(0xFF3E5481),
                                  //   size: 22.sp,
                                  // ),
                                ],
                              ),
                            ),
                        if (parcelCount == 0) SizedBox(height: 1.h),
                        GestureDetector(
                          onTap: () {
                            // Get.to(Spotlightview());
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 2.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.5.h,
                            ),

                            decoration:
                                theme.isDark
                                    ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF1C2A23),
                                          Color(0xFF2A2B29),
                                          Color(0xFF212726),
                                        ],
                                        stops: [0.0, 0.5, 1.0],
                                      ),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF4ADE80,
                                        ).withOpacity(0.2),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 12,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    )
                                    : BoxDecoration(
                                      color: const Color(0xFFE9F7F2),

                                      borderRadius: BorderRadius.circular(22),

                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFFD7E9E9),
                                          Color(0xFFE3EDEE),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFC8E6D9),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFD1E2DA,
                                          ).withValues(alpha: 0.5),
                                          blurRadius: 12,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 5.5.h,
                                  width: 5.5.h,
                                  decoration: BoxDecoration(
                                    color:
                                        theme.isDark
                                            ? const Color(0xFF2D4A3E)
                                            : const Color(0xFFBBE1DB),
                                    // આઈકોન પાછળનું આછું ગ્રીન સર્કલ
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AppConstants.spotlightIcon,
                                      height: 2.6.h,
                                      color:
                                          theme.isDark
                                              ? const Color(0xFF4ADE80)
                                              : const Color(
                                                0xFF009966,
                                              ), // ડાર્ક ગ્રીન આઈકોન
                                    ),
                                  ),
                                ),

                                SizedBox(width: 4.w),

                                // --- Text Section ---
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "spotlight",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight:
                                              FontWeight.w700, // વધુ બોલ્ડ
                                          color:
                                              theme.isDark
                                                  ? Colors.white
                                                  : const Color(0xFF2D3139),
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                      SizedBox(height: 0.2.h),
                                      Text(
                                        "Coming Soon",
                                        style: TextStyle(
                                          color:
                                              theme.isDark
                                                  ? Colors.grey[400]
                                                  : const Color(0xFF64748B),
                                          fontSize: 12.5.sp,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // --- Arrow Icon ---
                                // Icon(
                                //   Icons.chevron_right,
                                //   color:
                                //       theme.isDark
                                //           ? const Color(0xFF4ADE80)
                                //           : const Color(0xFF00A651),
                                //   size: 22.sp,
                                // ),
                              ],
                            ),
                          ),
                        ),

                        _buildQuickAccessRow(theme),
                        _buildWidgetsContainer(theme),
                        SizedBox(height: 12.h),
                      ],
                    ).paddingOnly(left: 3.w, right: 3.w, top: 6.h),
                  ),
                  if (isRegistration)
                    Container(
                      color: AppColors.black.withValues(alpha: .2),
                      child: const Loader(),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BottomBar(selected: 1, chatCount: chatCount),
                  ),
                ],
              ),
    );
  }

  Widget _buildWidgetsContainer(ThemeController theme) {
    final isDark = theme.isDark;

    // --- Colors ---
    final mainTextColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF757575);
    final barColor = !isDark ? Colors.grey[400] : const Color(0xFFDCC688);
    final accentColor =
        isDark ? const Color(0xFFDCC688) : const Color(0xf04B5D8A);
    final cardBorderColor =
        isDark ? const Color(0xf0272727) : const Color(0xFFDEE3EB);
    final cardBgColor =
        isDark ? const Color(0xFF212121) : const Color(0xf0F8FAFC);
    final buttonColor =
        isDark ? const Color(0xFF212121) : const Color(0xFF4A5288);
    final iconCircleBg =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEBEDF3);

    // --- Data Logic (Top Section) ---
    final allData = messageBoardModal?.data ?? [];
    final displayData = allData.take(3).toList();
    final hasData = displayData.isNotEmpty;

    // --- Data Logic (My Home Grid) ---
    final List<Map<String, dynamic>> homeServices = [
      {
        "title": "Event",
        "subtitle": "Event Detail",
        "icon": AppConstants.celebration,
        "screen": ViewEventDetailsScreen(),
      },
      {
        "title": "Accommodation",
        "subtitle": "Maintenance request",
        "icon": AppConstants.accommodation,
        "screen": ViewAccommodation(),
      },
      {
        "title": "Contracts",
        "subtitle": "Amenities access",
        "icon": AppConstants.contracts,
        "screen": const ViewContracts(),
      },
      {
        "title": "My Meetings",
        "subtitle": "View meetings",
        "icon": AppConstants.calendrIcon,
        "screen": MyMeetingsScreen(),
      },
    ];

    final List<Map<String, dynamic>> marketplaces = [
      {
        "title": "My Orders",
        "subtitle": "Track deliveries",
        "icon": AppConstants.ordrsIcon,
        "screen": Order_Screen(),
      },
      {
        "title": "Shopping",
        "subtitle": "Local vendors",
        "icon": AppConstants.shoppinsIcon,
        "screen": CommunityScreen(),
      },
      {
        "title": "Event",
        "subtitle": "What's on",
        "icon": AppConstants.eventsIcon,
        "screen": EventScreen(userId: loginModel?.data?.user?.id.toString()),
      },
      {
        "title": "Bookings",
        "subtitle": "event tickets",
        "icon": AppConstants.bookinsIcon,
        "screen": const EventbookingScreen(),
      },
    ];

    final List<Map<String, dynamic>> accounts = [
      {
        "title": "Profile",
        "subtitle": "Your details",
        "icon": AppConstants.personIcon,
        "screen": ViewProfile(id: loginModel?.data?.user?.id),
      },
      {
        "title": "Security",
        "subtitle": "Passwords & 2FA",
        "icon": AppConstants.securityIcon,
        "screen": const ChangePasswordScreen(),
      },
      {
        "title": "Terms",
        "subtitle": "Terms of service",
        "icon": AppConstants.termsIcon,
        "screen": "https://wavee.ai/legal/terms-of-service",
      },
      {
        "title": "Privacy",
        "subtitle": "Data & privacy",
        "icon": AppConstants.piracyIcon,
        "screen": "https://wavee.ai/legal/privacy-security",
      },
    ];

    // Helper widget to build a single card (avoids repeating code)
    Widget buildHomeCard(Map<String, dynamic> service) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final dynamic action = service['screen'];

            // CASE 1: It is a Link (String)
            if (action is String && action.isNotEmpty) {
              // final Uri url = Uri.parse(action);
              // if (await canLaunchUrl(url)) {
              //   await launchUrl(url, mode: LaunchMode.externalApplication);
              // }
              Get.to(WebViewScreen(url: action));
            }
            // CASE 2: It is a Screen (Widget)
            else if (action is Widget) {
              Get.to(action);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            // Fixed height or AspectRatio to ensure square-ish shape
            height: 14.5.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconCircleBg,
                  ),
                  child: SvgPicture.asset(
                    service["icon"]!,
                    colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
                    height: 2.8.h,
                    width: 2.8.h,
                  ),
                ),
                const Spacer(),
                Text(
                  service["title"]!,
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    // fontWeight: FontWeight.bold,
                    color: mainTextColor,
                    fontFamily: AppConstants.manropeBold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  service["subtitle"]!,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: subTextColor,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: 1.h, bottom: 2.5.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xf0272727) : const Color(0xFFC8CEDB),
        ),
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Drag Handle ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 0.5.h,
                width: 12.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: !isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // --- Header Section ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Building Updates",
                        style: TextStyle(
                          fontSize: 16.sp,
                          // fontWeight: FontWeight.bold,
                          color: mainTextColor,
                          fontFamily: AppConstants.manropeBold,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        height: 0.3.h,
                        width: 10.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: barColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "Latest from your community",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: subTextColor,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
              // GestureDetector(
              //   onTap: () {
              //     // Get.to(NotificationPage());
              //   },
              //   child: Container(
              //     padding: EdgeInsets.all(2.2.w),
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color:
              //           isDark
              //               ? Colors.transparent
              //               : accentColor.withValues(alpha: 0.07),
              //       border: Border.all(color: cardBorderColor),
              //     ),
              //     child: Icon(
              //       Icons.notifications_outlined,
              //       size: 17.sp,
              //       color: accentColor,
              //     ),
              //   ),
              // ),
            ],
          ).paddingOnly(right: 4.w, left: 4.w),
          SizedBox(height: 2.5.h),

          // --- Updates Carousel ---
          if (!hasData)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text(
                  "No updates available",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: subTextColor,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ),
            ).paddingOnly(right: 4.w, left: 4.w)
          else
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 3.4,
                      child: PageView.builder(
                        itemCount: displayData.length,
                        controller: PageController(viewportFraction: 1.0),
                        onPageChanged: (index) {
                          setState(() {
                            _activeUpdateIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final item = displayData[index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => Messageboard());
                            },
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: cardBorderColor),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            item.user?.conciergeImage ?? "",
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                CircleAvatar(
                                                  radius: 6.w,
                                                  backgroundImage:
                                                      imageProvider,
                                                ),
                                        placeholder:
                                            (context, url) => CircleAvatar(
                                              radius: 6.w,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              child:
                                                  const CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                            ),
                                        errorWidget:
                                            (context, url, error) =>
                                                CircleAvatar(
                                                  radius: 6.w,
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.person,
                                                  ),
                                                ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                            color: cardBgColor,
                                            // બેકગ્રાઉન્ડ સાથે મેચ કરવા
                                            shape: BoxShape.circle,
                                          ),
                                          child:
                                              const LiveIndicator(), // આપણું નવું એનિમેશન અહીં મૂક્યું
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "${item.user?.firstName ?? ""} ${item.user?.lastName ?? ""}",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15.sp,
                                                  color: mainTextColor,
                                                  fontFamily:
                                                      AppConstants.manropeBold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              formatPostDate(item.createdAt),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color: subTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          item.title ?? "Update",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppConstants.manrope,
                                            color: accentColor,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          item.text ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color:
                                                isDark
                                                    ? Colors.grey[400]
                                                    : const Color(0xFF7B8CAD),
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppConstants.manrope,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14.sp,
                                    color: subTextColor,
                                  ),
                                ],
                              ),
                            ).marginOnly(right: 1.w),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(displayData.length, (index) {
                        final isActive = index == _activeUpdateIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          width: isActive ? 6.w : 2.5.w,
                          height: 0.8.h,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? accentColor
                                    : (isDark
                                        ? Colors.white24
                                        : Colors.grey.shade300),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ).paddingOnly(right: 4.w, left: 4.w),

          SizedBox(height: 2.h),
          // "View All" Button
          SizedBox(
            width: double.infinity,
            height: 5.h,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => Messageboard());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: Text(
                "View All Updates",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontFamily: AppConstants.manropeBold,
                ),
              ),
            ),
          ).paddingOnly(right: 4.w, left: 4.w, bottom: 1.5.h),

          Divider(color: cardBorderColor, thickness: 1),
          SizedBox(height: 2.5.h),

          // --- My Home Header ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "My Event",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    height: 0.3.h,
                    width: 10.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: barColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Explore events & manage bookings",
                style: TextStyle(
                  fontSize: 14.5.sp,
                  color: subTextColor,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ).paddingOnly(right: 4.w, left: 4.w),

          SizedBox(height: 2.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                for (int i = 0; i < homeServices.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.w), // Vertical Spacing
                    child: Row(
                      children: [
                        Expanded(child: buildHomeCard(homeServices[i])),
                        SizedBox(width: 3.w),
                        if (i + 1 < homeServices.length)
                          Expanded(child: buildHomeCard(homeServices[i + 1]))
                        else
                          const Spacer(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: cardBorderColor, thickness: 1),
          SizedBox(height: 2.5.h),
          // --- Marketplace Header ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Marketplace",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    height: 0.3.h,
                    width: 10.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: barColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Shopping, orders & events",
                style: TextStyle(
                  fontSize: 14.5.sp,
                  color: subTextColor,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ).paddingOnly(right: 4.w, left: 4.w),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                for (int i = 0; i < marketplaces.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.w), // Vertical Spacing
                    child: Row(
                      children: [
                        Expanded(child: buildHomeCard(marketplaces[i])),
                        SizedBox(width: 3.w),
                        if (i + 1 < marketplaces.length)
                          Expanded(child: buildHomeCard(marketplaces[i + 1]))
                        else
                          const Spacer(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: cardBorderColor, thickness: 1),
          SizedBox(height: 2.5.h),
          // --- Marketplace Header ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: mainTextColor,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    height: 0.3.h,
                    width: 10.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: barColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                "Profile, security & legal",
                style: TextStyle(
                  fontSize: 14.5.sp,
                  color: subTextColor,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ).paddingOnly(right: 4.w, left: 4.w),
          SizedBox(height: 2.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                for (int i = 0; i < accounts.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(bottom: 3.w), // Vertical Spacing
                    child: Row(
                      children: [
                        Expanded(child: buildHomeCard(accounts[i])),
                        SizedBox(width: 3.w),
                        if (i + 1 < accounts.length)
                          Expanded(child: buildHomeCard(accounts[i + 1]))
                        else
                          const Spacer(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                handleWaveePetClick();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorderColor),
                ),
                child: Row(
                  // Changed Column to Row
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Icon Circle
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconCircleBg,
                      ),
                      child: SvgPicture.asset(
                        AppConstants.petsIcon, // Ensure you have this asset
                        colorFilter: ColorFilter.mode(
                          accentColor,
                          BlendMode.srcIn,
                        ),
                        height: 2.8.h,
                        width: 2.8.h,
                      ),
                    ),

                    SizedBox(width: 4.w), // Spacing between icon and text
                    // 2. Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        // Important for centering in Row
                        children: [
                          Text(
                            "Wavee Pet",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: mainTextColor,
                              fontFamily: AppConstants.manropeBold,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Pet services & policies',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: subTextColor,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.sp,
                      color: subTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ).paddingOnly(right: 4.w, left: 4.w),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildQuickAccessRow(ThemeController theme) {
    final isDark = theme.isDark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 3.w),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xf0272727) : const Color(0xf0C8CEDB),
        ),
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAccessBtn(
            theme: theme,
            label: "Chat",
            iconPath: AppConstants.chatHomeIcon,
            count: chatCount,

            onTap: () => Get.to(ChatScreen(selected: 3)),
          ),
          _buildQuickAccessBtn(
            theme: theme,
            label: "Accommodation",
            iconPath: AppConstants.visitorHomeIcon,
            count: visitorCount,

            onTap: () => Get.to( ViewAccommodation()),
          ),
          _buildQuickAccessBtn(
            theme: theme,
            label: "Contracts",
            iconPath: AppConstants.parcel,
            count: parcelCount,

            onTap: () => Get.to( ViewContracts()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessBtn({
    required ThemeController theme,
    required String label,
    required String iconPath,
    required int count,
    required VoidCallback onTap,
  }) {
    final isDark = theme.isDark;

    final btnBg = isDark ? const Color(0xFF212121) : Colors.white;
    final borderColor =
        isDark ? Colors.grey.withValues(alpha: 0.1) : const Color(0xf0D2D6E1);

    final iconColor = isDark ? const Color(0xFF4B5D8A) : AppColors.lightText;

    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    final badgeColor = const Color(0xFFC5B388);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            elevation: theme.isDark ? 2 : 0,
            borderRadius: BorderRadius.circular(20),

            child: Container(
              height: 10.h,
              width: 26.w,
              decoration: BoxDecoration(
                color: btnBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    height: 3.h,
                    width: 3.h,
                    color: iconColor,
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppConstants.manrope,
                      color: textColor,
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (count > 0)
            Positioned(
              right: -6,
              top: -10,
              child: Container(
                height: 6.w,
                width: 6.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF151515) : Colors.white,
                    width: 2,
                  ),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1A1A1A), // Dark text on Gold badge
                    fontFamily: AppConstants.manropeBold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? "",
    };
    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                profileModel = ProfileModel.fromJson(response.data);

                isLoading = false;
              });
            }
          } else {
            isLoading = false;
          }
        });
      } else {
        isLoading = false;
      }
    });
  }

  Future<void> _refreshCounts() async {
    if (loginModel?.data?.user?.id == null) {
      log("⚠️ User not loaded yet. Skipping refresh.");
      return;
    }

    log("🔄 Refreshing counts...");

    await ChatShowCount();
    await VisitorShowCount();
    await ParcelShowCount();
  }
  void _setupFirebaseMessagingListeners() {
    // 1. For messages received while the app is in the FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log(
          'Message also contained a notification: ${message.notification?.title}',
        );
      }

      // This is the key part: refresh your counts
      _refreshCounts();
    });

    // 2. For messages that are TAPPED, opening the app from the BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('A new onMessageOpenedApp event was published!');
      log('Message data: ${message.data}');

      // App was in the background, user tapped the notification.
      // Refresh counts when they arrive.
      _refreshCounts();
    });

    // 3. For messages that are TAPPED, opening the app from a TERMINATED state
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        log('App opened from terminated state by a notification!');
        log('Message data: ${message.data}');

        // App was closed, user tapped the notification.
        // Refresh counts immediately on load.
        _refreshCounts();
      }
    });
  }

  // ---- END OF FCM METHODS ----

  void launchTermsUrl() async {
    final Uri url = Uri.parse("https://wavee.ai/legal/terms-of-service");
    // final Uri url = Uri.parse("https://www.wavee.ai/terms-of-service");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void launchPrivacyPolicyUrl() async {
    // final Uri url = Uri.parse("https://wavee.ai/privacy-security");
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
      child: GestureDetector(
        onTap: onTap,

        // radius: 12.0,
        // borderRadius: BorderRadius.circular(2),
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
      child: GestureDetector(
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

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // int cartCount = cartDetailsModel?.data?.length ?? 0;

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  void ParcelShowCount1() {
    setState(() {
      isCount = true;
    });
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["type"] = "count";
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().parcelShowCountApi(data);
          parcelShowCountModel = ParcelShowCountModel.fromJson(response.data);
          if (response.statusCode == 200 &&
              parcelShowCountModel?.status == 200) {
            setState(() {
              parcelCount = parcelShowCountModel?.data ?? 0;
              isCount = false;
            });
          } else {
            setState(() {
              isCount = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isCount = false;
            });
          }
        }
      } else {
        setState(() {
          isCount = false;
        });
        // buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  bool isCount = false;

  void VisitorShowCount1() {
    setState(() {
      isCount = true;
    });
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["count"] = "visitor";

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().visitorShowCountApi(data);
          visitorShowCountModel = VisitorShowCountModel.fromJson(response.data);

          if (response.statusCode == 200 &&
              visitorShowCountModel?.status == 200) {
            setState(() {
              visitorCount = visitorShowCountModel?.data ?? 0;
              isCount = false;
            });
          } else {
            setState(() {
              isCount = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isCount = false;
            });
          }
        }
      } else {
        setState(() {
          isCount = false;
        });
        // buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> ChatShowCount() async {
    final Map<String, String> bodyData = {};
    bodyData['sender_id'] = '1';
    bodyData['receiver_id'] = loginModel?.data?.user?.id.toString() ?? "";

    checkInternet().then((internet) async {
      if (internet) {
        HomeProvider().chatCountApi(bodyData).then((response) async {
          chatShowCountModal = ChatShowCountModal.fromJson(response.data);
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isLoading = false;
                chatCount = chatShowCountModal?.data ?? 0;
              });
            }
          }
          if (response.statusCode == 404 || response.statusCode == 429) {
            chatShowCountModal = ChatShowCountModal.fromJson(response.data);

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

  Future<void>  ParcelShowCount() async {
    final Map<String, String> bodyData = {};
    bodyData["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    bodyData["type"] = "count";

    checkInternet().then((internet) async {
      if (internet) {
        HomeProvider().parcelShowCountApi(bodyData).then((response) async {
          parcelShowCountModel = ParcelShowCountModel.fromJson(response.data);

          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isLoading = false;
                parcelCount = parcelShowCountModel?.data ?? 0;
              });
            }
          }
          if (response.statusCode == 404 || response.statusCode == 429) {
            parcelShowCountModel = ParcelShowCountModel.fromJson(response.data);

            if (mounted) {
              setState(() {
                isLoading = false;
                parcelCount = parcelShowCountModel?.data ?? 0;
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

  Future<void> VisitorShowCount() async {
    final Map<String, String> bodyData = {};
    bodyData["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    bodyData["count"] = "visitor";

    checkInternet().then((internet) async {
      if (internet) {
        HomeProvider().visitorShowCountApi(bodyData).then((response) async {
          visitorShowCountModel = VisitorShowCountModel.fromJson(response.data);

          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isLoading = false;
                visitorCount = visitorShowCountModel?.data ?? 0;
              });
            }
          }
          if (response.statusCode == 404 || response.statusCode == 429) {
            visitorShowCountModel = VisitorShowCountModel.fromJson(
              response.data,
            );

            if (mounted) {
              setState(() {
                isLoading = false;
                visitorCount = visitorShowCountModel?.data ?? 0;
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
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
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
        context: context,
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
    print("sending Data $data");
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

  Future<void> handleWaveePetClick() async {
    setState(() {
      isRegistration = true; // Loader chalu thase
    });

    String? savedEmail = await SaveDataLocal.getEmail();
    final Map<String, String> data = {"email": savedEmail ?? ""};

    checkInternet().then((internet) async {
      if (internet) {
        try {
          // Tamari AuthProvider ni checkMail API call karo
          var response = await AuthProvider().checkMail(data);

          setState(() {
            isRegistration = false;
          });

          if (response.statusCode == 422) {
            launchStore();
          }
          // CASE 2: User nathi (200) -> Registration Dialog show karo
          else if (response.statusCode == 200) {
            final theme = context.read<ThemeController>();
            final accentColor =
                theme.isDark
                    ? const Color(0xFFDCC688)
                    : const Color(0xf04B5D8A);
            final cardBgColor =
                theme.isDark
                    ? const Color(0xFF212121)
                    : const Color(0xf0F8FAFC);

            showWaveePet(
              context: context,
              bgcolor: cardBgColor,
              accentClr: accentColor,
            );
          } else {
            print("CheckMail Error: ");
          }
        } catch (e) {
          setState(() => isRegistration = false);
          print("CheckMail Error: $e");
        }
      } else {
        setState(() => isRegistration = false);
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> showWaveePet({
    required BuildContext context,
    required bgcolor,
    required accentClr,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: bgcolor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🐾 Icon or image on top
                CircleAvatar(
                  radius: 30,
                  backgroundColor: accentClr.withValues(alpha: 0.2),
                  child: Icon(Icons.pets, color: accentClr, size: 25.sp),
                ),
                SizedBox(height: 2.h),

                // Title
                Text(
                  "Wavee Pet",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: accentClr,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle / Description
                Text(
                  "Do you want to create an account on Wavee Pets?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: accentClr.withValues(alpha: 0.7),
                    fontFamily: AppConstants.manrope,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
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
                    // Inside showWaveePet "Yes" button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentClr,
                          foregroundColor: bgcolor,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.back(); // 1. Close the "Wavee Pet" Dialog
                          SignupApi(); // 2. Call the API (which will show its own loader)
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

  Future<void> SignupApi() async {
    // 1. Show Blocking Loader immediately
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: Loader(),
        ); // Uses your existing Loader widget
      },
    );

    String? savedEmail = await SaveDataLocal.getEmail();

    final Map<String, String> data = {
      'name': fullName ?? '',
      'email': savedEmail.toString(),
      'password': "12345678",
      'role': '4',
    };

    // Check Internet
    bool internet = await checkInternet();

    if (internet) {
      try {
        final response = await AuthProvider1().SignUpApi(data);

        // 2. Close the Loader immediately after response
        Get.back();

        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body);

          int apiStatus = responseData['status'] ?? 0;
          String apiMessage = responseData['message'] ?? "Unknown error";

          if (response.statusCode == 200 && apiStatus == 200) {
            showSnackBar(
              context: context,
              title: "SignUp",
              message:
                  "Registration Successful \nYou can now login to Wavee Pets using your credentials.",
              backgoundColor: AppColors.maincolor,
              ColorText: AppColors.white,
              IconColor: AppColors.white,
              IconName: Icons.check_circle,
            );
            launchStore();
          } else {
            // Handle specific field errors
            if (responseData.containsKey('data') &&
                responseData['data'] is Map) {
              Map<String, dynamic> errorData = responseData['data'];
              String errorMessage = apiMessage;

              if (errorData.containsKey('email') &&
                  (errorData['email'] as List).isNotEmpty) {
                errorMessage = errorData['email'][0];
              } else if (errorData.containsKey('name') &&
                  (errorData['name'] as List).isNotEmpty) {
                errorMessage = errorData['name'][0];
              } else if (errorData.containsKey('password') &&
                  (errorData['password'] as List).isNotEmpty) {
                errorMessage = errorData['password'][0];
              }

              showSnackBar(
                context: context,
                title: "Sorry",
                message: errorMessage,
                backgoundColor: Colors.red.shade400,
                ColorText: Colors.white,
              );
            } else {
              showSnackBar(
                context: context,
                title: "Sorry",
                message: apiMessage,
                backgoundColor: AppColors.redColor,
                ColorText: AppColors.white,
              );
            }
          }
        } catch (jsonError) {
          showSnackBar(
            context: context,
            title: "Sorry",
            message: "Invalid response from server. Please try again.",
            backgoundColor: AppColors.redColor,
            ColorText: AppColors.white,
          );
        }
      } catch (e) {
        // Close loader if it hasn't been closed yet
        if (Get.isDialogOpen ?? false) Get.back();

        if (e.toString().contains("No Internet connection")) {
          showSnackBar(
            context: context,
            title: "Sorry",
            message: "No internet connection. Please check your network.",
            backgoundColor: Colors.red.shade400,
            ColorText: Colors.white,
          );
        } else {
          showSnackBar(
            context: context,
            title: "Sorry",
            message: "Registration failed. Please try again.",
            backgoundColor: Colors.red.shade400,
            ColorText: Colors.white,
          );
        }
      }
    } else {
      // No Internet initially
      Get.back(); // Close loader
      buildErrorDialog(context, 'Error', "Internet Required");
    }
  }

  Future<void> _checkDefaultPassword() async {
    // FIX: Changed context.watch to context.read
    // 'watch' causes the crash because this runs in addPostFrameCallback (outside the widget tree build).
    final theme = context.read<ThemeController>();

    final isDark = theme.isDark;
    LoginModel? userData = await SaveDataLocal.getDataFromLocal();
    if (userData?.data?.user?.isDefaultPass == 1) {
      // HomePage.isPasswordDialogShown = true;

      showMandatoryPasswordChangeDialog(
        isDark ? const Color(0xFF1E1E1E) : Colors.white,
        isDark ? const Color(0xFFDCC688) : const Color(0xFF4A5288),
      );
    }
  }

  void showMandatoryPasswordChangeDialog(bgcolor, accentClr) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgcolor,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.5.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Icon (ફેરફાર 3: સાઈઝ નાની કરી)
                        Container(
                          height: 10.h, // 15.h -> 10.h
                          width: 10.h,
                          decoration: BoxDecoration(
                            color: accentClr.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.security_rounded,
                              size: 30.sp, // 40.sp -> 30.sp
                              color: accentClr,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Spacing ઓછું કર્યું

                        // 2. Headline
                        Text(
                          "Password Reset",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17.sp, // થોડો ફોન્ટ નાનો કર્યો
                            fontFamily: AppConstants.manropeBold,
                            color: accentClr,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // 3. Subtext
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: Text(
                            "Please click here to update your password, as you are currently using the default one.",

                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5.sp, // 15.sp -> 13.sp
                              fontFamily: AppConstants.manrope,
                              color: accentClr.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        batan(
                          title: "Change Now",
                          route: () {
                            Get.back();
                            Get.to(() => const ChangePasswordScreen());
                          },
                          color: accentClr,
                          fontcolor: bgcolor,
                          height: 5.h,
                          width: double.infinity,
                          fontsize: 16.sp,
                          radius: 18.0,
                          fontFamily: AppConstants.manropeBold,
                          iconData1: Icons.arrow_forward_rounded,
                        ),
                      ],
                    ),
                  ),

                  // --- Close Button ---
                  Positioned(
                    top: 1.h,
                    right: 2.w,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: EdgeInsets.all(1.5.w),
                          child: Icon(
                            Icons.close_rounded,
                            color: accentClr,
                            size: 18.sp,
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
  }

  // final _weatherService = WeatherService(AppConstants.weatherApi);
  // WeatherModel? _weathermodel;
  //
  // _fetchWeather() async {
  //   String cityName = await _weatherService.getCurrentCity();
  //
  //   try {
  //     final weather = await _weatherService.getWeather(cityName);
  //
  //     setState(() {
  //       _weathermodel = weather;
  //     });
  //   } catch (e, stackTrace) {
  //     print(e);
  //     print("ERror $stackTrace");
  //   }
  // }

  String getWeatherSvg(String? condition) {
    if (condition == null) return AppConstants.weatherCloudy;

    final c = condition.toLowerCase();

    if (c.contains('clear')) {
      return AppConstants.light;
    } else if (c.contains('cloud')) {
      return AppConstants.weatherCloudy;
    } else if (c.contains('rain') || c.contains('drizzle')) {
      return AppConstants.weatherRainy;
    } else if (c.contains('thunder')) {
      return AppConstants.weatherThunder;
    } else if (c.contains('snow')) {
      return AppConstants.weatherSnow;
    } else if (c.contains('mist') || c.contains('fog') || c.contains('haze')) {
      return AppConstants.weatherFog;
    } else {
      return AppConstants.weatherCloudy;
    }
  }

  double getWeatherIconSize(String? condition) {
    if (condition == null) return 5.w;

    switch (condition.toLowerCase()) {
      case 'thunderstorm':
        return 3.w;
      case 'snow':
        return 4.w;
      default:
        return 5.w;
    }
  }
}

class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // ૧. પહેલું મોટું તરંગ (Outer Ripple)
            _buildRipple(
              scale: 1.0 + (_controller.value * 1.5),
              opacity: (1 - _controller.value),
            ),

            // ૨. બીજું નાનું તરંગ (Inner Ripple - થોડું મોડું શરૂ થાય તેવું લાગે)
            _buildRipple(
              scale: 1.0 + (((_controller.value + 0.5) % 1.0) * 1.2),
              opacity: (1 - ((_controller.value + 0.5) % 1.0)) * 0.5,
            ),

            // ૩. મુખ્ય ગ્રીન ડોટ (સ્થિર અને Glow સાથે)
            Container(
              height: 2.8.w,
              width: 2.8.w,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // રિપલ વિજેટ બનાવવા માટેનું હેલ્પર ફંક્શન
  Widget _buildRipple({required double scale, required double opacity}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        height: 2.5.w,
        width: 2.5.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00C853).withOpacity(opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}
