import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../open_ai_chatbot/view/open_ai_screen.dart';
import '../Model/service_booking_model.dart';
import '../Provider/booking_provider.dart';
import 'detailScreen.dart';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  List<String> categories = ['All', 'Pending Approval', 'Booking Confirmed'];
  int selectedCategory = 0;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> serviceBookingkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    ServiceBookingApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: serviceBookingkey,
      drawer: SideMenu(),
      body: Column(
        children: [
          SizedBox(height: 4.h),
          TitleBar(
            back: () {
              Get.back();
            },
            title: 'Service Booking',
            drawerCallback: () {
              serviceBookingkey.currentState?.openDrawer();
            },
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 5.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (selectedCategory != index) {
                      setState(() {
                        selectedCategory = index;
                        isLoading = true;
                      });
                      ServiceBookingApi();
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
                              ? const Color(0xFF734F96)
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
          isLoading
              ? Loader().paddingOnly(top: 30.h)
              : serviceBookingModel?.data?.length == 0 ||
                  serviceBookingModel?.data?.length == null
              ? Center(
                child: Text(
                  "No Service Booking Available",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontFamily: AppConstants.manrope,
                  ),
                ).paddingOnly(top: 30.h),
              )
              : Expanded(
                child: ListView.builder(
                  itemCount: serviceBookingModel?.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showMaintenanceDetailBottomSheet(
                          context,
                          serviceBookingModel?.data?[index].description ?? "",
                          serviceBookingModel?.data?[index].status ?? "",
                          serviceBookingModel?.data?[index].title ?? "",
                          serviceBookingModel?.data?[index].price ?? "",
                          serviceBookingModel?.data?[index].bookingDatetime ??
                              "",
                          imageUrl:
                              serviceBookingModel?.data?[index].images?[0],
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(2.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Status Row
                            Row(
                              children: [
                                Icon(
                                  serviceBookingModel?.data?[index].status ==
                                          'Booking Confirmed'
                                      ? Icons.check_circle
                                      : Icons.pending_rounded,
                                  color:
                                      serviceBookingModel
                                                  ?.data?[index]
                                                  .status ==
                                              'Booking Confirmed'
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  serviceBookingModel?.data?[index].status
                                          ?.toString()
                                          .capitalizeFirst ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: getStatusColor(
                                      serviceBookingModel?.data?[index].status
                                              ?.toString() ??
                                          "",
                                    ),
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),

                            /// Title
                            Text(
                              serviceBookingModel?.data?[index].title ?? "",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                            SizedBox(height: 1.h),

                            /// Description
                            ReadMoreText(
                              "${serviceBookingModel?.data?[index].description == null || serviceBookingModel?.data?[index].description == "" ? "N/A" : "${serviceBookingModel?.data?[index].description}"}",
                              trimLines: 2,
                              trimLength: 100,
                              colorClickableText: Colors.blue,
                              trimMode: TrimMode.Length,
                              trimCollapsedText: ' Show more',
                              trimExpandedText: ' Show less',
                              moreStyle: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manrope,
                                letterSpacing: 1,
                                color: AppColors.maincolor,
                              ),
                              lessStyle: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: AppConstants.manrope,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: AppColors.maincolor,
                              ),
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                            SizedBox(height: 1.h),

                            /// Price and Date Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "£${serviceBookingModel?.data?[index].totalPrice ?? "0.00"}",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                                serviceBookingModel
                                                ?.data?[index]
                                                .bookingDatetime ==
                                            null ||
                                        serviceBookingModel
                                                ?.data?[index]
                                                .bookingDatetime
                                                ?.length ==
                                            0
                                    ? SizedBox()
                                    : Text(
                                      formatDate(
                                        serviceBookingModel
                                            ?.data?[index]
                                            .bookingDatetime,
                                      ),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppConstants.manrope,
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
              ),
          SizedBox(height: 9.h),
        ],
      ).paddingSymmetric(horizontal: 3.w),
      floatingActionButton:
          isLoading
              ? Container()
              : Row(
                children: [
                  Spacer(),
                  FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(900),
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Get.to(() => const ChatBotScreen());
                    },
                    icon: Icon(
                      CupertinoIcons.chat_bubble_2,
                      color: Colors.black,
                    ),
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
                ],
              ),
    );
  }

  void showMaintenanceDetailBottomSheet(
    BuildContext context,
    String description,
    String type,
    String subject,
    String note,
    String created, {
    String? imageUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top handle
                Center(
                  child: Container(
                    height: 4,
                    width: 20.w,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                /// Image (if provided)
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                              Image(image: AssetImage(image)),
                    ),
                  ),
                if (imageUrl != null) SizedBox(height: 16),

                /// Heading
                Text(
                  "Booking Details",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 2.h),

                /// Details
                _detailRow("Title", subject),
                // _detailRow("Description", description),
                Row(
                  children: [
                    SizedBox(
                      width: 30.w,
                      child: Text(
                        "Description:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60.w,
                      child: ReadMoreText(
                        "${description == null || description == "" ? "N/A" : "${description}"}",
                        trimLines: 3,
                        trimLength: 60,
                        colorClickableText: Colors.blue,
                        trimMode: TrimMode.Length,
                        trimCollapsedText: ' Show more',
                        trimExpandedText: ' Show less',
                        // textAlign: TextAlign.right,
                        moreStyle: TextStyle(
                          fontSize: 15.sp,

                          fontWeight: FontWeight.bold,
                          fontFamily: AppConstants.manrope,
                          letterSpacing: 1,
                          color: AppColors.maincolor,
                        ),
                        lessStyle: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: AppConstants.manrope,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: AppColors.maincolor,
                        ),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ),
                  ],
                ),
                _detailRow("Price", "£${note ?? "-"}"),
                _detailRow(
                  "Status",
                  type.toString().capitalizeFirst ?? "",
                  color: getStatusColor(type),
                ),
                created == null || created.isEmpty
                    ? SizedBox()
                    : _detailRow("Booked", formatDate(created)),

                SizedBox(height: 24),

                /// Close Button
                batan(
                  title: "Close",
                  route: () {
                    Get.back();
                  },
                  color: AppColors.maincolor,
                  fontcolor: AppColors.white,
                  height: 5.h,
                  width: double.infinity,
                  fontsize: 18.sp,
                  radius: 12.0,
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: AppConstants.manrope,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black,
                fontSize: 15,
                fontFamily: AppConstants.manrope,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    return status == "pending" || status == "Pending"
        ? Colors.yellow.shade800
        : status == "booking confirmed" || status == "Booking Confirmed"
        ? Colors.green
        : Colors.black; // default color if none match
  }

  String getStatusFromTab(int index) {
    switch (index) {
      case 1:
        return "Pending Approval";
      case 2:
        return "Booking Confirmed";
      default:
        return ""; // For "All"
    }
  }

  ServiceBookingApi() async {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().ServiceBookingApi(
            loginModel?.data?.user?.id.toString() ?? '',
            getStatusFromTab(selectedCategory),
          );
          serviceBookingModel = ServiceBookingModel.fromJson(
            jsonDecode(response.body),
          );
          if (response.statusCode == 200) {
            log("API Response: ${response.body}");
            setState(() {
              aneminitiesDataModel = aneminitiesDataModel;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e, stackTrace) {
          log("Error ave che $stackTrace");
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

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat("dd-MM-yyyy hh:mm a").format(parsedDate);
    } catch (e) {
      return "N/A";
    }
  }
}
