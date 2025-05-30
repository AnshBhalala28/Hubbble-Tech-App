import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Booking/Model/amenities_book_status_model.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../open_ai_chatbot/view/open_ai_screen.dart';
import '../Model/booking_model.dart';
import '../Model/rejectbooking.dart';
import '../Provider/booking_provider.dart';
import 'book_amenities.dart';
import 'detailScreen.dart';
import 'form_screen.dart';

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
  List<Data1> allamenities = [];
  List<Data1> Requestedamenities = [];
  List<Data1> Rejectedamenities = [];
  List<Data1>? approvedAmenities = [];
  List<Data1>? requestedAmenities = [];
  Map<String, dynamic>? newBooking;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    BookAmetiesStatusApi();
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
        : Colors.black; // default color if none match
  }

  Color getStatusColor(String status, String? rsvp, String? attended) {
    if (attended == "1") return Colors.green;
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
        : Colors.black; // default
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      key: _scaffoldKeyBooking,
      backgroundColor: AppColors.bgcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: Column(
            children: [
              SizedBox(height: 4.h),
              TitleBar(
                back: () {
                  Get.back();
                },
                title: 'Booking',
                drawerCallback: () {
                  _scaffoldKeyBooking.currentState?.openDrawer();
                },
              ),
              SizedBox(height: 3.h),
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
                            isLoading = true;
                          });
                          BookAmetiesStatusApi(); // 👈 API call on tab change
                        }
                      },
                      child: Container(
                        height: 6.h,
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 5.w,
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
                        margin: EdgeInsets.symmetric(horizontal: 1.2.w),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            fontSize: 16.sp,
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
                  ? Loader().paddingOnly(top: 20.h)
                  : bookAmenitiesStatusModel?.data?.length == null ||
                      bookAmenitiesStatusModel?.data?.length == 0
                  ? Center(
                    child: Text(
                      "No Booking Available",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                    ).paddingOnly(top: 30.h),
                  )
                  : SizedBox(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount:
                              bookAmenitiesStatusModel?.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            var booking =
                                bookAmenitiesStatusModel?.data?[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => Form_Screen(
                                    amenites_id:
                                        booking?.amenity?.id.toString() ?? '',
                                    status: booking?.status ?? "",
                                    bookingDate: booking?.requestedAt ?? '',
                                    attend: booking?.attended.toString() ?? "",
                                    rsvp: booking?.rsvp,
                                    EventName: booking?.amenity?.name ?? "",
                                    bookingId:
                                        booking?.bookingId.toString() ?? "",
                                    requestedDate:
                                        booking?.requestedAt ?? "N/A",
                                    isPage: true,
                                  ),
                                );
                                log(
                                  "Booking Date Ave chee # ${booking?.requestedAt}",
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 1.w,
                                  vertical: 1.h,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            booking?.amenity?.imageUrl?.first
                                                ?.toString() ??
                                            '',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        placeholder:
                                            (context, url) => Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) =>
                                                Icon(Icons.error),
                                      ),
                                    ),
                                    SizedBox(width: 2.h),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                /// Date
                                                Text(
                                                  formatDate(
                                                    booking?.requestedAt ?? "",
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                SizedBox(height: 4),

                                                /// Amenity Name
                                                Text(
                                                  booking?.amenity?.name ?? '',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 4),

                                                /// Duration
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.timer,
                                                      size: 16,
                                                      color: Colors.black45,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      _formatDuration(
                                                        booking
                                                            ?.amenity
                                                            ?.durationOptions,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Right Side (Status + More Icon if pending)
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: getStatusColor(
                                                      booking?.status
                                                              .toString() ??
                                                          "",
                                                      booking?.rsvp,
                                                      booking?.attended,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    getStatusText(
                                                      booking?.status
                                                              .toString() ??
                                                          "",
                                                      booking?.rsvp,
                                                      booking?.attended,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ),
                                                if ((booking?.status
                                                            ?.toLowerCase() ==
                                                        'pending') &&
                                                    selectedCategory == 2) ...[
                                                  SizedBox(width: 10),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (
                                                          BuildContext context,
                                                        ) {
                                                          return Dialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                            elevation: 8,
                                                            backgroundColor:
                                                                Colors.white,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    20,
                                                                  ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Cancel Booking',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color:
                                                                          Colors
                                                                              .black87,
                                                                      fontFamily:
                                                                          AppConstants
                                                                              .manrope,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 12,
                                                                  ),
                                                                  Text(
                                                                    'Are you sure you want to cancel this booking?',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color:
                                                                          Colors
                                                                              .black54,
                                                                      fontFamily:
                                                                          AppConstants
                                                                              .manrope,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  batan(
                                                                    title:
                                                                        "Yes",
                                                                    route: () async {
                                                                      Navigator.pop(
                                                                        context,
                                                                      );
                                                                      rejectBooking(
                                                                        booking?.bookingId.toString() ??
                                                                            '',
                                                                        booking?.userId.toString() ??
                                                                            '',
                                                                      );
                                                                    },
                                                                    radius:
                                                                        4.0.w,
                                                                    color:
                                                                        AppColors
                                                                            .maincolor,
                                                                    fontcolor:
                                                                        AppColors
                                                                            .white,
                                                                    height: 6.h,
                                                                    width:
                                                                        Get.width *
                                                                        .65,
                                                                    fontsize:
                                                                        19.sp,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.more_vert,
                                                      color: Colors.black,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
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
                      Get.to(() => BookAmenities_Screen());
                    },
                    icon: Icon(Icons.home_repair_service, color: Colors.black),
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

  String getStatusFromTab(int index) {
    switch (index) {
      case 1:
        return "confirmed";
      case 2:
        return "pending";
      case 3:
        return "cancelled";
      default:
        return ""; // For "All"
    }
  }

  Future<void> AddBookingApi(String id) async {
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "amenity_id": id,
    };
    log("add data jay che${data}");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().AddBooking(data);

          if (response.statusCode == 200) {
            log("API Response: ${response.body}");
            setState(() {
              isLoading = false;
            });
            Get.off(() => BookingScreen(), arguments: {'tabIndex': 0});
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

  void rejectBooking(String bookingId, String userId) {
    final Map<String, String> data = {
      "booking_id": bookingId,
      "user_id": userId,
    };

    log("Reject Booking Data: $data");

    checkInternet().then((internet) async {
      if (internet) {
        setState(() => isLoading = true);

        try {
          var response = await AmenitiesProvider().rejectBookingApi(data);
          log("Reject Booking API Response: ${response.body}");

          if (response.statusCode == 200) {
            rejectBookingModel = RejectBookingModel.fromJson(
              jsonDecode(response.body),
            );

            if (rejectBookingModel?.status == 1) {
              buildErrorDialog(
                context,
                'Success',
                rejectBookingModel?.message ?? 'Rejected Successfully',
              );

              setState(() {
                selectedCategory = 3;
              });

              // await AmenitiesApi();
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
        } catch (e, stackTrace) {
          log("Exception while rejecting booking: $stackTrace");
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

  Future<void> BookAmetiesStatusApi() async {
    String status = getStatusFromTab(selectedCategory); // 👈 Added line

    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "status": status, // 👈 Use mapped status
    };

    log("Data jay che che $data");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().BookAmenitiesStatus(data);
          if (response.statusCode == 200) {
            log("API Response: ${response.body}");
            bookAmenitiesStatusModel = BookAmenitiesStatusModel.fromJson(
              jsonDecode(response.body),
            );

            setState(() {
              isLoading = false;
            });
            log("sucess response data avve che ${response.body}");
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

  List<Data>? filteredAmenities() {
    if (amenitiesModel?.data == null) return [];

    switch (selectedCategory) {
      case 0: // All
        return amenitiesModel!.data!;
      case 1: // Approved
        return amenitiesModel!.data!
            .where((item) => item.status?.toLowerCase() == 'active')
            .toList();
      case 2: // Requested
        return amenitiesModel!.data!
            .where((item) => item.status?.toLowerCase() == 'inactive')
            .toList();
      case 3: // Rejected
        return amenitiesModel!.data!
            .where((item) => item.status?.toLowerCase() == 'rejected')
            .toList();
      default:
        return [];
    }
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
