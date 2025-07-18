import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wavee/Screen/HomeNewPage/View/homenewpage.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../Model/booking_model.dart';
import '../Provider/booking_provider.dart';
import 'booking_screen.dart';
import 'form_screen.dart';

class BookAmenities_Screen extends StatefulWidget {
  final String? id;

  const BookAmenities_Screen({super.key, this.id});

  @override
  State<BookAmenities_Screen> createState() => _BookAmenities_ScreenState();
}

class _BookAmenities_ScreenState extends State<BookAmenities_Screen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyBookAmenities =
      GlobalKey<ScaffoldState>();
  bool isLoading = false;
  List<Map<String, dynamic>> dates = [];
  String selectedValue = 'days';
  int selectedIndex = 0;
  String? selectedDate;
  DateTime now = DateTime.now();
  DateTime selectedDay = DateTime.now();
  DateTime? selectedYear;
  bool load = false;
  bool isGlobalLoading = false;

  @override
  void initState() {
    _generateDatesBasedOnSelection();
    setState(() {
      isLoading = true;
      load = true;
    });
    AmenitiesApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      key: _scaffoldKeyBookAmenities,
      backgroundColor: AppColors.bgcolor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              child: Column(
                children: [
                  SizedBox(height: 4.h),
                  TitleBar(
                    back: () {
                      Get.to(HomePage(userName: "", selected: 1));
                    },
                    title: 'Amenities',
                    drawerCallback: () {
                      _scaffoldKeyBookAmenities.currentState?.openDrawer();
                    },
                  ),
                  SizedBox(height: 3.h),
                  isLoading
                      ? Loader().paddingOnly(top: 35.h)
                      : aneminitiesDataModel?.data1?.data == null
                      ? Center(
                        child: Text(
                          "No Amenities Available",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontFamily: AppConstants.manrope,
                          ),
                        ).paddingOnly(top: 35.h),
                      )
                      : SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount:
                              aneminitiesDataModel?.data1?.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            var booking =
                                aneminitiesDataModel?.data1?.data?[index];
                            log(
                              "Booking Data: ${aneminitiesDataModel?.data1?.data?.length}",
                            );
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Material(
                                  elevation: 1,
                                  borderRadius: BorderRadius.circular(12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => Form_Screen(
                                          amenites_id:
                                              booking?.id.toString() ?? '',
                                          isPage: false,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 33.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  (booking?.imageUrl != null &&
                                                          booking!
                                                              .imageUrl!
                                                              .isNotEmpty)
                                                      ? booking!.imageUrl!.first
                                                      : "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png",
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 20.h,
                                              placeholder:
                                                  (context, url) => Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Image(
                                                    image: NetworkImage(
                                                      "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png",
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          SizedBox(height: 1.h),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                            ),
                                            child: Text(
                                              booking?.name ?? "No Title",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2.w,
                                            ),
                                            child: Text(
                                              booking?.description ??
                                                  "No Description",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                color: Colors.grey[700],
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: 2.w,
                                              bottom: 1.h,
                                            ),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 18.sp,
                                                color: AppColors.maincolor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).marginOnly(bottom: 1.h),
                                Positioned(
                                  top: 1.h,
                                  right: 1.w,
                                  child: batan(
                                    title: "Book Now",
                                    route: () {
                                      Get.to(
                                        () => Form_Screen(
                                          amenites_id:
                                              booking?.id.toString() ?? '',
                                          isPage: false,
                                        ),
                                      );
                                    },
                                    color: AppColors.maincolor,
                                    fontcolor: Colors.white,
                                    height: 4.h,
                                    width: 22.w,
                                    fontsize: 15.sp,
                                    radius: 7.0,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                ],
              ),
            ),
          ),
          if (isGlobalLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
    );
  }

  Future<bool> AddBookingApi(String id) async {
    String finalDate =
        selectedDate ?? DateFormat('dd/MM/yyyy').format(DateTime.now());

    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "amenity_id": id ?? "",
      "date": finalDate,
    };
    log("📤 Booking Data: $data");

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
            isLoading = false;
          });
        }

        showBookingConfirmedDialog(
          context: context,
          selectedDate: finalDate.toString(),
        );

        return true;
      } else {
        if (mounted) {
          setState(() {
            isGlobalLoading = false;
            isLoading = false;
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
          isLoading = false;
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

  AmenitiesApi() async {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().amenitiesApi(
            loginModel?.data?.user?.id.toString() ?? '',
            "",
            "",
          );
          aneminitiesDataModel = AmenitiesModel.fromJson(response.data);
          if (response.statusCode == 200) {
            log("API Response AVE CHE: ${response.data}");
            setState(() {
              // aneminitiesDataModel = aneminitiesDataModel;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e, stackTrace) {
          log("Geeting Error $stackTrace");
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

  String formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(rawDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return "Invalid date";
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

  BuildContext? _bookingSheetContext;

  // void submitBooking(String id) {
  //   log("id ave ceh eee ${id}");
  //   if (_bookingSheetContext != null) {
  //     Navigator.pop(_bookingSheetContext!);
  //     _bookingSheetContext = null;
  //   }
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (BuildContext context) {
  //       _bookingSheetContext = context;
  //       return FractionallySizedBox(
  //         heightFactor: 0.6,
  //         child: Container(
  //           width: double.infinity,
  //           child: StatefulBuilder(
  //             builder: (BuildContext context, StateSetter setModalState) {
  //               return SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text(
  //                           amenitiesModel?.data?.data?[0].name ?? "",
  //                           style: TextStyle(
  //                             fontSize: 18.sp,
  //                             fontFamily: AppConstants.manrope,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ).paddingOnly(top: 2.h),
  //                       ],
  //                     ),
  //                     Divider(
  //                       thickness: 0.15.h,
  //                       color: Colors.grey,
  //                     ).paddingOnly(top: 1.h, bottom: 1.h),
  //                     Row(
  //                       children: [
  //                         Spacer(),
  //                         Container(
  //                           height: 5.h,
  //                           width: 37.w,
  //                           decoration: BoxDecoration(
  //                             color: Colors.white,
  //                             borderRadius: BorderRadius.circular(12),
  //                           ),
  //                           child: DropdownButtonHideUnderline(
  //                             child: DropdownButton(
  //                               icon: Padding(
  //                                 padding: EdgeInsets.symmetric(
  //                                   horizontal: 2.w,
  //                                   vertical: 1.h,
  //                                 ),
  //                                 child: Icon(
  //                                   CupertinoIcons.chevron_down,
  //                                   size: 16.sp,
  //                                   color: Colors.black,
  //                                 ),
  //                               ),
  //                               dropdownColor: Colors.white,
  //                               value: selectedValue,
  //                               isDense: true,
  //                               alignment: Alignment.bottomCenter,
  //                               items: [
  //                                 DropdownMenuItem(
  //                                   value: "days",
  //                                   child: Text(
  //                                     "This Week",
  //                                     style: TextStyle(
  //                                       color: Colors.black,
  //                                       fontFamily: AppConstants.manrope,
  //                                       fontSize: 16.sp,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 DropdownMenuItem(
  //                                   value: "month",
  //                                   child: Text(
  //                                     "This Month",
  //                                     style: TextStyle(
  //                                       color: Colors.black,
  //                                       fontFamily: AppConstants.manrope,
  //                                       fontSize: 16.sp,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 DropdownMenuItem(
  //                                   value: "year",
  //                                   child: Text(
  //                                     "This Year",
  //                                     style: TextStyle(
  //                                       color: Colors.black,
  //                                       fontFamily: AppConstants.manrope,
  //                                       fontSize: 16.sp,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                               onChanged: (value) {
  //                                 setModalState(() {
  //                                   selectedValue = value.toString();
  //                                 });
  //                               },
  //                             ),
  //                           ).paddingOnly(left: 2.w),
  //                         ),
  //                       ],
  //                     ).paddingOnly(right: 4.w),
  //                     SizedBox(height: 1.h),
  //                     isLoading
  //                         ? Center(
  //                           child: CircularProgressIndicator(
  //                             color: AppColors.maincolor,
  //                           ),
  //                         )
  //                         : selectedValue == "days"
  //                         ? _buildWeekView(
  //                           id,
  //                         ).paddingOnly(left: 4.w, right: 4.w, bottom: 2.h)
  //                         : selectedValue == "month"
  //                         ? _buildMonthView(
  //                           id,
  //                         ).paddingOnly(left: 4.w, right: 4.w)
  //                         : _buildYearView(
  //                           id,
  //                         ).paddingOnly(left: 4.w, right: 4.w, bottom: 2.h),
  //                     load
  //                         ? CircularProgressIndicator()
  //                         : Column(
  //                           crossAxisAlignment: CrossAxisAlignment.stretch,
  //                           children: [
  //                             Padding(
  //                               padding: EdgeInsets.symmetric(
  //                                 horizontal: 4.w,
  //                                 vertical: 2.h,
  //                               ),
  //                               child: Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   _slotCard(
  //                                     countColor: Colors.black,
  //                                     statusColor: Colors.black,
  //                                     title: "Total Slots",
  //                                     value:
  //                                         amenitiesModel
  //                                             ?.data?.data?[0]
  //                                             .totalBookingSlots
  //                                             .toString() ??
  //                                         "0",
  //                                     background: Colors.black26,
  //                                     color: Colors.white,
  //                                   ),
  //                                   _slotCard(
  //                                     title: "Booked",
  //                                     statusColor: Colors.white,
  //                                     countColor: Colors.white,
  //                                     background: Colors.white,
  //                                     value:
  //                                         amenitiesModel?.data?.data?[0].bookedSlots
  //                                             .toString() ??
  //                                         "0",
  //                                     color: Colors.redAccent,
  //                                   ),
  //                                   _slotCard(
  //                                     title: "Available",
  //                                     value:
  //                                         amenitiesModel
  //                                             ?.data?.data?[0]
  //                                             .availableSlots
  //                                             .toString() ??
  //                                         "0",
  //                                     countColor: Colors.white,
  //                                     statusColor: Colors.white,
  //                                     background: Colors.white,
  //                                     color: Colors.green,
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                             const SizedBox(height: 20),
  //                             Padding(
  //                               padding: EdgeInsets.symmetric(horizontal: 4.w),
  //                               child:
  //                                   isLoading == true
  //                                       ? CircularProgressIndicator()
  //                                       : batan(
  //                                         title: "Confirm Booking",
  //                                         route: () async {
  //                                           int available =
  //                                               int.tryParse(
  //                                                 amenitiesModel
  //                                                         ?.data?.data?[0]
  //                                                         .availableSlots
  //                                                         .toString() ??
  //                                                     "0",
  //                                               ) ??
  //                                               0;
  //                                           if (available > 0) {
  //                                             Navigator.pop(context);
  //                                             setState(() {
  //                                               isGlobalLoading = true;
  //                                             });
  //                                             await Future.delayed(
  //                                               Duration(milliseconds: 300),
  //                                             );
  //                                             bool success =
  //                                                 await AddBookingApi(id);
  //                                             if (mounted) {
  //                                               setState(() {
  //                                                 isGlobalLoading = false;
  //                                               });
  //                                             }
  //                                             if (success) {
  //                                               print(
  //                                                 "Booking added successfully",
  //                                               );
  //                                             }
  //                                           } else {
  //                                             Get.snackbar(
  //                                               "Sorry!",
  //                                               "No available slots for booking",
  //                                               backgroundColor:
  //                                                   AppColors.redColor,
  //                                               colorText: Colors.white,
  //                                               titleText: Text(
  //                                                 "Sorry!",
  //                                                 style: TextStyle(
  //                                                   fontSize: 18.sp,
  //                                                   fontWeight: FontWeight.bold,
  //                                                   color: Colors.white,
  //                                                   fontFamily:
  //                                                       AppConstants.manrope,
  //                                                 ),
  //                                               ),
  //                                               messageText: Text(
  //                                                 "No available slots for booking",
  //                                                 style: TextStyle(
  //                                                   fontSize: 16.sp,
  //                                                   color: Colors.white,
  //                                                   fontFamily:
  //                                                       AppConstants.manrope,
  //                                                 ),
  //                                               ),
  //                                             );
  //                                           }
  //                                         },
  //                                         color: AppColors.maincolor,
  //                                         fontcolor: Colors.white,
  //                                         height: 6.h,
  //                                         width: double.infinity,
  //                                         fontsize: 18.sp,
  //                                         radius: 12.0,
  //                                         fontWeight: FontWeight.normal,
  //                                         iconsize1: 22.sp,
  //                                         iconData1: Icons.check_circle_outline,
  //                                       ),
  //                             ),
  //                             const SizedBox(height: 16),
  //                           ],
  //                         ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   ).whenComplete(() {
  //     _bookingSheetContext = null;
  //     log("Bottom sheet closed & context cleared.");
  //   });
  // }

  Widget _slotCard({
    required String title,
    required String value,
    required Color color,
    required Color background,
    required Color statusColor,
    required Color countColor,
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

  // Widget _buildWeekView(String id) {
  //   return Container(
  //     height: 12.h,
  //     alignment: Alignment.center,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: dates.length,
  //       itemBuilder: (context, index) {
  //         DateTime date = dates[index]['fullDate'];
  //         bool isSelected = isSameDay(selectedCalendarDate, date);
  //         bool isToday = isSameDay(date, DateTime.now());
  //         return GestureDetector(
  //           onTap: () async {
  //             setState(() {
  //               selectedIndex = index;
  //               selectedCalendarDate = date;
  //               selectedDate = DateFormat('dd/MM/yyyy').format(date);
  //             });
  //             await Future.delayed(Duration(milliseconds: 300));
  //             if (mounted) setState(() => load = true);
  //             var success = await AmenitiesApi1(id);
  //             if (mounted) {
  //               setState(() {
  //                 load = false;
  //                 Navigator.pop(context);
  //               });
  //             }
  //             if (success) {
  //               submitBooking(id);
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text("Something went wrong. Please try again."),
  //                 ),
  //               );
  //             }
  //           },
  //           child: Container(
  //             width: 20.w,
  //             margin: const EdgeInsets.only(right: 10),
  //             decoration: BoxDecoration(
  //               color:
  //                   isSelected || isToday ? AppColors.maincolor : Colors.white,
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   dates[index]['day']!,
  //                   style: TextStyle(
  //                     color:
  //                         isSelected || isToday ? Colors.white : Colors.black,
  //                     fontSize: 17,
  //                     fontWeight: FontWeight.bold,
  //                     fontFamily: AppConstants.manrope,
  //                   ),
  //                 ),
  //                 Text(
  //                   dates[index]['weekday']!,
  //                   style: TextStyle(
  //                     color:
  //                         isSelected || isToday ? Colors.white : Colors.black,
  //                     fontSize: 15,
  //                     fontFamily: AppConstants.manrope,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  // Widget _buildMonthView(String id) {
  //   return TableCalendar(
  //     firstDay: DateTime(now.year, now.month, 1),
  //     lastDay: DateTime(now.year, now.month + 1, 0),
  //     focusedDay: selectedCalendarDate ?? now,
  //     calendarFormat: CalendarFormat.month,
  //     headerStyle: HeaderStyle(
  //       formatButtonVisible: false,
  //       leftChevronVisible: false,
  //       rightChevronVisible: false,
  //       titleCentered: true,
  //       titleTextStyle: TextStyle(
  //         color: Colors.black,
  //         fontSize: 18.sp,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //     ),
  //     daysOfWeekStyle: const DaysOfWeekStyle(
  //       weekdayStyle: TextStyle(
  //         color: Colors.black,
  //         fontFamily: AppConstants.manrope,
  //         fontSize: 13.5,
  //         fontWeight: FontWeight.normal,
  //       ),
  //       weekendStyle: TextStyle(
  //         color: Colors.black,
  //         fontFamily: AppConstants.manrope,
  //         fontSize: 13.5,
  //         fontWeight: FontWeight.normal,
  //       ),
  //     ),
  //     calendarStyle: const CalendarStyle(
  //       todayDecoration: BoxDecoration(
  //         color: Colors.grey,
  //         shape: BoxShape.circle,
  //       ),
  //       selectedDecoration: BoxDecoration(
  //         color: AppColors.maincolor,
  //         shape: BoxShape.circle,
  //       ),
  //       selectedTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //       todayTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //       defaultTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //       weekendTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //     ),
  //     selectedDayPredicate: (day) {
  //       return isSameDay(selectedCalendarDate, day);
  //     },
  //     onDaySelected: (newSelectedDay, focusedDay) {
  //       setState(() {
  //         selectedCalendarDate = newSelectedDay;
  //         selectedDate = DateFormat('dd/MM/yyyy').format(newSelectedDay);
  //         load = true;
  //       });
  //     },
  //     calendarBuilders: CalendarBuilders(
  //       defaultBuilder: (context, day, _) {
  //         bool isSelected = isSameDay(selectedCalendarDate, day);
  //         return GestureDetector(
  //           onTap: () async {
  //             setState(() {
  //               selectedCalendarDate = day;
  //               selectedDate = DateFormat('dd/MM/yyyy').format(day);
  //               load = true;
  //             });
  //             var success = await AmenitiesApi1(id);
  //             setState(() {
  //               load = false;
  //               Navigator.pop(context);
  //             });
  //             if (success) {
  //               submitBooking(id);
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text("Something went wrong. Please try again."),
  //                 ),
  //               );
  //             }
  //           },
  //           child: Container(
  //             margin: const EdgeInsets.all(6.0),
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: isSelected ? AppColors.maincolor : Colors.white,
  //               shape: BoxShape.circle,
  //             ),
  //             child: Text(
  //               '${day.day}',
  //               style: TextStyle(
  //                 color: isSelected ? Colors.white : Colors.black,
  //                 fontWeight: FontWeight.bold,
  //                 fontFamily: AppConstants.manrope,
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  // Widget _buildYearView(String id) {
  //   DateTime firstDayOfYear = DateTime(now.year, 1, 1);
  //   DateTime lastDayOfYear = DateTime(now.year, 12, 31);
  //   return TableCalendar(
  //     firstDay: firstDayOfYear,
  //     lastDay: lastDayOfYear,
  //     focusedDay: selectedYear ?? now,
  //     currentDay: now,
  //     calendarFormat: CalendarFormat.month,
  //     headerStyle: HeaderStyle(
  //       formatButtonVisible: false,
  //       titleCentered: true,
  //       titleTextStyle: TextStyle(
  //         color: Colors.black,
  //         fontSize: 18.sp,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //       leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
  //       rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
  //     ),
  //     daysOfWeekStyle: DaysOfWeekStyle(
  //       weekdayStyle: TextStyle(
  //         color: Colors.black,
  //         fontSize: 13.5,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //       weekendStyle: TextStyle(
  //         color: Colors.black,
  //         fontSize: 13.5,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //     ),
  //     calendarStyle: const CalendarStyle(
  //       todayDecoration: BoxDecoration(
  //         color: Colors.grey,
  //         shape: BoxShape.circle,
  //       ),
  //       selectedDecoration: BoxDecoration(
  //         color: Colors.black45,
  //         shape: BoxShape.circle,
  //       ),
  //       selectedTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //       todayTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //       defaultTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //       weekendTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontFamily: AppConstants.manrope,
  //       ),
  //     ),
  //     selectedDayPredicate: (day) {
  //       return isSameDay(selectedYear, day);
  //     },
  //     calendarBuilders: CalendarBuilders(
  //       defaultBuilder: (context, day, focusedDay) {
  //         bool isSelected = isSameDay(selectedCalendarDate, day);
  //         return GestureDetector(
  //           onTap: () async {
  //             setState(() {
  //               selectedCalendarDate = day;
  //               selectedDate = DateFormat('dd/MM/yyyy').format(day);
  //               load = true;
  //             });
  //             var success = await AmenitiesApi1(id);
  //             setState(() {
  //               load = false;
  //               Navigator.pop(context);
  //             });
  //             if (success) {
  //               submitBooking(id);
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text("Something went wrong. Please try again."),
  //                 ),
  //               );
  //             }
  //           },
  //           child: Container(
  //             margin: EdgeInsets.all(6.0),
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: isSelected ? AppColors.maincolor : AppColors.white,
  //               shape: BoxShape.circle,
  //             ),
  //             child: Text(
  //               '${day.day}',
  //               style: TextStyle(
  //                 color: isSelected ? AppColors.white : AppColors.black,
  //                 fontFamily: AppConstants.manrope,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //     onDaySelected: (newSelectedDay, focusedDay) {
  //       setState(() {
  //         selectedYear = newSelectedDay;
  //         selectedDate = DateFormat('yyyy/MM/dd').format(newSelectedDay);
  //         load = true;
  //       });
  //     },
  //     onPageChanged: (focusedDay) {
  //       if (focusedDay.isBefore(firstDayOfYear)) {
  //         setState(() {
  //           selectedYear = firstDayOfYear;
  //         });
  //       }
  //     },
  //   );
  // }
  // AmenitiesApi1(String Id) async {
  //   bool hasInternet = await checkInternet();
  //   if (!hasInternet) {
  //     buildErrorDialog(context, 'Error', "Internet Required");
  //     return false;
  //   }
  //   try {
  //     var response = await AmenitiesProvider().amenitiesApi(
  //       loginModel?.data?.user?.id.toString() ?? '',
  //       Id ?? "",
  //       selectedDate ?? "",
  //     );
  //     if (response.statusCode == 200) {
  //       amenitiesModel = AmenitiesModel.fromJson(response.data);
  //       setState(() {
  //         amenitiesModel = amenitiesModel;
  //         isLoading = false;
  //         load = false;
  //       });
  //       log(" ADD DATA ${loginModel?.data?.user?.id ?? ''}");
  //       submitBooking(Id);
  //       return true;
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //         load = false;
  //       });
  //       return false;
  //     }
  //   } catch (e, stackTrace) {
  //     log("Geeting Error $stackTrace");
  //     setState(() {
  //       isLoading = false;
  //       load = false;
  //     });
  //     return false;
  //   }
  // }

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
                          Icons.calendar_today,
                          size: 20.sp,
                          color: AppColors.maincolor,
                        ),
                        SizedBox(width: 2.w),
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
}
