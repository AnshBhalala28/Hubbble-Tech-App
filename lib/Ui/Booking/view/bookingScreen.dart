import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../../HomeScreen/View/homePage.dart';
import '../Provider/bookingsProvider.dart';
import '../modal/amenitiesBookStatusModel.dart';
import '../modal/rejectBookingModal.dart';
import 'amenitiesDetailsScreen.dart';
import 'bookAmenities.dart';

class BookingScreen extends StatefulWidget {
  final String? id;

  const BookingScreen({super.key, this.id});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyBooking =
      GlobalKey<ScaffoldState>();
  List<String> categories = ['All', 'Approved', 'Requested', 'Rejected'];
  bool isLoading = false;
  int selectedCategory = 0;
  String? selectedAmenity;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Map<String, dynamic>? newBooking;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    BookAmetiesStatusApi(selectedType.toLowerCase());
  }

  Color getStatusColor1(String status) {
    return status == "Pending"
        ? Colors.yellow.shade800
        : status == "Confirmed"
        ? Colors.green
        : status == "Cancelled"
        ? Colors.red
        : status == "Rejected"
        ? Colors.orange
        : Colors.black;
  }

  Color getStatusColor(String status, String? rsvp, String? attended) {
    if (attended == "1") return AppColors.maincolor;
    if (attended == "0") return Colors.redAccent;

    if (status == "Confirmed") {
      switch (rsvp?.toLowerCase()) {
        case "accept":
          return Colors.green;
        case "maybe":
          return Colors.orange;
        case "decline":
          return Colors.redAccent;
      }
    }

    return status == "Pending"
        ? Colors.yellow.shade800
        : status == "Confirmed"
        ? Colors.green
        : status == "Cancelled"
        ? Colors.red
        : status == "Rejected"
        ? Colors.orange
        : Colors.black;
  }

  String getStatusText(String status, String? rsvp, String? attended) {
    if (attended == "1") return "Attended";
    if (attended == "0") return "Not Attended";

    if (status == "Confirmed") {
      switch (rsvp?.toLowerCase()) {
        case "accept":
          return "RSVP: Accepted";
        case "maybe":
          return "RSVP: Maybe";
        case "decline":
          return "RSVP: Declined";
        default:
          return status;
      }
    }
    return status;
  }

  String selectedType = "all";

  @override
  Widget build(BuildContext context) {
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
      // drawer: SideMenu(),
      // key: _scaffoldKeyBooking,
      backgroundColor: AppColors.white,

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            TitleBar(
              back: () {
                Get.off(HomePage(userName: '', selected: 1));
              },
              title: 'My Bookings',
              drawerCallback: () {},
            ),
            SizedBox(height: 3.h),

            Row(
              children: [
                Row(
                  children: [
                    Text(
                      "Filter Status By",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppConstants.manropeBold,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 17.sp,
                      color: Colors.black,
                    ),
                  ],
                ),
                const Spacer(),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 4.5.h,
                    width: 32.w,
                    decoration: BoxDecoration(
                      color: AppColors.maincolor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          selectedType = value;
                          isLoading = true;
                        });

                        BookAmetiesStatusApi(selectedType.toLowerCase());
                      },
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      offset: const Offset(0, 45),
                      itemBuilder:
                          (BuildContext context) => [
                            PopupMenuItem(
                              value: "all",
                              child: Text(
                                "All",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,

                                  fontFamily: AppConstants.manropeBold,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: "confirmed",
                              child: Text(
                                "Confirmed",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,

                                  fontFamily: AppConstants.manropeBold,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: "pending",
                              child: Text(
                                "Pending",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,

                                  fontFamily: AppConstants.manropeBold,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: "cancelled",
                              child: Text(
                                "Cancelled",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppConstants.manropeBold,
                                ),
                              ),
                            ),
                          ],
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selectedType.toString().capitalizeFirst ?? "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manropeBold,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              CupertinoIcons.chevron_down,
                              color: Colors.white,
                              size: 15.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    isLoading
                        ? Loader().paddingOnly(top: 20.h)
                        : nonEmptyBookings.isEmpty || nonEmptyBookings.isEmpty
                        ? Center(
                          child: Text(
                            "No Bookings Found",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              fontFamily: AppConstants.manropeBold,
                            ),
                          ).paddingOnly(top: 30.h),
                        )
                        : SizedBox(
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: nonEmptyBookings.length,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemBuilder: (context, index) {
                                  final entry = nonEmptyBookings[index];
                                  final monthName = entry['month'].toString();
                                  final booking = entry['booking'];

                                  final dateTime = DateFormat(
                                    "yyyy-MM-dd hh:mm a",
                                  ).parse(booking['requested_at'] ?? "", true);

                                  final day =
                                      DateFormat(
                                        'EEE',
                                      ).format(dateTime).toUpperCase();
                                  final dayNum = DateFormat(
                                    'd',
                                  ).format(dateTime);
                                  final monthFormatted = DateFormat(
                                    'MMMM',
                                  ).format(dateTime);
                                  final time = DateFormat(
                                    'hh:mm a',
                                  ).format(dateTime);

                                  final isFirstOfMonth =
                                      index == 0 ||
                                      nonEmptyBookings[index - 1]['month'] !=
                                          monthName;

                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => Form_Screen(
                                          amenites_id:
                                              booking['amenity']['id']
                                                  .toString(),
                                          status: booking['status'],
                                          bookingDate: booking['requested_at'],
                                          attend:
                                              booking['attended']?.toString() ??
                                              "",
                                          rsvp: booking['rsvp'],
                                          EventName: booking['amenity']['name'],
                                          bookingId:
                                              booking['booking_id'].toString(),
                                          requestedDate:
                                              booking['requested_at'] ?? "N/A",
                                          startTime:
                                              booking['start_time'] ?? "N/A",
                                          endtime: booking['end_time'] ?? "N/A",
                                          isPage: true,
                                        ),
                                      );
                                    },

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isFirstOfMonth)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 16.0,
                                              bottom: 8,
                                            ),
                                            child: Text(
                                              monthFormatted,
                                              style: const TextStyle(
                                                fontFamily:
                                                    AppConstants.manropeBold,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    day,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                      fontFamily:
                                                          AppConstants
                                                              .manropeBold,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    dayNum,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppConstants
                                                              .manropeBold,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          formatTime12(
                                                            booking['start_time'],
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manropeBold,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: getStatusColor(
                                                              booking['status'] ??
                                                                  "",
                                                              booking['rsvp'],
                                                              booking['attended'],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            getStatusText(
                                                              booking['status']
                                                                  .toString(),
                                                              booking['rsvp'],
                                                              booking['attended'],
                                                            ),
                                                            style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manropeBold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      booking['amenity']['name'] ??
                                                          "Meeting Room",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                        fontFamily:
                                                            AppConstants
                                                                .manropeBold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      booking['amenity']['description'] ??
                                                          "",
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Divider(
                                                      thickness: 0.5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          isLoading
              ? Container()
              : Row(
                children: [
                  const Spacer(),
                  FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(900),
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Get.to(() => const BookAmenities_Screen());
                    },
                    icon: const Icon(
                      Icons.home_repair_service,
                      color: Colors.black,
                    ),
                    label: Text(
                      "Amenities",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  // FloatingActionButton.extended(
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(900)),
                  //   backgroundColor: Colors.white,
                  //   onPressed: () {
                  //     Get.to(() => const ChatBotScreen());
                  //   },
                  //   icon: Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
                  //   label: Text(
                  //     "Ai Concierge",
                  //     style: TextStyle(
                  //         color: Colors.black,
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 16.sp,
                  //         fontFamily: AppConstants.manrope),
                  //   ),
                  // ),
                ],
              ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusFromTab(int index) {
    switch (index) {
      case 1:
        return "confirmed";
      case 2:
        return "pending";
      case 3:
        return "cancelled";
      default:
        return "";
    }
  }

  Future<void> AddBookingApi(String id) async {
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "amenity_id": id,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().addBookingApi(data);

          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
            });
            Get.off(() => const BookingScreen(), arguments: {'tabIndex': 0});
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
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

  void rejectBooking(String bookingId, String userId) {
    final Map<String, String> data = {
      "booking_id": bookingId,
      "user_id": userId,
    };

    checkInternet().then((internet) async {
      if (internet) {
        setState(() => isLoading = true);

        try {
          var response = await AmenitiesProvider().rejectBookingApi(data);

          if (response.statusCode == 200) {
            rejectBookingModel = RejectBookingModel.fromJson(response.data);

            if (rejectBookingModel?.status == 1) {
              buildErrorDialog(
                context,
                'Success',
                rejectBookingModel?.message ?? 'Rejected Successfully',
              );

              setState(() {
                selectedCategory = 3;
              });
            } else {
              buildErrorDialog(
                context,
                'Failed',
                rejectBookingModel?.message ?? 'Something went wrong',
              );
            }
          } else {
            buildErrorDialog(
              context,
              'Error',
              'Server Error: ${response.statusCode}',
            );
          }
        } catch (e) {
          buildErrorDialog(context, 'Exception', e.toString());
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        buildErrorDialog(context, 'No Internet', 'Internet Required');
      }
    });
  }

  Future<void> BookAmetiesStatusApi(String status) async {
    String mappedStatus = status == "all" ? "" : status;

    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "status": mappedStatus,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().allAmenitiesApi(data);
          if (response.statusCode == 200) {
            bookAmenitiesStatusModel = BookAmenitiesStatusModel.fromJson(
              response.data,
            );

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e,stacktrace) {
          log("stacktracestacktracestacktrace$stacktrace");
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
}
