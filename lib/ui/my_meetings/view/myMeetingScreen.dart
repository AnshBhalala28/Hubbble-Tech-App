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
  DateTime selectedDate = DateTime.now();
  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
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

              SizedBox(height: 2.h),
              SizedBox(
                height: 12.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: 30, // આવતા 30 દિવસ બતાવશે
                  itemBuilder: (context, index) {
                    DateTime date = DateTime.now().add(Duration(days: index));
                    bool isSelected =
                        date.day == selectedDate.day &&
                        date.month == selectedDate.month;

                    return GestureDetector(
                      onTap: () => setState(() => selectedDate = date),
                      child: Container(
                        width: 18.w,
                        margin: EdgeInsets.only(right: 3.w),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? (isDark
                                      ? const Color(0xffCBB88C)
                                      : AppColors.lightText) // Selected Color
                                  : (isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow:
                              isSelected
                                  ? []
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.transparent
                                    : Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd').format(date),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontFamily: AppConstants.manropeBold,
                                color:
                                    isSelected
                                        ? (isDark ? Colors.black : Colors.white)
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                              ),
                            ),
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppConstants.manropeSemiBold,
                                color:
                                    isSelected
                                        ? (isDark
                                            ? Colors.black54
                                            : Colors.white70)
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ).paddingOnly(left: 3.w, right: 3.w),
        ],
      ),
      floatingActionButton: Row(
        children: [
          Spacer(),
          FloatingActionButton.extended(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(900),
            ),
            backgroundColor: theme.isDark ? Color(0xffCBB88C) : Colors.white,
            onPressed: () {},
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

  void _showFilterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Filter Meetings", style: TextStyle(fontSize: 16.sp, fontFamily: AppConstants.manropeBold)),
              SizedBox(height: 2.h),
              _filterOption("All", isDark),
              _filterOption("Pending", isDark),
              _filterOption("Completed", isDark),
              _filterOption("Cancelled", isDark),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(String title, bool isDark) {
    bool isSelected = selectedFilter == title;
    return ListTile(
      onTap: () {
        setState(() => selectedFilter = title);
        Get.back();
      },
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? const Color(0xffCBB88C) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontFamily: AppConstants.manropeSemiBold,
        ),
      ),
    );
  }

}
