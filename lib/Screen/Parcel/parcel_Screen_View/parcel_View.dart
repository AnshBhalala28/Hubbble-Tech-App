import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/Custom_AppBar.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/error_dialog.dart';
import '../Model/parcel_model.dart';
import '../Provider/parcel_provider.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  int selectedCategory = 0;
  bool isLoading = false;
  List<String> categories = ['All', 'Collected', 'Awaiting Collection'];

  List<Data3> allParcels = [];
  List<Data3> collectedParcels = [];
  List<Data3> inProgressParcels = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    ParselViewApi();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKeyParcel =
        GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: AppColors.bgcolor,
      drawer: const SideMenu(),
      key: _scaffoldKeyParcel,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            TitleBar(
              back: () {
                Get.back();
              },
              title: 'Parcel',
              drawerCallback: () {
                _scaffoldKeyParcel.currentState?.openDrawer();
              },
            ),
            SizedBox(height: 3.h),
            SizedBox(
              height: 6.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (selectedCategory != index) {
                        setState(() {
                          selectedCategory = index;
                        });

                        ParselViewApi();
                      }
                    },
                    child: Container(
                      height: 6.h,
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 7.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.grey),
                        color: selectedCategory == index
                            ? AppColors.maincolor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: selectedCategory == index
                              ? Colors.white
                              : Colors.black,
                          fontFamily: AppConstants.manrope,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 2.h),
            isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.maincolor),
                  ).paddingOnly(top: 25.h)
                : getSelectedParcelList().length == null ||
                        getSelectedParcelList().isEmpty
                    ? Center(
                        child: Text(
                          "No Parcel Available",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontFamily: AppConstants.manrope,
                          ),
                        ).paddingOnly(top: 30.h),
                      )
                    : Expanded(
                        child: Container(
                          height: 70.h,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: getSelectedParcelList().length,
                            itemBuilder: (context, index) {
                              var parcel = getSelectedParcelList()[index];

                              Map<String, Color> statusColors = {
                                "Pending": Colors.orange,
                                "Collected": Colors.green,
                                "Cancelled": Colors.red,
                                "Shipped": Colors.blue,
                                "Processing": Colors.purple,
                              };

                              String status =
                                  parcel.deliveryStatus ?? "Pending";
                              Color statusColor =
                                  statusColors[status] ?? Colors.grey;

                              return GestureDetector(
                                onTap: () {},
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 5)
                                        ],
                                      ),
                                      margin: EdgeInsets.only(bottom: 16),
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.pending_rounded,
                                                  color: statusColor,
                                                  size: 18.sp),
                                              SizedBox(width: 8),
                                              Text(
                                                '${status[0].toUpperCase()}${status.substring(1)}',
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: AppConstants.manrope,

                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          ReadMoreText(
                                            parcel.comment?.isNotEmpty == true
                                                ? '${parcel.comment![0].toUpperCase()}${parcel.comment!.substring(1)}'
                                                : '',
                                            style:  TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: AppConstants.manrope,

                                            ),
                                            trimLines: 2,
                                            colorClickableText: Colors.blue,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: ' Show More',
                                            trimExpandedText: ' Show Less',
                                            moreStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.maincolor,
                                            ),
                                            lessStyle: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppConstants.manrope,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.maincolor,
                                            ),
                                          ),
                                          parcel.unitsnumber == null
                                              ? SizedBox()
                                              : Text(
                                                  'Apartment No: ${parcel.unitsnumber?.blockNumber ?? ""}-${parcel.unitsnumber?.flatNumber ?? ""}',
                                                  style: TextStyle(
                                                      color: Colors.black,

                                                      fontFamily:
                                                          AppConstants.manrope),
                                                ),
                                          SizedBox(height: 2.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                ' ${parcel.amount ?? ""}',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                formatDateTime(
                                                    parcel.createdAt),
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontFamily: AppConstants.manrope,

                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ],
        ),
      ),
      // floatingActionButton: isLoading
      //     ? Container()
      //     : FloatingActionButton.extended(
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(900)),
      //         backgroundColor: Colors.white,
      //         onPressed: () {
      //           Get.to(() => const ChatBotScreen());
      //         },
      //         icon: Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
      //         label: Text(
      //           "Ai Concierge",
      //           style: TextStyle(
      //               color: Colors.black,
      //               fontWeight: FontWeight.w600,
      //               fontSize: 16.sp,
      //               fontFamily: AppConstants.manrope),
      //         ),
      //       ),
    );
  }

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);

    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  Future<void> ParselViewApi() async {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? ""
    };

    log("API Request: $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await ParcelProvider().ParcelApi(data);
          ParcelViewModal parcelViewModal =
              ParcelViewModal.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200 && parcelViewModal.status == 200) {
            log("API Response: ${response.body}");
            setState(() {
              allParcels = parcelViewModal.data ?? [];
              collectedParcels = allParcels
                  .where((p) => p.deliveryStatus == "Collected")
                  .toList();
              inProgressParcels = allParcels
                  .where((p) => p.deliveryStatus == "Pending")
                  .toList();
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e, stackTrace) {
          log("Geeting Error ${stackTrace}");
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

  List<Data3> getSelectedParcelList() {
    if (selectedCategory == 1) return collectedParcels;
    if (selectedCategory == 2) return inProgressParcels;
    return allParcels;
  }
}
