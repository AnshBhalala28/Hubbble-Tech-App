
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
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/ui/booking/modal/statusModal.dart';
import 'package:wavee/utils/checkInternetConnection.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/customAppBar.dart';
import 'package:wavee/utils/customSnackBars.dart';
import 'package:wavee/utils/errorDialog.dart';
import 'package:wavee/utils/loader.dart';
import 'package:wavee/utils/viewPdfFunction.dart';
import 'package:wavee/ui/booking/provider/bookingsProvider.dart';
import 'package:wavee/ui/booking/modal/bookingModel.dart';
import 'package:wavee/ui/booking/view/bookAmenities.dart';
import 'package:wavee/ui/booking/view/bookingScreen.dart';

import '../../../utils/const.dart';
import '../../../utils/customButton.dart';

class NormalAmenities extends StatefulWidget {
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

  const NormalAmenities({
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
  State<NormalAmenities> createState() => _NormalAmenitiesState();
}

class _NormalAmenitiesState extends State<NormalAmenities> {
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

  DateTime _parseTime(String timeStr, DateTime onDate) {
    final String cleanTimeStr = timeStr.trim();

    try {
      final format24 = DateFormat("HH:mm");
      final dt = format24.parse(cleanTimeStr);
      return DateTime(
        onDate.year,
        onDate.month,
        onDate.day,
        dt.hour,
        dt.minute,
      );
    } catch (e) {
      try {
        final format12 = DateFormat("h:mm a");
        final dt = format12.parse(cleanTimeStr);
        return DateTime(
          onDate.year,
          onDate.month,
          onDate.day,
          dt.hour,
          dt.minute,
        );
      } catch (e2) {
        print("!!! Failed to parse time: '$timeStr' !!!");
        return DateTime.now();
      }
    }
  }

  List<String> _extractStartTimesFromOperatingHours(
      OperatingHours? hours,
      DateTime selectedDate,
      ) {
    List<String> startTimes = [];

    if (hours == null) return startTimes;

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
      return startTimes;
    }

    for (var slot in timeSlots) {
      if (slot.open != null && slot.open!.isNotEmpty) {
        startTimes.add(slot.open!);
      }
    }

    return startTimes;
  }

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
                                                onPageChanged: (
                                                    index,
                                                    reason,
                                                    ) {
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
                                                          (
                                                          context,
                                                          url,
                                                          ) => const Center(
                                                        child:
                                                        CircularProgressIndicator(),
                                                      ),
                                                      errorWidget:
                                                          (
                                                          context,
                                                          url,
                                                          error,
                                                          ) => const Center(
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
                                                  const EdgeInsets.symmetric(
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
                                                : "${booking?.description.toString().capitalizeFirst}",
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
                                                            fontSize:
                                                            14.sp,
                                                            fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                            color: theme
                                                                .isDark
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
                                                          booking?.availableSlots
                                                              ?.toString() ??
                                                              "Unknown",
                                                          style:
                                                          TextStyle(
                                                            fontSize:
                                                            15.sp,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontFamily:
                                                            AppConstants
                                                                .manropeBold,
                                                            color: theme
                                                                .isDark
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
                                        // SingleChildScrollView(
                                        //   scrollDirection: Axis.horizontal,
                                        //   child: Row(
                                        //     children: [
                                        //       Container(
                                        //         padding:
                                        //         EdgeInsets.symmetric(
                                        //           horizontal: 3.w,
                                        //           vertical: 1.h,
                                        //         ),
                                        //         decoration: BoxDecoration(
                                        //           color: AppColors.bgcolor,
                                        //           borderRadius:
                                        //           BorderRadius.circular(
                                        //             12,
                                        //           ),
                                        //         ),
                                        //         child: Row(
                                        //           children: [
                                        //             Icon(
                                        //               Icons.timer,
                                        //               size: 18.sp,
                                        //               color:
                                        //               AppColors
                                        //                   .maincolor,
                                        //             ),
                                        //             SizedBox(width: 2.w),
                                        //             Text(
                                        //               "Duration: ${_formatDuration(booking?.durationOptions)}",
                                        //               style: TextStyle(
                                        //                 fontSize: 15.sp,
                                        //                 fontFamily:
                                        //                 AppConstants
                                        //                     .manrope,
                                        //                 fontWeight:
                                        //                 FontWeight.bold,
                                        //                 color: Colors.black,
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //       SizedBox(width: 1.h),
                                        //       Container(
                                        //         padding:
                                        //         EdgeInsets.symmetric(
                                        //           horizontal: 3.w,
                                        //           vertical: 1.h,
                                        //         ),
                                        //         decoration: BoxDecoration(
                                        //           color: AppColors.bgcolor,
                                        //           borderRadius:
                                        //           BorderRadius.circular(
                                        //             12,
                                        //           ),
                                        //         ),
                                        //         child: Row(
                                        //           children: [
                                        //             Icon(
                                        //               Icons.people,
                                        //               size: 18.sp,
                                        //               color:
                                        //               AppColors
                                        //                   .maincolor,
                                        //             ),
                                        //             SizedBox(width: 2.w),
                                        //             Text(
                                        //               "Capacity: ${booking?.capacity ?? ''}",
                                        //               style: TextStyle(
                                        //                 fontFamily:
                                        //                 AppConstants
                                        //                     .manrope,
                                        //                 fontSize: 15.sp,
                                        //                 fontWeight:
                                        //                 FontWeight.bold,
                                        //                 color: Colors.black,
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
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
                                                              (
                                                              index,
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
                                                              calendar1FocusedMonth = DateTime(
                                                                DateTime.now().year,
                                                                value +
                                                                    1,
                                                                1,
                                                              );
                                                              calendar1SelectedDate =
                                                                  calendar1FocusedMonth;
                                                              calendar1SelectedDateStr = DateFormat(
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
                                                selectedDayPredicate: (
                                                    day,
                                                    ) {
                                                  return isSameDay(
                                                    getRequestedDate(),
                                                    day,
                                                  );
                                                },
                                                calendarBuilders: CalendarBuilders(
                                                  defaultBuilder: (
                                                      context,
                                                      day,
                                                      focusedDay,
                                                      ) {
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
                                                  :_buildOperatingHoursExpansionTile( selectedAmenity
                                                  ?.operatingHours),

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
                                              ] else if (calendar1Loading)
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
                                                                    ? AppColors.white
                                                                    : AppColors.maincolor,
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
                                                                    ? AppColors.white
                                                                    : AppColors.maincolor,
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
                                                                      ? AppColors.white
                                                                      : Colors.black,
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
                                                                    ? AppColors.white
                                                                    : AppColors.maincolor,
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
                                                                      ? AppColors.white
                                                                      : Colors.black,
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
                                                            selectedDurationInMinutes,
                                                            booking?.name ??
                                                                "N/A",
                                                            selectEndTime.toString()??"N/A"

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
                                                          AppColors
                                                              .lightText,
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
                                                                AppConstants.manrope,
                                                                fontWeight:
                                                                FontWeight.normal,
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
                                                                border: Border.all(
                                                                  color:
                                                                  AppColors.white,
                                                                ),
                                                              ),
                                                              child: Stack(
                                                                alignment:
                                                                Alignment.center,
                                                                children: [
                                                                  Transform.translate(
                                                                    offset: const Offset(
                                                                      -4,
                                                                      0,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons.arrow_forward_ios,
                                                                      color:
                                                                      Colors.white,
                                                                      size:
                                                                      14.sp,
                                                                    ),
                                                                  ),
                                                                  Transform.translate(
                                                                    offset: const Offset(
                                                                      4,
                                                                      0,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons.arrow_forward_ios,
                                                                      color:
                                                                      Colors.white,
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
                  onTap: () {
                    final amenityData = amenitiesModel?.data?.data?.first;

                    /// 1️⃣ Check inactive status
                    if (amenityData?.status == "inactive") {
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

                    /// 2️⃣ Check available slots safely
                    if (amenityData != null && amenityData.availableSlots != null) {
                      final slotsValue = amenityData.availableSlots.toString().trim();

                      // If NOT unlimited, check numeric value
                      if (slotsValue.toLowerCase() != "unlimited") {
                        final slotCount = int.tryParse(slotsValue) ?? 0;

                        if (slotCount <= 0) {
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
                      }
                    }

                    /// 3️⃣ Check date selected
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

                    /// 4️⃣ Check start time selected
                    if (selectedStartTime == null || selectedStartTime!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(milliseconds: 800),
                          content: Text("Please select a start time."),
                        ),
                      );
                      return;
                    }

                    /// 5️⃣ Check closed day
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

                    /// ✅ All good → show booking details
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
    List<Map<String, String>> timeSlots = _extractTimeSlotsFromOperatingHours(
      hours,
      calendar1SelectedDate!,
    );
    final theme = context.watch<ThemeController>();

    final selectedAmenity = amenitiesModel?.data?.data?.first;
    int maintenanceMins = int.tryParse(selectedAmenity?.maintenanceDuration ?? "0") ?? 0;
    bool showMaintenanceNote = maintenanceMins > 0;
    bool isAllDayBooking = selectedAmenity?.isAllDayBooking == "1";
    int availableSlots = int.tryParse(
      selectedAmenity?.availableSlots?.toString() ?? "1",
    ) ?? 1;

    // ✅ Filter visible slots first
    List<Map<String, String>> visibleSlots = timeSlots.where((slot) {
      final String openTime = slot['open'] ?? '';
      final bool isBookedByMe = _isSlotAlreadyBookedByMe(openTime, calendar1SelectedDate!);

      if (!isAllDayBooking && availableSlots <= 0 && !isBookedByMe) {
        return false; // hide
      }
      return true; // show
    }).toList();

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
          Text(
            isAllDayBooking ? "Select Time Slot" : "Select Start Time",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manropeBold,
              color: theme.isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 1.h),

          // ✅ 3 cases handle
          if (timeSlots.isEmpty)
          // Case 1: API ma j koi slot nathi
            _buildEmptyMessage(
              theme,
              icon: Icons.calendar_today_outlined,
              message: "No time slots available for selected date",
            )
          else if (visibleSlots.isEmpty)
          // Case 2: Slots hata pan badha hide thaya (availableSlots == 0)
            _buildEmptyMessage(
              theme,
              icon: Icons.event_busy_rounded,
              message: "No slots available for this date.\nPlease select another date.",
              isWarning: true,
            )
          else
          // Case 3: Visible slots che → show karo
            Column(
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: visibleSlots.map((slot) {
                    final String openTime = slot['open'] ?? '';
                    final String closeTime = slot['close'] ?? '';
                    final String displayTime = "$openTime - $closeTime";

                    final bool isSelected = selectedStartTime == openTime;
                    final bool isBookedByMe = _isSlotAlreadyBookedByMe(
                      openTime,
                      calendar1SelectedDate!,
                    );

                    return GestureDetector(
                      onTap: isBookedByMe
                          ? null
                          : () {
                        setState(() {
                          selectedStartTime = openTime;
                          selectEndTime = closeTime;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: isBookedByMe
                              ? Colors.grey.shade300
                              : isSelected
                              ? AppColors.maincolor
                              : AppColors.bgcolor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isBookedByMe
                                ? Colors.grey.shade400
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
                                color: isBookedByMe
                                    ? Colors.grey.shade600
                                    : isSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: AppConstants.manrope,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isBookedByMe)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  "Booked",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.red,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (showMaintenanceNote) ...[
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

  Widget _buildEmptyMessage(
      ThemeController theme, {
        required IconData icon,
        required String message,
        bool isWarning = false,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.orange.shade50
            : theme.isDark
            ? Color(0xff1E1E1E)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWarning ? Colors.orange.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28.sp,
            color: isWarning ? Colors.orange.shade600 : Colors.grey.shade500,
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isWarning ? Colors.orange.shade800 : Colors.grey.shade600,
              fontFamily: AppConstants.manrope,
              fontWeight: FontWeight.w500,
            ),
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

        // Always add both open and close times for display
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

    // Get the all-day booking flag (as string comparison)
    final selectedAmenity = amenitiesModel?.data?.data?.first;
    bool isAllDayBooking = selectedAmenity?.isAllDayBooking == "1";

    // Format time slots based on booking type
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

  String _formatTimeTo12Hour(String time24) {
    try {
      // Try parsing with different formats
      if (time24.contains(':')) {
        final parts = time24.split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);

          DateTime dateTime = DateTime(2000, 1, 1, hour, minute);
          return DateFormat('h:mm a').format(dateTime);
        }
      }
      return time24;
    } catch (e) {
      return time24;
    }
  }

  Widget _buildOperatingHoursDisplay(
      String operatingHoursStr,
      List<ExistingBooking> existingBookings,
      ) {
    final theme = context.watch<ThemeController>();
    final selectedAmenity = amenitiesModel?.data?.data?.first;
    int? maintenanceMins =
        int.tryParse(selectedAmenity?.maintenanceDuration ?? "0") ?? 0;
    bool showMaintenanceNote = maintenanceMins != null && maintenanceMins > 0;
    bool isAllDayBooking = selectedAmenity?.isAllDayBooking == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: buildSlotBox(
                label: 'Total',
                value:
                (amenitiesModel?.data?.data?[0].totalBookingSlots ?? 0)
                    .toString(),
                color: theme.isDark ? Color(0xff262626) : Colors.blue,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: buildSlotBox(
                label: 'Booked',
                value:
                (amenitiesModel?.data?.data?[0].bookedSlots ?? 0)
                    .toString(),
                color: theme.isDark ? Color(0xff262626) : Colors.red,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: buildSlotBox(
                label: 'Available',
                value:
                (amenitiesModel?.data?.data?[0].availableSlots ?? 0)
                    .toString(),
                color: theme.isDark ? Color(0xff262626) : Colors.green,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Display operating hours with appropriate format
        // Container(
        //   padding: EdgeInsets.all(4.w),
        //   decoration: BoxDecoration(
        //     color: theme.isDark ? Color(0xff262626) : AppColors.bgcolor,
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: Colors.grey.shade300),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         children: [
        //           Icon(
        //             Icons.access_time,
        //             size: 18.sp,
        //             color: theme.isDark ? Colors.white : AppColors.maincolor,
        //           ),
        //           SizedBox(width: 2.w),
        //           Text(
        //             "Operating Hours:",
        //             style: TextStyle(
        //               fontSize: 16.sp,
        //               fontWeight: FontWeight.bold,
        //               fontFamily: AppConstants.manropeBold,
        //               color: theme.isDark ? Colors.white : Colors.black,
        //             ),
        //           ),
        //         ],
        //       ),
        //       SizedBox(height: 1.h),
        //       Text(
        //         operatingHoursStr,
        //         style: TextStyle(
        //           fontSize: 15.sp,
        //           color: theme.isDark ? Colors.white70 : Colors.black87,
        //           fontFamily: AppConstants.manrope,
        //         ),
        //       ),
        //
        //       // Show maintenance duration only for all-day booking
        //       if (showMaintenanceNote && isAllDayBooking) ...[
        //         SizedBox(height: 1.h),
        //         Divider(color: Colors.grey.shade400),
        //         SizedBox(height: 0.5.h),
        //         Row(
        //           children: [
        //             Icon(
        //               Icons.build,
        //               size: 16.sp,
        //               color: Colors.amber.shade700,
        //             ),
        //             SizedBox(width: 2.w),
        //             Expanded(
        //               child: Text(
        //                 "Maintenance Time: $maintenanceMins minute${maintenanceMins > 1 ? 's' : ''} between bookings",
        //                 style: TextStyle(
        //                   fontSize: 13.sp,
        //                   color: Colors.amber.shade800,
        //                   fontFamily: AppConstants.manrope,
        //                   fontWeight: FontWeight.w500,
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ],
        //     ],
        //   ),
        // ),
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
                        booking.startTime ?? '',
                      );

                      // For all-day booking, show both start and end times
                      if (isAllDayBooking) {
                        String endFormatted = _formatTimeTo12Hour(
                          booking.endTime ?? '',
                        );
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
            width: 10.w,
            child: Text(
              value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: AppConstants.manrope,
                fontWeight: FontWeight.w600,
                color: theme.isDark ? Colors.white : color,
              ),
            ),
          ),
        ],
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

  String _formatDuration(List<String>? durations) {
    if (durations == null || durations.isEmpty) return "N/A";

    int totalMinutes = selectedDurationInMinutes;

    if (totalMinutes < 60) {
      return "$totalMinutes min";
    } else {
      double hours = totalMinutes / 60;
      if (hours == hours.toInt()) {
        return "${hours.toInt()} hr";
      }

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
    return today.isAtSameMomentAs(parsedCutoffDate) ||
        today.isAfter(parsedCutoffDate);
  }

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

      onDaySelected: (newSelectedDay, focusedDay) {
        setState(() {
          calendar1SelectedDate = newSelectedDay;
          calendar1SelectedDateStr = DateFormat(
            'dd/MM/yyyy',
          ).format(newSelectedDay);
          calendar1FocusedMonth = focusedDay;
          calendar1Loading = true;
          selectedStartTime = null;
        });

        AmenitiesApi(date: calendar1SelectedDateStr).then((_) {
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

  // Future<bool> AddBookingApi(String date,
  //     String time,
  //     int duration,
  //     String name,) async
  // {
  //   String apiTime = convertTo24(time);
  //
  //   String endTime = calculateEndTime(apiTime, duration);
  //
  //   Map<String, String> data = {
  //     "user_id": loginModel?.data?.user?.id.toString() ?? "",
  //     "amenity_id": widget.amenites_id ?? '',
  //     "date": date,
  //     "start_time": apiTime,
  //     "is_first_slot": (!showPlus30).toString(),
  //     "duration_minutes": duration.toString(),
  //   };
  //
  //   log("data => $data");
  //
  //   setState(() {
  //     isGlobalLoading = true;
  //   });
  //
  //   bool hasInternet = await checkInternet();
  //   if (!hasInternet) {
  //     if (mounted) buildErrorDialog(context, 'Error', "Internet Required");
  //     setState(() {
  //       isGlobalLoading = false;
  //     });
  //     return false;
  //   }
  //
  //   try {
  //     var response = await AmenitiesProvider().addBookingApi(data);
  //
  //     if (response.statusCode == 200) {
  //       if (mounted) {
  //         setState(() {
  //           isGlobalLoading = false;
  //         });
  //       }
  //
  //       String durationStr = "${(duration / 60).toStringAsFixed(1)} hr";
  //       if (duration < 60) {
  //         durationStr = "$duration min";
  //       } else if (duration % 60 == 0) {
  //         durationStr = "${(duration / 60).toInt()} hr";
  //       }
  //
  //       showTornTicketDialog(
  //         attendeeInitials: 'NP',
  //         context: context,
  //         location: name,
  //         selectedDate: date.toString(),
  //         selectedTime: time,
  //         duration: durationStr,
  //         endTime: DateFormat(
  //           "hh:mm a",
  //         ).format(DateFormat("HH:mm").parse(endTime)),
  //       );
  //       return true;
  //     } else {
  //       if (mounted) {
  //         setState(() {
  //           isGlobalLoading = false;
  //         });
  //       }
  //       showSnackBar(
  //         context: context,
  //         title: "Booking Failed",
  //         message:
  //         response.data['message'] ??
  //             "Something went wrong. Please try again.",
  //         backgoundColor: AppColors.redColor,
  //         ColorText: Colors.white,
  //       );
  //
  //       return false;
  //     }
  //   } catch (e, stacktrace) {
  //     print("AddBookingApi Error: $e");
  //     print("AddBookingApi Error: $stacktrace");
  //     if (mounted) {
  //       setState(() {
  //         isGlobalLoading = false;
  //       });
  //     }
  //     showSnackBar(
  //       context: context,
  //       title: "Error",
  //       message: "Something went wrong. Please try again later.",
  //       backgoundColor: AppColors.redColor,
  //       ColorText: Colors.white,
  //     );
  //
  //     return false;
  //   }
  // }
  Future<bool> AddBookingApi(
      String date,
      String time,
      int duration,
      String name,
      String apiEndTime,

      ) async
  {
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
        String end = resData["end_time"] ?? apiEndTime;


        /// 🔥 CALCULATE DURATION FROM START & END
        int finalDuration = calculateDurationFromTimes(start, end);

        /// Convert duration to readable text
        String durationStr;
        if (finalDuration < 60) {
          durationStr = "$finalDuration min";
        } else if (finalDuration % 60 == 0) {
          durationStr = "${(finalDuration / 60).toInt()} hr";
        } else {
          durationStr = "${(finalDuration / 60).toStringAsFixed(1)} hr";
        }

        showTornTicketDialog(
            attendeeInitials: 'NP',
            context: context,
            location: name,
            selectedDate: date,
            selectedTime: start,
            duration: durationStr,
            endTime:end
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
  int calculateDurationFromTimes(String start24, String end24) {
    final s = start24.split(":");
    final e = end24.split(":");

    final startMin = int.parse(s[0]) * 60 + int.parse(s[1]);
    final endMin = int.parse(e[0]) * 60 + int.parse(e[1]);

    return endMin - startMin;
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

  bool _isSlotAlreadyBookedByMe(String slotTime, DateTime selectedDate) {
    final data = statusModal?.data;
    if (data == null || data.isEmpty) return false;

    final String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String uiTime24 = convertTo24(slotTime);
    final String uiHms = _toHms(uiTime24);

    for (final booking in data) {
      final String? bDate = booking.bookingDate;
      final String? bStart = booking.startTime;
      if (bDate == null || bStart == null) continue;
      if (bDate != dateStr) continue;

      String bookingHms = _toHms(bStart);

      if (booking.isFirstSlot == "false") {
        final DateTime parsed = DateFormat('HH:mm:ss').parseStrict(bookingHms);
        final DateTime adjusted = parsed.subtract(const Duration(minutes: 30));
        bookingHms = DateFormat('HH:mm:ss').format(adjusted);
      }

      print('Comparing >> UI Slot: $uiHms  |  Booking Final Time: $bookingHms');

      if (bookingHms == uiHms) {
        print('🎯 MATCHED: Slot is booked!');
        return true;
      }
    }
    return false;
  }

  statusApi() {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    data['amenity_id'] = widget.amenites_id??"";
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

    final Map<String, List<TimeSlot>?> daysMap = {
      'Monday': operatingHours.monday,
      'Tuesday': operatingHours.tuesday,
      'Wednesday': operatingHours.wednesday,
      'Thursday': operatingHours.thursday,
      'Friday': operatingHours.friday,
      'Saturday': operatingHours.saturday,
      'Sunday': operatingHours.sunday,
    };

    bool hasAnyHours =
    daysMap.values.any((slots) => slots != null && slots.isNotEmpty);

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
                    color: theme.isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
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
                    padding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                      theme.isDark ? Color(0xff1E1E1E) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  color: theme.isDark
                                      ? Colors.white
                                      : Colors.black87,
                                  fontFamily: AppConstants.manropeBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: slots != null && slots.isNotEmpty
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: slots.map((slot) {
                              String openTime = _formatTimeTo12Hour(
                                  slot.open ?? '');
                              String closeTime = _formatTimeTo12Hour(
                                  slot.close ?? '');

                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: slots.length > 1 ? 4 : 0),
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
                                          color: theme.isDark
                                              ? Colors.white70
                                              : Colors.grey.shade700,
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
  bool _isSlotFullyBooked(String slotOpenTime) {
    final selectedAmenity = amenitiesModel?.data?.data?.first;
    final existingBookings = selectedAmenity?.existingBookings ?? [];
    final availableSlots = selectedAmenity?.availableSlots;

    // If isAllDayBooking == "0" and availableSlots <= 0, hide all slots
    final bool isAllDayBooking = selectedAmenity?.isAllDayBooking == "1";

    if (!isAllDayBooking) {
      // Count how many bookings exist for this specific time slot
      int bookedCount = 0;
      final String slotTime24 = convertTo24(slotOpenTime);
      final String slotHms = _toHms(slotTime24);

      for (final booking in existingBookings) {
        final String? bStart = booking.startTime;
        if (bStart == null) continue;
        final String bookingHms = _toHms(bStart);
        if (bookingHms == slotHms) {
          bookedCount++;
        }
      }

      // Get capacity for comparison
      final int capacity = int.tryParse(
          selectedAmenity?.capacity?.toString() ?? "1"
      ) ?? 1;

      return bookedCount >= capacity;
    }

    return false;
  }
}

