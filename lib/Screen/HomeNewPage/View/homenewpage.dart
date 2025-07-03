import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/Screen/Booking/View/book_amenities.dart';
import 'package:wavee/Screen/Booking/View/booking_screen.dart';
import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
import 'package:wavee/Screen/Event/View/event_screen.dart';
import 'package:wavee/Screen/HomeNewPage/Model/parcel_show_count.dart';
import 'package:wavee/Screen/HomeNewPage/Model/visitor_show_count_model.dart';
import 'package:wavee/Screen/HomeNewPage/Provider/homescreen_provider.dart';
import 'package:wavee/Screen/Manintenance/View/maintenance_view.dart';
import 'package:wavee/Screen/Message_board/View/messageboard.dart';
import 'package:wavee/Screen/NotiFicationPage/Provider/notificationprovider.dart';
import 'package:wavee/Screen/Oredrscreen/View/order_screen_view.dart';
import 'package:wavee/Screen/Parcel/parcel_Screen_View/parcel_View.dart';
import 'package:wavee/Screen/ViewProfile/View/Mybuilding_Screen.dart';
import 'package:wavee/Screen/ViewProfile/View/viewprofile.dart';
import 'package:wavee/Screen/Visitor/View/visitorscreen.dart';
import 'package:wavee/comman/bottom_bar.dart';
import 'package:wavee/comman/check_inernet_connecty.dart';
import 'package:wavee/comman/error_dialog.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/input_decoration.dart';
import '../../Add to Cart/model/add_to_cart_model.dart';
import '../../Add to Cart/provider/add_to_cart_provider.dart';
import '../../Booking/View/service_booking_screen.dart';
import '../../Message_board/Model/Add_Post_Model.dart';
import '../../Message_board/Provider/messsage_board_provider.dart';
import '../../NotiFicationPage/Model/Notification_Model.dart';
import '../../NotiFicationPage/View/notification_page.dart';
import '../../ViewProfile/Model/profile_model.dart';
import '../../ViewProfile/Provider/profile_provider.dart';
import '../../Visitor/Model/latest_visitor_modal/latest_visitor_modal.dart';
import '../Model/chat_show_count_modal.dart';
import '../Model/message_board_modal.dart';

class HomePage extends StatefulWidget {
  int? selected;
  final String userName;

