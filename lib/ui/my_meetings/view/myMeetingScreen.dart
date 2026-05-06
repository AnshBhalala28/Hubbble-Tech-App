import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customAppBar.dart';

class MyMeetingsScreen extends StatefulWidget {
  const MyMeetingsScreen({super.key});

  @override
  State<MyMeetingsScreen> createState() => _MyMeetingsScreenState();
}

class _MyMeetingsScreenState extends State<MyMeetingsScreen> {
  String selectedFilter = "All";
  DateTime selectedDay = DateTime.now();
  DateTime currentMonth = DateTime.now();
  List<DateTime> projectDates = [];
  bool isLoading = false;
  String selectedValue = 'Meetings';
  String? selectedDate;
  final List<Map<String, dynamic>> staticMeetings = [
    {
      'id': 1,
      'title': 'Weekly Team Sync',
      'description': 'Monthly team meeting to discuss project progress and upcoming milestones',
      'date': DateTime.now(),
      'startTime': '14:00:00',
      'endTime': '15:00:00',
      'category': 'Business',
      'featured': true,
      'currentAttendees': 12,
      'maxAttendees': 20,
      'status': 'upcoming'
    }, {
      'id': 7,
      'title': 'Weekly Team Sync',
      'description': 'Monthly team meeting to discuss project progress and upcoming milestones',
      'date': DateTime.now(),
      'startTime': '14:00:00',
      'endTime': '15:00:00',
      'category': 'Business',
      'featured': true,
      'currentAttendees': 12,
      'maxAttendees': 20,
      'status': 'upcoming'
    }, {
      'id': 8,
      'title': 'Weekly Team Sync',
      'description': 'Monthly team meeting to discuss project progress and upcoming milestones',
      'date': DateTime.now(),
      'startTime': '14:00:00',
      'endTime': '15:00:00',
      'category': 'Business',
      'featured': true,
      'currentAttendees': 12,
      'maxAttendees': 20,
      'status': 'upcoming'
    },
    {
      'id': 2,
      'title': 'Product Design Review',
      'description': 'Review new product designs and provide feedback',
      'date': DateTime.now().add(const Duration(days: 2)),
      'startTime': '10:30:00',
      'endTime': '12:00:00',
      'category': 'Design',
      'featured': false,
      'currentAttendees': 8,
      'maxAttendees': 15,
      'status': 'upcoming'
    },
    {
      'id': 3,
      'title': 'Client Presentation',
      'description': 'Present quarterly results to key clients',
      'date': DateTime.now().add(const Duration(days: 5)),
      'startTime': '15:00:00',
      'endTime': '16:30:00',
      'category': 'Business',
      'featured': true,
      'currentAttendees': 5,
      'maxAttendees': 10,
      'status': 'upcoming'
    },
    {
      'id': 4,
      'title': 'Coffee Chat',
      'description': 'Informal coffee chat with the team',
      'date': DateTime.now().add(const Duration(days: -3)),
      'startTime': '11:00:00',
      'endTime': '11:30:00',
      'category': 'Social',
      'featured': false,
      'currentAttendees': 6,
      'maxAttendees': 12,
      'status': 'completed'
    },
    {
      'id': 5,
      'title': 'Workshop: Flutter Advanced',
      'description': 'Advanced Flutter development workshop',
      'date': DateTime.now().add(const Duration(days: 7)),
      'startTime': '09:00:00',
      'endTime': '17:00:00',
      'category': 'Workshop',
      'featured': true,
      'currentAttendees': 25,
      'maxAttendees': 30,
      'status': 'upcoming'
    },
    {
      'id': 6,
      'title': 'Canceled - Design Sprint',
      'description': 'Weekend design sprint session',
      'date': DateTime.now().add(const Duration(days: -5)),
      'startTime': '10:00:00',
      'endTime': '16:00:00',
      'category': 'Design',
      'featured': false,
      'currentAttendees': 0,
      'maxAttendees': 8,
      'status': 'cancelled'
    },
  ];

