import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:torn_ticket/torn_ticket.dart';
import 'package:wavee/Ui/Booking/modal/statusModal.dart';
import 'package:wavee/Utils/customSnackBars.dart';
import 'package:wavee/Utils/viewPdfFunction.dart';

import '../../../Services/themeServices.dart';
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/customBatan.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../Provider/bookingsProvider.dart';
import '../modal/bookingModel.dart';
import 'bookAmenities.dart';
import 'bookingScreen.dart';

class AmenitiesDetail extends StatefulWidget {
  final String? amenites_id;
  final String? status;
  final String? EventName;
  final String? bookingId;
  final String? rsvp;
  final String? attend;
  final String? bookingDate;
  final String? startTime;
  final String? endtime;
  final String? requestedDate;
  final bool? isPage;

  const AmenitiesDetail({
    super.key,
    this.amenites_id,
    this.isPage,
    this.status,
    this.requestedDate,
    this.EventName,
    this.bookingDate,
    this.bookingId,
    this.rsvp,
    this.startTime,
    this.endtime,
    this.attend,
  });

  @override
  State<AmenitiesDetail> createState() => _AmenitiesDetailState();
}

class _AmenitiesDetailState extends State<AmenitiesDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKeyForm = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool load = false;

  List<Map<String, dynamic>> dates = [];
  String selectedValue = 'days';
  int selectedIndex = 0;
  String? selectedDate;
  DateTime now = DateTime.now();
  DateTime selectedDay = DateTime.now();
  DateTime? selectedYear;
  bool isGlobalLoading = false;
  bool isRsvpLoading = false;
  bool showPlus30 = false;
  bool showBookingDetails = false;
  String? selectedSlotTime;
  String? selectedStartTime;
  String? selectEndTime;

  int selectedDurationInMinutes = 60;

  DateTime? getRequestedDate() {
    if (widget.requestedDate == null) return null;
    try {
      return DateFormat("yyyy-MM-dd hh:mm a").parse(widget.requestedDate!);
    } catch (e) {
      try {
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(widget.requestedDate!);
      } catch (e2) {
        print("Date parsing error: $e2");
        return null;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
      load = true;
      DateTime today = DateTime.now();
      selectedDate = DateFormat('dd/MM/yyyy').format(today);
    });
    focusedMonth = DateTime.now();
    selectedMonthIndex = focusedMonth.month - 1;

    calendar1SelectedDate = DateTime(
      focusedMonth.year,
      focusedMonth.month,
      focusedMonth.day,
    );
    calendar1SelectedDateStr = DateFormat(
      'dd/MM/yyyy',
    ).format(calendar1SelectedDate!);

    _generateDatesBasedOnSelection();
    AmenitiesApi(date: calendar1SelectedDateStr);

    statusApi();
  }

  int selectedMonthIndex = DateTime.now().month - 1;
  final List<String> calendar1Months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int calendar1SelectedMonthIndex = DateTime.now().month - 1;
  DateTime calendar1FocusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime? calendar1SelectedDate;
  String calendar1SelectedDateStr = '';
  bool calendar1Loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    final selectedAmenity = amenitiesModel?.data?.data?.first;
    DateTime now = DateTime.now();

    DateTime firstDay = DateTime(now.year, now.month, 1);
    DateTime lastDay = DateTime(now.year, now.month + 1, 0);
    DateTime requestedDay = getRequestedDate() ?? now;
    DateTime focusedDay =
    requestedDay.isBefore(firstDay)
        ? firstDay
        : requestedDay.isAfter(lastDay)
        ? lastDay
        : requestedDay;

    final String operatingHoursString =
    calendar1SelectedDate != null
        ? getOperatingHours(
      calendar1SelectedDate!,
      selectedAmenity?.operatingHours,
    )
        : "Select a date";

    return WillPopScope(
      onWillPop: () async {
        if (showBookingDetails) {
          setState(() {
            showBookingDetails = false;
            selectedStartTime = null;
          });
          return false;
        }

        widget.isPage == true
            ? Get.offAll(() => const BookingScreen())
            : Get.offAll(() => const BookAmenities_Screen());
        return false;
      },
      child: Scaffold(
        key: _scaffoldKeyForm,
        backgroundColor: theme.isDark ? Color(0xff1A1A1A) : AppColors.white,
        body: Stack(
          children: [
            isLoading
                ? Loader()
                : Column(
              children: [
                SizedBox(height: 6.h),
                TitleBar(
                  back: () {
                    if (showBookingDetails) {
                      setState(() {
                        showBookingDetails = false;
                        selectedStartTime = null;
                      });
                      return;
                    }
                    widget.isPage == true
                        ? Get.offAll(() => const BookingScreen())
                        : Get.offAll(() => const BookAmenities_Screen());
                  },
                  title: amenitiesModel?.data?.data?[0].name ?? "",
                  drawerCallback: () {},
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,

                            itemCount:
                            amenitiesModel?.data?.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              final booking =
                              amenitiesModel?.data?.data?[index];

                              final imageList = booking?.imageUrl ?? [];

                              int currentIndex = 0;

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 2.h),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        imageList.isEmpty
                                            ? Container(
                                          height: 25.h,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                              12,
                                            ),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                "assets/images/waveeLogoShort.png",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                            : Container(
                                          height: 25.h,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(
                                              12,
                                            ),
                                            child: CarouselSlider(
                                              options: CarouselOptions(
                                                autoPlay: true,
                                                viewportFraction: 1.0,
                                                enlargeCenterPage:
                                                false,
                                                height: 25.h,
                                                onPageChanged: (index,
                                                    reason,) {
                                                  setState(() {
                                                    currentIndex =
                                                        index;
                                                  });
                                                },
                                              ),
                                              items:
                                              imageList.map((url) {
                                                return Stack(
                                                  fit:
                                                  StackFit
                                                      .expand,
                                                  children: [
                                                    CachedNetworkImage(
                                                      imageUrl: url,
                                                      fit:
                                                      BoxFit
                                                          .cover,
                                                      placeholder:
                                                          (context,
                                                          url,) =>
                                                      const Center(
                                                        child:
                                                        CircularProgressIndicator(),
                                                      ),
                                                      errorWidget:
                                                          (context,
                                                          url,
                                                          error,) =>
                                                      const Center(
                                                        child: Icon(
                                                          Icons
                                                              .error,
                                                          color:
                                                          Colors.red,
                                                        ),
                                                      ),
                                                    ).marginOnly(
                                                      right: 0.5.w,
                                                    ),
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
                                                            Colors
                                                                .black45,
                                                            Colors
                                                                .transparent,
                                                          ],
                                                        ),
                                                      ),
                                                      margin:
                                                      EdgeInsets.only(
                                                        right:
                                                        1.w,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        if (imageList.length > 1)
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: List.generate(
                                              imageList.length,
                                                  (dotIndex) {
                                                    return AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 300,
                                                      ),
                                                      margin:
                                                      const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4,
                                                      ),
                                                      width:
                                                      currentIndex ==
                                                          dotIndex
                                                          ? 10
                                                          : 6,
                                                      height:
                                                      currentIndex ==
                                                          dotIndex
                                                          ? 10
                                                          : 6,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                        currentIndex ==
                                                            dotIndex
                                                            ? AppColors
                                                            .maincolor
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
                                            color:
                                            theme.isDark
                                                ? Colors.white
                                                : AppColors.black,
                                            fontFamily:
                                            AppConstants.manropeBold,
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Container(
                                          width: 92.w,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: ReadMoreText(
                                            booking?.description == null ||
                                                booking?.description ==
                                                    ""
                                                ? "N/A"
                                                : "${booking?.description
                                                .toString()
                                                .capitalizeFirst}",
                                            trimLines: 4,
                                            trimLength: 145,
                                            colorClickableText: Colors.blue,
                                            trimMode: TrimMode.Length,
                                            trimCollapsedText: ' Show more',
                                            trimExpandedText: ' Show less',
                                            moreStyle: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                              AppConstants.manrope,
                                              letterSpacing: 1,
                                              color:
                                              theme.isDark
                                                  ? Colors.white
                                                  : AppColors.maincolor,
                                            ),
                                            lessStyle: TextStyle(
                                              fontSize: 15.sp,
                                              fontFamily:
                                              AppConstants.manrope,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                              color:
                                              theme.isDark
                                                  ? Colors.white
                                                  : AppColors.maincolor,
                                            ),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color:
                                              theme.isDark
                                                  ? Colors.white
                                                  : Colors
                                                  .grey
                                                  .shade500,
                                              fontWeight: FontWeight.normal,
                                              fontFamily:
                                              AppConstants.manrope,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 1.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                  theme.isDark
                                                      ? Color(
                                                    0xff262626,
                                                  )
                                                      : Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    14,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(
                                                        0.05,
                                                      ),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                    color:
                                                    Colors
                                                        .grey
                                                        .shade400,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [

                                                    /// 🔹 Status Icon
                                                    Container(
                                                      padding:
                                                      EdgeInsets.all(
                                                        2.w,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                        theme.isDark
                                                            ? Color(
                                                          0xFFCFB583,
                                                        ).withValues(
                                                          alpha:
                                                          0.2,
                                                        )
                                                            : AppColors
                                                            .maincolor
                                                            .withOpacity(
                                                          0.12,
                                                        ),
                                                        shape:
                                                        BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        CupertinoIcons
                                                            .person_circle,
                                                        size: 18.sp,
                                                        color:
                                                        theme.isDark
                                                            ? Colors
                                                            .white
                                                            : AppColors
                                                            .maincolor,
                                                      ),
                                                    ),

                                                    SizedBox(width: 3.w),

                                                    /// 🔹 Text
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                            "Residents per Session",
                                                            style: TextStyle(
                                                              fontSize:
                                                              14.sp,
                                                              fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                              color:
                                                              theme.isDark
                                                                  ? Colors
                                                                  .white
                                                                  : Colors
                                                                  .grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 0.4.h,
                                                          ),
                                                          Text(
                                                            booking?.capacity
                                                                ?.toString() ??
                                                                "Unknown",
                                                            style: TextStyle(
                                                              fontSize:
                                                              15.sp,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              fontFamily:
                                                              AppConstants
                                                                  .manropeBold,
                                                              color:
                                                              theme.isDark
                                                                  ? Colors
                                                                  .white
                                                                  : Colors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            SizedBox(width: 2.w),

                                            Container(
                                              width: 39.w,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4.w,
                                                vertical: 1.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                theme.isDark
                                                    ? Color(0xff262626)
                                                    : Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(
                                                  14,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 10,
                                                    offset: const Offset(
                                                      0,
                                                      4,
                                                    ),
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color:
                                                  Colors.grey.shade400,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [

                                                  /// 🔹 Status Icon
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                      2.w,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                      theme.isDark
                                                          ? Color(
                                                        0xFFCFB583,
                                                      ).withValues(
                                                        alpha: 0.2,
                                                      )
                                                          : AppColors
                                                          .maincolor
                                                          .withOpacity(
                                                        0.12,
                                                      ),
                                                      shape:
                                                      BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.calendar_month,
                                                      size: 18.sp,
                                                      color:
                                                      theme.isDark
                                                          ? Colors.white
                                                          : AppColors
                                                          .maincolor,
                                                    ),
                                                  ),

                                                  SizedBox(width: 3.w),

                                                  /// 🔹 Text
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                          "Bookings Available",

                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                            color:
                                                            theme.isDark
                                                                ? Colors
                                                                .white
                                                                : Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 0.4.h,
                                                        ),
                                                        Text(
                                                          booking
                                                              ?.maxBookingPerMonth
                                                              ?.toString() ??
                                                              "Unknown",
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontFamily:
                                                            AppConstants
                                                                .manropeBold,
                                                            color:
                                                            theme.isDark
                                                                ? Colors
                                                                .white
                                                                : Colors
                                                                .black,
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
                                        SizedBox(height: 1.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4.w,
                                            vertical: 1.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                            booking?.status == "active"
                                                ? theme.isDark
                                                ? Color(0xff262626)
                                                : Colors.white
                                                : booking?.status ==
                                                "inactive"
                                                ? Colors.red.shade50
                                                : Colors.grey.shade200,
                                            borderRadius:
                                            BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                            border: Border.all(
                                              color:
                                              booking?.status ==
                                                  "active"
                                                  ? Colors.grey.shade400
                                                  : booking?.status ==
                                                  "inactive"
                                                  ? Colors.red
                                                  : Colors
                                                  .grey
                                                  .shade400,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [

                                              /// 🔹 Status Icon
                                              Container(
                                                padding: EdgeInsets.all(
                                                  2.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                  booking?.status ==
                                                      "active"
                                                      ? theme.isDark
                                                      ? Color(
                                                    0xff262626,
                                                  )
                                                      : AppColors
                                                      .maincolor
                                                      .withOpacity(
                                                    0.12,
                                                  )
                                                      : booking
                                                      ?.status ==
                                                      "inactive"
                                                      ? Colors.red
                                                      .withOpacity(
                                                    0.12,
                                                  )
                                                      : Colors
                                                      .grey
                                                      .shade300,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  booking?.status ==
                                                      "active"
                                                      ? Icons
                                                      .check_circle_rounded
                                                      : booking?.status ==
                                                      "inactive"
                                                      ? Icons.cancel_rounded
                                                      : Icons.info_outline,
                                                  size: 18.sp,
                                                  color:
                                                  booking?.status ==
                                                      "active"
                                                      ? theme.isDark
                                                      ? Colors.white
                                                      : AppColors
                                                      .maincolor
                                                      : booking
                                                      ?.status ==
                                                      "inactive"
                                                      ? Colors.red
                                                      : Colors
                                                      .grey
                                                      .shade700,
                                                ),
                                              ),

                                              SizedBox(width: 3.w),

                                              /// 🔹 Text
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      "Session Status",
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontFamily:
                                                        AppConstants
                                                            .manrope,
                                                        color:
                                                        theme.isDark
                                                            ? Colors
                                                            .white
                                                            : Colors
                                                            .grey
                                                            .shade600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 0.4.h),
                                                    Text(
                                                      booking?.status
                                                          ?.toString()
                                                          .capitalizeFirst ??
                                                          "Unknown",
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontFamily:
                                                        AppConstants
                                                            .manropeBold,
                                                        color:
                                                        booking?.status ==
                                                            "active"
                                                            ? theme.isDark
                                                            ? Colors
                                                            .white
                                                            : Colors
                                                            .black
                                                            : booking
                                                            ?.status ==
                                                            "inactive"
                                                            ? Colors.red
                                                            : Colors
                                                            .grey
                                                            .shade800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        GestureDetector(
                                          onTap: () {
                                            if (booking?.rulesNotice ==
                                                null ||
                                                booking!
                                                    .rulesNotice!
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "No rules available",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            /// 🔹 Open PDF / Image
                                            Get.to(
                                              PdfView(
                                                link: booking!.rulesNotice!,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              vertical: 1.h,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                              vertical: 1.6.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                              booking?.status ==
                                                  "active"
                                                  ? theme.isDark
                                                  ? Color(
                                                0xff262626,
                                              )
                                                  : Colors.white
                                                  : Colors
                                                  .grey
                                                  .shade300,
                                              borderRadius:
                                              BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(
                                                    0,
                                                    4,
                                                  ),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.grey.shade400,
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [

                                                /// 🔹 Leading Icon
                                                Container(
                                                  padding: EdgeInsets.all(
                                                    2.w,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                    booking?.status ==
                                                        "active"
                                                        ? theme.isDark
                                                        ? Colors
                                                        .white
                                                        : AppColors
                                                        .maincolor
                                                        .withOpacity(
                                                      0.12,
                                                    )
                                                        : Colors
                                                        .grey
                                                        .shade400,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .picture_as_pdf_rounded,
                                                    size: 18.sp,
                                                    color:
                                                    booking?.status ==
                                                        "active"
                                                        ? AppColors
                                                        .maincolor
                                                        : Colors
                                                        .grey
                                                        .shade700,
                                                  ),
                                                ),

                                                SizedBox(width: 3.w),

                                                /// 🔹 Text
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        "Rules & Notices",
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontFamily:
                                                          AppConstants
                                                              .manropeBold,
                                                          color:
                                                          booking?.status ==
                                                              "active"
                                                              ? theme.isDark
                                                              ? Colors
                                                              .white
                                                              : Colors
                                                              .black
                                                              : Colors
                                                              .grey
                                                              .shade700,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 0.4.h,
                                                      ),
                                                      Text(
                                                        "Tap to view guidelines & instructions",
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                          fontFamily:
                                                          AppConstants
                                                              .manrope,
                                                          color:
                                                          theme.isDark
                                                              ? Colors
                                                              .white
                                                              : Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                /// 🔹 Arrow
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 14.sp,
                                                  color:
                                                  booking?.status ==
                                                      "active"
                                                      ? theme.isDark
                                                      ? Colors.white
                                                      : Colors
                                                      .black54
                                                      : Colors
                                                      .grey
                                                      .shade600,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 1.h),

                                        SizedBox(height: 2.h),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            if (!showBookingDetails) ...[
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 150,
                                                    height: 4.5.h,
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                      AppColors.bgcolor,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                        12,
                                                      ),
                                                    ),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButton<
                                                          int
                                                      >(
                                                        dropdownColor:
                                                        Colors.white,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                        padding:
                                                        EdgeInsets.zero,
                                                        value:
                                                        calendar1SelectedMonthIndex,
                                                        items: List.generate(
                                                          calendar1Months
                                                              .length,
                                                              (index,
                                                              ) => DropdownMenuItem(
                                                            value: index,
                                                            child: Center(
                                                              child: Text(
                                                                calendar1Months[index],
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                                  color:
                                                                  AppColors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        onChanged:
                                                        widget.status ==
                                                            null
                                                            ? (value) {
                                                          if (value !=
                                                              null) {
                                                            setState(() {
                                                              calendar1SelectedMonthIndex =
                                                                  value;
                                                              calendar1FocusedMonth =
                                                                  DateTime(
                                                                    DateTime
                                                                        .now()
                                                                        .year,
                                                                    value +
                                                                        1,
                                                                    1,
                                                                  );
                                                              calendar1SelectedDate =
                                                                  calendar1FocusedMonth;
                                                              calendar1SelectedDateStr =
                                                                  DateFormat(
                                                                    'dd/MM/yyyy',
                                                                  ).format(
                                                                    calendar1SelectedDate!,
                                                                  );
                                                              selectedStartTime =
                                                              null;
                                                              AmenitiesApi(
                                                                date:
                                                                calendar1SelectedDateStr,
                                                              );
                                                            });
                                                          }
                                                        }
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Icon(
                                                    Icons.calendar_month,
                                                    color:
                                                    theme.isDark
                                                        ? Colors.white
                                                        : AppColors
                                                        .maincolor,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 2.h),
                                              widget.status == null
                                                  ? _buildCalendar1View()
                                                  : TableCalendar(
                                                firstDay: firstDay,
                                                lastDay: lastDay,
                                                focusedDay: focusedDay,
                                                calendarFormat:
                                                CalendarFormat
                                                    .month,
                                                headerVisible: false,
                                                daysOfWeekStyle: DaysOfWeekStyle(
                                                  weekdayStyle:
                                                  TextStyle(
                                                    color:
                                                    Colors
                                                        .black,
                                                    fontFamily:
                                                    AppConstants
                                                        .manrope,
                                                    fontSize: 13.5,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                  ),
                                                  weekendStyle:
                                                  TextStyle(
                                                    color:
                                                    Colors
                                                        .black,
                                                    fontFamily:
                                                    AppConstants
                                                        .manrope,
                                                    fontSize: 13.5,
                                                    fontWeight:
                                                    FontWeight
                                                        .normal,
                                                  ),
                                                ),
                                                calendarStyle: const CalendarStyle(
                                                  todayDecoration:
                                                  BoxDecoration(
                                                    color:
                                                    Colors.grey,
                                                    shape:
                                                    BoxShape
                                                        .circle,
                                                  ),
                                                  selectedDecoration:
                                                  BoxDecoration(
                                                    color:
                                                    AppColors
                                                        .maincolor,
                                                    shape:
                                                    BoxShape
                                                        .circle,
                                                  ),
                                                  selectedTextStyle:
                                                  TextStyle(
                                                    color:
                                                    Colors
                                                        .white,
                                                    fontFamily:
                                                    AppConstants
                                                        .manrope,
                                                  ),
                                                  todayTextStyle:
                                                  TextStyle(
                                                    color:
                                                    Colors
                                                        .white,
                                                    fontFamily:
                                                    AppConstants
                                                        .manrope,
                                                  ),
                                                  defaultTextStyle:
                                                  TextStyle(
                                                    color:
                                                    Colors
                                                        .black,
                                                    fontFamily:
                                                    AppConstants
                                                        .manrope,
                                                  ),
                                                  weekendTextStyle:
                                                  TextStyle(
                                                    color:
                                                    Colors
                                                        .black,
                                                    fontFamily:
                                                    AppConstants
                                                        .manrope,
                                                  ),
                                                  outsideTextStyle:
                                                  TextStyle(
                                                    color:
                                                    Colors.grey,
                                                  ),
                                                ),
                                                selectedDayPredicate: (day,) {
                                                  return isSameDay(
                                                    getRequestedDate(),
                                                    day,
                                                  );
                                                },
                                                calendarBuilders: CalendarBuilders(
                                                  defaultBuilder: (context,
                                                      day,
                                                      focusedDay,) {
                                                    bool
                                                    isSelected = isSameDay(
                                                      getRequestedDate(),
                                                      day,
                                                    );
                                                    bool isSameMonth =
                                                        day.month ==
                                                            focusedDay
                                                                .month;
                                                    return Container(
                                                      margin:
                                                      const EdgeInsets.all(
                                                        6.0,
                                                      ),
                                                      alignment:
                                                      Alignment
                                                          .center,
                                                      decoration: BoxDecoration(
                                                        color:
                                                        isSelected
                                                            ? AppColors
                                                            .maincolor
                                                            : Colors
                                                            .transparent,
                                                        shape:
                                                        BoxShape
                                                            .circle,
                                                      ),
                                                      child: Text(
                                                        '${day.day}',
                                                        style: TextStyle(
                                                          color:
                                                          isSameMonth
                                                              ? (isSelected
                                                              ? Colors.white
                                                              : Colors.black)
                                                              : Colors
                                                              .grey,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontFamily:
                                                          AppConstants
                                                              .manrope,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              widget.requestedDate != null
                                                  ? Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    getRequestedDate() !=
                                                        null
                                                        ? DateFormat(
                                                      "EEE, d MMM yyyy",
                                                    ).format(
                                                      getRequestedDate()!,
                                                    )
                                                        : "N/A",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                      FontWeight
                                                          .w600,
                                                      color:
                                                      AppColors
                                                          .maincolor,
                                                      fontFamily:
                                                      AppConstants
                                                          .manropeBold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  SizedBox(height: 6),

                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .access_time,
                                                          ),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            formatTime12(
                                                              widget
                                                                  .startTime,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize:
                                                              15.sp,
                                                              color:
                                                              Colors
                                                                  .black87,
                                                              fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                        width: 10,
                                                      ),

                                                      Text(
                                                        "→",
                                                        style: TextStyle(
                                                          fontSize:
                                                          15.sp,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color:
                                                          AppColors
                                                              .maincolor,
                                                        ),
                                                      ),

                                                      SizedBox(
                                                        width: 10,
                                                      ),

                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .access_time_outlined,
                                                          ),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            formatTime12(
                                                              widget
                                                                  .endtime,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize:
                                                              15.sp,
                                                              color:
                                                              Colors
                                                                  .black87,
                                                              fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                                  :_buildOperatingHoursExpansionTile(selectedAmenity?.operatingHours),

                                              // Column(
                                              //       children: [
                                              //         _buildSectionCard(
                                              //           title: "Opening Hours",
                                              //           icon: Icons.access_time,
                                              //           child:Container(),
                                              //         ),
                                              //         Text(
                                              //                                                         "Operating Hours: $operatingHoursString",
                                              //                                                         style: TextStyle(
                                              //         letterSpacing: 1,
                                              //         fontSize: 16.sp,
                                              //         color:
                                              //         theme.isDark
                                              //             ? Colors.white
                                              //             : AppColors
                                              //             .maincolor,
                                              //         fontFamily:
                                              //         AppConstants
                                              //             .manropeBold,
                                              //                                                         ),
                                              //                                                       ),
                                              //       ],
                                              //     ),

                                              if (calendar1SelectedDate !=
                                                  null &&
                                                  widget.status == null &&
                                                  !calendar1Loading) ...[
                                                Divider(height: 3.h),
                                                _buildOperatingHoursDisplay(
                                                  operatingHoursString,
                                                  selectedAmenity
                                                      ?.existingBookings ??
                                                      [],
                                                ),

                                                SizedBox(height: 2.h),

                                                // Time Selection from Operating Hours
                                                _buildTimeSelectionFromOperatingHours(
                                                  selectedAmenity
                                                      ?.operatingHours,
                                                ),
                                              ] else
                                                if (calendar1Loading)
                                                  Padding(
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                      vertical: 4.h,
                                                    ),
                                                    child: const Center(
                                                      child:
                                                      CircularProgressIndicator(),
                                                    ),
                                                  ),

                                              SizedBox(height: 2.h),
                                            ],
                                            if (showBookingDetails) ...[
                                              SizedBox(height: 2.h),
                                              Container(
                                                padding:
                                                const EdgeInsets.all(
                                                  16,
                                                ),
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color:
                                                  theme.isDark
                                                      ? Color(
                                                    0xf0252525,
                                                  )
                                                      : AppColors
                                                      .bgcolor,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                    12,
                                                  ),
                                                  border: Border.all(
                                                    color:
                                                    Colors
                                                        .grey
                                                        .shade300,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      booking?.name ??
                                                          "N/A",
                                                      style: TextStyle(
                                                        fontSize: 17.sp,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontFamily:
                                                        AppConstants
                                                            .manrope,
                                                      ),
                                                    ),
                                                    SizedBox(height: 3.h),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                      children: [
                                                        Flexible(
                                                          child: Column(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                size: 22.sp,
                                                                color:
                                                                theme.isDark
                                                                    ? AppColors
                                                                    .white
                                                                    : AppColors
                                                                    .maincolor,
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                calendar1SelectedDate !=
                                                                    null
                                                                    ? DateFormat(
                                                                  'EEE, d MMM',
                                                                ).format(
                                                                  calendar1SelectedDate!,
                                                                )
                                                                    : "",
                                                                textAlign:
                                                                TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                  fontSize:
                                                                  15.sp,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontFamily:
                                                                  AppConstants
                                                                      .manropeBold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Column(
                                                            children: [
                                                              Icon(
                                                                Icons.timer,
                                                                size: 22.sp,
                                                                color:
                                                                theme.isDark
                                                                    ? AppColors
                                                                    .white
                                                                    : AppColors
                                                                    .maincolor,
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                "$selectedStartTime",
                                                                textAlign:
                                                                TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize:
                                                                  15.sp,
                                                                  color:
                                                                  theme.isDark
                                                                      ? AppColors
                                                                      .white
                                                                      : Colors
                                                                      .black,
                                                                  fontFamily:
                                                                  AppConstants
                                                                      .manropeBold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Column(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .timelapse,
                                                                size: 22.sp,
                                                                color:
                                                                theme.isDark
                                                                    ? AppColors
                                                                    .white
                                                                    : AppColors
                                                                    .maincolor,
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                selectEndTime ??
                                                                    "N/A",

                                                                textAlign:
                                                                TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize:
                                                                  15.sp,
                                                                  color:
                                                                  theme.isDark
                                                                      ? AppColors
                                                                      .white
                                                                      : Colors
                                                                      .black,
                                                                  fontFamily:
                                                                  AppConstants
                                                                      .manropeBold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 3.h),
                                                    isGlobalLoading
                                                        ? Container(
                                                      height: 6.h,
                                                      alignment:
                                                      Alignment
                                                          .center,
                                                      width:
                                                      double
                                                          .infinity,
                                                      child: const CircularProgressIndicator(
                                                        color:
                                                        AppColors
                                                            .maincolor,
                                                      ),
                                                    )
                                                        : GestureDetector(
                                                      onTap: () {
                                                        AddBookingApi(
                                                          calendar1SelectedDateStr,
                                                          selectedStartTime!,

                                                          selectEndTime
                                                              .toString(),
                                                          selectedDurationInMinutes,
                                                          booking?.name ??
                                                              selectEndTime
                                                                  .toString(),

                                                        );
                                                      },
                                                      child: Container(
                                                        height: 6.h,
                                                        alignment:
                                                        Alignment
                                                            .center,
                                                        width:
                                                        double
                                                            .infinity,
                                                        decoration: BoxDecoration(
                                                          color:
                                                          AppColors.lightText,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          children: [
                                                            Text(
                                                              "Book Now",
                                                              style: TextStyle(
                                                                fontSize:
                                                                18.sp,
                                                                color:
                                                                AppColors.white,
                                                                fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                                fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                              3.w,
                                                            ),
                                                            Container(
                                                              height:
                                                              5.h,
                                                              width:
                                                              4.h,
                                                              alignment:
                                                              Alignment
                                                                  .center,
                                                              decoration: BoxDecoration(
                                                                shape:
                                                                BoxShape.circle,
                                                                border: Border
                                                                    .all(
                                                                  color:
                                                                  AppColors
                                                                      .white,
                                                                ),
                                                              ),
                                                              child: Stack(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                children: [
                                                                  Transform
                                                                      .translate(
                                                                    offset: const Offset(
                                                                      -4,
                                                                      0,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_forward_ios,
                                                                      color:
                                                                      Colors
                                                                          .white,
                                                                      size:
                                                                      14.sp,
                                                                    ),
                                                                  ),
                                                                  Transform
                                                                      .translate(
                                                                    offset: const Offset(
                                                                      4,
                                                                      0,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_forward_ios,
                                                                      color:
                                                                      Colors
                                                                          .white,
                                                                      size:
                                                                      14.sp,
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
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.status != null
                    ? buildStatusContainer(
                  widget.status ?? "",
                  widget.EventName.toString() ?? "",
                  widget.bookingId ?? "",
                  rsvp: widget.rsvp,
                  isAttended: widget.attend,
                )
                    : !showBookingDetails
                    ? GestureDetector(
                  // onTap: () {
                  //   if (amenitiesModel?.data?.data?[0].status ==
                  //       "inactive") {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         duration: Duration(milliseconds: 800),
                  //         content: Text(
                  //           "This amenity is currently inactive and cannot be booked.",
                  //         ),
                  //       ),
                  //     );
                  //     return;
                  //   }
                  //   final amenityData =
                  //       amenitiesModel?.data?.data?.first;
                  //   if (amenityData != null &&
                  //       amenityData.availableSlots != null &&
                  //       amenityData.availableSlots! <= 0) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         duration: Duration(milliseconds: 1200),
                  //         content: Text(
                  //           "Booking limit reached for this day. Please select another date.",
                  //         ),
                  //       ),
                  //     );
                  //     return;
                  //   }
                  //   if (calendar1SelectedDate == null) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         duration: Duration(milliseconds: 800),
                  //         content: Text(
                  //           "Please select a date before booking.",
                  //         ),
                  //       ),
                  //     );
                  //     return;
                  //   }
                  //
                  //   if (selectedStartTime == null ||
                  //       selectedStartTime!.isEmpty) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         duration: Duration(milliseconds: 800),
                  //         content: Text("Please select a start time."),
                  //       ),
                  //     );
                  //     return;
                  //   }
                  //
                  //   if (operatingHoursString == "Closed") {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //         duration: Duration(milliseconds: 800),
                  //         content: Text(
                  //           "Selected date is closed. Please choose another.",
                  //         ),
                  //       ),
                  //     );
                  //     return;
                  //   }
                  //
                  //   setState(() {
                  //     showBookingDetails = true;
                  //   });
                  // },
                  // In the build method where the Book Now button is
                  onTap: () {
                    if (amenitiesModel?.data?.data?[0].status == "inactive") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(milliseconds: 800),
                          content: Text(
                            "This amenity is currently inactive and cannot be booked.",
                          ),
                        ),
                      );
                      return;
                    }

                    final amenityData = amenitiesModel?.data?.data?.first;

                    // Check if available slots is "unlimited" or numeric and <= 0
                    String availableSlots = amenityData?.availableSlots
                        ?.toString() ?? "0";
                    bool isAvailableUnlimited = availableSlots.toLowerCase() ==
                        "unlimited";

                    // Only validate slots if NOT unlimited AND availableSlots <= 0
                    if (!isAvailableUnlimited && amenityData != null &&
                        amenityData.availableSlots != null &&
                        amenityData.availableSlots! <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(milliseconds: 1200),
                          content: Text(
                            "Booking limit reached for this day. Please select another date.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (calendar1SelectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(milliseconds: 800),
                          content: Text(
                            "Please select a date before booking.",
                          ),
                        ),
                      );
                      return;
                    }

                    if (selectedStartTime == null ||
                        selectedStartTime!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(milliseconds: 800),
                          content: Text("Please select a start time."),
                        ),
                      );
                      return;
                    }

                    if (operatingHoursString == "Closed") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(milliseconds: 800),
                          content: Text(
                            "Selected date is closed. Please choose another.",
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      showBookingDetails = true;
                    });
                  },
                  child: Container(
                    height: 6.h,
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                      (calendar1SelectedDate != null &&
                          operatingHoursString != "Closed")
                          ? AppColors.lightText
                          : Colors.grey,
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
                                offset: const Offset(-4, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 14.sp,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(4, 0),
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
                )
                    : const SizedBox(),
                SizedBox(height: 5.h),
              ],
            ).paddingSymmetric(horizontal: 3.w),
            if (isRsvpLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(child: Loader()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectionFromOperatingHours(OperatingHours? hours) {
    // List<Map<String, String>> timeSlots = _extractTimeSlotsFromOperatingHours(
    //   hours,
    //   calendar1SelectedDate!,
    // );

    List<Map<String, String>> baseSlots =
    _extractTimeSlotsFromOperatingHours(
      hours,
      calendar1SelectedDate!,
    );

    List<Map<String, String>> timeSlots =
    splitSlotByBookings(
      baseSlots,
      statusModal?.data ?? [],
      calendar1SelectedDate!,
    );
    final theme = context.watch<ThemeController>();

    final selectedAmenity = amenitiesModel?.data?.data?.first;
    int? maintenanceMins = int.tryParse(selectedAmenity?.maintenanceDuration ?? "0") ?? 0;
    bool showMaintenanceNote = maintenanceMins > 0;
    bool isAllDayBooking = selectedAmenity?.isAllDayBooking == "1";
    int allowedDuration =
    selectedAmenity?.durationOptions?.isNotEmpty == true
        ? int.tryParse(
      selectedAmenity!.durationOptions!.first.toString(),
    ) ??
        60
        : 60;
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.isDark ? Color(0xff262626) : AppColors.bgcolor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isAllDayBooking ? "Select Time Slot" : "Select Start Time",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manropeBold,
                  color: theme.isDark ? Colors.white : Colors.black,
                ),
              ),
              if (isAllDayBooking) ...[
                const Spacer(),
                isAlreadyBooked
                    ? SizedBox()
                    : batan(
                  title: "Custom Session",
                  route: () {

                    // if (timeSlots.isEmpty) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text("No slots available")),
                    //   );
                    //   return;
                    // }
                    //
                    // _showCustomTimePicker(
                    //   hours: hours,
                    //   selectedDate: calendar1SelectedDate!,
                    //
                    //   initialOpenTime: timeSlots.last['open'] ?? '09:00',
                    //   initialCloseTime: timeSlots.last['close'] ?? '10:00',
                    //
                    //   onTimeSelected: (startTime, endTime) {
                    //     setState(() {
                    //       selectedStartTime = startTime;
                    //       selectEndTime = endTime;
                    //
                    //       TimeOfDay start = _parseTimeOfDay(startTime);
                    //       TimeOfDay end = _parseTimeOfDay(endTime);
                    //
                    //       selectedDurationInMinutes =
                    //           _calculateDurationInMinutes(start, end);
                    //     });
                    //
                    //     addSlotAPi(
                    //       startTime,
                    //       endTime,
                    //       selectedAmenity?.name.toString() ?? "",
                    //     );
                    //   },
                    // );

                    Map<String, String> defaultSlot;

                    /// 🔥 If user already selected slot → use it
                    if (selectedStartTime != null &&
                        timeSlots.any((slot) => slot['open'] == selectedStartTime)) {
                      defaultSlot =
                          timeSlots.firstWhere((slot) => slot['open'] == selectedStartTime);
                    } else {
                      /// 🔥 Otherwise use LAST available slot
                      defaultSlot = timeSlots.last;
                    }

                    _showCustomTimePicker(
                      hours: hours,
                      selectedDate: calendar1SelectedDate!,
                      initialOpenTime: defaultSlot['open'] ?? '09:00',
                      initialCloseTime: defaultSlot['close'] ?? '10:00',
                      onTimeSelected: (startTime, endTime) {
                        setState(() {
                          selectedStartTime = startTime;
                          selectEndTime = endTime;

                          TimeOfDay start = _parseTimeOfDay(startTime);
                          TimeOfDay end = _parseTimeOfDay(endTime);

                          selectedDurationInMinutes =
                              _calculateDurationInMinutes(start, end);
                        });

                        addSlotAPi(
                          startTime,
                          endTime,
                          selectedAmenity?.name.toString() ?? "",
                        );
                      },
                    );
                  },
                  color: AppColors.lightText,
                  fontcolor: Colors.white,
                  height: 4.h,
                  radius: 12.0,
                  width: 40.w,
                  fontsize: 16.sp,
                ),
              ],
            ],
          ),
          SizedBox(height: 1.h),

          if (timeSlots.isEmpty)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                "No time slots available for selected date",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            )
          else
            Column(
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: timeSlots.asMap().entries.map((entry) {
                    final Map<String, String> slot = entry.value;
                    final String openTime = slot['open'] ?? '';
                    final String closeTime = slot['close'] ?? '';
                    final String displayTime = "$openTime - $closeTime";
                    final bool isSelected = selectedStartTime == openTime;

                    // ✅ Already booked check
                    // bool isBooked = _isSlotAlreadyBookedByMe(
                    //   openTime,
                    //   calendar1SelectedDate!,
                    // );
                    bool isBooked = _isSlotAlreadyBookedByMe(
                      openTime,
                      calendar1SelectedDate!,
                      slotCloseTime: closeTime, // ← add this
                    );
                    bool isInvalidDuration = false;

                    if (isAllDayBooking && openTime.isNotEmpty && closeTime.isNotEmpty) {
                      TimeOfDay open = _parseTimeOfDay(openTime);
                      TimeOfDay close = _parseTimeOfDay(closeTime);
                      int durationMins = _calculateDurationInMinutes(open, close);

                      /// 🔥 SLOT VALID ONLY IF MATCHES API DURATION
                      if (durationMins != allowedDuration) {
                        isInvalidDuration = true;
                      }
                    }
                    bool isDisabled = isBooked || isInvalidDuration;
                    return GestureDetector(
                      onTap: isDisabled
                          ? () {
                        // ✅ Over 90 min mate specific message
                        if (isInvalidDuration) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "This slot exceeds 90 minutes. Please use 'Custom Session' to select your preferred time.",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.orange.shade700,
                              duration: Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                          : () {
                        setState(() {
                          selectedStartTime = openTime;
                          if (isAllDayBooking) {
                            selectEndTime = closeTime;
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          // ✅ Over 90 min mate orange tint
                          color: isBooked
                              ? Colors.grey.shade300
                              :  isInvalidDuration
                              ? Colors.orange.shade50
                              : isSelected
                              ? AppColors.maincolor
                              : AppColors.bgcolor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isBooked
                                ? Colors.grey.shade400
                                : isInvalidDuration
                                ? Colors.orange.shade300
                                : isSelected
                                ? AppColors.maincolor
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayTime,
                              style: TextStyle(
                                color: isBooked
                                    ? Colors.grey.shade600
                                    : isInvalidDuration
                                    ? Colors.orange.shade800
                                    : isSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: AppConstants.manrope,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                decoration: isBooked
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (isBooked)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  "Booked",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.red,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            // ✅ NEW: Over 90 min label
                            if (isInvalidDuration)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  "Use Custom Session",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.orange.shade700,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (timeSlots.isNotEmpty && showMaintenanceNote) ...[
                  SizedBox(height: 1.5.h),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 16.sp,
                          color: Colors.amber.shade800,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            "+$maintenanceMins minute${maintenanceMins > 1 ? 's' : ''} maintenance time included before next booking",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.amber.shade800,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
  List<Map<String, String>> _extractTimeSlotsFromOperatingHours(
      OperatingHours? hours,
      DateTime selectedDate,
      ) {
    List<Map<String, String>> timeSlots = [];

    if (hours == null) return timeSlots;

    final weekday = getWeekdayName(selectedDate).toLowerCase();
    List<TimeSlot>? timeSlotObjects;

    switch (weekday) {
      case 'monday':
        timeSlotObjects = hours.monday;
        break;
      case 'tuesday':
        timeSlotObjects = hours.tuesday;
        break;
      case 'wednesday':
        timeSlotObjects = hours.wednesday;
        break;
      case 'thursday':
        timeSlotObjects = hours.thursday;
        break;
      case 'friday':
        timeSlotObjects = hours.friday;
        break;
      case 'saturday':
        timeSlotObjects = hours.saturday;
        break;
      case 'sunday':
        timeSlotObjects = hours.sunday;
        break;
    }

    if (timeSlotObjects == null || timeSlotObjects.isEmpty) {
      return timeSlots;
    }

    // Get the all-day booking flag (as string comparison)
    final selectedAmenity = amenitiesModel?.data?.data?.first;
    bool isAllDayBooking = selectedAmenity?.isAllDayBooking == "1";

    print("Extracting time slots - isAllDayBooking: $isAllDayBooking");
    print("Time slot objects count: ${timeSlotObjects.length}");

    for (var slot in timeSlotObjects) {
      if (slot.open != null && slot.open!.isNotEmpty) {
        // Format open time to 12-hour format
        String formattedOpen = _formatTimeTo12Hour(slot.open!);

        // Format close time if available
        String formattedClose = '';
        if (slot.close != null && slot.close!.isNotEmpty) {
          formattedClose = _formatTimeTo12Hour(slot.close!);
        }
        timeSlots.add({
          'open': formattedOpen,
          'close': formattedClose,
          'rawOpen': slot.open!,
          'rawClose': slot.close ?? '',
        });

        print("Added slot: $formattedOpen - $formattedClose");
      }
    }

    return timeSlots;
  }
  String getOperatingHours(DateTime selectedDate, OperatingHours? hours) {
    if (hours == null) return "No operating hours available";

    final weekday = getWeekdayName(selectedDate).toLowerCase();
    List<TimeSlot>? timeSlots;

    switch (weekday) {
      case 'monday':
        timeSlots = hours.monday;
        break;
      case 'tuesday':
        timeSlots = hours.tuesday;
        break;
      case 'wednesday':
        timeSlots = hours.wednesday;
        break;
      case 'thursday':
        timeSlots = hours.thursday;
        break;
      case 'friday':
        timeSlots = hours.friday;
        break;
      case 'saturday':
        timeSlots = hours.saturday;
        break;
      case 'sunday':
        timeSlots = hours.sunday;
        break;
    }

    if (timeSlots == null || timeSlots.isEmpty) {
      return "Closed";
    }

    final selectedAmenity = amenitiesModel?.data?.data?.first;
    bool isAllDayBooking = selectedAmenity?.isAllDayBooking == "1";

    List<String> formattedSlots = [];
    for (var slot in timeSlots) {
      if (slot.open != null && slot.open!.isNotEmpty) {
        String formattedOpen = _formatTimeTo12Hour(slot.open!);

        if (slot.close != null && slot.close!.isNotEmpty) {
          String formattedClose = _formatTimeTo12Hour(slot.close!);
          // Always show both open and close times since we have multiple slots
          formattedSlots.add('$formattedOpen - $formattedClose');
        } else {
          formattedSlots.add(formattedOpen);
        }
      }
    }

    return formattedSlots.isEmpty ? "Closed" : formattedSlots.join(', ');
  }

  Widget _buildOperatingHoursDisplay(String operatingHoursStr,
      List<ExistingBooking> existingBookings,)
  {
    final theme = context.watch<ThemeController>();
    final selectedAmenity = amenitiesModel?.data?.data?.first;
    int? maintenanceMins = int.tryParse(selectedAmenity?.maintenanceDuration??"0")??0;
    bool showMaintenanceNote = maintenanceMins != null && maintenanceMins > 0;
    bool isAllDayBooking = selectedAmenity?.isAllDayBooking == 1;

    // Check if values are "unlimited" or numeric
    String totalSlots = amenitiesModel?.data?.data?[0].totalBookingSlots
        ?.toString() ?? "0";
    String bookedSlots = amenitiesModel?.data?.data?[0].bookedSlots
        ?.toString() ?? "0";
    String availableSlots = amenitiesModel?.data?.data?[0].availableSlots
        ?.toString() ?? "0";

    // Check if any value is "unlimited"
    bool isTotalUnlimited = totalSlots.toLowerCase() == "unlimited";
    bool isBookedUnlimited = bookedSlots.toLowerCase() == "unlimited";
    bool isAvailableUnlimited = availableSlots.toLowerCase() == "unlimited";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: buildSlotBox(
                label: 'Total',
                value: isTotalUnlimited ? "Unlimited" : totalSlots,
                color: theme.isDark ? Color(0xff262626) : Colors.blue,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: buildSlotBox(
                label: 'Booked',
                value: isBookedUnlimited ? "Unlimited" : bookedSlots,
                color: theme.isDark ? Color(0xff262626) : Colors.red,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: buildSlotBox(
                label: 'Available',
                value: isAvailableUnlimited ? "Unlimited" : availableSlots,
                color: theme.isDark ? Color(0xff262626) : Colors.green,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        if (existingBookings.isNotEmpty)
          Column(
            children: [
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 18,
                          color: Colors.orange.shade700,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          "Already Booked:",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                            fontFamily: AppConstants.manropeBold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    ...existingBookings.map((booking) {
                      String startFormatted = _formatTimeTo12Hour(
                          booking.startTime ?? '');

                      // For all-day booking, show both start and end times
                      if (isAllDayBooking) {
                        String endFormatted = _formatTimeTo12Hour(booking
                            .endTime ?? '');
                        return Padding(
                          padding: EdgeInsets.only(bottom: 0.5.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                "$startFormatted - $endFormatted",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.orange.shade900,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // For regular booking, show only start time
                        return Padding(
                          padding: EdgeInsets.only(bottom: 0.5.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                startFormatted,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.orange.shade900,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  DateTime _timeToDateTime(String time, DateTime date) {
    time = time.trim();

    /// CASE 1 → 24h format "13:45" or "13:45:00"
    if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(time) && !time.contains("AM") && !time.contains("PM")) {
      final parts = time.split(":");
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    /// CASE 2 → 12h format "01:45 PM"
    try {
      final parsed = DateFormat("hh:mm a").parse(time);
      return DateTime(
        date.year,
        date.month,
        date.day,
        parsed.hour,
        parsed.minute,
      );
    } catch (_) {}

    /// CASE 3 → fallback try with seconds "01:45:00 PM"
    try {
      final parsed = DateFormat("hh:mm:ss a").parse(time);
      return DateTime(
        date.year,
        date.month,
        date.day,
        parsed.hour,
        parsed.minute,
      );
    } catch (_) {}

    /// FINAL fallback to avoid crash
    return DateTime(date.year, date.month, date.day, 0, 0);
  }
  String _formatTime(DateTime dt) {
    return DateFormat("HH:mm").format(dt);
  }


  List<Map<String, String>> splitSlotByBookings(
      List<Map<String, String>> slots,
      List bookingData,
      DateTime selectedDate,
      ) {
    List<Map<String, String>> result = [];

    for (var slot in slots) {
      DateTime slotStart = _timeToDateTime(slot['open']!, selectedDate);
      DateTime slotEnd = _timeToDateTime(slot['close']!, selectedDate);

      DateTime currentStart = slotStart;

      /// Sort bookings by start time (important)
      List filteredBookings = bookingData.where((b) =>
      b.bookingDate ==
          DateFormat('yyyy-MM-dd').format(selectedDate)).toList();

      filteredBookings.sort((a, b) =>
          a.startTime.compareTo(b.startTime));

      for (var booking in filteredBookings) {
        DateTime bookedStart =
        _timeToDateTime(booking.startTime, selectedDate);
        DateTime bookedEnd =
        _timeToDateTime(booking.endTime, selectedDate);

        /// Add free time before booked slot
        if (currentStart.isBefore(bookedStart)) {
          result.add({
            "open": _formatTime(currentStart),
            "close": _formatTime(bookedStart),
          });
        }

        /// Move pointer after booking
        if (bookedEnd.isAfter(currentStart)) {
          currentStart = bookedEnd;
        }
      }

      /// Add remaining time after last booking
      if (currentStart.isBefore(slotEnd)) {
        result.add({
          "open": _formatTime(currentStart),
          "close": _formatTime(slotEnd),
        });
      }
    }

    return result;
  }
  Widget buildSlotBox({
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = context.watch<ThemeController>();

    return Container(
      height: 5.h,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white38),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$label : ",
              style: TextStyle(
                fontSize: 15.sp,
                color: theme.isDark ? Colors.white : Colors.black87,
                fontFamily: AppConstants.manropeBold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              width: value == "Unlimited" ? 15.w : 10.w,
              // More width for "Unlimited"
              child: Text(
                value,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: value == "Unlimited" ? 13.sp : 15.sp,
                  // Slightly smaller for "Unlimited"
                  fontFamily: AppConstants.manrope,
                  fontWeight: FontWeight.w600,
                  color: theme.isDark ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getWeekdayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return '';
    }
  }

  String formatTime12(String? time24) {
    if (time24 == null || time24.isEmpty) return '';

    try {
      final format24 = DateFormat("HH:mm");
      final dt = format24.parse(time24);
      return DateFormat("h:mm a").format(dt);
    } catch (e) {
      try {
        final format12 = DateFormat("h:mm a");
        final dt = format12.parse(time24);
        return DateFormat("h:mm a").format(dt);
      } catch (e2) {
        return time24;
      }
    }
  }

  Widget buildStatusContainer(String status,
      String amenityName,
      String bookingID, {
        String? rsvp,
        String? isAttended,
      }) {
    String displayText = "";
    Color bgColor = Colors.grey;
    IconData icon = Icons.info;
    if (status == "Confirmed") {
      if (isAttended == "1") {
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
            if (bookingID.isNotEmpty) {
              _showAttendConfirmationDialog(
                context,
                amenityName,
                bookingID,
                rsvp,
              );
            }
          },
          child: _statusBox(displayText, bgColor, icon),
        );
      } else if (rsvp == "decline") {
        displayText = "Declined";
        bgColor = Colors.redAccent;
        icon = Icons.cancel_outlined;
        return _statusBox(displayText, bgColor, icon);
      } else {
        displayText = "RSVP";
        bgColor = Colors.green;
        icon = Icons.event_available;
        return GestureDetector(
          onTap: () {
            if (bookingID.isNotEmpty) {
              showRSVPDialog(context, amenityName, bookingID);
            }
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

  void showRSVPDialog(BuildContext context,
      String eventName,
      String bookingID,) {
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.maincolor.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.event_available,
                    color: AppColors.maincolor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "You're Invited!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manropeBold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Would you like to RSVP for",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\"$eventName\"",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maincolor,
                    fontFamily: AppConstants.manropeBold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();

                          RSVPAmenityApi(bookingID, 'maybe');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.help_outline, size: 20),
                            SizedBox(height: 4),
                            Text("Maybe"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          RSVPAmenityApi(bookingID, 'decline');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cancel_outlined, size: 20),
                            SizedBox(height: 4),
                            Text("Decline"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();

                          RSVPAmenityApi(bookingID, 'accept');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maincolor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
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

  void _showAttendConfirmationDialog(BuildContext context,
      String eventName,
      bookingID,
      rsvp,) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.maincolor.withValues(alpha: 0.1),
                  radius: 32,
                  child: const Icon(
                    Icons.how_to_reg,
                    color: AppColors.maincolor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${loginModel?.data?.user?.name?.firstName ?? " "} ${loginModel?.data?.user?.name?.lastName ?? ""}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manropeBold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Do you want to mark yourself as attended for\n\"$eventName\"?",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: AppConstants.manrope,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          RSVPAmenityAttend(bookingID, "1", rsvp);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maincolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
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

  void showTornTicketDialog({
    required BuildContext context,
    required String selectedDate,
    required String selectedTime,
    required String endTime,
    required String duration,
    required String location,
    required String attendeeInitials,
  }) {
    final theme = Provider.of<ThemeController>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(top: 40),
                child: TornTicket(
                  backgroundColor:
                  theme.isDark ? Color(0xff262626) : Colors.white,
                  height: 51.h,
                  borderRadius: 12,

                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 3.h + 10),
                          Center(
                            child: Text(
                              "Thank you!",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manrope,
                                color:
                                theme.isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: Text(
                              "Your booking was successful",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppConstants.manrope,
                                color:
                                theme.isDark ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                          const Divider(height: 30, thickness: 1),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:
                              theme.isDark
                                  ? Color(0xff262626)
                                  : Colors.grey.withValues(alpha: 0.20),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color:
                                      theme.isDark
                                          ? Colors.white
                                          : Colors.amber[800],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      selectedDate.replaceAll('/', '-'),
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                        color:
                                        theme.isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_filled,
                                      color:
                                      theme.isDark
                                          ? Colors.white
                                          : Colors.green[700],
                                      size: 22,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      selectedTime,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                        color:
                                        theme.isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward,
                                      color:
                                      theme.isDark
                                          ? Colors.white
                                          : Colors.black,
                                      size: 15.sp,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      endTime,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                        color:
                                        theme.isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.timelapse,
                                      color:
                                      theme.isDark
                                          ? Colors.white
                                          : Colors.blue[700],
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      duration,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                        color:
                                        theme.isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 3.h),

                          Text(
                            "Amenities",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.isDark ? Colors.white : Colors.black,
                              fontFamily: AppConstants.manropeBold,
                              letterSpacing: 1,
                            ),
                          ),

                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppConstants.manropeBold,
                              color: theme.isDark ? Colors.white : Colors.black,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          batan(
                            title: "Back to Home",
                            route: () {
                              Get.offAll(() => const BookingScreen());
                            },
                            color:
                            theme.isDark
                                ? Color(0xffCBB88C)
                                : AppColors.maincolor,
                            fontcolor:
                            theme.isDark ? Colors.black : Colors.white,
                            height: 5.h,
                            width: double.infinity,
                            fontsize: 18.sp,
                            radius: 12.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.maincolor,
                  child: Icon(Icons.check, size: 25.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _generateDatesBasedOnSelection() {
    DateTime today = DateTime.now();
    dates.clear();
    if (selectedValue == "days") {
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
    setState(() {});
  }

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

  DateTime focusedMonth = DateTime.now();

  Widget _buildCalendar1View() {
    final DateTime now = DateTime.now();
    final DateTime todayOnly = DateTime(now.year, now.month, now.day);

    calendar1SelectedDate ??= todayOnly;
    calendar1SelectedDateStr = DateFormat(
      'dd/MM/yyyy',
    ).format(calendar1SelectedDate!);

    final theme = context.watch<ThemeController>();
    final bool isDark = theme.isDark;

    // Theme based colors
    final Color primaryTextColor = isDark ? Colors.white : Colors.black;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.black87;
    final Color disabledTextColor = isDark ? Colors.white30 : Colors.grey;
    final Color todayBgColor = isDark ? Colors.white24 : Colors.grey[300]!;

    final DateTime kFirstDay = DateTime(now.year - 1, now.month, 1);
    final DateTime kLastDay = DateTime(now.year + 1, now.month + 1, 0);

    return TableCalendar(
      firstDay: kFirstDay,
      lastDay: kLastDay,
      focusedDay: calendar1FocusedMonth,
      calendarFormat: CalendarFormat.month,
      headerVisible: false,

      // Header tame custom banavyu hoy em lage che
      selectedDayPredicate: (day) => isSameDay(calendar1SelectedDate, day),

      enabledDayPredicate: (day) {
        final DateTime dayOnly = DateTime(day.year, day.month, day.day);
        return !dayOnly.isBefore(todayOnly);
      },

      onPageChanged: (focusedDay) {
        setState(() {
          calendar1FocusedMonth = focusedDay;
        });
      },

      // onDaySelected: (newSelectedDay, focusedDay) {
      //   setState(() {
      //     calendar1SelectedDate = newSelectedDay;
      //     calendar1SelectedDateStr = DateFormat(
      //       'dd/MM/yyyy',
      //     ).format(newSelectedDay);
      //     calendar1FocusedMonth = focusedDay;
      //     calendar1Loading = true;
      //     selectedStartTime = null;
      //   });
      //
      //   AmenitiesApi(date: calendar1SelectedDateStr).then((_) {
      //     setState(() {
      //       calendar1Loading = false;
      //     });
      //   });
      // },
      onDaySelected: (newSelectedDay, focusedDay) {
        setState(() {
          calendar1SelectedDate = newSelectedDay;
          calendar1SelectedDateStr =
              DateFormat('dd/MM/yyyy').format(newSelectedDay);
          calendar1FocusedMonth = focusedDay;
          calendar1Loading = true;
          selectedStartTime = null;
        });

        AmenitiesApi(date: calendar1SelectedDateStr).then((_) {
          statusApi(); // Add this to refresh booking status
          setState(() {
            calendar1Loading = false;
          });
        });
      },
      // --- Styling Section ---
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: secondaryTextColor,
          fontFamily: AppConstants.manropeBold,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: secondaryTextColor,
          fontFamily: AppConstants.manropeBold,
          fontWeight: FontWeight.w600,
        ),
      ),

      calendarStyle: CalendarStyle(
        // Ahiya default styles che, pan Builders badhu override kari deshe
        outsideDaysVisible: true,
      ),

      calendarBuilders: CalendarBuilders(
        // 1. Regular Days
        defaultBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(
            day: day,
            textColor: primaryTextColor,
            isBold: false,
          );
        },

        // 2. Selected Day
        selectedBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(
            day: day,
            textColor: Colors.white,
            bgColor: AppColors.lightText,
            isBold: true,
          );
        },

        // 3. Today
        todayBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(
            day: day,
            textColor: primaryTextColor,
            bgColor: todayBgColor,
            isBold: true,
          );
        },

        // 4. Disabled Days (Past dates)
        disabledBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(
            day: day,
            textColor: disabledTextColor,
            isBold: false,
          );
        },

        // 5. Outside Days (Next/Prev month dates)
        outsideBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(
            day: day,
            textColor: disabledTextColor,
            isBold: false,
          );
        },
      ),
    );
  }

  // Common Helper function for cleaner code
  Widget _buildCalendarDay({
    required DateTime day,
    required Color textColor,
    Color? bgColor,
    bool isBold = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontFamily: AppConstants.manrope,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<bool> AmenitiesApi({required String date}) async {
    if (date.isEmpty) return false;
    if (!load) {
      setState(() {
        calendar1Loading = true;
      });
    }
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      if (mounted) buildErrorDialog(context, 'Error', "Internet Required");
      setState(() {
        isLoading = false;
        load = false;
        calendar1Loading = false;
      });
      return false;
    }
    try {
      var response = await AmenitiesProvider().amenitiesApi(
        loginModel?.data?.user?.id.toString() ?? '',
        widget.amenites_id ?? "",
        date,
        '',
      );
      if (response.statusCode == 200) {
        amenitiesModel = AmenitiesModel.fromJson(response.data);

        if (amenitiesModel?.data?.data?.isNotEmpty == true &&
            amenitiesModel!.data!.data!.first.durationOptions?.isNotEmpty ==
                true) {
          selectedDurationInMinutes =
              int.tryParse(
                amenitiesModel!.data!.data!.first.durationOptions!.first,
              ) ??
                  60;
        } else {
          selectedDurationInMinutes = 60;
        }

        setState(() {
          amenitiesModel = amenitiesModel;
          isLoading = false;
          load = false;
          calendar1Loading = false;
        });
        return true;
      } else {
        setState(() {
          isLoading = false;
          load = false;
          calendar1Loading = false;
        });
        return false;
      }
    } catch (e) {
      print("AmenitiesApi Error: $e");
      setState(() {
        isLoading = false;
        load = false;
        calendar1Loading = false;
      });
      return false;
    }
  }

  String convertTo24(String time) {
    try {
      final parsed = DateFormat("hh:mm a").parse(time);
      return DateFormat("HH:mm").format(parsed);
    } catch (e) {
      return time;
    }
  }

  String calculateEndTime(String startTime, int durationMinutes) {
    try {
      final start = DateFormat("HH:mm:ss").parse(startTime);
      final end = start.add(Duration(minutes: durationMinutes));
      return DateFormat("HH:mm:ss").format(end);
    } catch (e) {
      return startTime;
    }
  }
  Future<bool> AddBookingApi(
      String date,
      String time,
      String apiEndTime,
      int duration,
      String name,) async {

    String apiTime = convertTo24(time);
    String apitime2 = convertTo24(apiEndTime);
    String endTime = calculateEndTime(apiTime, duration);

    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "amenity_id": widget.amenites_id ?? '',
      "date": date,
      "start_time": apiTime,
      "end_time": apitime2,
      "is_first_slot": (!showPlus30).toString(),
      "duration_minutes": duration.toString(),
    };

    log("BOOKING DATA => $data");

    setState(() => isGlobalLoading = true);

    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      if (mounted) buildErrorDialog(context, 'Error', "Internet Required");
      setState(() => isGlobalLoading = false);
      return false;
    }

    try {
      var response = await AmenitiesProvider().addBookingApi(data);

      log("BOOKING RESPONSE => ${response.data}");

      setState(() => isGlobalLoading = false);

      /// ✅ SUCCESS
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data["data"];

        String start = resData["start_time"] ?? time;
        String end = resData["end_time"] ?? endTime;
        String durationStr = "${(duration / 60).toStringAsFixed(1)} hr";

        if (duration < 60) {
          durationStr = "$duration min";
        } else if (duration % 60 == 0) {
          durationStr = "${(duration / 60).toInt()} hr";
        }

        showTornTicketDialog(
          attendeeInitials: 'NP',
          context: context,
          location: name,
          selectedDate: date,
          selectedTime: start,
          duration: durationStr,
          endTime: end,
        );

        return true;
      }

      /// ❌ SAFE ERROR MESSAGE HANDLING
      String msg = "Please try again later.";

      if (response.data != null && response.data is Map) {
        final backendMsg = response.data['message']?.toString() ?? "";

        // 👇 Show only small readable messages
        if (backendMsg.isNotEmpty &&
            backendMsg.length < 120 &&
            !backendMsg.toLowerCase().contains("html") &&
            !backendMsg.toLowerCase().contains("exception") &&
            !backendMsg.toLowerCase().contains("stack") &&
            !backendMsg.toLowerCase().contains("error:")) {
          msg = backendMsg;
        }
      }

      showSnackBar(
        context: context,
        title: "Booking Failed",
        message: msg,
        backgoundColor: AppColors.redColor,
        ColorText: Colors.white,
      );

      return false;

    } catch (e, stacktrace) {

      log("BOOKING ERROR => $e");
      log("BOOKING STACK => $stacktrace");

      setState(() => isGlobalLoading = false);

      /// ❌ BIG ERROR HIDE FROM USER
      showSnackBar(
        context: context,
        title: "Oops",
        message: "Please try again later.",
        backgoundColor: AppColors.redColor,
        ColorText: Colors.white,
      );

      return false;
    }
  }

  Future<void> RSVPAmenityApi(String bookingid, String rsvp) async {
    setState(() {
      isRsvpLoading = true;
    });
    Map<String, String> data = {"booking_id": bookingid, "rsvp_status": rsvp};
    bool hasInternet = await checkInternet();
    if (hasInternet) {
      try {
        var response = await AmenitiesProvider().rsvpToAmenityApi(data);
        if (response.statusCode == 200) {
          if (mounted) {
            Get.back();
            Get.offAll(() => const BookingScreen());
            showSnackBar(
              context: context,
              title: "RSVP Updated",
              message: "Your response has been recorded.",
              backgoundColor: AppColors.maincolor,
              ColorText: Colors.white,
            );
          }
        } else {
          if (mounted) {
            Get.back();
            showSnackBar(
              context: context,
              title: "Error",
              message: "Failed to update RSVP.",
              backgoundColor: AppColors.maincolor,
              ColorText: Colors.white,
            );
          }
        }
      } catch (e) {
        print("RSVPApi Error: $e");
        if (mounted) Get.back();
      } finally {
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
      if (mounted) buildErrorDialog(context, 'Error', "Internet Required");
    }
  }

  Future<void> RSVPAmenityAttend(String bookingid,
      String attended,
      String rsvp,) async {
    setState(() {
      isRsvpLoading = true;
    });
    Map<String, String> data = {
      "booking_id": bookingid,
      "attended": attended,
      "rsvp_status": rsvp,
    };
    bool hasInternet = await checkInternet();
    if (hasInternet) {
      try {
        var response = await AmenitiesProvider().rsvpToAmenityApi(data);
        if (response.statusCode == 200) {
          if (mounted) {
            Get.back();
            Get.offAll(() => const BookingScreen());
            showSnackBar(
              context: context,
              title: "Attendance Marked",
              message: "Thank you for attending!",
              backgoundColor: AppColors.maincolor,
              ColorText: Colors.white,
            );
          }
        } else {
          if (mounted) {
            Get.back();
            showSnackBar(
              context: context,
              title: "Error",
              message: "Failed to mark attendance.",
              backgoundColor: AppColors.maincolor,
              ColorText: Colors.white,
            );
          }
        }
      } catch (e) {
        print("AttendApi Error: $e");
        if (mounted) Get.back();
      } finally {
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
      if (mounted) buildErrorDialog(context, 'Error', "Internet Required");
    }
  }

  String _toHms(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
    } else if (parts.length == 3) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${parts[2].padLeft(2, '0')}';
    }
    return time;
  }

  bool _isSlotAlreadyBookedByMe(String slotOpenTime, DateTime selectedDate,
      {String? slotCloseTime}) {
    final data = statusModal?.data;
    if (data == null || data.isEmpty) return false;

    final String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Convert slot open/close to minutes for overlap check
    final String slotOpen24 = convertTo24(slotOpenTime);
    final String slotClose24 = slotCloseTime != null ? convertTo24(slotCloseTime) : '';

    int slotOpenMins = _timeToMinutes(slotOpen24);
    int slotCloseMins = slotClose24.isNotEmpty ? _timeToMinutes(slotClose24) : slotOpenMins + 1;

    final selectedAmenity = amenitiesModel?.data?.data?.first;
    bool isAllDayBooking = selectedAmenity?.isAllDayBooking == "1";

    for (final booking in data) {
      final String? bDate = booking.bookingDate;
      final String? bStart = booking.startTime;
      final String? bEnd = booking.endTime;

      if (bDate == null || bStart == null) continue;
      if (bDate != dateStr) continue;

      if (isAllDayBooking && slotCloseTime != null && bEnd != null) {
        // ✅ Overlap check: slot and booking overlap karе che ke nahi
        // Overlap condition: slotOpen < bookingEnd AND slotClose > bookingStart
        int bookingStartMins = _timeToMinutes(bStart);
        int bookingEndMins = _timeToMinutes(bEnd);

        bool overlaps = slotOpenMins < bookingEndMins && slotCloseMins > bookingStartMins;

        if (overlaps) {
          print('✅ OVERLAP FOUND: Slot $slotOpenTime-$slotCloseTime overlaps with booking $bStart-$bEnd');
          return true;
        }
      } else {
        // Original exact match logic for non-all-day booking
        String bookingHms = _toHms(bStart);
        String uiHms = _toHms(slotOpen24);

        if (booking.isFirstSlot == "false") {
          final DateTime parsed = DateFormat('HH:mm:ss').parseStrict(bookingHms);
          final DateTime adjusted = parsed.subtract(const Duration(minutes: 30));
          bookingHms = DateFormat('HH:mm:ss').format(adjusted);
        }

        if (bookingHms == uiHms) return true;
      }
    }

    return false;
  }

  int _timeToMinutes(String time) {
    try {
      // Handle HH:mm:ss format
      final parts = time.split(':');
      if (parts.length >= 2) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        return hours * 60 + minutes;
      }
    } catch (e) {
      print('Error converting time to minutes: $time - $e');
    }
    return 0;
  }

  statusApi() {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    log("Data $data");
    checkInternet().then((internet) async {
      if (internet) {
        AmenitiesProvider()
            .bookingStatusApi(data)
            .then((response) async {
          statusModal = StatusModal.fromJson(response.data);

          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
            });
          } else if (response.statusCode == 422) {
            setState(() {
              isLoading = false;
            });
          } else {
            log("errror ");
            setState(() {
              isLoading = false;
            });
          }

          setState(() {
            isLoading = false;
          });
          return false;
        })
            .catchError((error) {
          setState(() {
            isLoading = false;
          });

          return false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
        return false;
      }
    });
  }

  Future<void> _showCustomTimePicker({
    required OperatingHours? hours,
    required DateTime selectedDate,
    required String initialOpenTime,
    required String initialCloseTime,
    required Function(String startTime, String endTime) onTimeSelected,
  }) async
  {

    if (hours == null) return;

    /// 🔥 IMPORTANT FIX
    /// Selected slot MUST be the session user clicked earlier
    final TimeOfDay slotOpen = _parseTimeOfDay(initialOpenTime);
    final TimeOfDay slotClose = _parseTimeOfDay(initialCloseTime);

    /// Parse initial selection
    TimeOfDay selectedStartTime = slotOpen;
    TimeOfDay selectedEndTime = slotClose;

    final selectedAmenity = amenitiesModel?.data?.data?.first;
    int maintenanceMins =
        int.tryParse(selectedAmenity?.maintenanceDuration ?? "0") ?? 0;
    //
    // const int minDurationMinutes = 60;
    // const int maxDurationMinutes = 90;
    int fixedDuration =
    selectedAmenity?.durationOptions?.isNotEmpty == true
        ? int.tryParse(
      selectedAmenity!.durationOptions!.first.toString(),
    ) ??
        60
        : 60;
    bool isTimeInSelectedSlot(TimeOfDay time) {
      return _isTimeBetweenInclusive(time, slotOpen, slotClose);
    }
    bool isValidEndTimeForStart(TimeOfDay start, TimeOfDay end) {
      int startMinutes = start.hour * 60 + start.minute;
      int endMinutes = end.hour * 60 + end.minute;
      int slotOpenMinutes = slotOpen.hour * 60 + slotOpen.minute;
      int slotCloseMinutes = slotClose.hour * 60 + slotClose.minute;

      return endMinutes > startMinutes &&
          endMinutes >= slotOpenMinutes &&
          endMinutes <= slotCloseMinutes;
    }
    TimeOfDay _addMinutes(TimeOfDay time, int minutesToAdd) {
      final totalMinutes = time.hour * 60 + time.minute + minutesToAdd;
      return TimeOfDay(
        hour: (totalMinutes ~/ 60) % 24,
        minute: totalMinutes % 60,
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {

            int currentDuration =
            _calculateDurationInMinutes(selectedStartTime, selectedEndTime);

            // bool isDurationValid =
            //     currentDuration >= minDurationMinutes &&
            //         currentDuration <= maxDurationMinutes;
            //
            // bool isNearMaxDuration =
            //     currentDuration >= maxDurationMinutes - 30 &&
            //         currentDuration <= maxDurationMinutes;

            bool isStartInSlot = isTimeInSelectedSlot(selectedStartTime);
            bool isEndInSlot = isTimeInSelectedSlot(selectedEndTime);
            bool isEndTimeValidForStart =
            isValidEndTimeForStart(selectedStartTime, selectedEndTime);

            // bool isValidSelection =
            //     isDurationValid &&
            //         isStartInSlot &&
            //         isEndInSlot &&
            //         isEndTimeValidForStart;
            bool isValidSelection =
                isStartInSlot && isEndInSlot && isEndTimeValidForStart;
            return AlertDialog(
              title: const Text('Select Time Range'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// ✅ SELECTED SLOT INFO (NOW CORRECT)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.maincolor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.maincolor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: AppColors.maincolor, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${_formatTimeTo12Hour(initialOpenTime)} - ${_formatTimeTo12Hour(initialCloseTime)}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    /// CURRENT SELECTION INFO (unchanged design)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.maincolor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.maincolor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer,
                              color: AppColors.maincolor, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Selected: ${_formatTimeOfDayTo12Hour(selectedStartTime)} - ${_formatTimeOfDayTo12Hour(selectedEndTime)}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.maincolor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    /// SLOT HOURS INFO (correct now)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Slot hours: ${_formatTimeTo12Hour(initialOpenTime)} - ${_formatTimeTo12Hour(initialCloseTime)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    /// START PICKER
                    ListTile(
                      title: const Text('Start Time',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                      Text(_formatTimeOfDayTo12Hour(selectedStartTime)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedStartTime,
                        );

                        if (picked == null) return;

                        if (!isTimeInSelectedSlot(picked)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Select time within ${_formatTimeTo12Hour(initialOpenTime)} - ${_formatTimeTo12Hour(initialCloseTime)}"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          selectedStartTime = picked;
                          selectedEndTime = _addMinutes(picked, fixedDuration);
                        });
                      },
                    ),

                    /// END PICKER
                    ListTile(
                      title: const Text('End Time',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle:
                      Text(_formatTimeOfDayTo12Hour(selectedEndTime)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("End time is fixed (${fixedDuration} mins session)"),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 8),

                    /// DURATION INFO (unchanged design)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isValidSelection
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer,
                              color: isValidSelection
                                  ? Colors.green
                                  : Colors.red,
                              size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Session duration: $fixedDuration minutes",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isValidSelection
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    /// MAINTENANCE INFO (dynamic, same design style)
                    if (maintenanceMins > 0) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.build_circle_outlined,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "+$maintenanceMins mins maintenance time will be included in the selected session duration for this amenity",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isValidSelection
                      ? () {
                    Navigator.pop(context);

                    /// 🔥 MAINTENANCE ADDED HERE
                    final TimeOfDay apiEndTime =
                    _addMinutes(selectedEndTime, maintenanceMins);

                    onTimeSelected(
                      _formatTimeForAPI(selectedStartTime),
                      _formatTimeForAPI(apiEndTime),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValidSelection
                        ? AppColors.lightText
                        : Colors.grey,
                  ),
                  child: Text(
                    'Select',
                    style: TextStyle(
                      fontFamily: AppConstants.manrope,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isTimeBetweenInclusive(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    int timeMinutes = time.hour * 60 + time.minute;
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    // For normal time ranges where start < end
    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    }
    // For ranges that cross midnight (if needed)
    else {
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }

  String _formatTimeOfDayTo12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatTimeTo12Hour(String time24) {
    if (time24.isEmpty) return '';
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  Future<void> addSlotAPi(String startTime, String endTime,
      String amenitiesName) async {
    setState(() {
      isRsvpLoading = true;
    });
    Map<String, String> data = {
      "start_time": startTime,
      "end_time": endTime,
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "amenity_id": widget.amenites_id.toString() ?? "",
      "date": calendar1SelectedDateStr ?? "",
    };
    log("add Slot api $data");
    bool hasInternet = await checkInternet();
    if (hasInternet) {
      try {
        var response = await AmenitiesProvider().addSlotApi(data);
        if (response.statusCode == 200) {
          if (mounted) {
            log("API SUCESS${response.statusCode}");
            log("API SUCESS${response.data}");
            final resData = response.data["data"];

            String start = resData["start_time"] ?? startTime;
            String end = resData["end_time"] ?? endTime;

            showConfirmSlotDialog(start, end, amenitiesName);
          }
          AmenitiesApi(date: calendar1SelectedDateStr);
          // statusApi();
        } else {
          if (mounted) {
            Get.back();
            showSnackBar(
              context: context,
              title: "Error",
              message: "Failed to add slot.",
              backgoundColor: AppColors.maincolor,
              ColorText: Colors.white,
            );
          }
        }
      } catch (e, stackTrace) {
        print("RSVPApi Error: $e");
        print("RSVPApi Error: $stackTrace");
        if (mounted) Get.back();
      } finally {
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
      if (mounted) buildErrorDialog(context, 'Error', "Internet Required");
    }
  }

  String _formatTimeForAPI(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      try {
        final dateTime = DateFormat("h:mm a").parse(timeStr);
        return TimeOfDay.fromDateTime(dateTime);
      } catch (e) {
        final dateTime = DateFormat("HH:mm").parse(timeStr);
        return TimeOfDay.fromDateTime(dateTime);
      }
    } catch (e, stackTrace) {
      print("Error parsing time: $timeStr");
      print("Error: $e");
      print("StackTrace: $stackTrace");
    }

    return const TimeOfDay(hour: 9, minute: 0);
  }

  int _calculateDurationInMinutes(TimeOfDay start, TimeOfDay end) {
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;
    return endMinutes - startMinutes;
  }

  void showConfirmSlotDialog(String start, String end, String amenitiesName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ✅ Top Icon Circle
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 18),

                // ✅ Title
                const Text(
                  "Confirm Slot Booking",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                // ✅ Description
                const Text(
                  "Please confirm your selected time slot",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 18),

                // ✅ Time Box
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.maincolor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "$start  →  $end",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.maincolor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ✅ Buttons Row
                Row(
                  children: [

                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirm button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.maincolor,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          AddBookingApi(
                            calendar1SelectedDateStr,
                            start.toString(),

                            end
                                .toString(),
                            selectedDurationInMinutes,
                            amenitiesName
                                .toString(),

                          );

                          // showSnackBar(
                          //   context: context,
                          //   title: "Success",
                          //   message: "Slot confirmed successfully!",
                          //   backgoundColor: Colors.green,
                          //   ColorText: Colors.white,
                          // );
                        },
                        child: isGlobalLoading
                            ? Container(
                          height: 6.h,
                          alignment:
                          Alignment
                              .center,
                          width:
                          double
                              .infinity,
                          child: const CircularProgressIndicator(
                            color:
                            AppColors
                                .maincolor,
                          ),
                        )
                            : const Text(
                          "Confirm",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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

  Widget _buildOperatingHoursExpansionTile(OperatingHours? operatingHours) {
    final theme = context.watch<ThemeController>();

    if (operatingHours == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.isDark ? Color(0xff262626) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Text(
              "No operating hours available",
              style: TextStyle(
                color: theme.isDark ? Colors.white70 : Colors.grey.shade600,
                fontSize: 14,
                fontFamily: AppConstants.manrope,
              ),
            ),
          ],
        ),
      );
    }

    // Map of days with their time slots
    final Map<String, List<TimeSlot>?> daysMap = {
      'Monday': operatingHours.monday,
      'Tuesday': operatingHours.tuesday,
      'Wednesday': operatingHours.wednesday,
      'Thursday': operatingHours.thursday,
      'Friday': operatingHours.friday,
      'Saturday': operatingHours.saturday,
      'Sunday': operatingHours.sunday,
    };

    // Check if any day has operating hours
    bool hasAnyHours = daysMap.values.any((slots) => slots != null && slots.isNotEmpty);

    if (!hasAnyHours) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.isDark ? Color(0xff262626) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_filled, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Text(
              "No operating hours set",
              style: TextStyle(
                color: theme.isDark ? Colors.white70 : Colors.grey.shade600,
                fontSize: 14,
                fontFamily: AppConstants.manrope,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.isDark ? Color(0xff262626) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.maincolor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time,
              color: AppColors.maincolor,
              size: 20,
            ),
          ),
          title: Text(
            "Operating Hours",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.isDark ? Colors.white : Colors.black87,
              fontFamily: AppConstants.manropeBold,
            ),
          ),
          subtitle: Text(
            "Tap to view daily schedule",
            style: TextStyle(
              fontSize: 13,
              color: theme.isDark ? Colors.white70 : Colors.grey.shade600,
              fontFamily: AppConstants.manrope,
            ),
          ),
          iconColor: AppColors.maincolor,
          collapsedIconColor: AppColors.maincolor,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: daysMap.entries.map((entry) {
                  final day = entry.key;
                  final slots = entry.value;

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.isDark ? Color(0xff1E1E1E) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day indicator
                        Container(
                          width: 25.w,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: slots != null && slots.isNotEmpty
                                      ? Colors.green
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.isDark ? Colors.white : Colors
                                      .black87,
                                  fontFamily: AppConstants.manropeBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Time slots
                        Expanded(
                          child: slots != null && slots.isNotEmpty
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: slots.map((slot) {
                              String openTime = _formatTimeTo12Hour(slot.open ?? '');
                              String closeTime = _formatTimeTo12Hour(slot.close ?? '');

                              return Padding(
                                padding: EdgeInsets.only(bottom: slots.length > 1 ? 4 : 0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: AppColors.maincolor,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "$openTime - $closeTime",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.isDark ? Colors.white70 : Colors.grey.shade700,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                              : Text(
                            "Closed",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade400,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isAlreadyBooked=false;
}

