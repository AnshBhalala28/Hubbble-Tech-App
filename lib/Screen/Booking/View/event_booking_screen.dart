import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Booking/Model/event_detail_model.dart';
import 'package:wavee/Screen/Event/View/event_detail.dart';
import 'package:wavee/comman/Custom_AppBar.dart';
import 'package:wavee/comman/custom_batan.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../Model/event_booking_modal.dart';
import '../Provider/booking_provider.dart';

class EventbookingScreen extends StatefulWidget {
  const EventbookingScreen({super.key});

  @override
  State<EventbookingScreen> createState() => _EventbookingScreenState();
}

class _EventbookingScreenState extends State<EventbookingScreen> {
  final GlobalKey<ScaffoldState> _eventBookingScren =
      GlobalKey<ScaffoldState>();
  List<String> categories = ['All', 'Approved', 'Pending', 'Rejected'];
  int selectedCategory = 0;

  bool isLoading = false;
  bool isDetailLoading = false;
  bool isRsvpLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    BookEventStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 4.h),
                TitleBar(
                  title: "Event Booking",
                  drawerCallback: () {},
                  back: () {
                    Get.back();
                  },
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  height: 6.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // physics: CarouselScrollPhysics(),
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            if (selectedCategory != index) {
                              setState(() {
                                selectedCategory = index;
                                isLoading = true;
                              });
                              BookEventStatus();
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
                              color: selectedCategory == index
                                  ? AppColors.maincolor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 1.2.w),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: selectedCategory == index
                                    ? Colors.white
                                    : Colors.black,
                                fontFamily: selectedCategory == index
                                    ? AppConstants.manropeBold
                                    : AppConstants.manrope,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                isLoading
                    ? Center(child: Loader()).paddingOnly(top: 25.h)
                    : eventBookingModal?.data?.length == null ||
                        eventBookingModal?.data?.length == 0
                    ? Center(
                      child: Text(
                        "No Bookings Available",
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
                            itemCount: eventBookingModal?.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              var booking = eventBookingModal?.data?[index];
                              return GestureDetector(
                                onTap: () {
                                  EventDetailApi(
                                    booking?.eventId.toString() ?? "",
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
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 1.w,
                                    vertical: 1.h,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 2.h),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  formatDate(
                                                    booking?.eventDate ?? "",
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: getStatusColor(
                                                      booking?.status ?? '',
                                                      booking?.rsvp,
                                                      booking?.isAttended,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    getDisplayStatus(
                                                      booking?.status ?? '',
                                                      booking?.rsvp,
                                                      booking?.isAttended,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              booking?.eventName ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 1.5.h),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: Colors.black45,
                                                ),
                                                const SizedBox(width: 4),
                                                SizedBox(
                                                  width: 70.w,
                                                  child: Text(
                                                    booking?.eventLocation ??
                                                        "",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ],
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
            ).paddingSymmetric(horizontal: 3.w, vertical: 2.h),
          ),
          if (isDetailLoading)
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

  Color getStatusColor(String status, String? rsvp, int? isAttended) {
    if (isAttended == 1) return Colors.green;
    if (isAttended == 0) return Colors.redAccent;

    if (status.toLowerCase() == "approved") {
      switch (rsvp?.toLowerCase()) {
        case "accept":
          return AppColors.maincolor;
        case "decline":
          return Colors.red.shade400;
        case "maybe":
          return Colors.orange.shade400;
      }
    }

    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "completed":
        return Colors.green;
      default:
        return AppColors.maincolor;
    }
  }

  String getDisplayStatus(String status, String? rsvp, int? isAttended) {
    if (isAttended == 1) {
      return "Attended";
    } else if (isAttended == 0) {
      return "Not Attended";
    }

    if (status.toLowerCase() == "approved") {
      switch (rsvp?.toLowerCase()) {
        case "accept":
          return "RSVP Accepted";
        case "decline":
          return "RSVP Declined";
        case "maybe":
          return "RSVP: Maybe";
      }
    }

    switch (status.toLowerCase()) {
      case "pending":
        return "Pending";
      case "confirmed":
        return "Confirmed";
      case "rejected":
        return "Rejected";
      case "completed":
        return "Completed";
      default:
        return status.toString().capitalizeFirst ?? "";
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

  String getStatusFromTab(int index) {
    switch (index) {
      case 1:
        return "approved";
      case 2:
        return "pending";
      case 3:
        return "rejected";
      default:
        return "";
    }
  }

  Future<void> BookEventStatus() async {
    String status = getStatusFromTab(selectedCategory);

    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "status": status,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().eventBookingStatusApi(data);
          if (response.statusCode == 200) {
            eventBookingModal = EventBookingModal.fromJson(response.data);

            setState(() {
              isLoading = false;
            });
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

  Future<void> EventDetailApi(String eventId) async {
    setState(() {
      isDetailLoading = true;
    });

    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "event_id": eventId,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().eventBookingStatusApi(data);
          if (response.statusCode == 200) {
            eventDetailModel = EventDetailModel.fromJson(response.data);

            setState(() {
              isDetailLoading = false;
            });
            showEventDetailBottomSheet(context, eventDetailModel!);
          } else {
            setState(() {
              isDetailLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isDetailLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isDetailLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void showEventDetailBottomSheet(
    BuildContext context,
    EventDetailModel? booking,
  ) {
    final event =
        booking?.data?.isNotEmpty == true ? booking!.data!.first : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 20.w,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              _detailRow("Event Name", event?.eventName ?? "-"),
              _detailRow("Location", event?.eventLocation ?? "-"),
              _detailRow(
                "Date",
                event?.eventDate != null
                    ? DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(DateTime.parse(event!.eventDate!))
                    : "-",
              ),
              _detailRow(
                "Status",
                _getDisplayStatus(event),
                color: getStatusColor(
                  event?.status ?? "",
                  event?.rsvp,
                  event?.isAttended,
                ),
              ).paddingOnly(bottom: 1.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      EventDetail(
                        eventID: event?.eventId.toString() ?? "",
                        status: event?.status ?? "",
                      ),
                    );
                  },
                  child: Text(
                    "View Details",
                    style: TextStyle(
                      fontFamily: AppConstants.manrope,
                      decoration: TextDecoration.underline,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (hideAttendBatan(event))
                batan(
                  title: _getActionButtonTitle(event),
                  route: () {
                    if (event?.status?.toLowerCase() == "approved") {
                      final rsvp = event?.rsvp?.toLowerCase();
                      if (rsvp == "accept" || rsvp == "maybe") {
                        _showAttendConfirmationDialog(
                          context,
                          event?.eventName ?? "",
                          event?.eventId.toString() ?? "",
                          event?.rsvp.toString(),
                        );
                      } else {
                        showRSVPDialog(
                          context,
                          event?.eventName ?? "this event",
                          event?.eventId.toString() ?? "",
                        );
                      }
                    } else {
                      Get.back();
                    }
                  },
                  color: AppColors.maincolor,
                  fontcolor: AppColors.white,
                  height: 5.h,
                  width: double.infinity,
                  fontsize: 18.sp,
                  radius: 12.0,
                ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  bool hideAttendBatan(Data? event) {
    if (event == null) return false;
    if (event.isAttended == 1) {
      return false;
    }
    final rsvp = event.rsvp?.toLowerCase();
    final isRSVPed = rsvp == "accept" || rsvp == "maybe";
    if (isRSVPed) {
      if (event.eventDate != null) {
        final eventDateTime = DateTime.tryParse(event.eventDate!);
        if (eventDateTime != null) {
          final now = DateTime.now();
          final todayDate = DateTime(now.year, now.month, now.day);
          final eventDate = DateTime(
            eventDateTime.year,
            eventDateTime.month,
            eventDateTime.day,
          );

          final showAttend =
              todayDate.isAtSameMomentAs(eventDate) ||
              todayDate.isAfter(eventDate);

          return showAttend;
        }
      }
      return false;
    }
    return true;
  }

  String _getDisplayStatus(Data? event) {
    if (event == null) return "-";
    if (event.rsvp != null && event.rsvp!.isNotEmpty) {
      return "RSVP: ${event.rsvp!.capitalizeFirst}";
    }
    return event.status?.capitalizeFirst ?? "-";
  }

  String _getActionButtonTitle(Data? event) {
    if (event?.status?.toLowerCase() != "approved") {
      return "Close";
    }

    final rsvp = event?.rsvp?.toLowerCase();
    if (rsvp == "accept" || rsvp == "maybe") {
      return "Attend";
    }

    return "RSVP";
  }

  void _showAttendConfirmationDialog(
    BuildContext context,
    String eventName,
    String eventid,
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
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Do you want to mark yourself as attended for\n$eventName?",
                  style: TextStyle(
                    fontSize: 15.sp,
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
                          Navigator.pop(context);
                          RSVPAttendApi(eventid, 'no', rsvp);
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
                          Navigator.pop(context);
                          Navigator.pop(context);
                          RSVPAttendApi(eventid, 'yes', rsvp);
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
              style: const TextStyle(
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

  void showRSVPDialog(BuildContext context, String eventName, String eventID) {
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
                 Text(
                  "You're Invited!",
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
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
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          RsvpToEventApi(eventID, 'maybe');
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
                          children: [
                            Icon(Icons.help_outline),
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
                          Navigator.pop(context);
                          Navigator.pop(context);
                          RsvpToEventApi(eventID, 'decline');
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
                          children: [
                            Icon(Icons.cancel_outlined),
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
                          Navigator.pop(context);
                          Navigator.pop(context);
                          RsvpToEventApi(eventID, 'accept');
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

  Future<void> RsvpToEventApi(String eventID, String rsvp) async {
    setState(() {
      isRsvpLoading = true;
    });
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "event_id": eventID,
      "rsvp": rsvp,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().rsvpToEventApi(data);
          if (response.statusCode == 200) {
            setState(() {
              isRsvpLoading = false;
            });
            BookEventStatus();
          } else {
            setState(() {
              isRsvpLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            isRsvpLoading = false;
          });
        }
      } else {
        setState(() {
          isRsvpLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> RSVPAttendApi(String eventID, String status, String rsvp) async {
    setState(() {
      isRsvpLoading = true;
    });
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "event_id": eventID,
      "attended": status,
      "rsvp": rsvp,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().rsvpToEventApi(data);
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isRsvpLoading = false;
              });
            }
            BookEventStatus();
          } else {
            setState(() {
              isRsvpLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            isRsvpLoading = false;
          });
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
