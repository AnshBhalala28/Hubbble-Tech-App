import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Utils/customSnackBars.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customBatan.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../../Booking/View/eventBookingScreen.dart';
import '../../CommunityDetailsPage/view/communityDetailPage.dart';
import '../Provider/eventProvider.dart';
import '../modal/eventDetailModal.dart';
import '../modal/sendEventModel.dart';

class EventDetail extends StatefulWidget {
  String? eventID;
  String? status;

  EventDetail({super.key, this.eventID, this.status});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  bool isLoading = false;
  bool isBooking = false;
  String AppLat = '';
  String AppLon = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    eventDetailApi();
    _getCurrentLocation().then((value) {
      eventDetailApi();
    });
  }

  // bool isDark = false;
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, null);
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
        body:
            isLoading
                ? Loader()
                : Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 2.h,
                            horizontal: 3.w,
                          ),
                          decoration: BoxDecoration(
                            color:
                                theme.isDark
                                    ? Color(0xff272727)
                                    : AppColors.bgcolor,
                            border: Border(
                              top: BorderSide(
                                color:
                                    theme.isDark
                                        ? Color(0xffbdab82)
                                        : Colors.grey,
                              ),
                              left: BorderSide(
                                color:
                                    theme.isDark
                                        ? Color(0xffbdab82)
                                        : Colors.grey,
                              ),
                              right: BorderSide(
                                color:
                                    theme.isDark
                                        ? Color(0xffbdab82)
                                        : Colors.grey,
                              ),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () => Get.back(),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      height: 28,
                                      width: 28,
                                      decoration: const BoxDecoration(),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.arrow_back,
                                        color:
                                            theme.isDark
                                                ? Color(0xffbdab82)
                                                : AppColors.maincolor,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ).paddingOnly(top: 1.h),
                                  SizedBox(height: 2.h),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      width: double.infinity,
                                      height: 25.h,
                                      imageUrl:
                                          eventDetailModal?.data?.attachment ??
                                          "",
                                      fit: BoxFit.fill,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.maincolor,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Container(
                                            height: 30.h,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color:
                                                    theme.isDark
                                                        ? Color(0xffbdab82)
                                                        : AppColors.borderColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Image(
                                              image: AssetImage(
                                                'assets/images/Applogo_remove_background.png',
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    eventDetailModal?.data?.title ?? "",
                                    style: TextStyle(
                                      color:
                                          theme.isDark
                                              ? Color(0xffbdab82)
                                              : AppColors.maincolor,
                                      fontSize: 19.sp,
                                      fontFamily: AppConstants.manropeBold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    height: 0.6.h,
                                    width: 25.w,
                                    decoration: BoxDecoration(
                                      color:
                                          theme.isDark
                                              ? Color(0xffbdab82)
                                              : AppColors.borderColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ).paddingOnly(right: 5.w, bottom: 2.h),
                                  Container(
                                    width: 92.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ReadMoreText(
                                      eventDetailModal?.data?.bio ?? "",
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
                                  ).paddingOnly(bottom: 2.h),
                                  Text(
                                    "Business Overview",
                                    style: TextStyle(
                                      color:
                                          theme.isDark
                                              ? Color(0xffbdab82)
                                              : AppColors.maincolor,
                                      fontSize: 18.sp,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).paddingOnly(bottom: 1.h),

                                  Container(
                                    height: 0.6.h,
                                    width: 25.w,
                                    decoration: BoxDecoration(
                                      color:
                                          theme.isDark
                                              ? Color(0xffbdab82)
                                              : AppColors.borderColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ).paddingOnly(right: 5.w, bottom: 2.h),

                                  InkWell(
                                    onTap: () {
                                      Get.to(
                                        BusinessDetailPage(
                                          businessID:
                                              eventDetailModal
                                                  ?.data
                                                  ?.business?[0]
                                                  .id
                                                  .toString() ??
                                              "",
                                          lat: AppLat,
                                          long: AppLon,
                                          userID:
                                              loginModel?.data?.user?.id
                                                  .toString() ??
                                              "",
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 7.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              theme.isDark
                                                  ? Color(0xffbdab82)
                                                  : AppColors.black,
                                        ),

                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  eventDetailModal
                                                      ?.data
                                                      ?.business?[0]
                                                      .logo ??
                                                  "",
                                              fit: BoxFit.cover,

                                              width: 50,
                                              // circle width
                                              height: 50,
                                              // circle height
                                              placeholder:
                                                  (
                                                    context,
                                                    url,
                                                  ) => const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              AppColors
                                                                  .maincolor,
                                                        ),
                                                  ),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        width: 1,
                                                        color:
                                                            AppColors
                                                                .borderColor,
                                                      ),
                                                    ),
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/images/Applogo_remove_background.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          ).paddingOnly(left: 3.w, right: 3.w),
                                          Text(
                                            eventDetailModal
                                                    ?.data
                                                    ?.business?[0]
                                                    .businessName ??
                                                "",
                                            style: TextStyle(
                                              color:
                                                  theme.isDark
                                                      ? Color(0xffbdab82)
                                                      : AppColors.blackColor,
                                              fontFamily: AppConstants.manrope,
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).paddingOnly(bottom: 1.h),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color:
                                            theme.isDark
                                                ? Color(0xffbdab82)
                                                : AppColors.black,
                                        width: 0.2.w,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color:
                                              theme.isDark
                                                  ? Color(0xffbdab82)
                                                  : AppColors.maincolor,
                                        ).paddingOnly(right: 2.w),

                                        SizedBox(
                                          width: 79.w,
                                          child: Text(
                                            eventDetailModal?.data?.location ??
                                                "",
                                            style: TextStyle(
                                              fontFamily: AppConstants.manrope,
                                              fontSize: 15.sp,
                                              color:
                                                  theme.isDark
                                                      ? Color(0xffbdab82)
                                                      : AppColors.maincolor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ).paddingOnly(left: 3.w),
                                  ).paddingOnly(bottom: 1.h),

                                  Container(
                                    height: 5.h,
                                    padding: const EdgeInsets.all(5),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color:
                                            theme.isDark
                                                ? Color(0xffbdab82)
                                                : AppColors.blackColor,
                                        width: 0.2.w,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color:
                                              theme.isDark
                                                  ? Color(0xffbdab82)
                                                  : AppColors.maincolor,
                                        ).paddingOnly(right: 2.w),
                                        Text(
                                          "Event Date: ${formatDateTime(eventDetailModal?.data?.eventDate ?? "")}",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            color:
                                                theme.isDark
                                                    ? Color(0xffbdab82)
                                                    : AppColors.maincolor,
                                          ),
                                        ),
                                      ],
                                    ).paddingOnly(left: 3.w),
                                  ).paddingOnly(bottom: 1.h),

                                  Container(
                                    height: 5.h,
                                    padding: const EdgeInsets.all(5),
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color:
                                            theme.isDark
                                                ? Color(0xffbdab82)
                                                : AppColors.maincolor,
                                        width: 0.2.w,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          eventDetailModal?.data?.status ==
                                                  'active'
                                              ? Icons.check_circle
                                              : Icons.block,
                                          color:
                                              eventDetailModal?.data?.status ==
                                                      'active'
                                                  ? theme.isDark
                                                      ? Color(0xffbdab82)
                                                      : AppColors.maincolor
                                                  : AppColors.redColor,
                                        ).paddingOnly(right: 2.w),
                                        Text(
                                          "Status: ${eventDetailModal?.data?.status?.capitalizeFirst ?? ""}",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            color:
                                                theme.isDark
                                                    ? Color(0xffbdab82)
                                                    : AppColors.maincolor,
                                          ),
                                        ),
                                      ],
                                    ).paddingOnly(left: 3.w),
                                  ).paddingOnly(bottom: 2.h),
                                  eventDetailModal?.data?.status == "inactive"
                                      ? Center(
                                        child: batan(
                                          title: 'Inactive',
                                          route: () {},
                                          color:
                                              theme.isDark
                                                  ? Color(0xffbdab82)
                                                  : AppColors.maincolor,
                                          fontcolor: AppColors.white,
                                          height: 5.h,
                                          width: 50.w,
                                          fontsize: 16.sp,
                                          radius: 15.0,
                                        ),
                                      )
                                      : Center(
                                        child: batan(
                                          title:
                                              widget.status == ""
                                                  ? "Request Reservation"
                                                  : widget
                                                      .status
                                                      ?.capitalizeFirst,
                                          route: () {
                                            widget.status == ""
                                                ? sendlistap(widget.eventID)
                                                : null;
                                          },
                                          color: AppColors.maincolor,
                                          fontcolor: AppColors.white,
                                          height: 5.h,
                                          width: 50.w,
                                          fontsize: 16.sp,
                                          radius: 15.0,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isBooking)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.1),
                        ),
                        child: Loader(),
                      ),
                  ],
                ),
      ),
    );
  }

  sendlistap(selectedid) {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    data['event_id'] = selectedid ?? "";

    setState(() {
      isBooking = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        EventProvider()
            .sendeventapi(data)
            .then((response) async {
              sendeventModel = SendeventModel.fromJson(response.data);

              if (response.statusCode == 200 || sendeventModel?.data == 200) {
                setState(() {
                  isBooking = false;
                });
                Get.to(const EventbookingScreen());
                showSnackBar(
                  context: context,
                  title: "Event Request",
                  message: "Event access has been requested",
                  backgoundColor: AppColors.maincolor,
                  ColorText: AppColors.white,
                );
              } else if (response.statusCode == 422) {
                setState(() {
                  isBooking = false;
                });
              } else {
                setState(() {
                  isBooking = false;
                });
              }

              setState(() {
                isBooking = false;
              });
              return false;
            })
            .catchError((error) {
              setState(() {
                isBooking = false;
              });

              return false;
            });
      } else {
        setState(() {
          isBooking = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
        return false;
      }
    });
  }

  eventDetailApi() {
    final Map<String, String> data = {"user_id": widget.eventID ?? ""};

    checkInternet().then((internet) async {
      if (internet) {
        EventProvider().eventDetailApi(data).then((response) async {
          eventDetailModal = EventDetailModal.fromJson(response.data);

          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else if (response.statusCode == 422) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        AppLat = position.latitude.toString();
        AppLon = position.longitude.toString();
      });
    }
  }
}
