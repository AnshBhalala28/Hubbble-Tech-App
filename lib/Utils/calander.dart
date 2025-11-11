import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wavee/Utils/colors.dart';

import 'const.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final Function(DateTime)? onDaySelected;
  final List<dynamic> homeDashboardList;
  final DateTime? selectedDate;
  final DateTime firstDay;
  final DateTime lastDay;
  final bool headerVisible;
  final CalendarFormat calendarFormat;

  const CustomCalendar({
    super.key,
    required this.focusedDay,
    this.onDaySelected,
    required this.homeDashboardList,
    this.selectedDate,
    required this.firstDay,
    required this.lastDay,
    this.headerVisible = true,
    this.calendarFormat = CalendarFormat.month,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;
  late Map<DateTime, List<Map<String, String>>> eventDates;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.focusedDay.year, widget.focusedDay.month);
    _selectedDay = widget.selectedDate;
    _prepareEvents();
  }

  @override
  void didUpdateWidget(covariant CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDay = widget.selectedDate;
    }
    if (widget.homeDashboardList != oldWidget.homeDashboardList) {
      _prepareEvents();
    }
  }

  void _prepareEvents() {
    final DateTime now = DateTime.now();
    eventDates = {};
    for (var e in widget.homeDashboardList) {
      if (e.start != null) {
        DateTime dt = DateTime.tryParse(e.start.toString()) ?? now;
        DateTime normalized = DateTime(dt.year, dt.month, dt.day);

        if (!eventDates.containsKey(normalized)) {
          eventDates[normalized] = [];
        }
        eventDates[normalized]!.add({
          "id": e.id.toString(),
          "title": e.title ?? "",
          "eventtitle": e.eventtitle ?? "",
          "color": e.color ?? "#89CFF0",
          "notes": e.description ?? "",
          "time": e.start ?? "",
          "apartment_no": e.apartmentNo ?? "",
        });
      }
    }
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDayEnabled(DateTime day) {
    final DateTime todayOnly = DateTime.now();
    final DateTime dayOnly = DateTime(day.year, day.month, day.day);
    return !dayOnly.isBefore(todayOnly);
  }

  @override
  Widget build(BuildContext context) {
    DateTime firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    int daysInMonth = lastDayOfMonth.day;
    int startWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Add empty containers for days before the first day of month
    for (int i = 1; i < startWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDay = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        day,
      );

      bool isToday = _isSameDay(currentDay, DateTime.now());
      bool isSelected = _isSameDay(_selectedDay, currentDay);
      bool isEnabled = _isDayEnabled(currentDay);

      // Get events for this day
      List<Map<String, String>> events = eventDates[currentDay] ?? [];
      String? mainColor = events.isNotEmpty ? events.first["color"] : null;

      dayWidgets.add(
        GestureDetector(
          onTap:
              isEnabled
                  ? () {
                    setState(() {
                      _selectedDay = currentDay;
                    });
                    widget.onDaySelected?.call(currentDay);

                    if (events.isNotEmpty) {
                      _showEventDialog(context, currentDay, events);
                    }
                  }
                  : null,
          child: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isSelected
                      ? AppColors.maincolor
                      : isToday
                      ? Colors.grey[300]
                      : mainColor != null
                      ? Color(int.parse(mainColor.replaceFirst('#', '0xff')))
                      : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$day",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                    color:
                        isSelected
                            ? Colors.white
                            : isToday
                            ? Colors.black
                            : mainColor != null
                            ? Colors.white
                            : isEnabled
                            ? Colors.black
                            : Colors.grey,
                  ),
                ),
                if (events.length > 1)
                  Text(
                    "+${events.length - 1}",
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header - conditionally visible
        if (widget.headerVisible) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    );
                  });
                },
              ),
              Text(
                "${_monthName(_currentMonth.month)} ${_currentMonth.year}",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text("Mon", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Tue", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Wed", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Thu", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Fri", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Sat", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Sun", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),

        SizedBox(height: 1.h),

        // Calendar grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          padding: EdgeInsets.zero,
          children: dayWidgets,
        ),
      ],
    );
  }

  void _showEventDialog(
    BuildContext context,
    DateTime day,
    List<Map<String, String>> events,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: 8,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            title: Column(
              children: [
                Text(
                  "Events on ${day.day}-${day.month}-${day.year}",
                  style: TextStyle(
                    fontFamily: AppConstants.manrope,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                const Divider(),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    events.map((event) {
                      final eventColor =
                          event["color"] != null
                              ? Color(
                                int.parse(
                                  event["color"]!.replaceFirst('#', '0xff'),
                                ),
                              )
                              : Colors.blueAccent;

                      return Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: eventColor,
                              child: Text(
                                event["eventtitle"]!.isNotEmpty
                                    ? event["eventtitle"]!
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              "Title :- ${event["eventtitle"] ?? ""}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: AppConstants.manrope,
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((event["eventtitle"] ?? "").isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    "Description :- ${event["eventtitle"] ?? ""}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[700],
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      StringFormatDate(event["time"] ?? "N/A"),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ).marginOnly(bottom: 1.h);
                    }).toList(),
              ),
            ),
          ),
    );
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}

String StringFormatDate(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) return "N/A";
  DateTime parsedDate = DateTime.parse(createdAt);
  return "${DateFormat('dd MMM yyyy').format(parsedDate)}, ${DateFormat('hh:mm a').format(parsedDate)}";
}
