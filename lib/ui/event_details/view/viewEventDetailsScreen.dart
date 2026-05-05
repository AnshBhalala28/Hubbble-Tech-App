import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';

import '../../../utils/checkInternetConnection.dart';
import '../../../utils/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/customAppBar.dart';
import '../../../utils/loader.dart';
import '../../../utils/viewPdfFunction.dart';


class ViewEventDetailsScreen extends StatefulWidget {


  const ViewEventDetailsScreen({super.key,});

  @override
  State<ViewEventDetailsScreen> createState() => _ViewEventDetailsScreen();
}

class _ViewEventDetailsScreen extends State<ViewEventDetailsScreen> {
  final GlobalKey<ScaffoldState> Mybuilding = GlobalKey<ScaffoldState>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;

  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final bool isDark = theme.isDark;

    final Color backgroundColor =
    isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F4F7);
    final Color cardBackgroundColor =
    isDark ? const Color(0xFF252525) : Colors.white;

    // Text Colors
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subtitleColor =
    isDark ? Colors.grey.shade500 : Colors.grey.shade600;

    // Accent/Button Colors
    final Color goldColor = const Color(0xFFC7B283);
    final Color blueColor = const Color(0xFF5A6385);

    final Color primaryButtonColor = isDark ? goldColor : blueColor;

    // Icon Containers
    final Color iconBgColor =
    isDark ? const Color(0xf02F2F2F) : blueColor.withValues(alpha: 0.15);

    final Color iconColor = isDark ? const Color(0xf0CBB88C) : blueColor;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6.h),
          TitleBar(
            back: () => Get.back(),
            title: "Event Details",
            drawerCallback: () {},
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.2.h,
                ),
                decoration: BoxDecoration(
                  color: cardBackgroundColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: iconBgColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSingleInfoCard(
                      icon: Icons.person,
                      label: "Event Owner Name",
                      value: 'Wedding Hall',
                      iconBg:
                      theme.isDark
                          ? const Color(0xf036342F)
                          : const Color(0xf0E9EAEF),

                      iconColor: iconColor,
                      labelColor: subtitleColor,
                      valueColor: titleColor,
                      cardColor: cardBackgroundColor,
                      isDark: isDark,
                    ),
                    _buildSingleInfoCard(
                      icon: Icons.date_range,
                      label: "Event Date",
                      value: "addressController.text",
                      iconBg:
                      theme.isDark
                          ? const Color(0xf036342F)
                          : const Color(0xf0E9EAEF),

                      iconColor: iconColor,
                      labelColor: subtitleColor,
                      valueColor: titleColor,
                      cardColor: cardBackgroundColor,
                      isDark: isDark,
                    ),
                    _buildSingleInfoCard(
                      icon: Icons.info,
                      label: "Event Name",
                      value: "landline.text",
                      iconBg:
                      theme.isDark
                          ? const Color(0xf036342F)
                          : const Color(0xf0E9EAEF),

                      iconColor: iconColor,
                      labelColor: subtitleColor,
                      valueColor: titleColor,
                      cardColor: cardBackgroundColor,
                      isDark: isDark,
                    ),
                    _buildSingleInfoCard(
                      icon: Icons.event,
                      label: "Event Type",
                      value: "number.text",
                      iconBg:
                      theme.isDark
                          ? const Color(0xf036342F)
                          : const Color(0xf0E9EAEF),

                      iconColor: iconColor,
                      labelColor: subtitleColor,
                      valueColor: titleColor,
                      cardColor: cardBackgroundColor,
                      isDark: isDark,
                    ),
                    _buildSingleInfoCard(
                      icon: Icons.confirmation_number,
                      label: "Booking Type",
                      value: "parkingInfoController.text",
                      iconBg:
                      theme.isDark
                          ? const Color(0xf036342F)
                          : const Color(0xf0E9EAEF),

                      iconColor: iconColor,
                      labelColor: subtitleColor,
                      valueColor: titleColor,
                      cardColor: cardBackgroundColor,
                      isDark: isDark,
                    ),
                    _buildSingleInfoCard(
                      icon: Icons.comment,
                      label: "Event Comments",
                      value: "conciergeInfoController.text",
                      iconBg:
                      theme.isDark
                          ? const Color(0xf036342F)
                          : const Color(0xf0E9EAEF),

                      iconColor: iconColor,
                      labelColor: subtitleColor,
                      valueColor: titleColor,
                      cardColor: cardBackgroundColor,
                      isDark: isDark,
                    ),


                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          Text(
                            "Event Space Timings",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                          SizedBox(height: 1.h),

                          _buildSingleInfoCard(
                            icon: Icons.email,
                            label: "Event Email",
                            value: "conciergeInfoController.text",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor: cardBackgroundColor,
                            isDark: isDark,
                          ),
                          _buildSingleInfoCard(
                            icon: Icons.phone,
                            label: "Contact ",
                            value: "conciergeInfoController.text",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor: cardBackgroundColor,
                            isDark: isDark,
                          ),
                          _buildSingleInfoCard(
                            icon: Icons.group,
                            label: "Guests ",
                            value: "conciergeInfoController.text",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor: cardBackgroundColor,
                            isDark: isDark,
                          ),
                          _buildSingleInfoCard(
                            icon: Icons.chair_alt,
                            label: "Furniture Required ",
                            value: "conciergeInfoController.text",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor: cardBackgroundColor,
                            isDark: isDark,
                          ),
                          _buildSingleInfoCard(
                            icon: Icons.person,
                            label: "Venue coordinator",
                            value: "conciergeInfoController.text",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor: cardBackgroundColor,
                            isDark: isDark,
                          ),
                        ],
                      ),


                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          Text(
                            "Team Members",
                            style: TextStyle(
                              fontFamily: AppConstants.manropeBold,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          _buildSingleInfoCard(
                            icon: Icons.people,
                            label: "Team Members",
                            value: "conciergeInfoController.text",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor: cardBackgroundColor,
                            isDark: isDark,
                          ),

                        ],
                      ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ).paddingOnly(left: 3.w, right: 3.w),
    );
  }

  Widget _buildSingleInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
    required Color iconColor,
    required Color labelColor,
    required Color valueColor,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: iconBg),
        boxShadow:
        isDark
            ? []
            : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.8.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 19.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: labelColor,
                    fontFamily: AppConstants.manropeBold,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value == '' ? "--" : value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                    fontFamily: AppConstants.manrope,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




  String capitalize(String? s) {
    if (s == null || s.isEmpty) return '';
    return s
        .split(' ')
        .map(
          (word) =>
      word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '',
    )
        .join(' ');
  }
}