  HomePage({super.key, this.selected, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? fullName;
  int sel = 0;
  bool isLoading = false;
  int parcelCount = 0;
  int visitorCount = 0;
  int chatCount = 0;
  int notificationCount = 0;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isSending = false;
  final addPostFormkey = GlobalKey<FormState>();
  TextEditingController _descController = TextEditingController();
  TextEditingController _title = TextEditingController();
  List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _cartButtonPosition = Offset(
          screenSize.width - 70,
          (screenSize.height / 2) - 28,
        );
      });
    });
    getnotificationCount();

    ParcelShowCount();
    VisitorShowCount();
    ChatShowCount();
    LatestVisitorApi();
    MessageBoardApi();
    GetProfile();
    GetCartDetailApi();

    print('Login modal ${loginModel?.data?.user?.name?.firstName ?? ""}');
  }

  Offset _cartButtonPosition = Offset.zero;

  @override
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey_home =
        GlobalKey<ScaffoldState>();
    return Scaffold(
      bottomNavigationBar: Bottom_bar(selected: 1),
      body: isLoading
          ? Loader()
          : Stack(
              children: [
                Positioned(
                  top: 8.h,
                  bottom: 10,
                  right: 0,
                  left: 0.w,
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          height: 222,
                          width: 222,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/homescreen_map1.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Wavee Ai",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 22.sp,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Stack(
                                children: [
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(
                                          ChatScreen(
                                            selected: 3,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 17.h,
                                        width: 28.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.blackColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 7.h,
                                              width: 15.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: AppColors.white,
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  AppConstants.chat,
                                                  height: 4.5.h,
                                                  width: 4.5.h,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              "Chat",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color: AppColors.white,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 5,
                                    top: 0.3.h,
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 7.w,
                                      width: 7.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "$chatCount",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: AppColors.black,
                                          fontFamily: AppConstants.manrope,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                children: [
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(VisitorScreen(
                                          latestVisitor: "lestesh_visitor",
                                        ));
                                      },
                                      child: Container(
                                        height: 17.h,
                                        width: 28.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.blackColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 7.h,
                                              width: 15.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: AppColors.white,
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  AppConstants.visitor,
                                                  height: 4.5.h,
                                                  width: 4.5.h,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              "Visitors",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color: AppColors.white,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 5,
                                    top: 0.3.h,
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 7.w,
                                      width: 7.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "$visitorCount",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: AppColors.black,
                                          fontFamily: AppConstants.manrope,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                children: [
                                  Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(ParcelScreen());
                                      },
                                      child: Container(
                                        height: 17.h,
                                        width: 28.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.blackColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 7.h,
                                              width: 15.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: AppColors.white,
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  AppConstants.parcel,
                                                  height: 4.5.h,
                                                  width: 4.5.h,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              "Parcels",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color: AppColors.white,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 5,
                                    top: 0.3.h,
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 7.w,
                                      width: 7.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "$parcelCount",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: AppColors.black,
                                          fontFamily: AppConstants.manrope,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 11.h,
                  left: 0,
                  right: 0,
                  bottom: 0.h,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.32,
                    minChildSize: 0.30,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(45),
                            topLeft: Radius.circular(45),
                          ),
                          color: Colors.white,
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 45.h,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(45),
                                    topLeft: Radius.circular(45),
                                    bottomLeft: Radius.circular(45),
                                    bottomRight: Radius.circular(45),
                                  ),
                                  color: AppColors.bottomSheetBG,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        height: 1.h,
                                        width: 20.w,
                                        decoration: BoxDecoration(
                                          color: Color(0xf0D9D9D9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ).paddingOnly(top: 2.h, bottom: 2.h),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Message Board",
                                          style: TextStyle(
                                            color: AppColors.black,
                                            fontFamily: AppConstants.manrope,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.sp,
                                          ),
                                        ),
                                        Spacer(),
                                        // Stack(
                                        //   clipBehavior: Clip.none,
                                        //   children: [
                                        //     InkWell(
                                        //       onTap: () {
                                        //         Get.to(NotificationPage());
                                        //       },
                                        //       child: Icon(
                                        //         Icons
                                        //             .notifications_none_outlined,
                                        //         color: AppColors.blackColor,
                                        //         size: 22.sp,
                                        //       ),
                                        //     ),
                                        //     Positioned(
                                        //       right: -5,
                                        //       top: -3,
                                        //       child: Container(
                                        //         padding: EdgeInsets.all(4),
                                        //         decoration: BoxDecoration(
                                        //           color: AppColors.borderColor,
                                        //           shape: BoxShape.circle,
                                        //         ),
                                        //         constraints: BoxConstraints(
                                        //           minWidth: 18,
                                        //           minHeight: 18,
                                        //         ),
                                        //         child: Center(
                                        //           child: Text(
                                        //             notificationCount
                                        //                     .toString() ??
                                        //                 "0",
                                        //             style: TextStyle(
                                        //               color: Colors.black,
                                        //               fontSize: 12.sp,
                                        //               fontFamily:
                                        //                   AppConstants.manrope,
                                        //               fontWeight:
                                        //                   FontWeight.bold,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                      ],
                                    ).paddingOnly(bottom: 1.h),
                                    messageBoardModal?.data != null &&
                                            messageBoardModal!.data!.isNotEmpty
                                        ? Container(
                                            height: 28.h,
                                            decoration: BoxDecoration(
                                                color: AppColors.offWhite,
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Message Board",
                                                        style: TextStyle(
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope),
                                                      ),
                                                      Spacer(),
                                                      InkWell(
                                                        onTap: () {
                                                          addpostsheet(
                                                              context,
                                                              loginModel?.data
                                                                      ?.user?.id
                                                                      .toString() ??
                                                                  "");
                                                        },
                                                        child: Container(
                                                          height: 4.h,
                                                          width: 40.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            border: Border.all(
                                                              color: AppColors
                                                                  .bottomSheetBG,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "Post New Message",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .add_circle_outline_outlined,
                                                                  size: 19.sp,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ).paddingOnly(bottom: 1.h),
                                                  Container(
                                                    height: 20.5.h,
                                                    width: 75.w,
                                                    decoration: BoxDecoration(
                                                      color: AppColors
                                                          .bottomSheetBG,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              CachedNetworkImage(
                                                                  imageUrl: messageBoardModal
                                                                          ?.data?[
                                                                              0]
                                                                          .user
                                                                          ?.conciergeImage ??
                                                                      "",
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
                                                                          Container(
                                                                            width:
                                                                                40,
                                                                            height:
                                                                                40,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              image: DecorationImage(
                                                                                image: imageProvider,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      CircularProgressIndicator(),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Icon(Icons
                                                                          .error)),
                                                              SizedBox(
                                                                width: 2.w,
                                                              ),
                                                              Text(
                                                                "${messageBoardModal?.data?[0].user?.firstName ?? ""} ${messageBoardModal?.data?[0].user?.lastName ?? ""}",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                  fontSize:
                                                                      15.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 2.w,
                                                              ),
                                                              Text(
                                                                "•${formatPostDate(messageBoardModal?.data?[0].createdAt)}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 0.5.h,
                                                          ),
                                                          Text(
                                                            "${messageBoardModal?.data?[0].title ?? "Join us at The Crumpets Cafe!"}",
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${messageBoardModal?.data?[0].text ?? ""}",
                                                            maxLines: 4,
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .AlbertSansLight,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ).paddingOnly(bottom: 1.h)
                                        : Center(
                                            child: Text(
                                              "No messages found.",
                                              style: TextStyle(
                                                fontSize: 17.sp,
                                                color: Colors.grey,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                          ).paddingOnly(
                                            top: 15.h, bottom: 10.h),
                                    InkWell(
                                      onTap: () {
                                        Get.to(() => Messageboard());
                                      },
                                      child: Center(
                                        child: Container(
                                          height: 4.h,
                                          width: 45.w,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: AppColors.borderColor,
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AppConstants.messageBoard,
                                                  width: 20,
                                                  height: 20,
                                                ).paddingOnly(
                                                    left: 9.w, right: 2.w),
                                                Text(
                                                  "View All",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ).paddingOnly(bottom: 1.h),
                                    ),
                                  ],
                                ).paddingOnly(left: 5.w, right: 5.w),
                              ),
                              Text(
                                "My Home",
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                ),
                              ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                              Container(
                                height: 0.6.h,
                                width: 18.w,
                                decoration: BoxDecoration(
                                  color: AppColors.blackColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ).paddingOnly(left: 5.w, right: 5.w),
                              Text(
                                "Explore your building, submit maintenance requests and make bookings.",
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontFamily: AppConstants.AlbertSansLight,
                                  fontWeight: FontWeight.w200,
                                  fontSize: 16.sp,
                                ),
                              ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: homeCard(
                                      iconName: AppConstants.building,
                                      name: "Building",
                                      onTap: () {
                                        Get.to(MyBuilding_Screen());
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: homeCard(
                                      iconName: AppConstants.booking,
                                      name: "My Bookings",
                                      onTap: () {
                                        Get.to(BookingScreen());
                                      },
                                    ),
                                  ),
                                ],
                              ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: homeCard(
                                      iconName: AppConstants.amenities,
                                      name: "Amenities",
                                      onTap: () {
                                        Get.to(BookAmenities_Screen());
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: homeCard(
                                      iconName: AppConstants.maintance,
                                      name: "Maintenance",
                                      onTap: () {
                                        Get.to(MaintenanceScreen());
                                      },
                                    ),
                                  ),
                                ],
                              ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                              Container(
                                height: 0.1.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color(0xf0e3e3e3)),
                              ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                              Text(
                                "Business Overview",
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                ),
                              ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                              Container(
                                height: 0.6.h,
                                width: 18.w,
                                decoration: BoxDecoration(
                                  color: AppColors.blackColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ).paddingOnly(left: 5.w, right: 5.w),
                              Row(
                                children: [
                                  Expanded(
                                    child: homeCard(
                                      iconName: AppConstants.myOrder,
                                      name: "My Orders",
                                      onTap: () {
                                        Get.to(Order_Screen());
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: homeCard(
                                      iconName: AppConstants.maintance,
                                      name: "My Service Bookings",
                                      onTap: () {
                                        Get.to(ServiceBookingScreen());
                                      },
                                    ),
                                  ),
                                ],
                              ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: homeCard(
                                      iconName: AppConstants.shopping,
                                      name: "Shopping",
                                      onTap: () {
                                        Get.to(CommunityScreen());
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: homeCard(
                                      iconName: AppConstants.events,
                                      name: "Events",
                                      onTap: () {
                                        Get.to(EventScreen());
                                      },
                                    ),
                                  ),
                                ],
                              ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                              Container(
                                height: 0.1.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color(0xf0e3e3e3)),
                              ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                              Text(
                                "Information",
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                ),
                              ).paddingOnly(left: 5.w, right: 5.w, top: 1.h),
                              Container(
                                height: 0.6.h,
                                width: 18.w,
                                decoration: BoxDecoration(
                                  color: AppColors.blackColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ).paddingOnly(left: 5.w, right: 5.w),
                              Row(
                                children: [
                                  Expanded(
                                    child: HomeProfileCard(
                                      iconName: AppConstants.profile,
                                      name: "Profile",
                                      onTap: () {
                                        Get.to(ViewProfile(
                                          id: loginModel?.data?.user?.id ?? 0,
                                        ));
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: HomeProfileCard(
                                      iconName: AppConstants.settings,
                                      name: "Settings",
                                      onTap: () {
                                        Get.to(ViewProfile(
                                          id: loginModel?.data?.user?.id ?? 0,
                                        ));
                                      },
                                    ),
                                  ),
                                ],
                              ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: HomeProfileCard(
                                      iconName: AppConstants.Privacy,
                                      name: "Privacy Policy",
                                      onTap: () {
                                        launchPrivacyPolicyUrl();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Expanded(
                                    child: HomeProfileCard(
                                      iconName: AppConstants.terms,
                                      name: "Terms & Conditions",
                                      onTap: () {
                                        launchTermsUrl();
                                      },
                                    ),
                                  ),
                                ],
                              ).paddingOnly(left: 5.w, right: 5.w, top: 2.h),
                              SizedBox(height: 3.h,),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isSending)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Loader(),
                    ),
                  ),
              ],
            ),
    );
  }

  void launchTermsUrl() async {
    final Uri url = Uri.parse("https://www.wavee.ai/terms-of-service");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void launchPrivacyPolicyUrl() async {
    final Uri url = Uri.parse("https://www.wavee.ai/privacy-policy");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  String formatPostDate(String? createdAt) {
    if (createdAt == null) return "";

    final postDate = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(postDate).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "1 day ago";
    } else {
      return "$difference days ago";
    }
  }

  Widget homeCard({
    required String iconName,
    required String name,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 12.h,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFfafafa),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconName,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 25.w,
                    child: Text(
                      name,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 20.sp,
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget HomeProfileCard({
    required String iconName,
    required String name,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 9.5.h,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFfafafa),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconName,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dispose() {
    super.dispose();
  }

  int cartCount = cartDetailsModel?.data?.length ?? 0;

  Future<void> GetCartDetailApi() async {
    checkInternet().then((internet) async {
      if (internet) {
        CartProvider()
            .GetCartDetailsApi(
          loginModel?.data?.user?.id.toString() ?? "",
        )
            .then((response) async {
          cartDetailsModel =
              CartDetailsModel.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200) {
            print("Response: ${response.body}");

            setState(() {
              isLoading = false;
              cartCount = cartDetailsModel?.data?.length ?? 0;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            log("Error");
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

  Widget _buildIconTile(String title, IconData icon, VoidCallback onTap,
      {int notificationCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 8.h,
                width: 15.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.maincolor,
                  size: 27.sp,
                ),
              ),
              Positioned(
                top: -5,
                right: -10,
                child: Container(
                  alignment: Alignment.center,
                  height: 3.h,
                  width: 4.h,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notificationCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBox(
      {required String title, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 6.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope),
            ),
            Container(
              height: 4.h,
              width: 8.w,
              decoration: BoxDecoration(
                color: Colors.purple.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.black,
                size: 17.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotification(IconData icon, VoidCallback onTap,
      {int notificationCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 1.5.h,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.black,
                      size: 23.sp,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: -8,
                  child: Container(
                    alignment: Alignment.center,
                    height: 2.5.h,
                    width: 3.h,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  Widget _buildVisitorCard() {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: AppColors.white,
            ),
          )
        : latestVisitorModal?.data == null || latestVisitorModal!.data!.isEmpty
            ? SizedBox(
                child: Center(
                  child: Text(
                    "No Visitors Available",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      fontFamily: AppConstants.manrope,
                    ),
                  ).paddingOnly(bottom: 6.h, top: 5.h),
                ),
              )
            : SizedBox(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: (latestVisitorModal?.data?.length ?? 0) > 2
                      ? 2
                      : latestVisitorModal?.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    var visitor = latestVisitorModal?.data?[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visitor?.visitorName?.capitalizeFirst ?? "",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.phone, color: AppColors.maincolor),
                              SizedBox(width: 2.w),
                              Text(
                                visitor?.visitorPhone ?? "",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: AppConstants.manrope,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.timer,
                                      color: AppColors.maincolor, size: 15.sp)
                                  .paddingOnly(right: 1.w),
                              Text(
                                "${visitor?.checkInDate ?? ""} ${visitor?.checkInTime ?? ""}",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
  }

  Widget _buildMessageCard() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.white,
        ),
      );
    }

    if (messageBoardModal?.data == null || messageBoardModal!.data!.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 4.h),
        child: Center(
          child: Text(
            "No Messages Available",
            style: TextStyle(
              fontSize: 17.sp,
              fontFamily: AppConstants.manrope,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 18.5.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (messageBoardModal?.data?.length ?? 0) > 2
            ? 2
            : messageBoardModal?.data?.length ?? 0,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          var message = messageBoardModal?.data?[index];
          int totalMessages = messageBoardModal?.data?.length ?? 0;
          return Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.all(12),
            width: (totalMessages == 1) ? 92.w : 85.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (message?.file?.isNotEmpty == true)
                      ? (message!.file![0].toLowerCase().endsWith('.pdf')
                          ? GestureDetector(
                              onTap: () async {
                                final url = message!.file![0];
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url),
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Could not open PDF')),
                                  );
                                }
                              },
                              child: Container(
                                width: 20.w,
                                height: 20.h,
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.picture_as_pdf,
                                          color: Colors.red, size: 24.sp),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: message!.file![0],
                              fit: BoxFit.cover,
                              width: 20.w,
                              height: 20.h,
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.maincolor,
                                ),
                              ),
                              errorWidget: (context, url, error) => SizedBox(
                                width: 20.w,
                                height: 20.h,
                              ),
                            ))
                      : SizedBox(
                          width: 0.w,
                          height: 0.h,
                        ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message?.user != null
                            ? "${message!.user!.firstName ?? 'No Name'} ${message!.user!.lastName ?? ''}"
                            : "Unknown User",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppConstants.manrope,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "${message?.text ?? ''}",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: AppConstants.manrope,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          formatDateTime(message?.createdAt ?? ''),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.black,
                            fontFamily: AppConstants.manrope,
                          ),
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
    );
  }

  void ParcelShowCount() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["type"] = "count";

    log("Delete account : $data");
    log("login Id is ${loginModel?.data?.user?.id}");

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().ParcerShowCount(data);
          parcelShowCountModel =
              ParcelShowCountModel.fromJson(jsonDecode(response.body));

          if (response.statusCode == 200 &&
              parcelShowCountModel?.status == 200) {
            log("${response.body}");

            setState(() {
              parcelCount = parcelShowCountModel?.data ?? 0;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
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

  void VisitorShowCount() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["count"] = "visitor";

    log("Visitor Data jay ce  $data");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().VisitorShowCount(data);
          visitorShowCountModel =
              VisitorShowCountModel.fromJson(jsonDecode(response.body));

          if (response.statusCode == 200 &&
              visitorShowCountModel?.status == 200) {
            log("Responce Data ${response.body}");

            setState(() {
              visitorCount = visitorShowCountModel?.data ?? 0;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void ChatShowCount() {
    final Map<String, String> data = {};
    data["sender_id"] = "1";
    data["receiver_id"] = loginModel?.data?.user?.id.toString() ?? "";

    log("chat count data  $data");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().ChatShowCount(data);
          chatShowCountModal =
              ChatShowCountModal.fromJson(jsonDecode(response.body));

          if (response.statusCode == 200 && chatShowCountModal?.status == 200) {
            log("Responce Data ${response.body}");

            setState(() {
              chatCount = chatShowCountModal?.data ?? 0;
              isLoading = false;
            });
            log("Count${chatCount}");
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
          }
        } catch (e) {
          if (mounted)
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

  void LatestVisitorApi() async {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    data["lestesh_visitor"] = "lestesh_visitor";

    log("Latest Visitor data send $data");

    bool internet = await checkInternet();
    if (!internet) {
      setState(() {
        isLoading = false;
      });
      log("❌ No Internet Connection");
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      var response = await HomeProvider().LatestVisitor(data);

      if (response.statusCode == 200) {
        latestVisitorModal =
            LatestVisitorModal.fromJson(jsonDecode(response.body));
        log("✅ Latest visitor data received: ${response.body}");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        log("❌ Failed response error ave che: ${response.statusCode}");
        log("❌ Response body: ${response.body}");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        if (response.statusCode == 422) {
          buildErrorDialog(
              context, 'Error', "Invalid Data Sent. Please Check Inputs.");
        }
      }
    } catch (e, stackTrace) {
      log("❌ Exception occurred: $e");
      log("❌ StackTrace: $stackTrace");

      setState(() {
        isLoading = false;
      });

      if (e.toString().contains("Failed to connect")) {
        log("❌ Server connection issue detected.");
      }
    }
  }

  MessageBoardApi() {
    final Map<String, String> data = {};
    data["user_id"] = loginModel?.data?.user?.id.toString() ?? "";
    log("Data sending${loginModel?.data?.user?.id.toString() ?? ""}");
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await HomeProvider().MessageBoardApi(data);
          messageBoardModal =
              MessageBoardModal.fromJson(jsonDecode(response.body));

          if (response.statusCode == 200 && messageBoardModal?.status == 200) {
            log("message board api data ave cje${response.body}");

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print(response.body);
            log("Error ");
          }
        } catch (e) {
          log("Error $e");

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

  void GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? ''
    };
    print("RegisterApi : ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().ProfileApi(data).then((response) async {
          profileModel = ProfileModel.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200 && profileModel?.status == 200) {
            print("adfdsfsdf${response.body}");
            print(
                "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}");
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            setState(() {
              isLoading = false;
            });
            log("Error");
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

  getnotificationCount() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await NotificationProvider()
              .NotificationApi((loginModel?.data?.user?.id).toString());
          print("login user id : ${(loginModel?.data?.user?.id).toString()}");

          if (response.statusCode == 200) {
            notificationmodel =
                NotificationModell.fromJson(json.decode(response.body));
            print("Notification get: ${response.body}");
            setState(() {
              notificationCount = notificationmodel?.data?.totalCount ?? 0;
              isLoading = false;
            });
            print("notificationCount : ${notificationCount}");
          } else {
            log("Failed response error ave che: ${response.statusCode}");
            log("Response body: ${response.body}");
          }
        } catch (e) {
          log("Exception occurred: $e");
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Widget commonLoader() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.maincolor),
      ),
    );
  }

  Future<void> _pickImages(Function setModalState) async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedImages = await _picker.pickMultiImage();

    if (pickedImages != null && pickedImages.isNotEmpty) {
      setModalState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  void addpostsheet(
    BuildContext parentContext,
    String userid,
  ) {
    bool _imagesValid = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future.delayed(Duration.zero, () {
              if (isSending) {
                setModalState(() => isSending = false);
              }
            });

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: addPostFormkey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Add Post",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        cursorColor: AppColors.black,
                        controller: _title,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Title";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Title',
                          searchIcon: Icon(
                            Icons.contact_mail,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        cursorColor: AppColors.black,
                        controller: _descController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your Description";
                          }
                          return null;
                        },
                        decoration: inputDecoration(
                          hintText: 'Enter Description',
                          searchIcon: Icon(
                            Icons.contact_mail,
                            size: 20.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      batan(
                        title: "Choose Image",
                        route: () {
                          _pickImages(setModalState);
                        },
                        color: AppColors.maincolor,
                        fontcolor: Colors.white,
                        height: 5.h,
                        width: 50.w,
                        radius: 12.0,
                        iconData: Icons.image,
                        fontsize: 17.sp,
                      ),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      if (_images.isNotEmpty)
                        const Text(
                          "Selected Images",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      SizedBox(height: 8),
                      if (_images.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_images[index].path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          _images.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 24),
                      Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: AppColors.maincolor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (addPostFormkey.currentState!.validate()) {
                              Addpostapi();
                              Navigator.pop(context);
                            }
                          },
                          borderRadius: BorderRadius.circular(5),
                          child: Center(
                            child: Text(
                              "Add Post",
                              style: TextStyle(
                                  fontSize: 17.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: AppConstants.manrope),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void Addpostapi() {
    if (addPostFormkey.currentState!.validate()) {
      final Map<String, String> data = {
        'user_post_id': (loginModel?.data?.user?.id).toString(),
        'description': _descController.text.trim(),
        'title': _title.text.trim(),
      };

      print("Post data: $data");

      setState(() {
        isSending = true;
      });

      checkInternet().then((internet) async {
        if (internet) {
          MessageBoardProvider()
              .addpostapWithImages(
            bodyData: data,
            images: _images,
          )
              .then((response) async {
            if (response.statusCode == 200) {
              var responseData = json.decode(response.body);
              add_Post_Model = Add_Post_Model.fromJson(responseData);
              print("Post upload successful");

              _descController.clear();
              _images = [];
            } else if (response.statusCode == 429) {
              print("Too many requests");
            } else {
              print("Internal Server Error");
            }
            if (mounted) {
              setState(() {
                isSending = false;
              });
            }
          });
        } else {
          setState(() {
            isSending = false;
          });
          buildErrorDialog(context, 'Error', "Internet Required");
        }
      });
    }
  }
}
