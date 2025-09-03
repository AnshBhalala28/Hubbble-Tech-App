import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/messageBoard/View/messageboard.dart';
import 'package:wavee/Screen/messageScreen/View/messageScreen.dart';
import 'package:wavee/Screen/NotiFicationPage/Model/ReadNotificationModel.dart';
import 'package:wavee/Screen/NotiFicationPage/Provider/notificationprovider.dart';
import 'package:wavee/Screen/Parcel/parcel_Screen_View/parcel_View.dart';
import 'package:wavee/Screen/Visitor/View/visitorscreen.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../../orderScreen/View/orderdetailscreen.dart';

class AllNotificationPage extends StatefulWidget {
  const AllNotificationPage({super.key});

  @override
  State<AllNotificationPage> createState() => _AllNotificationPageState();
}

class _AllNotificationPageState extends State<AllNotificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeyParcel =
      GlobalKey<ScaffoldState>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    // getnotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            TitleBar(
              back: () {
                Get.back();
              },
              title: 'Notifications',
              drawerCallback: () {},
            ),
            SizedBox(height: 3.h),
            Expanded(child: _buildNotificationList()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return notificationmodel?.data == null ||
            notificationmodel!.data!.notifications!.isEmpty
        ? Center(
          child: Text(
            "No Notifications Available",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontFamily: AppConstants.manrope,
            ),
          ).paddingOnly(bottom: 6.h, top: 5.h),
        )
        : ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: (notificationmodel?.data?.notifications?.length ?? 0),
          itemBuilder: (context, index) {
            var notification = notificationmodel?.data?.notifications?[index];
            return GestureDetector(
              onTap: () {
                String? type = notification?.type;

                if (type == "messageboard") {
                  Get.to(() => Messageboard());
                } else if (type == "parcel") {
                  Get.to(() => const ParcelScreen());
                } else if (type == "chat") {
                  String chatName = "";
                  String profileImage = "";
                  String chatType = notification?.msgTo ?? "";

                  if (notification?.conciergeProfile != null) {
                    chatName =
                        "${notification?.conciergeProfile?.firstName ?? ''} ${notification?.conciergeProfile?.lastName ?? ''}"
                            .trim();
                    if (notification?.conciergeProfile?.conciergeImage !=
                            null &&
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
                  Get.to(() => const VisitorScreen());
                } else if (type == "order") {
                  Get.to(
                    () => Orderdetail_Screen(
                      orderid: notification?.msgTo ?? "",
                      orderProductID:
                          notification?.chatCreateId.toString() ?? "",
                    ),
                  );
                } else {}

                Readnotification();
              },
              child: Container(
                height: 15.h,
                margin: EdgeInsets.only(bottom: 1.h),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
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
                            notification?.data?.capitalizeFirst ?? "No Message",
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
                                Icon(
                                  Icons.timer,
                                  color: Colors.grey,
                                  size: 15.sp,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  formatDateTime(
                                    notification?.notificationDate ?? '',
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

  // getnotification() {
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       try {
  //         final response = await NotificationProvider().notificationApi(
  //           (loginModel?.data?.user?.id).toString(),
  //         );
  //         EasyLoading.dismiss();
  //         if (response.statusCode == 200) {
  //           setState(() {
  //             notificationmodel = NotificationModell.fromJson(response.data);
  //           });
  //         } else {}
  //       } catch (e) {}
  //     } else {
  //       EasyLoading.dismiss();
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }

  Readnotification() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await NotificationProvider().notificationReadApi(
            (notificationmodel?.data?.notifications?[0].id).toString(),
          );

          EasyLoading.dismiss();
          if (response.statusCode == 200) {
            notificationreadModel =
                NotificationReadModel.fromJson(response.data)
                    as NotificationReadModel?;
          } else {}
        } catch (e) {}
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