  final List<Map<String, dynamic>> pendingRequests = [
    {
      'id': 1,
      'title': 'Project Kickoff Meeting',
      'requester': 'John Doe',
      'date': DateTime.now().add(const Duration(days: 3)),
      'startTime': '13:00:00',
      'priority': 'high',
      'status': 'pending'
    },
    {
      'id': 2,
      'title': 'Technical Interview',
      'requester': 'Sarah Smith',
      'date': DateTime.now().add(const Duration(days: 4)),
      'startTime': '11:00:00',
      'priority': 'medium',
      'status': 'pending'
    },
    {
      'id': 3,
      'title': 'Budget Review',
      'requester': 'Mike Johnson',
      'date': DateTime.now().add(const Duration(days: 1)),
      'startTime': '09:30:00',
      'priority': 'high',
      'status': 'pending'
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
    _updateProjectDates();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    final filteredItems = _getFilteredMeetings();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xf01A1A1A) : const Color(
          0xFFF0F2F5),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 6.h),
              TitleBar(
                back: () => Get.back(),
                title: "My Meetings",
                drawerCallback: () {},
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52, // Fixed height optimization
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.isDark ? const Color(0xFF252525) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculator for sliding width
                          double width = constraints.maxWidth / options.length;
                          int selectedIndex = options.indexOf(selectedValue);

                          return Stack(
                            children: [
                              // Sliding Background Indicator
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOutCubic, // Smooth movement
                                alignment: Alignment(
                                  (selectedIndex * 2 / (options.length - 1)) - 1,
                                  0,
                                ),
                                child: Container(
                                  width: width,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: theme.isDark ? const Color(0xffCBB88C) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Actual Tab Buttons
                              Row(
                                children: options.map((String value) {
                                  bool isSelected = selectedValue == value;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedValue = value;
                                          selectedFilter = "All";
                                        });
                                      },
                                      behavior: HitTestBehavior.opaque,
                                      child: Center(
                                        child: AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 300),
                                          style: TextStyle(
                                            fontFamily: AppConstants.manropeBold,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.black
                                                : (theme.isDark ? Colors.grey : Colors.grey.shade600),
                                          ),
                                          child: Text(value),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Expanded(child: SingleChildScrollView(child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: theme.isDark ? const Color(0xf00ff212121) : Colors
                          .white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.isDark
                                    ? const Color(0xf033312C)
                                    : AppColors.lightText.withValues(alpha: .2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: theme.isDark
                                      ? const Color(0xf0CBB88C)
                                      : AppColors.lightText,
                                  size: 22.sp,
                                ),
                                onPressed: () =>
                                    setState(() {
                                      currentMonth = DateTime(currentMonth.year,
                                          currentMonth.month - 1);
                                      _updateProjectDates();
                                    }),
                              ),
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(currentMonth),
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: theme.isDark
                                    ? AppColors.white
                                    : AppColors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manropeBold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.isDark
                                    ? const Color(0xf033312C)
                                    : AppColors.lightText.withValues(alpha: .2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: theme.isDark
                                      ? const Color(0xf0CBB88C)
                                      : AppColors.lightText,
                                  size: 22.sp,
                                ),
                                onPressed: () =>
                                    setState(() {
                                      currentMonth = DateTime(currentMonth.year,
                                          currentMonth.month + 1);
                                      _updateProjectDates();
                                    }),
                              ),
                            ),
                          ],
                        ).paddingOnly(bottom: 1.h),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                                .map((day) {
                              return SizedBox(
                                width: 10.w,
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.isDark
                                        ? AppColors.white
                                        : Colors.grey,
                                    fontSize: 15.sp,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                          itemCount: _generateDaysInMonth(currentMonth).length,
                          itemBuilder: (context, index) {
                            final day = _generateDaysInMonth(
                                currentMonth)[index];
                            final isSelected = DateFormat('yyyy-MM-dd').format(
                                day) == selectedDate;
                            final isCurrentMonth = day.month ==
                                currentMonth.month;
                            final today = DateTime.now();
                            final isToday = day.day == today.day &&
                                day.month == today.month &&
                                day.year == today.year;
                            final hasEvent = projectDates.any(
                                  (d) =>
                              d.year == day.year && d.month == day.month &&
                                  d.day == day.day,
                            );

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDay = day;
                                  selectedDate =
                                      DateFormat('yyyy-MM-dd').format(day);
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? (theme.isDark
                                      ? const Color(0xf0CBB88C)
                                      : const Color(0xFFF4F7F9))
                                      : isToday && hasEvent
                                      ? (theme.isDark
                                      ? const Color(0xFF33312C)
                                      : const Color(0xFFE8EEF5))
                                      : hasEvent
                                      ? (theme.isDark
                                      ? const Color(0xFF2C2C2C)
                                      : const Color(0xFFF1F3F6))
                                      : Colors.transparent,
                                  border: isToday
                                      ? Border.all(
                                      color: const Color(0xf0CBB88C),
                                      width: 1.5)
                                      : hasEvent && theme.isDark
                                      ? Border.all(
                                      color: const Color(0xf0CBB88C)
                                          .withOpacity(0.5), width: 1)
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${day.day}",
                                      style: TextStyle(
                                        fontWeight: (isSelected || hasEvent ||
                                            isToday)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontFamily: AppConstants.manrope,
                                        color: theme.isDark
                                            ? (isCurrentMonth
                                            ? Colors.white
                                            : Colors.grey.shade600)
                                            : (isCurrentMonth
                                            ? Colors.black
                                            : Colors.grey.shade300),
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    if (hasEvent)
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: theme.isDark ? const Color(
                                              0xf0CBB88C) : Colors.black,
                                          shape: BoxShape.circle,
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
                  // Expanded(
                  //   child:
                  filteredItems.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 50.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          selectedValue == 'Pending Requests'
                              ? "No pending requests"
                              : "No meetings for this day",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.only(bottom: 30.sp),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      if (selectedValue == 'Pending Requests') {
                        return _buildPendingRequestCard(filteredItems[index]);
                      } else {
                        return _buildEventCard(filteredItems[index]);
                      }
                    },
                  ),
                ],
              ),)),

