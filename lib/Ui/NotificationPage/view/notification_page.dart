import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Ui/NotificationPage/modal/Notification_Model.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/errorDialog.dart';
import '../../HomeScreen/View/homePage.dart';
import '../../MessageScreen/View/messageScreen.dart' show MessageScreen;
import '../../OrderScreen/view/orderDetailsScreen.dart';
import '../../Parcel/view/parcelViewScreen.dart';
import '../../Visitor/view/visitorsScreen.dart';
import '../../messageBoard/View/messageBoardScreen.dart';
import '../provider/notificationprovider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = false;
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getnotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    // થીમ મુજબ કલર સેટ કરવા માટે
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.bgcolor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              // કસ્ટમ એપ બાર
              TitleBar(
                back: () => Get.to(HomePage(selected: 1, userName: '')),
                title: 'Notifications',
                drawerCallback: () {},
              ),
              SizedBox(height: 2.h),
              // નોટિફિકેશન લિસ્ટ
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildNotificationList(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // બધી જ નોટિફિકેશન બતાવતું લિસ્ટ
  Widget _buildNotificationList(bool isDark) {
    final notifications = notificationmodel?.data?.notifications;

    if (notifications == null || notifications.isEmpty) {
      return Center(
        child: Text(
          "No Notifications Available",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
            fontFamily: AppConstants.manrope,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => getnotificationCount(),
      child: ListView.builder(
        padding: EdgeInsets.only(top: 1.h, bottom: 4.h),
        // હવે બધી જ નોટિફિકેશન દેખાશે (No Limit)
        itemCount: notifications.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          var notification = notifications[index];
          return _notificationCard(notification, isDark);
        },
      ),
    );
  }

  // સિંગલ નોટિફિકેશન કાર્ડ ડિઝાઇન
  Widget _notificationCard(var notification, bool isDark) {
    return GestureDetector(
      onTap: () {
        String? type = notification?.type;
        String notificationId = notification?.id?.toString() ?? "";

        Readnotification(notificationId);

        // Navigation Logic
        if (type == "messageboard") {
          Get.to(() => Messageboard());
        } else if (type == "parcel") {
          Get.to(() => const ParcelScreen());
        } else if (type == "chat") {
          _handleChatNavigation(notification);
        } else if (type == "visitor") {
          Get.to(() => const VisitorScreen());
        } else if (type == "order") {
          Get.to(() => Orderdetail_Screen(
            orderid: notification?.msgTo ?? "",
            orderProductID: notification?.chatCreateId.toString() ?? "",
          ));
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(13.sp),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252525) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : const Color(0xFFD6DBEA).withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : const Color(0xFFD6DBEA).withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ઈમેજ જેવું સર્કલ આઈકોન
            Container(
              height: 5.5.h,
              width: 5.5.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3E3C35) : const Color(0xFFF0F2F8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getIconByType(notification?.type),
                  color: isDark ? const Color(0xFFCDBA81) : AppColors.maincolor,
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // ટેક્સ્ટ ડિટેલ્સ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification?.type ?? "Notification",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            fontFamily: AppConstants.manropeBold,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification?.notificationDate),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    notification?.data ?? "No description available",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey[400] : const Color(0xFF7A869A),
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ચેટ નેવિગેશન હેન્ડલર
  void _handleChatNavigation(var notification) {
    String chatName = "";
    String profileImage = "";
    String chatType = notification?.msgTo ?? "";

    if (notification?.conciergeProfile != null) {
      chatName = "${notification?.conciergeProfile?.firstName ?? ''} ${notification?.conciergeProfile?.lastName ?? ''}".trim();
      if (notification?.conciergeProfile?.conciergeImage?.isNotEmpty ?? false) {
        profileImage = notification.conciergeProfile!.conciergeImage!.first;
      }
    } else if (notification?.businessProfile != null) {
      chatName = notification?.businessProfile?.name ?? '';
      profileImage = notification?.businessProfile?.profile ?? '';
    }

    Get.to(() => MessageScreen(
      chatName: chatName,
      conciergeID: notification?.chatCreateId.toString() ?? "",
      type: chatType,
      image: profileImage,
    ));
  }

  // ટાઈપ મુજબ આઈકોન નક્કી કરવા
  IconData _getIconByType(String? type) {
    switch (type?.toLowerCase()) {
      case 'parcel': return Icons.inventory_2_outlined;
      case 'visitor': return Icons.person_add_alt_1_outlined;
      case 'messageboard': return Icons.dashboard_customize_outlined;
      case 'chat': return Icons.chat_bubble_outline;
      case 'order': return Icons.shopping_bag_outlined;
      default: return Icons.notifications_none_rounded;
    }
  }

  // ટાઈમ ફોર્મેટ કરવા માટે
  String _formatTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(createdAt);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return "";
    }
  }

  // --- API Methods ---

  Readnotification(String notificationId) {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          await NotificationProvider().notificationReadApi(notificationId);
          getnotificationCount();
        } catch (e) { log("Read Error: $e"); }
      }
    });
  }

  getnotificationCount() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await NotificationProvider().notificationApi(
            (loginModel?.data?.user?.id).toString(),
          );
          if (response.statusCode == 200) {
            setState(() {
              notificationmodel = NotificationModell.fromJson(response.data);
              notificationCount = notificationmodel?.data?.totalCount ?? 0;
              isLoading = false;
            });
          }
        } catch (e) {
          log("Fetch Error: $e");
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}