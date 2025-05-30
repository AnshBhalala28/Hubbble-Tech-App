import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/open_ai_chatbot/view/open_ai_screen.dart';
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
    // ParcelFetch();
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

            // Category Selection
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
                      padding: EdgeInsets.symmetric(
                        vertical: 1.h,
                        horizontal: 7.w,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.grey),
                        color:
                            selectedCategory == index
                                ? Color(0xFF734F96)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          fontSize: 15.sp,
                          color:
                              selectedCategory == index
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
                  child: CircularProgressIndicator(color: AppColors.maincolor),
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
                      itemCount: getSelectedParcelList().length,
                      // ✅ Uses filtered parcel list
                      itemBuilder: (context, index) {
                        var parcel =
                            getSelectedParcelList()[index]; // ✅ Fetch filtered parcel

                        // ✅ Define Status Colors
                        Map<String, Color> statusColors = {
                          "Pending": Colors.orange,
                          "Collected": Colors.green,
                          "Cancelled": Colors.red,
                          "Shipped": Colors.blue,
                          "Processing": Colors.purple,
                        };

                        String status = parcel.deliveryStatus ?? "Pending";
                        Color statusColor = statusColors[status] ?? Colors.grey;

                        return GestureDetector(
                          onTap: () {},
                          child: Stack(
                            children: [
                              // ✅ Parcel Container
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ✅ Status Row
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.pending_rounded,
                                          color: statusColor,
                                          size: 18.sp,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '${status[0].toUpperCase()}${status.substring(1)}',
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),

                                    ReadMoreText(
                                      parcel.comment?.isNotEmpty == true
                                          ? '${parcel.comment![0].toUpperCase()}${parcel.comment!.substring(1)}'
                                          : 'N/A',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      trimLines: 2,
                                      // 2 lines sudhi show karva mate
                                      colorClickableText: Colors.blue,
                                      // "Show More" ane "Show Less" no color
                                      trimMode: TrimMode.Line,
                                      // Line based trimming
                                      trimCollapsedText: ' Show More',
                                      // Show More text
                                      trimExpandedText: ' Show Less',
                                      // Show Less text
                                      moreStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.maincolor,
                                      ),
                                      lessStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.maincolor,
                                      ),
                                    ),
                                    // Text(
                                    //   parcel.comment?.isNotEmpty == true
                                    //       ? '${parcel.comment![0].toUpperCase()}${parcel.comment!.substring(1)}'
                                    //       : 'N/A',
                                    //   style: TextStyle(
                                    //     fontSize: 18,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    //   maxLines: 2, // Maximum 2 lines sudhi j text dekhashe
                                    //   overflow: TextOverflow.ellipsis, // 3rd line ma jatu hoy to ... dekhashe
                                    // ),

                                    // ✅ Comment
                                    // Text(
                                    //   parcel.comment?.isNotEmpty == true
                                    //       ? '${parcel.comment![0].toUpperCase()}${parcel.comment!.substring(1)}'
                                    //       : 'N/A',
                                    //   style: TextStyle(
                                    //     color: Colors.grey,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    // ),

                                    // ✅ Apartment Number
                                    Text(
                                      'Apartment No: ${parcel.apartmentNo ?? "N/A"}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    SizedBox(height: 2.h),

                                    // ✅ Amount & Date Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ' ${parcel.amount ?? ""}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          // parcel.createdAt != null
                                          //     ? DateFormat('yyyy-MM-dd').format(DateTime.parse(parcel.createdAt!))
                                          //     : "N/A",
                                          formatDateTime(parcel.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ Image on Top-Right
                              // Positioned(
                              //   top: 0,
                              //   right: 0,
                              //   child: Image.asset(
                              //     "assets/images/pc.png",
                              //     height: 80,
                              //     width: 80,
                              //   ),
                              // ),
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
      floatingActionButton:
          isLoading
              ? Container()
              : FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(900),
                ),
                backgroundColor: Colors.white,
                onPressed: () {
                  Get.to(() => const ChatBotScreen());
                },
                icon: Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
                label: Text(
                  "Ai Concierge",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    fontFamily: AppConstants.manrope,
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

  Future<void> ParselViewApi() async {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
    };

    log("API Request: $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await ParcelProvider().ParcelApi(data);
          ParcelViewModal parcelViewModal = ParcelViewModal.fromJson(
            jsonDecode(response.body),
          );
          if (response.statusCode == 200 && parcelViewModal.status == 200) {
            log("API Response: ${response.body}");
            setState(() {
              allParcels = parcelViewModal.data ?? [];
              collectedParcels =
                  allParcels
                      .where((p) => p.deliveryStatus == "Collected")
                      .toList();
              inProgressParcels =
                  allParcels
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
          log("Error ave  che ${stackTrace}");
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
    return allParcels; // ✅ All
  }
}
