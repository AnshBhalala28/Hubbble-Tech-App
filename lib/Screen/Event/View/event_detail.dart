import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/HomeNewPage/View/homenewpage.dart';
import 'package:wavee/comman/custom_batan.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../Model/eventDetailModal.dart';
import '../Model/send_event_model.dart';
import '../Provider/event_provider.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });

    print("cssad${widget.status}");
    eventDetailApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                          color: AppColors.bgcolor,
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey),
                            right: BorderSide(color: Colors.grey),
                          ),
                          borderRadius: BorderRadius.only(
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
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    width: double.infinity,
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
                                              color: AppColors.borderColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Image(
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
                                    color: AppColors.maincolor,
                                    fontSize: 20.sp,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                                Container(
                                  height: 0.6.h,
                                  width: 25.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.borderColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ).paddingOnly(right: 5.w, bottom: 2.h),
                                Container(
                                  width: 92.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ReadMoreText(
                                    "${eventDetailModal?.data?.bio ?? ""}",
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
                                  "Event Location",
                                  style: TextStyle(
                                    color: AppColors.maincolor,
                                    fontSize: 18.sp,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ).paddingOnly(bottom: 1.h),

                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: AppColors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppColors.maincolor,
                                      ).paddingOnly(right: 2.w),

                                      SizedBox(
                                        width: 79.w,
                                        child: Text(
                                          "${eventDetailModal?.data?.location ?? ""}",
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(left: 3.w),
                                ).paddingOnly(bottom: 1.h),

                                Container(
                                  height: 5.h,
                                  padding: EdgeInsets.all(5),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: AppColors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                      ).paddingOnly(right: 2.w),
                                      Text(
                                        "Event Date: ${formatDateTime(eventDetailModal?.data?.eventDate ?? "")}",
                                        style: TextStyle(
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(left: 3.w),
                                ).paddingOnly(bottom: 1.h),

                                Container(
                                  height: 5.h,
                                  padding: EdgeInsets.all(5),
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: AppColors.white,
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
                                                ? AppColors.maincolor
                                                : AppColors.redColor,
                                      ).paddingOnly(right: 2.w),
                                      Text(
                                        "Status: ${eventDetailModal?.data?.status?.capitalizeFirst ?? ""}",
                                        style: TextStyle(
                                          fontFamily: AppConstants.manrope,
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
                                        color: AppColors.maincolor,
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
                                            widget.status == "rejected"
                                                ? "Reject"
                                                : widget.status == ""
                                                ? "Request Reservation"
                                                : "Pending",
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
                        color: AppColors.black.withOpacity(0.1),
                      ),
                      child: Loader(),
                    ),
                ],
              ),
    );
  }

  sendlistap(selectedid) {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    data['event_id'] = selectedid ?? "";
    print("send event data jai che$data");

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
                Get.to(HomePage(userName: ""));
                Get.snackbar(
                  "Event Request",
                  "Event access has been requested",
                  backgroundColor: AppColors.maincolor,
                  colorText: AppColors.white,
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

    print("login data jai che$data");
    checkInternet().then((internet) async {
      if (internet) {
        EventProvider().eventDetailApi(data).then((response) async {
          eventDetailModal = EventDetailModal.fromJson(response.data);

          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
            });
          } else if (response.statusCode == 422) {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
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
}
