import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customAppBar.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  const DeliveryDetailsScreen({super.key});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;

    final Color blueColor = const Color(0xFF5A6385);
    final Color iconColor = isDark ? const Color(0xf0B8A780) : blueColor;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subtitleColor =
    isDark ? Colors.grey.shade500 : Colors.grey.shade600;

    return  Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),

      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 6.h),

              TitleBar(
                back: () => Get.back(),
                title: "Deliver Details",
                drawerCallback: () {},
              ),

              SizedBox(height: 2.h),

              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                          theme.isDark
                              ? const Color(0xf02F2F2F)
                              : Colors.grey.withValues(alpha: .2),
                        ),
                        color:
                        theme.isDark
                            ? const Color(0xf0212121)
                            : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 2.h,
                      ),
                      child: Column(
                        children: [
                          _buildSingleInfoCard(
                            icon: Icons.business,
                            label: "Delivery Company Name",
                            value: "Hubbble Tech",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                            theme.isDark
                                ? const Color(0xf0252525)
                                : Colors.white,
                            isDark: isDark,
                          ),
                          SizedBox(height: 1.h,),

                          _buildSingleInfoCard(
                            icon: Icons.celebration,
                            label: "Event Name",
                            value: "Wedding",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                            theme.isDark
                                ? const Color(0xf0252525)
                                : Colors.white,
                            isDark: isDark,
                          ),
                          SizedBox(height: 1.h,),
                          _buildSingleInfoCard(
                            icon: Icons.phone,
                            label: "Contact ",
                            value: "9714064841",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                            theme.isDark
                                ? const Color(0xf0252525)
                                : Colors.white,
                            isDark: isDark,
                          ),

                          SizedBox(height: 1.h,),

                          _buildSingleInfoCard(
                            icon: Icons.inventory,
                            label: "Items ",
                            value: "Chear",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                            theme.isDark
                                ? const Color(0xf0252525)
                                : Colors.white,
                            isDark: isDark,
                          ),
                          SizedBox(height: 1.h,),
                          _buildSingleInfoCard(
                            icon: Icons.comment,
                            label: "Comments ",
                            value: "Wedding decoration items",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                            theme.isDark
                                ? const Color(0xf0252525)
                                : Colors.white,
                            isDark: isDark,
                          ),

                          SizedBox(height: 1.h,),
                          _buildSingleInfoCard(
                            icon: Icons.date_range,
                            label: "Scheduled Date",
                            value: "05-05-2026",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                            theme.isDark
                                ? const Color(0xf0252525)
                                : Colors.white,
                            isDark: isDark,
                          ),
                          SizedBox(height: 1.h,),
                          _buildSingleInfoCard(
                            icon: Icons.timer,
                            label: "Time",
                            value: "12:00 PM",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                            theme.isDark
                                ? const Color(0xf0252525)
                                : Colors.white,
                            isDark: isDark,
                          ),
                          SizedBox(height: 1.h,),
                          _buildSingleInfoCard(
                            icon: Icons.hourglass_empty,
                            label: "Delivery Status",
                            value: "Pending",
                            iconBg:
                            theme.isDark
                                ? const Color(0xf036342F)
                                : const Color(0xf0E9EAEF),

                            iconColor: iconColor,
                            labelColor: subtitleColor,
                            valueColor: titleColor,
                            cardColor:
                            theme.isDark
                                ? const Color(0xf0252525)
                                : Colors.white,
                            isDark: isDark,
                          ),

                        ],
                      ),
                    )
                  ],
                ),
              ))
            ],
          ).paddingSymmetric(horizontal: 3.w)
        ],
      ),

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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: labelColor,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value,
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

}