              // ),
            ],
          ).paddingOnly(left: 3.w, right: 3.w),
        ],
      ),
      floatingActionButton: selectedValue == 'Pending Requests'
          ? SizedBox()
          : Row(
        children: [
          const Spacer(),
          FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(900)),
            backgroundColor: theme.isDark ? const Color(0xffCBB88C) : Colors
                .white,
            onPressed: () {
              log("Request Meeting button tapped");
              showAddRequestBottomSheet(context);
            },
            label: SizedBox(
              width: 30.w,
              child: Text(
                "Request Meeting",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.5.sp,
                  fontFamily: AppConstants.manropeBold,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
    );
  }

  void _updateProjectDates() {
    projectDates =
        staticMeetings.map((meeting) => meeting['date'] as DateTime).toList();
  }

  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstDisplayedDay = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    final lastDisplayedDay = lastDayOfMonth.add(
      Duration(days: 6 - (lastDayOfMonth.weekday % 7)),
    );

    return List.generate(
      lastDisplayedDay
          .difference(firstDisplayedDay)
          .inDays + 1,
          (index) => firstDisplayedDay.add(Duration(days: index)),
    );
  }

  List<Map<String, dynamic>> _getFilteredMeetings() {
    if (selectedValue == 'Pending Requests') {
      return pendingRequests;
    }

    var meetings = staticMeetings.where((meeting) {
      final meetingDate = meeting['date'] as DateTime;
      final isSameDay = DateFormat('yyyy-MM-dd').format(meetingDate) ==
          selectedDate;

      if (!isSameDay) return false;

      if (selectedFilter == 'All') return true;
      return meeting['status'] == selectedFilter.toLowerCase();
    }).toList();

    return meetings;
  }


  Widget _buildEventCard(Map<String, dynamic> meeting) {
    final theme = context.watch<ThemeController>();

    return GestureDetector(
      onTap: () {
        log("Meeting tapped: ${meeting['title']}");
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.isDark ? const Color(0xf0252525) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            width: 1,
            color: theme.isDark ? const Color(0xf0353535) : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: theme.isDark
                    ? const Color(0xf0CBB88C).withValues(alpha: .2)
                    : const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(meeting['date']),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: theme.isDark ? const Color(0xf0CBB88C) : AppColors
                          .black,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(meeting['date']),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.isDark ? const Color(0xf0CBB88C) : AppColors
                          .black,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getCategoryIcon(meeting['category']),
                      const SizedBox(width: 4),
                      Text(
                        meeting['category'],
                        style: TextStyle(
                          color: _getCategoryColor(meeting['category']),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      const Spacer(),
                      if (meeting['featured'] == true) _buildFeaturedBadge(),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    meeting['title'],
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: theme.isDark ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  if (meeting['description'] != null)
                    Text(
                      meeting['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.isDark ? AppColors.white : AppColors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  SizedBox(height: 1.5.h),
                  _buildEventFooter(
                      meeting['startTime'], meeting['currentAttendees'],
                      meeting['maxAttendees']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestCard(Map<String, dynamic> request) {
    final theme = context.watch<ThemeController>();

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0xf0252525) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          width: 1,
          color: theme.isDark ? const Color(0xf0353535) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.isDark
                      ? const Color(0xf0CBB88C).withValues(alpha: .2)
                      : const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.pending_actions,
                  color: const Color(0xf0CBB88C),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['title'],
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: theme.isDark ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    Text(
                      "Requested by: ${request['requester']}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
              SizedBox(width: 2.w),
              Text(
                DateFormat('MMM dd, yyyy').format(request['date']),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.isDark ? AppColors.white : AppColors.black,
                  fontFamily: AppConstants.manrope,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
              SizedBox(width: 2.w),
              Text(
                _formatTime(request['startTime']),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.isDark ? AppColors.white : AppColors.black,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    log("Rejected request: ${request['title']}");
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Reject",
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    log("Accepted request: ${request['title']}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffCBB88C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Accept",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return const Icon(Icons.wine_bar, size: 14, color: Colors.orange);
      case 'business':
        return const Icon(Icons.business_center, size: 14, color: Colors.blue);
      case 'design':
        return const Icon(
            Icons.design_services, size: 14, color: Colors.purple);
      case 'workshop':
        return const Icon(Icons.school, size: 14, color: Colors.green);
      default:
        return const Icon(Icons.event, size: 14, color: Colors.grey);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Colors.pinkAccent;
      case 'business':
        return Colors.blue;
      case 'design':
        return Colors.purple;
      case 'workshop':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFeaturedBadge() {
    final theme = context.watch<ThemeController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.isDark
            ? const Color(0xf0CBB88C).withValues(alpha: .2)
            : const Color(0xFFE8EEF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: theme.isDark ? const Color(0xf0CBB88C) : const Color(
                0xFF5D6A78),
          ),
          const SizedBox(width: 4),
          Text(
            "Featured",
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.isDark ? const Color(0xf0CBB88C) : const Color(
                  0xFF5D6A78),
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    try {
      DateTime tempDate = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("h:mm a").format(tempDate);
    } catch (e) {
      return time;
    }
  }

  Widget _buildEventFooter(String time, int currentAttendees,
      int maxAttendees) {
    final theme = context.watch<ThemeController>();

    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          _formatTime(time),
          style: TextStyle(
            fontSize: 13.sp,
            color: theme.isDark ? AppColors.white : AppColors.black,
            fontFamily: AppConstants.manrope,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.circle, size: 4, color: Colors.grey),
        const SizedBox(width: 12),
        const Icon(Icons.people_outline, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          "$currentAttendees/$maxAttendees",
          style: TextStyle(
            fontSize: 13.sp,
            color: theme.isDark ? AppColors.white : AppColors.black,
            fontFamily: AppConstants.manrope,
          ),
        ),
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();


  final List<String> options = ['Meetings', 'Pending Requests'];
  String selectedTimeType = "Flexible";
  String? meetingType;
  String? selectedTime;

  void showAddRequestBottomSheet(BuildContext context) {
    final theme = Provider.of<ThemeController>(context, listen: false);


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 0,
                right: 0,
                top: 0,
              ),
              decoration: BoxDecoration(
                color: theme.isDark ? const Color(0xff1A1A1A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modern Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header with close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32), // Placeholder for balance
                        Text(
                          "Request Meeting",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppConstants.manropeBold,
                            color: theme.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(onTap: () {
                            Get.back();
                          },child: Icon(Icons.close, size: 18.sp, color: theme.isDark ? Colors.white70 : Colors.black))
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Form Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        left: 20,
                        right: 20,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Modern Title Field
                            _buildModernTextField(
                              label: "Meeting Title",
                              hint: "e.g., Product Brainstorming",
                              controller: subjectController,
                              icon: Icons.title_outlined,
                              theme: theme,
                            ),
                            const SizedBox(height: 20),

                            // Row for Date and Time
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    label: "Date",
                                    hint: "Select date",
                                    controller: dateController,
                                    icon: Icons.calendar_today_outlined,
                                    theme: theme,
                                    onTap: () async {
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        dateController.text = DateFormat('dd MMM yyyy').format(picked);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    label: "Time",
                                    hint: "Select time",
                                    controller: timeController,
                                    icon: Icons.access_time_outlined,
                                    theme: theme,
                                    onTap: () async {
                                      TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (picked != null) {
                                        timeController.text = picked.format(context);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Meeting Type with elegant chips
                            Text(
                              "Meeting Type",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppConstants.manrope,
                                color: theme.isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildTypeChip("In Person", Icons.person_outline, meetingType == "In Person", () {
                                  setState(() {
                                    meetingType = "In Person";
                                  });
                                }, theme),
                                const SizedBox(width: 12),
                                _buildTypeChip("Zoom", Icons.videocam_outlined, meetingType == "Zoom", () {
                                  setState(() {
                                    meetingType = "Zoom";
                                  });
                                }, theme),
                                const SizedBox(width: 12),
                                _buildTypeChip("Phone Call", Icons.phone_outlined, meetingType == "Phone Call", () {
                                  setState(() {
                                    meetingType = "Phone Call";
                                  });
                                }, theme),
                              ],
                            ),
                            const SizedBox(height: 24),


                            Text(
                              "Additional Notes (Optional)",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppConstants.manrope,
                                color: theme.isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: noteController,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: theme.isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: "Add any special requests or details...",
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                                filled: true,
                                fillColor: theme.isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Elegant Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    if (meetingType == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please select a meeting type")),
                                      );
                                      return;
                                    }
                                    if (dateController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please select a date")),
                                      );
                                      return;
                                    }
                                    if (timeController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please select a time")),
                                      );
                                      return;
                                    }
                                    Get.back();
                                    // Add your submission logic here
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffCBB88C),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  "Submit Request",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppConstants.manropeBold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required ThemeController theme,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            fontFamily: AppConstants.manrope,
            color: theme.isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          style: TextStyle(
            fontSize: 13.sp,
            color: theme.isDark ? Colors.white : Colors.black,
            fontFamily: AppConstants.manrope,

          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18.sp, color: const Color(0xffCBB88C)),
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: AppConstants.manrope,

              color: Colors.black,
            ),
            filled: true,
            fillColor: theme.isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (onTap != null && (value == null || value.isEmpty)) {
              return "Required";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, IconData icon, bool isSelected, VoidCallback onTap, ThemeController theme) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xffCBB88C)
                : (theme.isDark ? Colors.grey.shade800 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.transparent,
              width: 0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.black : (theme.isDark ? Colors.white70 : Colors.black),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.black : (theme.isDark ? Colors.white70 : Colors.black),
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}