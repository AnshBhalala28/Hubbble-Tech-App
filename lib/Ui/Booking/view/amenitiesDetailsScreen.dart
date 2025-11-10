import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:torn_ticket/torn_ticket.dart';

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

class Form_Screen extends StatefulWidget {
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

  const Form_Screen({
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
  State<Form_Screen> createState() => _Form_ScreenState();
}

class _Form_ScreenState extends State<Form_Screen> {
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

  bool showBookingDetails = false;

  String? selectedStartTime; // દા.ત., "10:30 AM"
  // ▼▼▼ ડ્યુરેશન હવે API માંથી સેટ થશે ▼▼▼
  int selectedDurationInMinutes = 60; // ડિફોલ્ટ 60 મિનિટ

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

  // ડેટ/ટાઇમ પાર્સ કરવા માટેના હેલ્પર ફંક્શન્સ
  DateTime _parseTime(String timeStr, DateTime onDate) {
    // 1. સૌથી પહેલા સ્ટ્રિંગમાંથી વધારાની સ્પેસ દૂર કરો
    final String cleanTimeStr = timeStr.trim();

    try {
      // 2. પહેલા 24-કલાક (HH:mm) ફોર્મેટમાં પાર્સ કરવાનો પ્રયાસ કરો
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
      // 3. જો 24-કલાક ફોર્મેટ નિષ્ફળ જાય, તો AM/PM (h:mm a) ફોર્મેટમાં પ્રયાસ કરો
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
        // 4. જો બંન્ને નિષ્ફળ જાય, તો એરર પ્રિન્ટ કરો
        print("!!! Failed to parse time: '$timeStr' !!!");
        // ક્રેશ થવાથી બચવા માટે, આજની તારીખ પરત કરો
        return DateTime.now();
      }
    }
  }

  // ઉપલબ્ધ સ્લોટ જનરેટ કરવા માટેનું મુખ્ય લોજિક
  List<String> _generateAvailableSlots(
    String operatingHoursStr,
    List<ExistingBooking> existingBookings,
    int bufferInMinutes,
  ) {
    List<String> availableSlots = [];
    final DateTime now = DateTime.now();
    final DateTime selectedDay = calendar1SelectedDate!;

    // 1. ઓપરેટિંગ અવર્સ પાર્સ કરો
    if (operatingHoursStr == "Closed" ||
        operatingHoursStr == "No operating hours available" ||
        !operatingHoursStr.contains(" - ")) {
      return []; // કોઈ સ્લોટ નથી
    }
    final parts = operatingHoursStr.split(" - ");
    final DateTime openingTime = _parseTime(parts[0].trim(), selectedDay);
    final DateTime closingTime = _parseTime(parts[1].trim(), selectedDay);

    DateTime currentTime = openingTime;

    // 2. બધા ૩૦-મિનિટના સ્લોટ જનરેટ કરો
    while (currentTime.isBefore(closingTime)) {
      final DateTime slotStartTime = currentTime;
      // ▼▼▼ ડ્યુરેશન હવે ફિક્સ છે (selectedDurationInMinutes માંથી) ▼▼▼
      final DateTime slotEndTime = slotStartTime.add(
        Duration(minutes: selectedDurationInMinutes),
      );

      bool isAvailable = true;
      // જો સ્લોટનો અંતિમ સમય ક્લોઝિંગ ટાઇમ પછી હોય તો સ્લોટ ન બતાવો
      if (slotEndTime.isAfter(closingTime)) {
        isAvailable = false;
      }
      // જો આજનો દિવસ પસંદ કરેલ હોય અને સ્લોટ ભૂતકાળમાં હોય તો ન બતાવો
      if (isSameDay(selectedDay, now) && slotStartTime.isBefore(now)) {
        isAvailable = false;
      }

      // 3. એક્ઝિસ્ટિંગ બુકિંગ સાથે ઓવરલેપ ચેક કરો
      if (isAvailable) {
        for (final booking in existingBookings) {
          if (booking.startTime == null || booking.endTime == null) continue;

          final DateTime bookingStart = _parseTime(
            booking.startTime!,
            selectedDay,
          );
          final DateTime bookingEnd = _parseTime(booking.endTime!, selectedDay);

          // બફર ટાઇમ સાથે બુકિંગનો અંતિમ સમય
          final DateTime bufferEndTime = bookingEnd.add(
            Duration(minutes: bufferInMinutes),
          );

          if ((slotStartTime.isBefore(bufferEndTime)) &&
              (slotEndTime.isAfter(bookingStart))) {
            isAvailable = false;
            break;
          }
        }
      }

      if (isAvailable) {
        availableSlots.add(DateFormat("h:mm a").format(slotStartTime));
      }

      // ▼▼▼ ફેરફાર અહીં છે ▼▼▼
      // 30 મિનિટના બદલે, હવે આપણે બુકિંગ ડ્યુરેશન જેટલો વધારો કરીશું
      // આનાથી 60 મિનિટના ડ્યુરેશન માટે 9:00, 10:00, 11:00 જેવા સ્લોટ બનશે

      // જો selectedDurationInMinutes 0 હોય (જે API માંથી કદાચ ન આવે, પણ સુરક્ષા માટે),
      // તો ડિફોલ્ટ 30 મિનિટનો વધારો કરો જેથી અનંત લૂપ ન થાય.
      final int increment =
          selectedDurationInMinutes > 0 ? selectedDurationInMinutes : 30;
      currentTime = currentTime.add(Duration(minutes: increment));
      // ▲▲▲ ફેરફાર પૂરો ▲▲▲
    }

    return availableSlots;
  }

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
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            isLoading
                ? Loader()
                : Column(
                  children: [
                    SizedBox(height: 4.h),
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
                                              style: const TextStyle(
                                                color: AppColors.black,
                                                fontFamily:
                                                    AppConstants.manrope,
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
                                                  color: AppColors.maincolor,
                                                ),
                                                lessStyle: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                  color: AppColors.maincolor,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.grey.shade500,
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 3.w,
                                                          vertical: 1.h,
                                                        ),
                                                    margin: EdgeInsets.only(
                                                      right: 2.w,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          booking?.status ==
                                                                  "active"
                                                              ? AppColors
                                                                  .bgcolor
                                                              : booking
                                                                      ?.status ==
                                                                  "inactive"
                                                              ? Colors.red
                                                              : AppColors
                                                                  .bgcolor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          booking?.status ==
                                                                  "active"
                                                              ? Icons
                                                                  .check_circle
                                                              : booking
                                                                      ?.status ==
                                                                  "inactive"
                                                              ? Icons.cancel
                                                              : null,
                                                          size: 18.sp,
                                                          color:
                                                              booking?.status ==
                                                                      "active"
                                                                  ? AppColors
                                                                      .maincolor
                                                                  : booking
                                                                          ?.status ==
                                                                      "inactive"
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .white,
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
                                                                    ? Colors
                                                                        .black
                                                                    : booking
                                                                            ?.status ==
                                                                        "inactive"
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .white,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 3.w,
                                                          vertical: 1.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.bgcolor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.book,
                                                          size: 18.sp,
                                                          color:
                                                              AppColors
                                                                  .maincolor,
                                                        ),
                                                        SizedBox(width: 2.w),
                                                        Text(
                                                          "Max Booking per Day: ${booking?.maxBookingPerDay ?? 'N/A'}",
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
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
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 3.w,
                                                          vertical: 1.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.bgcolor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.timer,
                                                          size: 18.sp,
                                                          color:
                                                              AppColors
                                                                  .maincolor,
                                                        ),
                                                        SizedBox(width: 2.w),
                                                        Text(
                                                          "Duration: ${_formatDuration(booking?.durationOptions)}",
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
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
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 3.w,
                                                          vertical: 1.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.bgcolor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.people,
                                                          size: 18.sp,
                                                          color:
                                                              AppColors
                                                                  .maincolor,
                                                        ),
                                                        SizedBox(width: 2.w),
                                                        Text(
                                                          "Capacity: ${booking?.capacity ?? ''}",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
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
                                                      const Icon(
                                                        Icons.calendar_month,
                                                        color:
                                                            AppColors.maincolor,
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
                                                        daysOfWeekStyle:
                                                            const DaysOfWeekStyle(
                                                              weekdayStyle: TextStyle(
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
                                                              weekendStyle: TextStyle(
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

                                                          // ---- TIME ROW ----
                                                          Row(
                                                            children: [
                                                              // Start Time
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

                                                              // End Time
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
                                                      : Text(
                                                        "Operating Hours: $operatingHoursString",
                                                        style: TextStyle(
                                                          letterSpacing: 1,
                                                          fontSize: 16.sp,
                                                          color:
                                                              AppColors
                                                                  .maincolor,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manropeBold,
                                                        ),
                                                      ),

                                                  if (calendar1SelectedDate !=
                                                          null &&
                                                      widget.status == null &&
                                                      !calendar1Loading) ...[
                                                    Divider(height: 3.h),
                                                    _buildTimeSlotPicker(
                                                      operatingHoursString,
                                                      selectedAmenity
                                                              ?.existingBookings ??
                                                          [],
                                                      30, // Buffer time (30 min)
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
                                                      color: AppColors.bgcolor,
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
                                                                        AppColors
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
                                                                        AppColors
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
                                                                          Colors
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
                                                                        AppColors
                                                                            .maincolor,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                    _formatDuration(
                                                                      booking
                                                                          ?.durationOptions,
                                                                    ),

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
                                                                          Colors
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
                                                                  selectedDurationInMinutes,
                                                                  booking?.name ??
                                                                      "N/A",
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
                            if (amenitiesModel?.data?.data?[0].status ==
                                "inactive") {
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
                            final amenityData =
                                amenitiesModel?.data?.data?.first;
                            if (amenityData != null &&
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

                            if (selectedStartTime == null) {
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
                color: Colors.black.withOpacity(0.3),
                child: Center(child: Loader()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotPicker(
    String operatingHoursStr,
    List<ExistingBooking> existingBookings,
    int bufferInMinutes,
  ) {
    final List<String> availableSlots = _generateAvailableSlots(
      operatingHoursStr,
      existingBookings,
      bufferInMinutes,
    );

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
                    amenitiesModel?.data?.data?[0].totalBookingSlots
                        .toString() ??
                    "0",
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: buildSlotBox(
                label: 'Booked',
                value:
                    amenitiesModel?.data?.data?[0].bookedSlots.toString() ??
                    "0",
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: buildSlotBox(
                label: 'Available',
                value:
                    amenitiesModel?.data?.data?[0].availableSlots.toString() ??
                    "0",
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),

        SizedBox(height: 2.h),

        Text(
          "Select Start Time",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: AppConstants.manropeBold,
          ),
        ),
        SizedBox(height: 1.h),

        if (availableSlots.isEmpty)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.bgcolor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              "No available slots for the selected date.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppConstants.manrope,
                fontSize: 14.sp,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                availableSlots.map((time) {
                  final bool isSelected = selectedStartTime == time;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStartTime = time;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.maincolor
                                : AppColors.bgcolor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.maincolor
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontFamily: AppConstants.manrope,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }

  Widget buildSlotBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 5.h,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label : ",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black87,
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
                color: color,
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
        selectedDayHours = hours.sunday;
        break;
    }
    if (selectedDayHours != null &&
        selectedDayHours.open != null &&
        selectedDayHours.close != null) {
      if (selectedDayHours.open!.isNotEmpty &&
          selectedDayHours.close!.isNotEmpty) {
        return "${selectedDayHours.open} - ${selectedDayHours.close}";
      } else {
        return "Closed";
      }
    } else {
      return "Closed";
    }
  }

  String _formatDuration(List<String>? durations) {
    if (durations == null || durations.isEmpty) return "N/A";
    // હવે આપણે selectedDurationInMinutes નો ઉપયોગ કરીશું, જે API માંથી સેટ થાય છે
    int totalMinutes = selectedDurationInMinutes;

    if (totalMinutes < 60) {
      return "$totalMinutes min";
    } else {
      double hours = totalMinutes / 60;
      if (hours == hours.toInt()) {
        // જો બરાબર 1.0, 2.0, વગેરે હોય તો ".0" દૂર કરો
        return "${hours.toInt()} hr";
      }
      // જો 1.5 hr હોય તો બતાવો
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
                  backgroundColor: AppColors.maincolor.withOpacity(0.1),
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
                  backgroundColor: AppColors.maincolor.withOpacity(0.1),
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
                          Navigator.pop(context);
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

  // void showTornTicketDialog({
  //   required BuildContext context,
  //   required String selectedDate,
  //   required String selectedTime,
  //   required String endTime,
  //   required String duration,
  //   required String location,
  //   required String attendeeInitials,
  // }) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         backgroundColor: Colors.transparent,
  //         child: Stack(
  //           alignment: Alignment.topCenter,
  //           children: [
  //             Container(
  //               margin: const EdgeInsets.only(top: 40),
  //               child: TornTicket(
  //                 height: 51.h,
  //                 borderRadius: 12,
  //                 child: Container(
  //                   padding: const EdgeInsets.all(20),
  //                   width: double.infinity,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       SizedBox(height: 3.h + 10),
  //                       Center(
  //                         child: Text(
  //                           "Thank you!",
  //                           style: TextStyle(
  //                             fontSize: 20.sp,
  //                             fontWeight: FontWeight.bold,
  //                             fontFamily: AppConstants.manrope,
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(height: 1.h),
  //                       const Center(
  //                         child: Text(
  //                           "Your booking was successful",
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             fontFamily: AppConstants.manrope,
  //                             color: Colors.grey,
  //                           ),
  //                         ),
  //                       ),
  //                       const Divider(height: 30, thickness: 1),
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           _buildTicketInfo(
  //                             Icons.calendar_today,
  //                             selectedDate.replaceAll('/', '-'),
  //                           ),
  //                           _buildTicketInfo(Icons.access_time, selectedTime),
  //                           _buildTicketInfo(Icons.access_time, endTime),
  //                           _buildTicketInfo(Icons.timelapse, duration),
  //                         ],
  //                       ),
  //                       SizedBox(height: 3.h),
  //                       const Text(
  //                         "Amenities",
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           color: Colors.grey,
  //                           fontFamily: AppConstants.manrope,
  //                           letterSpacing: 1,
  //                         ),
  //                       ),
  //                       Text(
  //                         location,
  //                         style: const TextStyle(
  //                           fontSize: 15,
  //                           fontWeight: FontWeight.w500,
  //                           fontFamily: AppConstants.manrope,
  //                         ),
  //                       ),
  //                       SizedBox(height: 1.h),
  //                       SizedBox(height: 4.h),
  //                       batan(
  //                         title: "Back to Home",
  //                         route: () {
  //                           Get.offAll(() => const BookingScreen());
  //                         },
  //                         color: AppColors.maincolor,
  //                         fontcolor: Colors.white,
  //                         height: 5.h,
  //                         width: double.infinity,
  //                         fontsize: 18.sp,
  //                         radius: 12.0,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               top: 0,
  //               child: CircleAvatar(
  //                 radius: 40,
  //                 backgroundColor: AppColors.maincolor,
  //                 child: Icon(Icons.check, size: 25.sp, color: Colors.white),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // Widget _buildTicketInfo(IconData icon, String label) {
  //   return Column(
  //     children: [
  //       Icon(icon, color: Colors.amber[700]),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
  //       ),
  //     ],
  //   );
  // }
  void showTornTicketDialog({
    required BuildContext context,
    required String selectedDate,
    required String selectedTime,
    required String endTime,
    required String duration,
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
                margin: const EdgeInsets.only(top: 40),
                child: TornTicket(
                  height: 51.h,
                  borderRadius: 12,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
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

                        // ✅ New Better Design
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.withOpacity(0.20),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // DATE
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.amber[800],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    selectedDate.replaceAll('/', '-'),
                                    style:  TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,

                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              // START → END
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_filled,
                                    color: Colors.green[700],
                                    size: 22,
                                  ),
                                  SizedBox(width: 8),

                                  Text(
                                    selectedTime,
                                    style:  TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,

                                    ),
                                  ),

                                  const SizedBox(width: 6),
                                 Icon(Icons.arrow_forward,  color: Colors.black,
                                   size: 15.sp,),
                                  const SizedBox(width: 6),

                                  Text(
                                    endTime,
                                    style:  TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,

                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              // Duration
                              Row(
                                children: [
                                  Icon(
                                    Icons.timelapse,
                                    color: Colors.blue[700],
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    duration,
                                    style:  TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,

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
                            color: Colors.black,
                            fontFamily: AppConstants.manropeBold,
                            letterSpacing: 1,
                          ),
                        ),

                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        batan(
                          title: "Back to Home",
                          route: () {
                            Get.offAll(() => const BookingScreen());
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

    final DateTime kFirstDay = DateTime(now.year - 1, now.month, 1);
    final DateTime kLastDay = DateTime(now.year + 1, now.month + 1, 0);

    return TableCalendar(
      firstDay: kFirstDay,
      lastDay: kLastDay,

      focusedDay: calendar1FocusedMonth,

      calendarFormat: CalendarFormat.month,
      headerVisible: false,
      selectedDayPredicate: (day) => isSameDay(calendar1SelectedDate, day),

      onPageChanged: (focusedDay) {
        setState(() {
          calendar1FocusedMonth = focusedDay;
        });
      },

      enabledDayPredicate: (day) {
        final DateTime dayOnly = DateTime(day.year, day.month, day.day);
        return !dayOnly.isBefore(todayOnly);
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
          color: Colors.black,
          fontFamily: AppConstants.manrope,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: AppConstants.manrope,
        ),
        outsideTextStyle: TextStyle(color: Colors.grey),

        disabledTextStyle: TextStyle(
          color: Colors.grey,
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
        defaultBuilder: (context, day, focusedDay) {
          final bool isSelected = isSameDay(calendar1SelectedDate, day);
          final DateTime dayOnly = DateTime(day.year, day.month, day.day);
          final bool isPastDate = dayOnly.isBefore(todayOnly);
          final bool isToday = isSameDay(dayOnly, todayOnly);
          Color? bgColor;
          Color fgColor;

          if (isSelected) {
            bgColor = AppColors.maincolor;
            fgColor = Colors.white;
          } else if (isToday) {
            bgColor = Colors.grey[300];
            fgColor = isPastDate ? Colors.grey : Colors.black;
          } else {
            bgColor = Colors.transparent;
            fgColor = isPastDate ? Colors.grey : Colors.black;
          }

          return Container(
            margin: const EdgeInsets.all(6.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.manrope,
              ),
            ),
          );
        },
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

        // API માંથી ડ્યુરેશન સેટ કરો
        if (amenitiesModel?.data?.data?.isNotEmpty == true &&
            amenitiesModel!.data!.data!.first.durationOptions?.isNotEmpty ==
                true) {
          // API માંથી મળેલ પ્રથમ ડ્યુરેશનને સેટ કરો
          selectedDurationInMinutes =
              int.tryParse(
                amenitiesModel!.data!.data!.first.durationOptions!.first,
              ) ??
              60; // જો પાર્સ ન થાય તો 60
        } else {
          selectedDurationInMinutes = 60; // જો API માંથી ન મળે તો 60
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
      return DateFormat("HH:mm:ss").format(parsed);
    } catch (e) {
      return time; // fallback
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

  // String apiTime = convertTo24(time);
  // Future<bool> AddBookingApi(
  //   String date,
  //   String time,
  //   int duration,
  //   String name,
  // ) async {
  //   String apiTime = convertTo24(time);
  //   Map<String, String> data = {
  //     "user_id": loginModel?.data?.user?.id.toString() ?? "",
  //     "amenity_id": widget.amenites_id ?? '',
  //     "date": date,
  //     "start_time": apiTime,
  //     "duration_minutes": duration.toString(),
  //   };
  //   log("data data data data $data");
  //   setState(() {
  //     isGlobalLoading = true;
  //   });
  //   bool hasInternet = await checkInternet();
  //   if (!hasInternet) {
  //     if (mounted) buildErrorDialog(context, 'Error', "Internet Required");
  //     setState(() {
  //       isGlobalLoading = false;
  //     });
  //     return false;
  //   }
  //   try {
  //     var response = await AmenitiesProvider().addBookingApi(data);
  //     if (response.statusCode == 200) {
  //       if (mounted) {
  //         setState(() {
  //           isGlobalLoading = false;
  //         });
  //       }
  //
  //       // ટિકિટ માટે ડ્યુરેશન સ્ટ્રિંગ ફોર્મેટ કરો
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
  //
  //         endTime: ''
  //       );
  //       return true;
  //     } else {
  //       if (mounted) {
  //         setState(() {
  //           isGlobalLoading = false;
  //         });
  //       }
  //       Get.snackbar(
  //         "Booking Failed",
  //         response.data['message'] ?? "Something went wrong. Please try again.",
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //       return false;
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         isGlobalLoading = false;
  //       });
  //     }
  //     Get.snackbar(
  //       "Error",
  //       "Something went wrong. Please try again later.",
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return false;
  //   }
  // }
  Future<bool> AddBookingApi(
    String date,
    String time,
    int duration,
    String name,
  ) async {
    // Convert AM/PM to 24-hour if needed
    String apiTime = convertTo24(time);

    // 🔹 Calculate end time from duration
    String endTime = calculateEndTime(apiTime, duration);

    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "amenity_id": widget.amenites_id ?? '',
      "date": date,
      "start_time": apiTime,
      "end_time": endTime, // 👈 Added
      "duration_minutes": duration.toString(),
    };

    log("data => $data");

    setState(() {
      isGlobalLoading = true;
    });

    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      if (mounted) buildErrorDialog(context, 'Error', "Internet Required");
      setState(() {
        isGlobalLoading = false;
      });
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

        // Format duration for ticket
        String durationStr = "${(duration / 60).toStringAsFixed(1)} hr";
        if (duration < 60) {
          durationStr = "$duration min";
        } else if (duration % 60 == 0) {
          durationStr = "${(duration / 60).toInt()} hr";
        }

        // ✅ show ticket with end time
        showTornTicketDialog(
          attendeeInitials: 'NP',
          context: context,
          location: name,
          selectedDate: date.toString(),
          selectedTime: time,
          duration: durationStr,
          endTime: DateFormat("hh:mm a").format(
            DateFormat("HH:mm:ss").parse(endTime),
          ), // convert to AM/PM for display
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
          response.data['message'] ?? "Something went wrong. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
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
    bool hasInternet = await checkInternet();
    if (hasInternet) {
      try {
        var response = await AmenitiesProvider().rsvpToAmenityApi(data);
        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.pop(context);
            Get.offAll(() => const BookingScreen());
            Get.snackbar("RSVP Updated", "Your response has been recorded.");
          }
        } else {
          if (mounted) {
            Navigator.pop(context);
            Get.snackbar("Error", "Failed to update RSVP.");
          }
        }
      } catch (e) {
        print("RSVPApi Error: $e");
        if (mounted) Navigator.pop(context);
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
            Navigator.pop(context);
            Get.offAll(() => const BookingScreen());
            Get.snackbar("Attendance Marked", "Thank you for attending!");
          }
        } else {
          if (mounted) {
            Navigator.pop(context);
            Get.snackbar("Error", "Failed to mark attendance.");
          }
        }
      } catch (e) {
        print("AttendApi Error: $e");
        if (mounted) Navigator.pop(context);
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
}
