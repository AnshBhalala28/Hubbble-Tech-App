import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/errorDialog.dart';
import '../../HomeScreen/View/homePage.dart';
import '../Provider/eventProvider.dart';
import '../View/eventDetails.dart';
import '../modal/eventModel.dart';
import '../modal/sendEventModel.dart';

class EventScreen extends StatefulWidget {
  String? userId;

  EventScreen({super.key, this.userId});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with TickerProviderStateMixin {
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
  bool isRequested = false;
  final GlobalKey<ScaffoldState> _scaffoldKeyEvent = GlobalKey<ScaffoldState>();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

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
    projectlistap();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
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
      return DateFormat("dd-MM-yyyy").format(parsedDate);
    } catch (e) {
      return "N/A";
    }
  }

  void _generateDatesBasedOnSelection() {
    DateTime today = DateTime.now();
    dates.clear();

    if (selectedValue == "month") {
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

  Widget _buildAnimatedLoader() {
    return Center(
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 9.h,
          width: 18.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              height: 4.5.h,
              width: 4.5.h,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 2 * 3.14159),
                duration: const Duration(milliseconds: 1000),
                builder: (context, double value, child) {
                  return Transform.rotate(angle: value, child: child);
                },
                child: const CircularProgressIndicator(
                  color: AppColors.maincolor,
                  strokeWidth: 3.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            TitleBar(
              back: () {
                Get.to(HomePage(selected: 1, userName: ''));
              },
              title: 'Events',
              drawerCallback: () {},
            ),
            SizedBox(height: 3.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Row(
                  children: [
                    const Spacer(),
                    Container(
                      height: 5.h,
                      width: 37.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          icon: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
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
                              value: "month",
                              child: Text(
                                "This Month",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: "days",
                              child: Text(
                                "This Week",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: "year",
                              child: Text(
                                "This Year",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value.toString();
                            });

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                setState(() {});
                              },
                            );
                          },
                        ).paddingOnly(left: 2.w),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Column(
                children: [
                  if (selectedValue == "month")
                    _buildMonthView()
                  else if (selectedValue == "days")
                    _buildWeekView()
                  else
                    _buildYearView(),

                  const SizedBox(height: 20),

                  Expanded(
                    child:
                        isLoading
                            ? _buildAnimatedLoader()
                            : event_list_Model?.data?.data?.length == 0 ||
                                event_list_Model?.data?.data?.length == null
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
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  event_list_Model?.data?.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                return _buildEventItem(index);
                              },
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(int index) {
    String eventId = event_list_Model?.data?.data?[index].id?.toString() ?? "";
    bool isRequestSent = sentEventIds.contains(eventId);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: Interval(0.1 * index, 1.0, curve: Curves.easeIn),
          ),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.5, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _fadeController,
              curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut),
            ),
          ),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            shadowColor: AppColors.maincolor.withOpacity(0.2),
            child: InkWell(
              onTap: () {
                Get.to(
                  EventDetail(
                    eventID: eventId,
                    status: event_list_Model?.data?.data?[index].requestEvent,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.maincolor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.maincolor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            formatDate(
                              event_list_Model?.data?.data?[index].eventDate,
                            ),
                            style: TextStyle(
                              color: AppColors.maincolor,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (event_list_Model?.data?.data?[index].requestEvent
                                ?.toLowerCase() ==
                            "pending")
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Requested",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      event_list_Model?.data?.data?[index].title ?? "N/A",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        // fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manropeBold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.maincolor,
                          size: 18.sp,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event_list_Model?.data?.data?[index].location ??
                                "N/A",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15.sp,
                              fontFamily: AppConstants.manrope,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    if (event_list_Model?.data?.data?[index].description !=
                        null)
                      Text(
                        event_list_Model?.data?.data?[index].description ?? "",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14.sp,
                          fontFamily: AppConstants.manrope,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  sendlistap(selectedid) {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    data['event_id'] = selectedid ?? "";

    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        EventProvider()
            .sendeventapi(data)
            .then((response) async {
              sendeventModel = SendeventModel.fromJson(response.data);

              if (response.statusCode == 200 || sendeventModel?.data == 200) {
                projectlistap();
              } else if (response.statusCode == 422) {
                load = false;
              } else {
                EasyLoading.showError("Internal Server Error");
              }

              setState(() {
                isLoading = false;
              });
              return false;
            })
            .catchError((error) {
              setState(() {
                isLoading = false;
              });
              EasyLoading.showError("Request Failed");
              return false;
            });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
        return false;
      }
    });
  }

  projectlistap01() {
    final Map<String, String> data = {"user_id": widget.userId ?? ""};

    checkInternet().then((internet) async {
      if (internet) {
        EventProvider().eventapi(data).then((response) async {
          eventlistModel = EventlistModel.fromJson(response.data);

          if (response.statusCode == 200) {
            var jsonData = response.data;

            List<DateTime> dates =
                jsonData['data'].map<DateTime>((project) {
                  return DateTime.parse(project['event_date'].split('T')[0]);
                }).toList();

            setState(() {
              projectDates = dates;
              isLoading = false;
              load = false;
            });
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

  projectlistap1() {
    final Map<String, String> data = {"user_id": widget.userId ?? ""};

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await EventProvider().eventapi(data);

          if (response.statusCode == 200) {
            eventlistModel = EventlistModel.fromJson(response.data);
            var jsonData = response.data;

            List<DateTime> dates = [];
            if (jsonData['data'] != null &&
                jsonData['data']['data'] != null &&
                jsonData['data']['data'] is List) {
              List<dynamic> projectList = jsonData['data']['data'];

              dates =
                  projectList.map<DateTime>((project) {
                    return DateTime.parse(project['event_date'].split(' ')[0]);
                  }).toList();
            } else {}

            if (mounted) {
              setState(() {
                projectDates = dates;
                isLoading = false;
                load = false;
              });
            }
          } else {
            setState(() {
              load = false;
              isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            load = false;
            isLoading = false;
          });
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  projectlistap() {
    setState(() {
      load = true;
    });
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    data['date'] = selectedDate.toString() ?? "";

    log("API Data: $data");

    checkInternet().then((internet) async {
      if (internet) {
        EventProvider().eventapi(data).then((response) async {
          event_list_Model = EventlistModel.fromJson(response.data);
          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
              load = false;
            });
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
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.maincolor : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dates[index]['day']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                  Text(
                    dates[index]['weekday']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 15.sp,
                      fontFamily: AppConstants.manropeBold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).marginOnly(right: 2.w);
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
        return isSameDay(selectedDay, day);
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          DateTime normalizedDay = DateTime(day.year, day.month, day.day);
          DateTime today = DateTime.now();
          bool isPastDate = normalizedDay.isBefore(
            DateTime(today.year, today.month, today.day),
          );

          bool isHighlighted = projectDates.any((createdDate) {
            DateTime normalizedCreatedDate = DateTime(
              createdDate.year,
              createdDate.month,
              createdDate.day,
            );
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
              margin: const EdgeInsets.all(6.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isHighlighted
                        ? AppColors.maincolor
                        : (isPastDate ? Colors.grey.shade300 : AppColors.white),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color:
                      isHighlighted
                          ? Colors.white
                          : (isPastDate ? Colors.grey.shade600 : Colors.black),
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
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
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
          DateTime today = DateTime.now();
          bool isPastDate = DateTime(
            day.year,
            day.month,
            day.day,
          ).isBefore(DateTime(today.year, today.month, today.day));

          bool isMonthDate = projectDates.any((projectDate) {
            return isSameDay(projectDate, day);
          });

          return Container(
            margin: const EdgeInsets.all(6.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isMonthDate
                      ? AppColors.maincolor
                      : (isPastDate ? Colors.grey.shade300 : AppColors.white),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color:
                    isMonthDate
                        ? Colors.white
                        : (isPastDate ? Colors.grey.shade600 : Colors.black),
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
