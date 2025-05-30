import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wavee/Screen/Booking/View/book_amenities.dart';
import 'package:wavee/comman/custom_batan.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/viewPdfFunction.dart';
import '../Model/booking_model.dart';
import '../Provider/booking_provider.dart';
import 'booking_screen.dart';

class Form_Screen extends StatefulWidget {
  final String? amenites_id;
  final String? status;
  final String? EventName;
  final String? bookingId;
  final String? rsvp;
  final String? attend;
  final String? bookingDate;
  final String? requestedDate;
  final bool? isPage;

  Form_Screen({
    super.key,
    this.amenites_id,
    this.isPage,
    this.status,
    this.requestedDate,
    this.EventName,
    this.bookingDate,
    this.bookingId,
    this.rsvp,
    this.attend,
  });

  @override
  State<Form_Screen> createState() => _Form_ScreenState();
}

class _Form_ScreenState extends State<Form_Screen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyForm = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool load = false;
  int _currentIndex = 0;
  List<Map<String, dynamic>> dates = [];
  String selectedValue = 'days';
  int selectedIndex = 0;
  String? selectedDate;
  DateTime now = DateTime.now();
  DateTime selectedDay = DateTime.now();
  DateTime? selectedYear;
  bool isGlobalLoading = false;
  bool isRsvpLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
      load = true;
      DateTime today = DateTime.now();
      selectedDate = DateFormat('dd/MM/yyyy').format(today);
    });
    _generateDatesBasedOnSelection();
    AmenitiesApi();
  }

  @override
  Widget build(BuildContext context) {
    log("id ave che amenites ni ${widget.amenites_id}");
    log("Amenities Status Ave che che ${widget.status}");
    log("Amenities Status Ave che che ${widget.requestedDate}");
    return Scaffold(
      drawer: SideMenu(),
      key: _scaffoldKeyForm,
      backgroundColor: AppColors.bgcolor,
      body: Stack(
        children: [
          isLoading
              ? Loader()
              : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 4.h),
                    TitleBar(
                      back: () {
                        widget.isPage == true
                            ? Get.to(BookingScreen())
                            : Get.to(BookAmenities_Screen());
                      },
                      title: amenitiesModel?.data?[0].name ?? "",
                      drawerCallback: () {
                        _scaffoldKeyForm.currentState?.openDrawer();
                      },
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: amenitiesModel?.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          final booking = amenitiesModel?.data?[index];
                          final imageList = booking?.imageUrl ?? [];

                          int currentIndex = 0;

                          return StatefulBuilder(
                            // 👈 To manage index inside ListView item
                            builder: (context, setState) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 25.h,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CarouselSlider(
                                          options: CarouselOptions(
                                            autoPlay: true,
                                            viewportFraction: 1.0,
                                            enlargeCenterPage: false,
                                            height: 25.h,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                currentIndex = index;
                                              });
                                            },
                                          ),
                                          items:
                                              imageList.map((url) {
                                                return Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Image.network(
                                                      url,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (
                                                        context,
                                                        child,
                                                        progress,
                                                      ) {
                                                        if (progress == null)
                                                          return child;
                                                        return Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        );
                                                      },
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Center(
                                                            child: Icon(
                                                              Icons.error,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                    ).marginOnly(right: 0.5.w),
                                                    // Gradient overlay
                                                    Container(
                                                      decoration: const BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin:
                                                              Alignment
                                                                  .bottomCenter,
                                                          end:
                                                              Alignment
                                                                  .topCenter,
                                                          colors: [
                                                            Colors.black45,
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                      ),
                                                      margin: EdgeInsets.only(
                                                        right: 1.w,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        imageList.length,
                                        (dotIndex) {
                                          return AnimatedContainer(
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            width:
                                                currentIndex == dotIndex
                                                    ? 10
                                                    : 6,
                                            height:
                                                currentIndex == dotIndex
                                                    ? 10
                                                    : 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  currentIndex == dotIndex
                                                      ? AppColors.maincolor
                                                      : Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      booking?.name ?? '',
                                      style: TextStyle(
                                        color: AppColors.black,
                                        fontFamily: AppConstants.manrope,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),

                                    //
                                    // SizedBox(
                                    //   height: 1.h,
                                    // ),
                                    Container(
                                      width: 92.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ReadMoreText(
                                        "${booking?.description == null || booking?.description == "" ? "N/A" : "${booking?.description.toString().capitalize}"}",
                                        trimLines: 4,
                                        trimLength: 145,
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
                                    ),
                                    SizedBox(height: 2.h),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 3.w,
                                              vertical: 1.h,
                                            ),
                                            margin: EdgeInsets.only(right: 2.w),
                                            decoration: BoxDecoration(
                                              color:
                                                  booking?.status == "active"
                                                      ? Colors.white
                                                      : booking?.status ==
                                                          "inactive"
                                                      ? Colors.red
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  booking?.status == "active"
                                                      ? Icons.check_circle
                                                      : booking?.status ==
                                                          "inactive"
                                                      ? Icons.cancel
                                                      : null,
                                                  size: 18.sp,
                                                  color:
                                                      booking?.status ==
                                                              "active"
                                                          ? AppColors.maincolor
                                                          : booking?.status ==
                                                              "inactive"
                                                          ? Colors.white
                                                          : Colors.white,
                                                ),
                                                SizedBox(width: 2.w),
                                                Text(
                                                  "Status: ${booking?.status.toString().capitalizeFirst ?? ''}",
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        booking?.status ==
                                                                "active"
                                                            ? Colors.black
                                                            : booking?.status ==
                                                                "inactive"
                                                            ? Colors.white
                                                            : Colors.white,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 3.w,
                                              vertical: 1.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.book,
                                                  size: 18.sp,
                                                  color: AppColors.maincolor,
                                                ),
                                                SizedBox(width: 2.w),
                                                Text(
                                                  "Max Booking per Day: ${booking?.maxBookingPerDay}",
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Row(
                                      children: [
                                        Container(
                                          width: 47.w,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 3.w,
                                            vertical: 1.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.timer,
                                                size: 18.sp,
                                                color: AppColors.maincolor,
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                // widget.requestedDate == null
                                                //     ? "Amenity Date: ${formatDate(booking?.createdAt ?? 'N/A')}"
                                                //     : "Requested Date: ${widget.requestedDate}",
                                                "Duration Time: ${_formatDuration(booking?.durationOptions)}",

                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 1.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 3.w,
                                            vertical: 1.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.today,
                                                size: 18.sp,
                                                color: AppColors.maincolor,
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                "Capacity: ${booking?.capacity ?? ''}",
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      "Rules/Notice",
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontFamily: AppConstants.manrope,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          PdfView(
                                            link: booking?.rulesNotice ?? "",
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 10.h,
                                        width: 20.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          border: Border.all(
                                            width: 1,
                                            color: AppColors.maincolor,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: AppColors.maincolor,
                                          size: 30.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    isLoading
                        ? CircularProgressIndicator()
                        : widget.status != null
                        ? buildStatusContainer(
                          widget.status ?? "",
                          widget.EventName.toString() ?? "",
                          widget.bookingId ?? "",
                          rsvp: widget.rsvp,
                          isAttended: widget.attend,
                        )
                        : GestureDetector(
                          onTap: () {
                            submitBooking();
                          },
                          child: Container(
                            height: 6.h,
                            alignment: Alignment.center,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.maincolor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Book Now",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: AppColors.white,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Container(
                                  height: 5.h,
                                  width: 4.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.white),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Transform.translate(
                                        offset: Offset(-4, 0), // Left shifted
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(4, 0), // Right shifted
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ).paddingSymmetric(horizontal: 3.w),
              ),
          if (isGlobalLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
          if (isRsvpLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
    );
  }

  String _formatDuration(List<String>? durations) {
    if (durations == null || durations.isEmpty) return "N/A";

    int totalMinutes = int.tryParse(durations.first) ?? 0;

    if (totalMinutes < 60) {
      return "$totalMinutes min";
    } else {
      double hours = totalMinutes / 60;
      return "${hours.toStringAsFixed(1)} hr";
    }
  }

  bool _canShowAttendButton(
    String? eventDateStr, {
    String? cutoff = "2025-04-21",
  }) {
    if (eventDateStr == null) return false;

    final parsedEventDate = DateTime.tryParse(eventDateStr);
    final parsedCutoffDate = DateTime.tryParse(cutoff ?? "");
    if (parsedEventDate == null || parsedCutoffDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Only allow Attend if today is on or after the cutoff date (21st)
    return today.isAtSameMomentAs(parsedCutoffDate) ||
        today.isAfter(parsedCutoffDate);
  }

  // Widget buildStatusContainer(
  //   String status,
  //   String amenityName,
  //   String bookingID, {
  //   String? rsvp,
  //   String? isAttended,
  //       String? eventDateStr,
  // }) {
  //   String displayText = "";
  //   Color bgColor = Colors.grey;
  //   IconData icon = Icons.info;
  //   if (status == "Confirmed") {
  //     if (isAttended == "1") {
  //       displayText = "Attended";
  //       bgColor = Colors.blue;
  //       icon = Icons.done;
  //       return _statusBox(displayText, bgColor, icon);
  //     }
  //     else if ((rsvp == "accept" || rsvp == "maybe") &&
  //         _canShowAttendButton(eventDateStr))
  //     {
  //       displayText = "Attend";
  //       bgColor = Colors.indigo;
  //       icon = Icons.how_to_reg;
  //       return GestureDetector(
  //         onTap: () {
  //           _showAttendConfirmationDialog(
  //             context,
  //             amenityName,
  //             bookingID,
  //             rsvp,
  //           );
  //         },
  //         child: _statusBox(displayText, bgColor, icon),
  //       );
  //     } else if (rsvp == "decline") {
  //       displayText = "Declined";
  //       bgColor = Colors.redAccent;
  //       icon = Icons.cancel_outlined;
  //       return _statusBox(displayText, bgColor, icon);
  //     }
  //     else {
  //       displayText = "RSVP";
  //       bgColor = Colors.green;
  //       icon = Icons.event_available;
  //
  //       return GestureDetector(
  //         onTap: () {
  //           showRSVPDialog(context, amenityName, bookingID);
  //         },
  //         child: _statusBox(displayText, bgColor, icon),
  //       );
  //     }
  //   }
  //
  //   switch (status) {
  //     case "Pending":
  //       displayText = "Pending";
  //       bgColor = Colors.orange;
  //       icon = Icons.hourglass_top;
  //       break;
  //     case "Rejected":
  //       displayText = "Rejected";
  //       bgColor = Colors.red;
  //       icon = Icons.cancel_outlined;
  //       break;
  //     case "Completed":
  //       displayText = "Completed";
  //       bgColor = Colors.blue;
  //       icon = Icons.done_all;
  //       break;
  //     default:
  //       displayText = status;
  //       bgColor = AppColors.maincolor;
  //       icon = Icons.info_outline;
  //   }
  //
  //   return _statusBox(displayText, bgColor, icon);
  // }
  Widget buildStatusContainer(
    String status,
    String amenityName,
    String bookingID, {
    String? rsvp,
    String? isAttended,
  }) {
    String displayText = "";
    Color bgColor = Colors.grey;
    IconData icon = Icons.info;

    if (status == "Confirmed") {
      if (isAttended == 1) {
        // ✅ Already attended
        displayText = "Attended";
        bgColor = Colors.blue;
        icon = Icons.done;
        return _statusBox(displayText, bgColor, icon);
      } else if (rsvp == "accept" || rsvp == "maybe") {
        displayText = "Attend";
        bgColor = Colors.indigo;
        icon = Icons.how_to_reg;

        return GestureDetector(
          onTap: () {
            _showAttendConfirmationDialog(
              context,
              amenityName,
              bookingID,
              rsvp,
            );
          },
          child: _statusBox(displayText, bgColor, icon),
        );
      } else if (rsvp == "decline") {
        displayText = "Declined";
        bgColor = Colors.redAccent;
        icon = Icons.cancel_outlined;
        return _statusBox(displayText, bgColor, icon);
      } else {
        // No RSVP yet
        displayText = "RSVP";
        bgColor = Colors.green;
        icon = Icons.event_available;

        return GestureDetector(
          onTap: () {
            showRSVPDialog(context, amenityName, bookingID);
          },
          child: _statusBox(displayText, bgColor, icon),
        );
      }
    }
    switch (status) {
      case "Pending":
        displayText = "Pending";
        bgColor = Colors.orange;
        icon = Icons.hourglass_top;
        break;
      case "Rejected":
        displayText = "Rejected";
        bgColor = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      case "Completed":
        displayText = "Completed";
        bgColor = Colors.blue;
        icon = Icons.done_all;
        break;
      default:
        displayText = status;
        bgColor = AppColors.maincolor;
        icon = Icons.info_outline;
    }

    return _statusBox(displayText, bgColor, icon);
  }

  Widget _statusBox(String text, Color color, IconData icon) {
    return Container(
      height: 6.h,
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          SizedBox(width: 2.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontFamily: AppConstants.manrope,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void showRSVPDialog(
    BuildContext context,
    String eventName,
    String bookingID,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          insetPadding: EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.maincolor.withOpacity(0.1),
                  child: Icon(
                    Icons.event_available,
                    color: AppColors.maincolor,
                    size: 36,
                  ),
                ),
                SizedBox(height: 16),

                // Title
                Text(
                  "You're Invited!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                ),

                SizedBox(height: 8),
                Text(
                  "Would you like to RSVP for",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "\"$eventName\"",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maincolor,
                    fontFamily: AppConstants.manrope,
                  ),
                ),

                SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Maybe
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          RSVPAmenityApi(bookingID, 'maybe');
                          print("RSVP: Maybe");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.help_outline),
                            SizedBox(height: 4),
                            Text("Maybe"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Decline
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          RSVPAmenityApi(bookingID, 'decline');

                          print("RSVP: Declined");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cancel_outlined),
                            SizedBox(height: 4),
                            Text("Decline"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Accept
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          RSVPAmenityApi(bookingID, 'accept');

                          print("RSVP: Accepted");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maincolor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline),
                            SizedBox(height: 4),
                            Text("Accept"),
                          ],
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

  void _showAttendConfirmationDialog(
    BuildContext context,
    String eventName,
    bookingID,
    rsvp,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top icon
                CircleAvatar(
                  backgroundColor: AppColors.maincolor.withOpacity(0.1),
                  radius: 32,
                  child: Icon(
                    Icons.how_to_reg,
                    color: AppColors.maincolor,
                    size: 36,
                  ),
                ),
                SizedBox(height: 16),

                // Title
                Text(
                  "${loginModel?.data?.user?.name?.firstName ?? " "} ${loginModel?.data?.user?.name?.lastName ?? ""}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 8),

                // Subtitle
                Text(
                  "Do you want to mark yourself as attended for\n\"$eventName\"?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: AppConstants.manrope,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // No Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          RSVPAmenityAttend(bookingID, "0", rsvp);
                          print("User chose: No");
                          // NO logic here
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "No",
                          style: TextStyle(
                            fontFamily: AppConstants.manrope,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Yes Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          RSVPAmenityAttend(bookingID, "1", rsvp);

                          print("User chose: Yes");
                          // YES logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maincolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppConstants.manrope,
                            fontWeight: FontWeight.w500,
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

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(rawDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid date";
    }
  }

  void submitBooking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: Container(
            width: double.infinity,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            amenitiesModel?.data?[0].name ?? "",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.bold,
                            ),
                          ).paddingOnly(top: 2.h),
                        ],
                      ),
                      Divider(
                        thickness: 0.15.h,
                        color: Colors.grey,
                      ).paddingOnly(top: 1.h, bottom: 1.h),
                      Row(
                        children: [
                          Spacer(),
                          Container(
                            height: 5.h,
                            width: 37.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                icon: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 1.h,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.chevron_down,
                                    size: 16.sp,
                                    color: Colors.black,
                                  ),
                                ),
                                dropdownColor: Colors.white,
                                value: selectedValue,
                                isDense: true,
                                alignment: Alignment.bottomCenter,
                                items: [
                                  DropdownMenuItem(
                                    value: "days",
                                    child: Text(
                                      "This Week",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: AppConstants.manrope,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "month",
                                    child: Text(
                                      "This Month",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: AppConstants.manrope,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "year",
                                    child: Text(
                                      "This Year",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: AppConstants.manrope,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setModalState(() {
                                    selectedValue = value.toString();
                                  });
                                },
                              ),
                            ).paddingOnly(left: 2.w),
                          ),
                        ],
                      ).paddingOnly(right: 4.w),
                      SizedBox(height: 1.h),
                      isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.maincolor,
                            ),
                          )
                          : selectedValue == "days"
                          ? _buildWeekView().paddingOnly(
                            left: 4.w,
                            right: 4.w,
                            bottom: 2.h,
                          )
                          : selectedValue == "month"
                          ? _buildMonthView().paddingOnly(left: 4.w, right: 4.w)
                          : _buildYearView().paddingOnly(
                            left: 4.w,
                            right: 4.w,
                            bottom: 2.h,
                          ),
                      load
                          ? CircularProgressIndicator()
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _slotCard(
                                      countColor: Colors.black,
                                      statusColor: Colors.black,
                                      title: "Total Slots",
                                      value:
                                          amenitiesModel
                                              ?.data?[0]
                                              .totalBookingSlots
                                              .toString() ??
                                          "0",
                                      iconColor: Colors.white,
                                      background: Colors.black26,
                                      color: Colors.white,
                                      icon: Icons.event_available,
                                    ),
                                    _slotCard(
                                      title: "Booked",
                                      iconColor: AppColors.redColor,
                                      statusColor: Colors.white,
                                      countColor: Colors.white,
                                      background: Colors.white,
                                      value:
                                          amenitiesModel?.data?[0].bookedSlots
                                              .toString() ??
                                          "0",
                                      color: Colors.redAccent,
                                      icon: Icons.event_busy,
                                    ),
                                    _slotCard(
                                      title: "Available",
                                      value:
                                          amenitiesModel
                                              ?.data?[0]
                                              .availableSlots
                                              .toString() ??
                                          "0",
                                      iconColor: Colors.green,
                                      countColor: Colors.white,
                                      statusColor: Colors.white,
                                      background: Colors.white,
                                      color: Colors.green,
                                      icon: Icons.schedule,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child:
                                    isLoading
                                        ? CircularProgressIndicator()
                                        : batan(
                                          title: "Confirm Booking",
                                          route: () async {
                                            int available =
                                                int.tryParse(
                                                  amenitiesModel
                                                          ?.data?[0]
                                                          .availableSlots
                                                          .toString() ??
                                                      "0",
                                                ) ??
                                                0;

                                            if (available > 0) {
                                              // 1️⃣ Close the bottom sheet
                                              Navigator.pop(context);

                                              // 2️⃣ Show full screen loader
                                              setState(() {
                                                isGlobalLoading = true;
                                              });

                                              // 3️⃣ Wait a bit to show animation smoothly
                                              await Future.delayed(
                                                Duration(milliseconds: 300),
                                              );

                                              // 4️⃣ Call the API
                                              bool success =
                                                  await AddBookingApi();

                                              // 5️⃣ Hide loader (already handled inside AddBookingApi if you prefer)
                                              if (mounted) {
                                                setState(() {
                                                  isGlobalLoading = false;
                                                });
                                              }

                                              // ✅ Optional: Do something else if success
                                              if (success) {
                                                log("booked sucess");
                                              }
                                            } else {
                                              // ❌ No slots available
                                              Get.snackbar(
                                                "Sorry!",
                                                "No available slots for booking",
                                                backgroundColor:
                                                    AppColors.redColor,
                                                colorText: Colors.white,
                                                titleText: Text(
                                                  "Sorry!",
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                                messageText: Text(
                                                  "No available slots for booking",
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.white,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          color: AppColors.maincolor,
                                          fontcolor: Colors.white,
                                          height: 6.h,
                                          width: double.infinity,
                                          fontsize: 18.sp,
                                          radius: 12.0,
                                          fontWeight: FontWeight.normal,
                                          iconsize1: 22.sp,
                                          iconData1: Icons.check_circle_outline,
                                        ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showBookingConfirmedDialog({
    required BuildContext context,
    required String selectedDate,
  }) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(20),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48.sp,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Booking Confirmed!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                      fontFamily: AppConstants.manrope,
                      color: AppColors.maincolor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    "Your booking is successfully confirmed for:",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                      fontFamily: AppConstants.manrope,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 1.2.h,
                      horizontal: 4.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.maincolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today, // or Icons.event
                          size: 20.sp,
                          color: AppColors.maincolor,
                        ),
                        SizedBox(width: 2.w), // spacing between icon and text
                        Text(
                          selectedDate,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manrope,
                            color: AppColors.maincolor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Note",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // TextFormField(
                  //   maxLines: 3,
                  //   decoration: InputDecoration(
                  //     hintText: 'Enter note',
                  //     filled: true,
                  //     fillColor: AppColors.maincolor.withOpacity(0.1),
                  //     contentPadding:
                  //         EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 4.w),
                  //     hintStyle: TextStyle(
                  //       fontSize: 16.sp,
                  //       fontWeight: FontWeight.w500,
                  //       fontFamily: AppConstants.manrope,
                  //       color: Colors.black45,
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderSide: BorderSide.none,
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderSide: BorderSide(color: AppColors.maincolor),
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //   ),
                  //   style: TextStyle(
                  //     fontSize: 16.sp,
                  //     fontWeight: FontWeight.bold,
                  //     fontFamily: AppConstants.manrope,
                  //     color: AppColors.maincolor,
                  //   ),
                  // ),
                  // SizedBox(height: 3.h),
                  // batan(
                  //   title: "Ok",
                  //   route: () {
                  //     Get.off(() => BookingScreen(), arguments: {
                  //       'tabIndex': 0,
                  //     });
                  //   },
                  //   color: AppColors.maincolor,
                  //   fontcolor: Colors.white,
                  //   height: 5.h,
                  //   width: double.infinity,
                  //   fontsize: 18,
                  //   radius: 12.0,
                  // ),
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter note',
                      filled: true,
                      fillColor: AppColors.maincolor.withOpacity(0.1),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 1.2.h,
                        horizontal: 4.w,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppConstants.manrope,
                        color: Colors.black45,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.maincolor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                      color: AppColors.maincolor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a note';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 3.h),
                  batan(
                    title: "Ok",
                    route: () {
                      if (_formKey.currentState!.validate()) {
                        Get.off(
                          () => BookingScreen(),
                          arguments: {'tabIndex': 0},
                        );
                      }
                    },
                    color: AppColors.maincolor,
                    fontcolor: Colors.white,
                    height: 5.h,
                    width: double.infinity,
                    fontsize: 18,
                    radius: 12.0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _slotCard({
    required String title,
    required String value,
    required Color color,
    required Color background,
    required Color statusColor,
    required Color countColor,
    required Color iconColor,
    required IconData icon,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28.w,
        padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: background,
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: AppConstants.manrope,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: countColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.manrope,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateDatesBasedOnSelection() {
    DateTime today = DateTime.now();
    dates.clear();

    if (selectedValue == "days") {
      // **This Week Dates**
      DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      for (int i = 0; i < 7; i++) {
        DateTime date = startOfWeek.add(Duration(days: i));
        dates.add({
          'day': date.day.toString(),
          'weekday': _getWeekday(date.weekday),
          'fullDate': date,
        });

        if (date.day == today.day &&
            date.month == today.month &&
            date.year == today.year) {
          selectedIndex = i;
        }
      }
    }

    setState(() {}); // UI Update
  }

  DateTime? selectedCalendarDate;

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  DateTime today = DateTime.now();

  Widget _buildWeekView() {
    return Container(
      height: 12.h,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          DateTime date = dates[index]['fullDate'];
          bool isSelected = isSameDay(selectedCalendarDate, date);
          bool isToday = isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () async {
              setState(() {
                selectedIndex = index;
                selectedCalendarDate = date;
                selectedDate = DateFormat('dd/MM/yyyy').format(date);
              });

              await Future.delayed(Duration(milliseconds: 300));

              if (mounted) setState(() => load = true);

              var success = await AmenitiesApi(); // API call

              if (mounted) {
                setState(() {
                  load = false;
                  Navigator.pop(context);
                });
              }

              if (success) {
                submitBooking();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Something went wrong. Please try again."),
                  ),
                );
              }
            },
            child: Container(
              width: 20.w,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color:
                    isSelected || isToday ? AppColors.maincolor : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dates[index]['day']!,
                    style: TextStyle(
                      color:
                          isSelected || isToday ? Colors.white : Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  Text(
                    dates[index]['weekday']!,
                    style: TextStyle(
                      color:
                          isSelected || isToday ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontFamily: AppConstants.manrope,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthView() {
    return TableCalendar(
      firstDay: DateTime(now.year, now.month, 1),
      lastDay: DateTime(now.year, now.month + 1, 0),
      focusedDay: selectedCalendarDate ?? now,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontFamily: AppConstants.manrope,
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.black,
          fontFamily: AppConstants.manrope,
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
        ),
        weekendStyle: TextStyle(
          color: Colors.black,
          fontFamily: AppConstants.manrope,
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
        ),
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.maincolor,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
        todayTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
        defaultTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(selectedCalendarDate, day);
      },
      onDaySelected: (newSelectedDay, focusedDay) {
        setState(() {
          selectedCalendarDate = newSelectedDay;
          selectedDate = DateFormat('dd/MM/yyyy').format(newSelectedDay);
          load = true;
        });
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          bool isSelected = isSameDay(selectedCalendarDate, day);
          return GestureDetector(
            onTap: () async {
              setState(() {
                selectedCalendarDate = day;
                selectedDate = DateFormat('dd/MM/yyyy').format(day);
                load = true;
              });

              var success = await AmenitiesApi(); // Api call

              setState(() {
                load = false;
                Navigator.pop(context);
              });

              if (success) {
                submitBooking();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Something went wrong. Please try again."),
                  ),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.all(6.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.maincolor : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearView() {
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    DateTime lastDayOfYear = DateTime(now.year, 12, 31);
    return TableCalendar(
      firstDay: firstDayOfYear,
      lastDay: lastDayOfYear,
      focusedDay: selectedYear ?? now,
      currentDay: now,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontFamily: AppConstants.manrope,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.black,
          fontSize: 13.5,
          fontFamily: AppConstants.manrope,
        ),
        weekendStyle: TextStyle(
          color: Colors.black,
          fontSize: 13.5,
          fontFamily: AppConstants.manrope,
        ),
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.maincolor,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
        todayTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
        defaultTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(selectedYear, day);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          bool isSelected = isSameDay(selectedCalendarDate, day);
          return GestureDetector(
            onTap: () async {
              setState(() {
                selectedCalendarDate = day;
                selectedDate = DateFormat('dd/MM/yyyy').format(day);
                load = true;
              });

              var success = await AmenitiesApi(); // Api call

              setState(() {
                load = false;
                Navigator.pop(context);
              });

              if (success) {
                submitBooking();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Something went wrong. Please try again."),
                  ),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.all(6.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.maincolor : AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.black,
                  fontFamily: AppConstants.manrope,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      onDaySelected: (newSelectedDay, focusedDay) {
        setState(() {
          selectedYear = newSelectedDay; // Update selected day
          selectedDate = DateFormat('yyyy/MM/dd').format(newSelectedDay);
          load = true;
        });
        // projectlistap();
      },
      onPageChanged: (focusedDay) {
        // Prevent going to past months
        if (focusedDay.isBefore(firstDayOfYear)) {
          setState(() {
            selectedYear = firstDayOfYear; // Reset to current month
          });
        }
      },
    );
  }

  Future<bool> AmenitiesApi() async {
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return false;
    }

    try {
      var response = await AmenitiesProvider().AmenitiesApi(
        loginModel?.data?.user?.id.toString() ?? '',
        widget.amenites_id ?? "",
        selectedDate ?? "",
      );

      if (response.statusCode == 200) {
        amenitiesModel = AmenitiesModel.fromJson(jsonDecode(response.body));
        log("API Response: ${response.body}");
        setState(() {
          amenitiesModel = amenitiesModel;
          isLoading = false;
          load = false;
        });
        return true;
      } else {
        setState(() {
          isLoading = false;
          load = false;
        });
        return false;
      }
    } catch (e, stackTrace) {
      log("Error ave che $stackTrace");
      setState(() {
        isLoading = false;
        load = false;
      });
      return false;
    }
  }

  Future<bool> AddBookingApi() async {
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "amenity_id": widget.amenites_id ?? '',
      "date": selectedDate ?? "",
    };

    log("📤 Booking Data: $data");

    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return false;
    }

    try {
      var response = await AmenitiesProvider().AddBooking(data);

      if (response.statusCode == 200) {
        log("✅ Booking Success: ${response.body}");

        if (mounted) {
          setState(() {
            isGlobalLoading = false; // This is your full screen loader flag
          });
        }

        // Show confirmation dialog
        showBookingConfirmedDialog(
          context: context,
          selectedDate: selectedDate.toString(),
        );

        return true;
      } else {
        if (mounted) {
          setState(() {
            isGlobalLoading = false;
          });
        }

        Get.snackbar(
          "Booking Failed",
          "Something went wrong. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return false;
      }
    } catch (e, stackTrace) {
      log("❌ Booking Error: $e");
      log("StackTrace: $stackTrace");

      if (mounted) {
        setState(() {
          isGlobalLoading = false;
        });
      }

      Get.snackbar(
        "Error",
        "Something went wrong. Please try again later.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return false;
    }
  }

  Future<void> RSVPAmenityApi(String bookingid, String rsvp) async {
    setState(() {
      isRsvpLoading = true;
    });
    Map<String, String> data = {"booking_id": bookingid, "rsvp_status": rsvp};

    log("Data jay che che $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().RSVPtoAmenityApi(data);
          if (response.statusCode == 200) {
            log("API Response: ${response.body}");
            // eventBookingModal =
            //     EventBookingModal.fromJson(jsonDecode(response.body));
            if (mounted) {
              setState(() {
                isRsvpLoading = false;
              });
            }
            Get.to(BookingScreen()); // BookEventStatus();
            log(
              "sucess response data avve che event booking no${response.body}",
            );
          } else {
            setState(() {
              isRsvpLoading = false;
            });
          }
        } catch (e, stackTrace) {
          log("Error ave che $stackTrace");
          if (mounted) {
            setState(() {
              isRsvpLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isRsvpLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> RSVPAmenityAttend(
    String bookingid,
    String attended,
    String rsvp,
  ) async {
    setState(() {
      isRsvpLoading = true;
    });
    Map<String, String> data = {
      "booking_id": bookingid,
      "attended": attended,
      "rsvp_status": rsvp,
    };

    log("Data jay che che $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().RSVPtoAmenityApi(data);
          if (response.statusCode == 200) {
            log("API Response: ${response.body}");
            // eventBookingModal =
            //     EventBookingModal.fromJson(jsonDecode(response.body));
            if (mounted) {
              setState(() {
                isRsvpLoading = false;
              });
            }
            // BookEventStatus();
            log(
              "sucess response data avve che event booking no${response.body}",
            );
          } else {
            setState(() {
              isRsvpLoading = false;
            });
          }
        } catch (e, stackTrace) {
          log("Error ave che $stackTrace");
          if (mounted) {
            setState(() {
              isRsvpLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isRsvpLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
