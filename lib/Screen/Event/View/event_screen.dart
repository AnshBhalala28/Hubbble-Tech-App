import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../HomeNewPage/View/homenewpage.dart';
import '../../open_ai_chatbot/view/open_ai_screen.dart';
import '../Model/event_model.dart';
import '../Model/send_event_model.dart';
import '../Provider/event_provider.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  TextEditingController requestController = TextEditingController();
  String selectedValue = 'month';
  int selectedIndex = 0;
  String? selectedDate;
  List<String> sentEventIds = [];
  bool load = false;
  List<Map<String, dynamic>> dates = [];
  DateTime selectedDay = DateTime.now();
  DateTime? selectedYear;
  DateTime now = DateTime.now();
  List<DateTime> projectDates = [];
  bool isLoading = false;
  String? selectedStatus;
  bool isRequestValid = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isRequested = false; // Track if the request has been sent
  final GlobalKey<ScaffoldState> _scaffoldKeyEvent = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _generateDatesBasedOnSelection();
    super.initState();
    requestController.addListener(() {
      setState(() {
        isRequestValid = requestController.text.trim().isNotEmpty;
      });
    });
    setState(() {
      DateTime today = DateTime.now();
      selectedDate = DateFormat('yyyy-MM-dd').format(today);
      isLoading = true;
    });
    projectlistap1();
  }

  @override
  void dispose() {
    requestController.dispose();
    super.dispose();
  }

  Color getStatusColors(String? status) {
    if (status?.toLowerCase() == 'active') {
      return Colors.green;
    } else if (status?.toLowerCase() == 'inactive') {
      return Colors.red;
    }
    return Colors.grey;
  }

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat("dd-MM-yyyy").format(parsedDate); // Format: 2025-03-1
    } catch (e) {
      return "N/A"; // Error handle
    }
  }

  void _generateDatesBasedOnSelection() {
    DateTime today = DateTime.now();
    dates.clear();

    if (selectedValue == "month") {
      // **This Week Dates**
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

    setState(() {}); // UI Update
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      key: _scaffoldKeyEvent,
      backgroundColor: AppColors.bgcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: Column(
            children: [
              SizedBox(height: 4.h),
              TitleBar(
                back: () {
                  Get.to(HomeNewPage(
                    selected: 1,
                    userName: '',
                  ));
                },
                title: 'Events',
                drawerCallback: () {
                  _scaffoldKeyEvent.currentState?.openDrawer();
                },
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Spacer(),
                  Container(
                    height: 5.h,
                    width: 37.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        icon: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          child: Icon(
                            CupertinoIcons.chevron_down,
                            size: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        value: selectedValue,
                        isDense: true,
                        alignment: Alignment.bottomCenter,
                        items: [
                          DropdownMenuItem(
                            value: "days",
                            child: Text(
                              "This Week",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 16.sp),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "month",
                            child: Text(
                              "This Month",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 16.sp),
                            ),
                          ),
                          DropdownMenuItem(
                            value: "year",
                            child: Text(
                              "This Year",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 16.sp),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            // isLoading = true; // Show loader
                            selectedValue = value.toString();
                          });

                          Future.delayed(Duration(milliseconds: 500), () {
                            setState(() {
                              // isLoading =
                              // false; // Hide loader after delay
                            });
                          });
                        },
                      ),
                    ).paddingOnly(left: 2.w),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // isLoading
              //     ? Center(
              //         child:
              //             CircularProgressIndicator(color: AppColors.maincolor))
              //     :
              // selectedValue == "days"
              //         ? _buildWeekView()
              //         : selectedValue == "month"
              //             ? _buildMonthView()
              //             : _buildYearView(),
              //
              //
              // load
              //     ? SizedBox(
              //   height: 65.h,
              //   child: Center(
              //     child: CircularProgressIndicator(color: AppColors.maincolor),
              //   ),
              // )
              //     :
              // event_list_Model?.data?.length == 0 ||
              //             event_list_Model?.data?.length == null
              //         ? Container(
              //             height: selectedValue == "days" ? 65.h : 20.h,
              //             alignment: Alignment.center,
              //             child: Text(
              //               "No Events Available",
              //               style: TextStyle(
              //                 color: Colors.black,
              //                 fontFamily: AppConstants.manrope,
              //                 fontWeight: FontWeight.bold,
              //                 fontSize: 17.sp,
              //               ),
              //             ),
              //           )
              //         : Container(
              //             alignment: Alignment.center,
              //             child: ListView.builder(
              //               padding: EdgeInsets.zero,
              //               shrinkWrap: true,
              //               scrollDirection: Axis.vertical,
              //               physics: NeverScrollableScrollPhysics(),
              //               itemCount: event_list_Model?.data?.length ?? 0,
              //               itemBuilder: (context, index) {
              //                 String eventId = event_list_Model
              //                         ?.data?[index]?.id
              //                         ?.toString() ??
              //                     "";
              //                 bool isRequestSent =
              //                     sentEventIds.contains(eventId);
              //                 bool isLoading = false; // Local state for loader
              //                 return StatefulBuilder(
              //                   builder: (context, setState) {
              //                     return GestureDetector(
              //                       onTap: () {},
              //                       child: Container(
              //                         margin:
              //                             EdgeInsets.symmetric(vertical: 10),
              //                         padding: EdgeInsets.all(16),
              //                         decoration: BoxDecoration(
              //                           color: Colors.white,
              //                           borderRadius: BorderRadius.circular(20),
              //                         ),
              //                         child: Column(
              //                           crossAxisAlignment:
              //                               CrossAxisAlignment.start,
              //                           children: [
              //                             Row(
              //                               children: [
              //                                 Text(
              //                                   formatDate(event_list_Model
              //                                       ?.data?[index].eventDate),
              //                                   style: TextStyle(
              //                                     color: Colors.black,
              //                                     fontFamily:
              //                                         AppConstants.manrope,
              //                                     fontWeight: FontWeight.bold,
              //                                     fontSize: 15.sp,
              //                                   ),
              //                                 ),
              //                                 Spacer(),
              //                                 if (isLoading)
              //                                   CircularProgressIndicator()
              //                                 else if (event_list_Model
              //                                         ?.data?[index]
              //                                         ?.requestEvent
              //                                         ?.toLowerCase() ==
              //                                     "pending")
              //                                   Text(
              //                                     "Requested",
              //                                     style: TextStyle(
              //                                       fontWeight: FontWeight.bold,
              //                                       color: Colors.orange,
              //                                     ),
              //                                   ),
              //                                 if (!isRequestSent &&
              //                                     (event_list_Model
              //                                                 ?.data?[index]
              //                                                 ?.requestEvent ==
              //                                             null ||
              //                                         event_list_Model!
              //                                             .data![index]
              //                                             .requestEvent!
              //                                             .isEmpty))
              //                                   InkWell(
              //                                     onTap: () {
              //                                       requestController.clear();
              //                                       showDialog(
              //                                         context: context,
              //                                         builder: (BuildContext
              //                                             context) {
              //                                           return StatefulBuilder(
              //                                             builder: (context,
              //                                                 setDialogState) {
              //                                               return Dialog(
              //                                                 backgroundColor:
              //                                                     Colors.white,
              //                                                 shape:
              //                                                     RoundedRectangleBorder(
              //                                                   borderRadius:
              //                                                       BorderRadius
              //                                                           .circular(
              //                                                               16),
              //                                                 ),
              //                                                 child: Container(
              //                                                   padding:
              //                                                       EdgeInsets
              //                                                           .all(
              //                                                               20),
              //                                                   decoration:
              //                                                       BoxDecoration(
              //                                                     color: Colors
              //                                                         .white,
              //                                                     borderRadius:
              //                                                         BorderRadius
              //                                                             .circular(
              //                                                                 16),
              //                                                   ),
              //                                                   child: Form(
              //                                                     key: _formKey,
              //                                                     autovalidateMode:
              //                                                         AutovalidateMode
              //                                                             .onUserInteraction,
              //                                                     child: Column(
              //                                                       mainAxisSize:
              //                                                           MainAxisSize
              //                                                               .min,
              //                                                       children: [
              //                                                         // Name
              //                                                         Text(
              //                                                           "${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} ${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}",
              //                                                           style:
              //                                                               TextStyle(
              //                                                             color:
              //                                                                 Colors.black,
              //                                                             fontSize:
              //                                                                 20.sp,
              //                                                             fontFamily:
              //                                                                 AppConstants.manrope,
              //                                                             fontWeight:
              //                                                                 FontWeight.bold,
              //                                                           ),
              //                                                         ),
              //                                                         SizedBox(
              //                                                             height:
              //                                                                 8),
              //                                                         //Title
              //                                                         Text(
              //                                                           event_list_Model?.data?[index]?.title ??
              //                                                               "N/A",
              //                                                           style:
              //                                                               TextStyle(
              //                                                             fontFamily:
              //                                                                 AppConstants.manrope,
              //                                                             fontSize:
              //                                                                 16,
              //                                                             fontWeight:
              //                                                                 FontWeight.bold,
              //                                                             color:
              //                                                                 Colors.black38,
              //                                                           ),
              //                                                         ),
              //                                                         SizedBox(
              //                                                             height:
              //                                                                 10),
              //                                                         //time
              //                                                         // Text(
              //                                                         //   event_list_Model?.data?[index]?.eventDate ?? "N/A",
              //                                                         //   style: TextStyle(
              //                                                         //     fontFamily: AppConstants.manrope,
              //                                                         //     fontSize: 16,
              //                                                         //     fontWeight: FontWeight.bold,
              //                                                         //     color: Colors.black38,
              //                                                         //   ),
              //                                                         // ),
              //                                                         Text(
              //                                                           event_list_Model?.data?[index]?.eventDate !=
              //                                                                   null
              //                                                               ? DateFormat.jm().format(DateTime.parse(event_list_Model!.data![index]!.eventDate!))
              //                                                               : "N/A",
              //                                                           style:
              //                                                               TextStyle(
              //                                                             fontFamily:
              //                                                                 AppConstants.manrope,
              //                                                             fontSize:
              //                                                                 16,
              //                                                             fontWeight:
              //                                                                 FontWeight.bold,
              //                                                             color:
              //                                                                 Colors.black38,
              //                                                           ),
              //                                                         ),
              //                                                         SizedBox(
              //                                                             height:
              //                                                                 12),
              //
              //                                                         TextFormField(
              //                                                           controller:
              //                                                               requestController,
              //                                                           maxLines:
              //                                                               3,
              //                                                           decoration:
              //                                                               InputDecoration(
              //                                                             hintText:
              //                                                                 "Enter your request...",
              //                                                             border:
              //                                                                 OutlineInputBorder(
              //                                                               borderRadius:
              //                                                                   BorderRadius.circular(10),
              //                                                               borderSide:
              //                                                                   BorderSide(color: Colors.black26),
              //                                                             ),
              //                                                             enabledBorder:
              //                                                                 OutlineInputBorder(
              //                                                               borderRadius:
              //                                                                   BorderRadius.circular(10),
              //                                                               borderSide:
              //                                                                   BorderSide(color: Colors.black26),
              //                                                             ),
              //                                                             focusedBorder:
              //                                                                 OutlineInputBorder(
              //                                                               borderRadius:
              //                                                                   BorderRadius.circular(10),
              //                                                               borderSide:
              //                                                                   BorderSide(color: Colors.blue),
              //                                                             ),
              //                                                             errorBorder:
              //                                                                 OutlineInputBorder(
              //                                                               borderRadius:
              //                                                                   BorderRadius.circular(10),
              //                                                               borderSide:
              //                                                                   BorderSide(color: Colors.red),
              //                                                             ),
              //                                                             focusedErrorBorder:
              //                                                                 OutlineInputBorder(
              //                                                               borderRadius:
              //                                                                   BorderRadius.circular(10),
              //                                                               borderSide:
              //                                                                   BorderSide(color: Colors.red),
              //                                                             ),
              //                                                             fillColor:
              //                                                                 Colors.white,
              //                                                             filled:
              //                                                                 true,
              //                                                           ),
              //                                                           style: TextStyle(
              //                                                               color:
              //                                                                   Colors.black),
              //                                                           validator:
              //                                                               (value) {
              //                                                             if (value == null ||
              //                                                                 value.trim().isEmpty) {
              //                                                               return "Please enter your request";
              //                                                             }
              //                                                             return null;
              //                                                           },
              //                                                         ),
              //                                                         SizedBox(
              //                                                             height:
              //                                                                 20),
              //
              //                                                         Row(
              //                                                           mainAxisAlignment:
              //                                                               MainAxisAlignment.center,
              //                                                           children: [
              //                                                             batan(
              //                                                               title:
              //                                                                   "Yes",
              //                                                               route:
              //                                                                   () async {
              //                                                                 if (_formKey.currentState!.validate()) {
              //                                                                   setDialogState(() {
              //                                                                     isLoading = true;
              //                                                                   });
              //                                                                   setState(() {
              //                                                                     event_list_Model!.data![index].requestEvent = "pending";
              //                                                                   });
              //                                                                   await sendlistap(eventId);
              //                                                                   setDialogState(() {
              //                                                                     isLoading = false; // Stop loader
              //                                                                   });
              //                                                                   Get.back();
              //                                                                 }
              //                                                               },
              //                                                               radius:
              //                                                                   4.0.w,
              //                                                               color:
              //                                                                   AppColors.maincolor,
              //                                                               fontcolor:
              //                                                                   AppColors.white,
              //                                                               height:
              //                                                                   6.h,
              //                                                               width:
              //                                                                   Get.width * .65,
              //                                                               fontsize:
              //                                                                   19.sp,
              //                                                             ),
              //                                                           ],
              //                                                         ),
              //                                                       ],
              //                                                     ),
              //                                                   ),
              //                                                 ),
              //                                               );
              //                                             },
              //                                           );
              //                                         },
              //                                       );
              //                                     },
              //                                     child: isLoading
              //                                         ? CircularProgressIndicator(
              //                                             color: Colors.blue)
              //                                         : Icon(Icons.more_vert,
              //                                             color: Colors.black),
              //                                   ),
              //                               ],
              //                             ),
              //                             SizedBox(height: 1.h),
              //                             Text(
              //                               event_list_Model
              //                                       ?.data?[index]?.title ??
              //                                   "N/A",
              //                               style: TextStyle(
              //                                 color: Colors.black,
              //                                 fontSize: 16.5.sp,
              //                                 fontWeight: FontWeight.bold,
              //                                 fontFamily: AppConstants.manrope,
              //                               ),
              //                             ),
              //                             SizedBox(height: 1.h),
              //                             Row(
              //                               children: [
              //
              //                                 Icon(Icons.location_on,
              //                                     color: Colors.black,
              //                                     size: 18.sp),
              //                                 SizedBox(width: 5),
              //                                 Expanded(
              //                                   child: Text(
              //                                     event_list_Model?.data?[index]
              //                                             ?.location ??
              //                                         "N/A",
              //                                     style: TextStyle(
              //                                       color: Colors.black,
              //                                       fontSize: 15.sp,
              //                                       fontFamily:
              //                                           AppConstants.manrope,
              //                                     ),
              //                                     overflow:
              //                                         TextOverflow.ellipsis,
              //                                   ),
              //                                 ),
              //                               ],
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //                     );
              //                   },
              //                 );
              //               },
              //             ),
              //           ),

              isLoading
                  ? SizedBox(
                      height: 65.h,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.maincolor),
                      ),
                    )
                  : Column(
                      children: [
                        selectedValue == "days"
                           ? _buildWeekView()
                        //_buildWeekView()
                            : selectedValue == "month"
                                ? _buildMonthView()
                                : _buildYearView(),
                        const SizedBox(height: 20),
                        event_list_Model?.data?.length == 0 ||
                                event_list_Model?.data?.length == null
                            ? Container(
                                height: selectedValue == "month" ? 65.h : 20.h,
                                alignment: Alignment.center,
                                child: Text(
                                  "No Events Available",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.sp,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: event_list_Model?.data?.length ?? 0,
                                itemBuilder: (context, index) {
                                  String eventId = event_list_Model
                                          ?.data?[index]?.id
                                          ?.toString() ??
                                      "";
                                  bool isRequestSent =
                                      sentEventIds.contains(eventId);
                                  bool isLoading =
                                      false; // Local state for loader
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    formatDate(event_list_Model
                                                        ?.data?[index]
                                                        .eventDate),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15.sp,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  if (isLoading)
                                                    CircularProgressIndicator()
                                                  else if (event_list_Model
                                                          ?.data?[index]
                                                          ?.requestEvent
                                                          ?.toLowerCase() ==
                                                      "pending")
                                                    Text(
                                                      "Requested",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                  if (!isRequestSent &&
                                                      (event_list_Model
                                                                  ?.data?[index]
                                                                  ?.requestEvent ==
                                                              null ||
                                                          event_list_Model!
                                                              .data![index]
                                                              .requestEvent!
                                                              .isEmpty))
                                                    InkWell(
                                                      onTap: () {
                                                        requestController
                                                            .clear();
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return StatefulBuilder(
                                                              builder: (context,
                                                                  setDialogState) {
                                                                return Dialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            16),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
                                                                    ),
                                                                    child: Form(
                                                                      key:
                                                                          _formKey,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          // Name
                                                                          Row(
                                                                            children: [

                                                                              SizedBox(width: 21.w,),
                                                                              Text(
                                                                              //  profileModel?.data?.name?.toString().capitalizeFirst ?? "",
                                                                                "${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} ${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}",
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                  fontSize: 20.sp,
                                                                                  fontFamily: AppConstants.manrope,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 8.w,),
                                                                              CloseButton(),
                                                                            ],
                                                                          ),
                                                                          // Text(
                                                                          //   "${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} ${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}",
                                                                          //   style:
                                                                          //       TextStyle(
                                                                          //     color: Colors.black,
                                                                          //     fontSize: 20.sp,
                                                                          //     fontFamily: AppConstants.manrope,
                                                                          //     fontWeight: FontWeight.bold,
                                                                          //   ),
                                                                          // ),
                                                                          // SizedBox(
                                                                          //     height: 8),
                                                                          //Title
                                                                          Text(
                                                                            event_list_Model?.data?[index]?.title ??
                                                                                "N/A",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: AppConstants.manrope,
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black38,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 10),
                                                                          //time
                                                                          // Text(
                                                                          //   event_list_Model?.data?[index]?.eventDate ?? "N/A",
                                                                          //   style: TextStyle(
                                                                          //     fontFamily: AppConstants.manrope,
                                                                          //     fontSize: 16,
                                                                          //     fontWeight: FontWeight.bold,
                                                                          //     color: Colors.black38,
                                                                          //   ),
                                                                          // ),
                                                                          Text(
                                                                            event_list_Model?.data?[index]?.eventDate != null
                                                                                ? DateFormat.jm().format(DateTime.parse(event_list_Model!.data![index]!.eventDate!))
                                                                                : "N/A",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: AppConstants.manrope,
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black38,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 12),

                                                                          TextFormField(
                                                                            controller:
                                                                                requestController,
                                                                            maxLines:
                                                                                3,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              hintText: "Enter your request...",
                                                                              border: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(color: Colors.black26),
                                                                              ),
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(color: Colors.black26),
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(color: Colors.blue),
                                                                              ),
                                                                              errorBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(color: Colors.red),
                                                                              ),
                                                                              focusedErrorBorder: OutlineInputBorder(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                borderSide: BorderSide(color: Colors.red),
                                                                              ),
                                                                              fillColor: Colors.white,
                                                                              filled: true,
                                                                            ),
                                                                            style:
                                                                                TextStyle(color: Colors.black),
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.trim().isEmpty) {
                                                                                return "Please enter your request";
                                                                              }
                                                                              return null;
                                                                            },
                                                                          ),
                                                                          SizedBox(
                                                                              height: 20),

                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              batan(
                                                                                title: "Send Request",
                                                                                route: () async {
                                                                                  if (_formKey.currentState!.validate()) {
                                                                                    setDialogState(() {
                                                                                      isLoading = true;
                                                                                    });
                                                                                    setState(() {
                                                                                      event_list_Model!.data![index].requestEvent = "pending";
                                                                                    });
                                                                                    await sendlistap(eventId);
                                                                                    setDialogState(() {
                                                                                      isLoading = false; // Stop loader
                                                                                    });
                                                                                    Get.back();
                                                                                  }
                                                                                },
                                                                                radius: 4.0.w,
                                                                                color: AppColors.maincolor,
                                                                                fontcolor: AppColors.white,
                                                                                height: 6.h,
                                                                                width:72.w,
                                                                                fontsize: 19.sp,
                                                                              ),
                                                                            ],
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
                                                      },
                                                      child: isLoading
                                                          ? CircularProgressIndicator(
                                                              color:
                                                                  Colors.blue)
                                                          : Icon(
                                                              Icons.more_vert,
                                                              color:
                                                                  Colors.black),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(
                                                event_list_Model
                                                        ?.data?[index]?.title ??
                                                    "N/A",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.5.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on,
                                                      color: Colors.black,
                                                      size: 18.sp),
                                                  SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      event_list_Model
                                                              ?.data?[index]
                                                              ?.location ??
                                                          "N/A",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.sp,
                                                        fontFamily: AppConstants
                                                            .manrope,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                },
                              ),
                      ],
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: isLoading
          ? Container()
          : FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(900)),
              backgroundColor: Colors.white,
              onPressed: () {
                Get.to(() => const ChatBotScreen());
              },
              icon: Icon(CupertinoIcons.chat_bubble_2, color: Colors.black),
              label: Text(
                "Ai Concierge",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    fontFamily: AppConstants.manrope),
              ),
            ),
    );
  }

  sendlistap(selectedid) {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    data['event_id'] = selectedid ?? "";
    print("send event data jai che$data");

    // Show full-screen loader
    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        EventProvider().sendeventapi(data).then((response) async {
          sendeventModel = SendeventModel.fromJson(json.decode(response.body));

          if (response.statusCode == 200 || sendeventModel?.data == 200) {
            log("Response body avve che che ==>> ${response.body}");
            projectlistap();
          } else if (response.statusCode == 422) {
            load = false;
          } else {
            EasyLoading.showError("Internal Server Error");
          }

          setState(() {
            isLoading = false; // Loader Stop (Success or Error both cases)
          });
          return false; // Failed request
        }).catchError((error) {
          setState(() {
            isLoading = false; // Loader Stop on Error
          });
          EasyLoading.showError("Request Failed");
          return false; // Failed request due to error
        });
      } else {
        setState(() {
          isLoading = false; // Loader Stop on No Internet
        });
        buildErrorDialog(context, 'Error', "Internet Required");
        return false; // No internet connection
      }
    });
  }

  projectlistap1() {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    print("login data jai che$data");
    checkInternet().then((internet) async {
      if (internet) {
        EventProvider().eventapi(data).then((response) async {
          eventlistModel = EventlistModel.fromJson(json.decode(response.body));

          if (response.statusCode == 200) {
            log("Response body avve che che ==>> ${response.body}");
            var jsonData = jsonDecode(response.body);

            List<DateTime> dates = jsonData['data'].map<DateTime>((project) {
              return DateTime.parse(project['event_date'].split('T')[0]);
            }).toList();

            setState(() {
              projectDates = dates;
              isLoading = false;
              load = false;
            });

            log("Without date${projectDates}");
          } else if (response.statusCode == 422) {
            setState(() {
              isLoading = false;
              load = false;
            });
          } else {
            EasyLoading.showError("Internal Server Error");
          }
        });
      } else {
        setState(() {
          isLoading = false;
          load = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  projectlistap() {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    data['date'] = selectedDate.toString() ?? "";

    print("data jai che$data");
    checkInternet().then((internet) async {
      if (internet) {
        EventProvider().eventapi(data).then((response) async {
          event_list_Model =
              EventlistModel.fromJson(json.decode(response.body));
          if (response.statusCode == 200) {
            log("Response body avve che che dasdad==>> ${response.body}");
            setState(() {
              isLoading = false;
              load = false;
            });

            log("Date Ave Ave che hhee projejsdf ${projectDates}");
          } else if (response.statusCode == 422) {
            setState(() {
              isLoading = false;
              load = false;
            });
          } else {
            EasyLoading.showError("Internal Server Error");
          }
        });
      } else {
        setState(() {
          isLoading = false;
          load = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Widget _buildWeekView() {
    return Container(
      height: 12.h,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          DateTime date = dates[index]['fullDate'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
                load = true;
                selectedDate = DateFormat('yyyy-MM-dd').format(date);
              });
              projectlistap();
            },
            child: Container(
              width: 20.w,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.maincolor : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dates[index]['day']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  Text(
                    dates[index]['weekday']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontFamily: AppConstants.manrope,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthView() {
    return TableCalendar(
      firstDay: DateTime(now.year, now.month, 1),
      lastDay: DateTime(now.year, now.month + 1, 0),
      focusedDay: now,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontFamily: AppConstants.manrope,
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.black,
          fontFamily: AppConstants.manrope,
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
        ),
        weekendStyle: TextStyle(
          color: Colors.black,
          fontFamily: AppConstants.manrope,
          fontSize: 13.5,
          fontWeight: FontWeight.normal,
        ),
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.maincolor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        selectedTextStyle:
            TextStyle(color: Colors.white, fontFamily: AppConstants.manrope),
        todayTextStyle:
            TextStyle(color: Colors.white, fontFamily: AppConstants.manrope),
        defaultTextStyle:
            TextStyle(color: Colors.white, fontFamily: AppConstants.manrope),
        weekendTextStyle:
            TextStyle(color: Colors.white, fontFamily: AppConstants.manrope),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          DateTime normalizedDay = DateTime(day.year, day.month, day.day);
          bool isHighlighted = projectDates.any((createdDate) {
            DateTime normalizedCreatedDate =
                DateTime(createdDate.year, createdDate.month, createdDate.day);
            return isSameDay(normalizedCreatedDate, normalizedDay);
          });
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = day;
                selectedDate = DateFormat('yyyy-MM-dd').format(day);
                load = true;
              });
              projectlistap();
            },
            child: Container(
              margin: EdgeInsets.all(6.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isHighlighted ? AppColors.maincolor : AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isHighlighted ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ),
          );
        },
      ),
      onDaySelected: (newSelectedDay, focusedDay) {
        setState(() {
          selectedDay = newSelectedDay;
          selectedDate = DateFormat('yyyy-MM-dd').format(newSelectedDay);
          load = true;
        });
        projectlistap();
      },
    );
  }

  Widget _buildYearView() {
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    DateTime lastDayOfYear = DateTime(now.year, 12, 31);
    return TableCalendar(
      firstDay: firstDayOfYear,
      lastDay: lastDayOfYear,
      focusedDay: selectedYear ?? now,
      currentDay: now,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontFamily: AppConstants.manrope,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Colors.black,
          fontSize: 13.5,
          fontFamily: AppConstants.manrope,
        ),
        weekendStyle: TextStyle(
          color: Colors.black,
          fontSize: 13.5,
          fontFamily: AppConstants.manrope,
        ),
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.maincolor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.black45,
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
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppConstants.manrope,
        ),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(selectedYear, day);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          bool isMonthDate = projectDates.any((projectDate) {
            return isSameDay(projectDate, day);
          });

          return Container(
            margin: EdgeInsets.all(6.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isMonthDate ? AppColors.maincolor : AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isMonthDate ? Colors.white : Colors.black,
                fontFamily: AppConstants.manrope,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      onDaySelected: (newSelectedDay, focusedDay) {
        setState(() {
          selectedYear = newSelectedDay; // Update selected day
          selectedDate = DateFormat('yyyy-MM-dd').format(newSelectedDay);
          load = true;
        });
        projectlistap();
      },
      onPageChanged: (focusedDay) {
        // Prevent going to past months
        if (focusedDay.isBefore(firstDayOfYear)) {
          setState(() {
            selectedYear = firstDayOfYear; // Reset to current month
          });
        }
      },
    );
  }
}
