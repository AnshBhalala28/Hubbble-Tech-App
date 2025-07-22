import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:torn_ticket/torn_ticket.dart';
import 'package:wavee/Screen/Booking/View/book_amenities.dart';
import 'package:wavee/Screen/HomeNewPage/View/homenewpage.dart';
import 'package:wavee/comman/custom_batan.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
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

  bool showBookingDetails = false;

  DateTime? getRequestedDate() {
    if (widget.requestedDate == null) return null;

    try {
      return DateFormat("yyyy-MM-dd hh:mm a").parse(widget.requestedDate!);
    } catch (e) {
      return null;
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

    _generateDatesBasedOnSelection();
    AmenitiesApi(date: '');
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
    final String? selectedOperatingHours =
        calendar1SelectedDate != null
            ? getOperatingHours(
              calendar1SelectedDate!,
              selectedAmenity?.operatingHours,
            )
            : null;
    return WillPopScope(
      onWillPop: () async {
        if (showBookingDetails) {
          setState(() {
            showBookingDetails = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                        title: amenitiesModel?.data?.data?[0].name ?? "",
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
                          itemCount: amenitiesModel?.data?.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final booking = amenitiesModel?.data?.data?[index];
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
                                      imageList.length == 0
                                          ? Container(
                                            height: 25.h,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: DecorationImage(
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
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: CarouselSlider(
                                                options: CarouselOptions(
                                                  autoPlay: true,
                                                  viewportFraction: 1.0,
                                                  enlargeCenterPage: false,
                                                  height: 25.h,
                                                  onPageChanged: (
                                                    index,
                                                    reason,
                                                  ) {
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
                                                          CachedNetworkImage(
                                                            imageUrl: url,
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  error,
                                                                ) => Center(
                                                                  child: Icon(
                                                                    Icons.error,
                                                                    color:
                                                                        Colors
                                                                            .red,
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
                                      Container(
                                        width: 92.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                              margin: EdgeInsets.only(
                                                right: 2.w,
                                              ),
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
                                                            ? AppColors
                                                                .maincolor
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          booking?.status ==
                                                                  "active"
                                                              ? Colors.black
                                                              : booking
                                                                      ?.status ==
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 47.w,
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
                                                    Icons.timer,
                                                    size: 18.sp,
                                                    color: AppColors.maincolor,
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Text(
                                                    "Duration Time: ${_formatDuration(booking?.durationOptions)}",
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton<int>(
                                                      padding: EdgeInsets.zero,
                                                      value:
                                                          calendar1SelectedMonthIndex,
                                                      items: List.generate(
                                                        calendar1Months.length,
                                                        (
                                                          index,
                                                        ) => DropdownMenuItem(
                                                          value: index,
                                                          child: Center(
                                                            child: Text(
                                                              calendar1Months[index],
                                                              style: TextStyle(
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
                                                          widget.status == null
                                                              ? (value) {
                                                                if (value !=
                                                                    null) {
                                                                  setState(() {
                                                                    calendar1SelectedMonthIndex =
                                                                        value;
                                                                    calendar1FocusedMonth = DateTime(
                                                                      calendar1FocusedMonth
                                                                          .year,
                                                                      value + 1,
                                                                      1,
                                                                    );
                                                                    calendar1SelectedDate =
                                                                        null;
                                                                  });
                                                                }
                                                              }
                                                              : null,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                const Icon(
                                                  Icons.calendar_month,
                                                  color: AppColors.maincolor,
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
                                                      CalendarFormat.month,
                                                  headerVisible: false,
                                                  daysOfWeekStyle:
                                                      const DaysOfWeekStyle(
                                                        weekdayStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                          fontSize: 13.5,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        weekendStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                          fontSize: 13.5,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                  calendarStyle:
                                                      const CalendarStyle(
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
                                                                  Colors.white,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                        todayTextStyle:
                                                            TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                        defaultTextStyle:
                                                            TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                        weekendTextStyle:
                                                            TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                      ),
                                                  selectedDayPredicate: (day) {
                                                    return isSameDay(
                                                      getRequestedDate(),
                                                      day,
                                                    );
                                                  },
                                                  calendarBuilders: CalendarBuilders(
                                                    defaultBuilder: (
                                                      context,
                                                      day,
                                                      _,
                                                    ) {
                                                      bool isSelected =
                                                          isSameDay(
                                                            getRequestedDate(),
                                                            day,
                                                          );
                                                      return Container(
                                                        margin:
                                                            const EdgeInsets.all(
                                                              6.0,
                                                            ),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              isSelected
                                                                  ? AppColors
                                                                      .maincolor
                                                                  : Colors
                                                                      .white,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Text(
                                                          '${day.day}',
                                                          style: TextStyle(
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                ? Text(
                                                  widget.requestedDate
                                                          .toString() ??
                                                      "",
                                                  style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: 16.sp,
                                                    color: AppColors.maincolor,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                )
                                                : Text(
                                                  calendar1SelectedDate != null
                                                      ? getOperatingHours(
                                                        calendar1SelectedDate!,
                                                        selectedAmenity
                                                            ?.operatingHours,
                                                      )
                                                      : "Select a date",
                                                  style: TextStyle(
                                                    letterSpacing: 1,
                                                    fontSize: 16.sp,
                                                    color: AppColors.maincolor,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Material(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: Container(
                                                      height: 5.h,
                                                      width: 12.h,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.maincolor,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  buildSlotBox(
                                                    label: 'Total',
                                                    value:
                                                        amenitiesModel
                                                            ?.data
                                                            ?.data?[0]
                                                            .totalBookingSlots
                                                            .toString() ??
                                                        "0",
                                                    color: Colors.blue,
                                                  ),
                                                  SizedBox(width: 6),
                                                  buildSlotBox(
                                                    label: 'Booked',
                                                    value:
                                                        amenitiesModel
                                                            ?.data
                                                            ?.data?[0]
                                                            .bookedSlots
                                                            .toString() ??
                                                        "0",
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 6),
                                                  buildSlotBox(
                                                    label: 'Available',
                                                    value:
                                                        amenitiesModel
                                                            ?.data
                                                            ?.data?[0]
                                                            .availableSlots
                                                            .toString() ??
                                                        "0",
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 6),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                          ],
                                          if (showBookingDetails) ...[
                                            SizedBox(height: 2.h),
                                            Container(
                                              height: 25.h,
                                              padding: EdgeInsets.all(16),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${aneminitiesDataModel?.data?.data?[0].name}",
                                                    style: TextStyle(
                                                      fontSize: 17.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                  SizedBox(height: 3.h),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_month,
                                                            size: 22.sp,
                                                            color:
                                                                AppColors
                                                                    .maincolor,
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
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Icon(
                                                            Icons.timer,
                                                            size: 22.sp,
                                                            color:
                                                                AppColors
                                                                    .maincolor,
                                                          ),
                                                          Text(
                                                            "${getOperatingHours(calendar1SelectedDate!, selectedAmenity?.operatingHours)}",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .confirmation_num,
                                                            size: 22.sp,
                                                            color:
                                                                AppColors
                                                                    .maincolor,
                                                          ),
                                                          Text(
                                                            "Free",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  isGlobalLoading
                                                      ? Container(
                                                        height: 5.h,
                                                        alignment:
                                                            Alignment.center,
                                                        width: double.infinity,
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  AppColors
                                                                      .maincolor,
                                                            ),
                                                      )
                                                      : GestureDetector(
                                                        onTap: () {
                                                          AddBookingApi(
                                                            getOperatingHours(
                                                              calendar1SelectedDate!,
                                                              selectedAmenity
                                                                  ?.operatingHours,
                                                            ),
                                                            calendar1SelectedDateStr,
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 6.h,
                                                          alignment:
                                                              Alignment.center,
                                                          width:
                                                              double.infinity,
                                                          decoration: BoxDecoration(
                                                            color:
                                                                AppColors
                                                                    .maincolor,
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
                                                                      AppColors
                                                                          .white,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 3.w,
                                                              ),
                                                              Container(
                                                                height: 5.h,
                                                                width: 4.h,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                  border: Border.all(
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
                                                                    Transform.translate(
                                                                      offset:
                                                                          Offset(
                                                                            -4,
                                                                            0,
                                                                          ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .arrow_forward_ios,
                                                                        color:
                                                                            Colors.white,
                                                                        size:
                                                                            14.sp,
                                                                      ),
                                                                    ),
                                                                    Transform.translate(
                                                                      offset:
                                                                          Offset(
                                                                            4,
                                                                            0,
                                                                          ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .arrow_forward_ios,
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
                          : !showBookingDetails
                          ? GestureDetector(
                            onTap: () {
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

                              if (selectedOperatingHours == "Closed") {
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
                              if (amenitiesModel?.data?.data?[0].status ==
                                  "inactive") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(milliseconds: 800),
                                    content: Text(
                                      "Selected amenities status was inactive",
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                showBookingDetails = true;
                              });
                              log(
                                "selectedCalendarDate: $calendar1SelectedDate",
                              );
                            },
                            child: Container(
                              height: 6.h,
                              alignment: Alignment.center,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color:
                                    (calendar1SelectedDate != null &&
                                            selectedOperatingHours != "Closed")
                                        ? AppColors.maincolor
                                        : AppColors.maincolor,
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
                                      border: Border.all(
                                        color: AppColors.white,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Transform.translate(
                                          offset: Offset(-4, 0),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white,
                                            size: 14.sp,
                                          ),
                                        ),
                                        Transform.translate(
                                          offset: Offset(4, 0),
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
                          : SizedBox(),
                      SizedBox(height: 5.h),
                    ],
                  ).paddingSymmetric(horizontal: 3.w),
                ),
            if (isRsvpLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: Loader()),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSlotBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 5.h,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 4),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 14.5.sp,
              color: Colors.black87,
              fontFamily: AppConstants.manrope,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: AppConstants.manrope,
              fontWeight: FontWeight.w600,
              color: color,
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

  String getOperatingHours(DateTime selectedDate, OperatingHours? hours) {
    if (hours == null) return "No operating hours available";

    final weekday = selectedDate.weekday;

    Monday? selectedDayHours;

    switch (weekday) {
      case DateTime.monday:
        selectedDayHours = hours.monday;
        break;
      case DateTime.tuesday:
        selectedDayHours = hours.tuesday;
        break;
      case DateTime.wednesday:
        selectedDayHours = hours.wednesday;
        break;
      case DateTime.thursday:
        selectedDayHours = hours.thursday;
        break;
      case DateTime.friday:
        selectedDayHours = hours.friday;
        break;
      case DateTime.saturday:
        selectedDayHours = hours.saturday;
        break;
      case DateTime.sunday:
        selectedDayHours = hours.saturday;
        break;
    }

    if (selectedDayHours != null &&
        selectedDayHours.open != null &&
        selectedDayHours.close != null) {
      return " ${selectedDayHours.open} - ${selectedDayHours.close}";
    } else {
      return "Closed";
    }
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
      if (isAttended == 1) {
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          RSVPAmenityApi(bookingID, 'maybe');
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          RSVPAmenityApi(bookingID, 'decline');
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          RSVPAmenityApi(bookingID, 'accept');
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
                Text(
                  "${loginModel?.data?.user?.name?.firstName ?? " "} ${loginModel?.data?.user?.name?.lastName ?? ""}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 8),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          RSVPAmenityAttend(bookingID, "0", rsvp);
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          RSVPAmenityAttend(bookingID, "1", rsvp);
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

  void showTornTicketDialog({
    required BuildContext context,
    required String selectedDate,
    required String selectedTime,
    required String location,
    required String attendeeInitials,
  }) {
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
                margin: const EdgeInsets.only(top: 30),
                child: TornTicket(
                  height: 51.h,
                  borderRadius: 12,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 3.h),
                        Center(
                          child: Text(
                            "Thank you!",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        const Center(
                          child: Text(
                            "Your booking was successful",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppConstants.manrope,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const Divider(height: 30, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTicketInfo(
                              Icons.calendar_today,
                              calendar1SelectedDateStr,
                            ),
                            _buildTicketInfo(Icons.access_time, selectedTime),
                            _buildTicketInfo(Icons.bookmark_border, "Free"),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        const Text(
                          "Amenities",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: AppConstants.manrope,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        SizedBox(height: 4.h),
                        batan(
                          title: "Back to Home",
                          route: () {
                            Get.to(HomePage(userName: "", selected: 1));
                          },
                          color: AppColors.maincolor,
                          fontcolor: Colors.white,
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
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.maincolor,
                child: Icon(Icons.check, size: 25.sp, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketInfo(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
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

  DateTime today = DateTime.now();

  DateTime focusedMonth = DateTime.now();

  Widget _buildCalendar1View() {
    final DateTime now = DateTime.now();
    final DateTime todayOnly = DateTime(now.year, now.month, now.day);

    calendar1SelectedDate ??= todayOnly;
    calendar1SelectedDateStr = DateFormat(
      'dd/MM/yyyy',
    ).format(calendar1SelectedDate!);

    final DateTime calendar1FirstDay = DateTime(
      calendar1FocusedMonth.year,
      calendar1FocusedMonth.month,
      1,
    );
    final DateTime calendar1LastDay = DateTime(
      calendar1FocusedMonth.year,
      calendar1FocusedMonth.month + 1,
      0,
    );

    final DateTime calendar1FocusDay =
        calendar1SelectedDate!.isAfter(calendar1FirstDay) &&
                calendar1SelectedDate!.isBefore(calendar1LastDay)
            ? calendar1SelectedDate!
            : calendar1FirstDay;

    return TableCalendar(
      firstDay: calendar1FirstDay,
      lastDay: calendar1LastDay,
      focusedDay: calendar1FocusDay,
      calendarFormat: CalendarFormat.month,
      headerVisible: false,
      selectedDayPredicate: (day) => isSameDay(calendar1SelectedDate, day),
      onDaySelected: (newSelectedDay, focusedDay) {
        final DateTime selectedOnly = DateTime(
          newSelectedDay.year,
          newSelectedDay.month,
          newSelectedDay.day,
        );
        if (selectedOnly.isBefore(todayOnly)) return;

        setState(() {
          calendar1SelectedDate = newSelectedDay;
          calendar1SelectedDateStr = DateFormat(
            'dd/MM/yyyy',
          ).format(newSelectedDay);
          calendar1Loading = true;
        });
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.maincolor,
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
          color: Colors.black,
          fontFamily: AppConstants.manrope,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: AppConstants.manrope,
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.black,
          fontFamily: AppConstants.manrope,
        ),
        weekendStyle: TextStyle(
          color: Colors.black,
          fontFamily: AppConstants.manrope,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          final bool isSelected = isSameDay(calendar1SelectedDate, day);
          final DateTime dayOnly = DateTime(day.year, day.month, day.day);
          final bool isPastDate = dayOnly.isBefore(todayOnly);

          return GestureDetector(
            onTap:
                isPastDate
                    ? null
                    : () async {
                      setState(() {
                        calendar1SelectedDate = day;
                        calendar1SelectedDateStr = DateFormat(
                          'dd/MM/yyyy',
                        ).format(day);
                        calendar1Loading = true;
                      });

                      bool success = await AmenitiesApi(
                        date: calendar1SelectedDateStr,
                      );

                      setState(() {
                        calendar1Loading = false;
                      });

                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Something went wrong. Please try again.",
                            ),
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
                  color:
                      isPastDate
                          ? Colors.grey
                          : (isSelected ? Colors.white : Colors.black),
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

  Future<bool> AmenitiesApi({required String date}) async {
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return false;
    }

    try {
      var response = await AmenitiesProvider().amenitiesApi(
        loginModel?.data?.user?.id.toString() ?? '',
        widget.amenites_id ?? "",
        date,
      );

      if (response.statusCode == 200) {
        amenitiesModel = AmenitiesModel.fromJson(response.data);

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
      setState(() {
        isLoading = false;
        load = false;
      });
      return false;
    }
  }

  Future<bool> AddBookingApi(String time, date) async {
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "amenity_id": widget.amenites_id ?? '',
      "date": date ?? "",
    };

    setState(() {
      isGlobalLoading = true;
    });
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return false;
    }

    try {
      var response = await AmenitiesProvider().addBookingApi(data);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            isGlobalLoading = false;
          });
        }

        showTornTicketDialog(
          attendeeInitials: 'NP',
          context: context,
          location: aneminitiesDataModel?.data?.data?[0].name ?? "",
          selectedDate: selectedDate.toString(),
          selectedTime: time,
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

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().rsvpToAmenityApi(data);
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isRsvpLoading = false;
              });
            }
            Get.to(BookingScreen());
          } else {
            setState(() {
              isRsvpLoading = false;
            });
          }
        } catch (e, stackTrace) {
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

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().rsvpToAmenityApi(data);
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isRsvpLoading = false;
              });
            }
          } else {
            setState(() {
              isRsvpLoading = false;
            });
          }
        } catch (e, stackTrace) {
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
