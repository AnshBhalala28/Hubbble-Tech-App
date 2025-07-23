import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Message_screen/View/messageScreen.dart';
import 'package:wavee/Screen/NotiFicationPage/Provider/notificationprovider.dart';
import 'package:wavee/Screen/NotiFicationPage/View/all_notifications_page.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../../HomeNewPage/View/homenewpage.dart';
import '../../Message_board/View/messageboard.dart';
import '../../Oredrscreen/View/orderdetailscreen.dart';
import '../../Parcel/parcel_Screen_View/parcel_View.dart';
import '../../Visitor/View/visitorscreen.dart';
import '../Model/Notification_Model.dart';
import '../Model/ReadNotificationModel.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeyParcel =
      GlobalKey<ScaffoldState>();

  bool isLoading = false;
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getnotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      drawer: const SideMenu(),
      key: _scaffoldKeyParcel,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            TitleBar(
              back: () {
                Get.to(HomePage(selected: 1, userName: ''));
              },
              title: 'Notifications',
              drawerCallback: () {
                _scaffoldKeyParcel.currentState?.openDrawer();
              },
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [_buildNotificationList()]),
              ),
            ),
            if (notifications != null && notifications!.length! > 5)
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.to(() => AllNotificationPage());
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.blue),
                    ],
                  ),
                ),
              )
            else
              SizedBox(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  final notifications = notificationmodel?.data?.notifications;

  Widget _buildNotificationList() {
    final notifications = notificationmodel?.data?.notifications;
    if (notifications == null || notifications.isEmpty) {
      return Center(
        child: Text(
          "No Notifications Available",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: AppConstants.manrope,
          ),
        ).paddingOnly(bottom: 6.h, top: 35.h),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount:
          (notificationmodel?.data?.notifications?.length ?? 0) > 5
              ? 5
              : notificationmodel?.data?.notifications?.length ?? 0,
      itemBuilder: (context, index) {
        var notification = notificationmodel?.data?.notifications?[index];

        return GestureDetector(
          onTap: () {
            String? type = notification?.type;
            String notificationId = notification?.id?.toString() ?? "";

            Readnotification(notificationId);
            if (type == "messageboard") {
              Get.to(() => Messageboard());
            } else if (type == "parcel") {
              Get.to(() => ParcelScreen());
            } else if (type == "chat") {
              String chatName = "";
              String profileImage = "";
              String chatType = notification?.msgTo ?? "";

              if (notification?.conciergeProfile != null) {
                chatName =
                    "${notification?.conciergeProfile?.firstName ?? ''} ${notification?.conciergeProfile?.lastName ?? ''}"
                        .trim();
                if (notification?.conciergeProfile?.conciergeImage != null &&
                    notification!
                        .conciergeProfile!
                        .conciergeImage!
                        .isNotEmpty) {
                  profileImage =
                      notification.conciergeProfile!.conciergeImage!.first;
                }
              } else if (notification?.businessProfile != null) {
                chatName = notification?.businessProfile?.name ?? '';
                profileImage = notification?.businessProfile?.profile ?? '';
              }

              Get.to(
                () => MessageScreen(
                  chatName: chatName,
                  conciergeID: notification?.chatCreateId.toString() ?? "",
                  type: chatType,
                  image: profileImage,
                ),
              );
            } else if (type == "visitor") {
              Get.to(() => VisitorScreen());
            } else if (type == "order") {
              Get.to(
                () => Orderdetail_Screen(
                  orderid: notification?.msgTo ?? "",
                  orderProductID: notification?.chatCreateId.toString() ?? "",
                ),
              );
            } else {}
          },
          child: Container(
            height: 14.5.h,
            margin: EdgeInsets.only(bottom: 1.h),
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.maincolor,
                  radius: 6.w,
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification?.type?.capitalizeFirst ?? "No Type",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        notification?.data?.capitalizeFirst ?? "No Data",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.timer, color: Colors.grey, size: 15.sp),
                            SizedBox(width: 1.w),
                            Text(
                              formatDateTime(
                                notification?.notificationDate ?? "No Date",
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade500,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  getnotification() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await NotificationProvider().notificationApi(
            (loginModel?.data?.user?.id).toString(),
          );
          print(
            "login user id newwwww: ${(loginModel?.data?.user?.id).toString()}",
          );
          EasyLoading.dismiss();
          if (response.statusCode == 200) {
            notificationmodel = NotificationModell.fromJson(response.data);
          } else {}
        } catch (e, stackTrace) {}
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Readnotification(String notificationId) {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await NotificationProvider().notificationReadApi(
            notificationId,
          );

          EasyLoading.dismiss();
          if (response.statusCode == 200) {
            notificationreadModel = NotificationReadModel.fromJson(
              response.data,
            );

            getnotificationCount();
          } else {}
        } catch (e, stackTrace) {}
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
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
            notificationmodel = NotificationModell.fromJson(response.data);

            setState(() {
              notificationCount = notificationmodel?.data?.totalCount ?? 0;
              isLoading = false;
            });
          } else {}
        } catch (e) {}
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
