import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Services/themeServices.dart' show ThemeController;
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/loader.dart';
import '../../HomeScreen/View/homePage.dart';
import '../Provider/bookingsProvider.dart';
import '../modal/amenitiesBookStatusModel.dart';
import 'amenitiesDetailsScreen.dart';
import 'bookAmenities.dart';

class BookingScreen extends StatefulWidget {
  final String? id;

  const BookingScreen({super.key, this.id});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool isLoading = false;
  String selectedType = "all";

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    BookAmetiesStatusApi(selectedType.toLowerCase());
  }

  // સ્ટેટસ કલર લોજિક
  Color getStatusColor(String status, String? attended) {
    if (attended == "1")
      return const Color(0xFF2ECC71); // Completed/Attended લીલો કલર
    if (attended == "0") return Colors.redAccent;

    status = status.toLowerCase();
    if (status == "confirmed" || status == "completed")
      return const Color(0xFF2ECC71);
    if (status == "cancelled" || status == "rejected") return Colors.redAccent;
    if (status == "pending") return Colors.orange;

    return Colors.grey;
  }

  String getStatusText(String status, String? attended) {
    if (attended == "1") return "Completed";
    if (attended == "0") return "Not Attended";
    return status.capitalizeFirst!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    // થીમ મુજબ કલર સેટિંગ્સ
    final bgColor =
        theme.isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    final cardColor = theme.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = theme.isDark ? Colors.white : Colors.black;
    final secondaryTextColor = theme.isDark ? Colors.white70 : Colors.black54;
    final filterBtnColor =
        theme.isDark ? const Color(0xFFD4C18F) : const Color(0xFF5B6B8E);
    final filterTxtColor = theme.isDark ? Colors.black : Colors.white;
    final iconBgColor =
        theme.isDark ? Color(0xf036342F) : const Color(0xFFF0F2F8);

    Map<String, dynamic>? bookingsData =
        bookAmenitiesStatusModel?.data?.toJson();
    final List<dynamic> nonEmptyBookings = [];
    bookingsData?.forEach((monthName, bookings) {
      if (bookings != null && bookings.isNotEmpty) {
        for (var booking in bookings) {
          nonEmptyBookings.add({"month": monthName, "booking": booking});
        }
      }
    });

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              TitleBar(
                back: () => Get.off(HomePage(userName: '', selected: 1)),
                title: 'My Bookings',
                drawerCallback: () {},
              ),
              SizedBox(height: 3.h),

              // Filter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Filter Status By",
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manropeBold,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: secondaryTextColor,
                        size: 20.sp,
                      ),
                    ],
                  ),
                  _buildFilterDropdown(filterBtnColor, filterTxtColor),
                ],
              ),
              SizedBox(height: 2.h),

              Expanded(
                child:
                    isLoading
                        ? Center(child: Loader())
                        : nonEmptyBookings.isEmpty
                        ? Center(
                          child: Text(
                            "No Bookings Found",
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 15.sp,
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: nonEmptyBookings.length,
                          padding: EdgeInsets.only(bottom: 12.h),
                          itemBuilder: (context, index) {
                            final booking = nonEmptyBookings[index]['booking'];
                            return _buildBookingCard(
                              booking,
                              cardColor,
                              primaryTextColor,
                              secondaryTextColor,
                              iconBgColor,
                              theme.isDark,
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),

      // Floating Action Button (ઈમેજ મુજબ મોટું બટન)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          isLoading
              ? Container()
              : Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                width: double.infinity,
                height: 7.h,
                child: FloatingActionButton.extended(
                  elevation: 2,
                  backgroundColor: filterBtnColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  onPressed: () => Get.to(() => const BookAmenities_Screen()),
                  icon: Icon(Icons.add, color: filterTxtColor, size: 24),
                  label: Text(
                    "Book Amenity",
                    style: TextStyle(
                      color: filterTxtColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildFilterDropdown(Color btnColor, Color txtColor) {
    return Container(
      // width: 30.w,
      height: 5.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          setState(() {
            selectedType = value;
            isLoading = true;
          });
          BookAmetiesStatusApi(value.toLowerCase());
        },
        itemBuilder:
            (context) =>
                ["all", "confirmed", "pending", "cancelled"]
                    .map(
                      (e) => PopupMenuItem(
                        value: e,
                        child: Text(
                          e.capitalizeFirst!,
                          style: TextStyle(fontFamily: AppConstants.manrope),
                        ),
                      ),
                    )
                    .toList(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              selectedType.capitalizeFirst!,
              style: TextStyle(
                color: txtColor,
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.manropeBold,
              ),
            ).paddingOnly(right: 2.w),
            Icon(Icons.keyboard_arrow_down, color: txtColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    dynamic booking,
    Color cardColor,
    Color pTextColor,
    Color sTextColor,
    Color iconBg,
    bool isDark,
  ) {
    String status = booking['status'] ?? "Pending";
    Color sColor = getStatusColor(status, booking['attended']?.toString());

    return GestureDetector(
      onTap: () {
        Get.to(
          () => AmenitiesDetail(
            amenites_id: booking['amenity']['id'].toString(),
            status: booking['status'],
            bookingDate: booking['requested_at'],
            attend: booking['attended']?.toString() ?? "",
            rsvp: booking['rsvp'],
            EventName: booking['amenity']['name'],
            bookingId: booking['booking_id'].toString(),
            requestedDate: booking['requested_at'] ?? "N/A",
            startTime: booking['start_time'] ?? "N/A",
            endtime: booking['end_time'] ?? "N/A",
            isPage: true,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1),
          ),
          boxShadow:
              isDark
                  ? []
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
        ),
        child: Column(
          children: [
            // Status & ID Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      status.toLowerCase() == "cancelled"
                          ? Icons.cancel
                          : Icons.check_circle,
                      color: sColor,
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      getStatusText(status, booking['attended']?.toString()),
                      style: TextStyle(
                        color: sColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ],
                ),
                Text(
                  booking['booking_id']?.toString() ?? "",
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                    fontSize: 12.sp,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            // Content Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: isDark ? Color(0xf0C9B68B) : const Color(0xFF5B6B8E),
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['amenity']['name'] ?? "Amenity",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: pTextColor,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      // તારીખ બતાવવા માટે
                      _iconDetail(
                        Icons.calendar_month,
                        formatDate(booking['requested_at']),
                        // આ આપોઆપ "30 Dec 2025" બતાવશે
                        sTextColor,
                      ),

                      // સમય બતાવવા માટે
                      _iconDetail(
                        Icons.access_time,
                        formatTime12(booking['requested_at']),
                        // આ આપોઆપ "09:55 AM" બતાવશે
                        sTextColor,
                      ),
                      _iconDetail(
                        Icons.location_on_outlined,
                        "Lower Ground Floor",
                        sTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconDetail(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13.sp, color: color.withOpacity(0.5)),
          SizedBox(width: 2.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13.sp,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  // --- API Logic ---
  Future<void> BookAmetiesStatusApi(String status) async {
    String mappedStatus = status == "all" ? "" : status;
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "status": mappedStatus,
    };
    log("fff$data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().allAmenitiesApi(data);
          if (response.statusCode == 200) {
            bookAmenitiesStatusModel = BookAmenitiesStatusModel.fromJson(
              response.data,
            );
            print(response.data);
            print(
              "bookAmenitiesStatusModel?.databookAmenitiesStatusModel?.data${bookAmenitiesStatusModel?.data}",
            );
            setState(() => isLoading = false);
          }
        } catch (e) {
          setState(() => isLoading = false);
          log(
            "bookAmenitiesStatusModel?.databookAmenitiesStatusModel?.data${bookAmenitiesStatusModel?.data}",
          );
        }
      }
    });
  }

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "N/A";
    try {
      // જો તારીખ "2025-12-30 09:55 AM" ફોર્મેટમાં હોય તો તેને આ રીતે પાર્સ કરવી પડે
      DateTime parsedDate = DateFormat("yyyy-MM-dd hh:mm a").parse(rawDate);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      try {
        // જો ઉપરનું ફોર્મેટ ફેલ જાય, તો સ્ટાન્ડર્ડ પાર્સિંગ ટ્રાય કરશે
        DateTime parsedDate = DateTime.parse(rawDate);
        return DateFormat('dd MMM yyyy').format(parsedDate);
      } catch (e) {
        return "N/A";
      }
    }
  }

  String formatTime12(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "N/A";
    try {
      // આખી સ્ટ્રિંગમાંથી ટાઈમ પાર્સ કરશે
      DateTime parsedDate = DateFormat("yyyy-MM-dd hh:mm a").parse(rawDate);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return rawDate; // જો પહેલેથી જ ફક્ત ટાઈમ આવતો હોય તો તે જ બતાવશે
    }
  }
}
