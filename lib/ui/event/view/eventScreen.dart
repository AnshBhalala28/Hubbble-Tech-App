import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/ui/event/modal/eventModel.dart';
import 'package:wavee/ui/event/view/eventDetails.dart';

import '../../../utils/checkInternetConnection.dart';
import '../../../utils/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/customAppBar.dart';
import '../provider/eventProvider.dart';

class EventScreen extends StatefulWidget {
  final String? userId;

  const EventScreen({super.key, this.userId});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime currentMonth = DateTime.now();
  String? selectedDate;
  List<DateTime> projectDates = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    selectedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
    projectlistap1();
    projectlistap();
  }

  // --- Custom Calendar Logic ---
  List<DateTime> _generateDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Start from the most recent Sunday to fill the first row
    final firstDisplayedDay = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    final lastDisplayedDay = lastDayOfMonth.add(
      Duration(days: 6 - (lastDayOfMonth.weekday % 7)),
    );

    return List.generate(
      lastDisplayedDay.difference(firstDisplayedDay).inDays + 1,
      (index) => firstDisplayedDay.add(Duration(days: index)),
    );
  }

  // bool isDark = true;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: theme.isDark ? AppColors.darkBack : AppColors.lightBack,
      body: Column(
        children: [
          SizedBox(height: 5.h),
          TitleBar(
            title: "Events",
            drawerCallback: () {},
            back: () => Get.back(),
          ),

          // --- Custom Calendar Card ---
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: theme.isDark ? const Color(0xf00ff212121) : Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                // Month Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            theme.isDark
                                ? const Color(0xf033312C)
                                : AppColors.lightText.withValues(alpha: .2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color:
                              theme.isDark
                                  ? const Color(0xf0CBB88C)
                                  : AppColors.lightText,
                          size: 22.sp,
                        ),
                        onPressed:
                            () => setState(
                              () =>
                                  currentMonth = DateTime(
                                    currentMonth.year,
                                    currentMonth.month - 1,
                                  ),
                            ),
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(currentMonth),
                      style: TextStyle(
                        fontSize: 17.sp,
                        color: theme.isDark ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manropeBold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            theme.isDark
                                ? const Color(0xf033312C)
                                : AppColors.lightText.withValues(alpha: .2),
                        shape: BoxShape.circle,
                      ),

                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color:
                              theme.isDark
                                  ? const Color(0xf0CBB88C)
                                  : AppColors.lightText,
                          size: 22.sp,
                        ),
                        onPressed:
                            () => setState(
                              () =>
                                  currentMonth = DateTime(
                                    currentMonth.year,
                                    currentMonth.month + 1,
                                  ),
                            ),
                      ),
                    ),
                  ],
                ).paddingOnly(bottom: 1.h),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) {
                          return SizedBox(
                            width: 10.w,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    theme.isDark
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
                    final day = _generateDaysInMonth(currentMonth)[index];
                    final isSelected =
                        DateFormat('yyyy-MM-dd').format(day) == selectedDate;
                    final isCurrentMonth = day.month == currentMonth.month;

                    // Aaje ni date check karva mate
                    final today = DateTime.now();
                    final isToday =
                        day.day == today.day &&
                        day.month == today.month &&
                        day.year == today.year;

                    final hasEvent = projectDates.any(
                      (d) =>
                          d.year == day.year &&
                          d.month == day.month &&
                          d.day == day.day,
                    );

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = day;
                          selectedDate = DateFormat('yyyy-MM-dd').format(day);
                          isLoading = true;
                        });
                        projectlistap();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected
                                  ? (theme.isDark
                                      ? const Color(0xf0CBB88C)
                                      : const Color(
                                        0xFFF4F7F9,
                                      )) // Selected color
                                  : isToday && hasEvent
                                  ? (theme.isDark
                                      ? const Color(0xFF33312C)
                                      : const Color(
                                        0xFFE8EEF5,
                                      )) // Today with Event highlight
                                  : hasEvent
                                  ? (theme.isDark
                                      ? const Color(0xFF2C2C2C)
                                      : const Color(
                                        0xFFF1F3F6,
                                      )) // Normal Event highlight
                                  : Colors.transparent,
                          border:
                              (isToday)
                                  ? Border.all(
                                    color: const Color(0xf0CBB88C),
                                    width: 1.5,
                                  ) // Today ni border highlight
                                  : hasEvent && theme.isDark
                                  ? Border.all(
                                    color: const Color(
                                      0xf0CBB88C,
                                    ).withOpacity(0.5),
                                    width: 1,
                                  )
                                  : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${day.day}",
                              style: TextStyle(
                                fontWeight:
                                    (isSelected || hasEvent || isToday)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontFamily: AppConstants.manrope,
                                color:
                                    theme.isDark
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
                                  color:
                                      theme.isDark
                                          ? const Color(0xf0CBB88C)
                                          : Colors.black,
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

          // --- Event List Section ---
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color:
                            theme.isDark
                                ? const Color(0xf0CBB88C)
                                : AppColors.maincolor,
                      ),
                    )
                    : (event_list_Model?.data?.data?.isEmpty ?? true)
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: EdgeInsets.only(top: 2.h),
                      itemCount: event_list_Model?.data?.data?.length ?? 0,
                      itemBuilder: (context, index) => _buildEventCard(index),
                    ),
          ),
        ],
      ).paddingSymmetric(horizontal: 3.w),
    );
  }

  Widget _buildEventCard(int index) {
    final theme = context.watch<ThemeController>();

    var event = event_list_Model?.data?.data?[index];
    return GestureDetector(
      onTap: () {
        Get.to(
          EventDetail(
            eventID: event.id.toString() ?? "",
            status: event_list_Model?.data?.data?[index].requestEvent,
          ),
        );
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
                color:
                    theme.isDark
                        ? const Color(0xf0CBB88C).withValues(alpha: .2)
                        : const Color(0xFFF1F3F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(DateTime.parse(event!.eventDate!)),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color:
                          theme.isDark
                              ? const Color(0xf0CBB88C)
                              : AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(DateTime.parse(event.eventDate!)),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:
                          theme.isDark
                              ? const Color(0xf0CBB88C)
                              : AppColors.black,

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
                      const Icon(
                        Icons.wine_bar,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Social",
                        style: TextStyle(
                          color: Colors.pinkAccent,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                      const Spacer(),
                      _buildFeaturedBadge(),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    event.title?.toString().capitalizeFirst ?? "",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: theme.isDark ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  if (event.description != null)
                    Text(
                      event.description ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.isDark ? AppColors.white : AppColors.black,

                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  SizedBox(height: 1.5.h),
                  _buildEventFooter(event.startTime ?? ""),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBadge() {
    final theme = context.watch<ThemeController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            theme.isDark
                ? const Color(0xf0CBB88C).withValues(alpha: .2)
                : const Color(0xFFE8EEF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            size: 12,
            color:
                theme.isDark
                    ? const Color(0xf0CBB88C)
                    : const Color(0xFF5D6A78),
          ),
          const SizedBox(width: 4),
          Text(
            "Featured",
            style: TextStyle(
              fontSize: 12.sp,
              color:
                  theme.isDark
                      ? const Color(0xf0CBB88C)
                      : const Color(0xFF5D6A78),

              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventFooter(String time) {
    String formattedTime = "";
    try {
      DateTime tempDate = DateFormat("HH:mm:ss").parse(time);
      formattedTime = DateFormat("h:mm a").format(tempDate);
    } catch (e) {
      formattedTime = time;
    }
    final theme = context.watch<ThemeController>();

    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          formattedTime, // Ahia hve badlayelo time dekhase
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
          "42/60",
          style: TextStyle(
            fontSize: 13.sp,
            color: theme.isDark ? AppColors.white : AppColors.black,

            fontFamily: AppConstants.manrope,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = context.watch<ThemeController>();

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  theme.isDark
                      ? const Color(0xf0CBB88C).withValues(alpha: .2)
                      : AppColors.lightText,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 22.sp,
              color: theme.isDark ? const Color(0xf0CBB88C) : Colors.white,
            ),
          ).paddingOnly(bottom: 1.h),
          Text(
            "No Events",
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.isDark ? AppColors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
            ),
          ).paddingOnly(bottom: 0.5.h),
          Text(
            "No events on this date",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ).paddingOnly(top: 10.h),
    );
  }

  // --- API Logic ---
  void projectlistap() {
    final Map<String, String> data = {
      'user_id': loginModel?.data?.user?.id.toString() ?? "",
      'date': selectedDate ?? "",
    };
    checkInternet().then((internet) async {
      if (internet) {
        EventProvider().eventapi(data).then((response) {
          setState(() {
            event_list_Model = EventlistModel.fromJson(response.data);
            isLoading = false;
          });
        });
      }
    });
  }

  void projectlistap1() {
    final Map<String, String> data = {"user_id": widget.userId ?? ""};
    checkInternet().then((internet) async {
      if (internet) {
        final response = await EventProvider().eventapi(data);
        if (response.statusCode == 200) {
          var jsonData = response.data;
          if (jsonData['data'] != null && jsonData['data']['data'] is List) {
            List<dynamic> projectList = jsonData['data']['data'];
            setState(() {
              projectDates =
                  projectList
                      .map<DateTime>(
                        (p) => DateTime.parse(p['event_date'].split(' ')[0]),
                      )
                      .toList();
            });
          }
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }
}
