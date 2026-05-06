import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customAppBar.dart';

class VenueProfileScreen extends StatefulWidget {
  const VenueProfileScreen({super.key});

  @override
  State<VenueProfileScreen> createState() => _VenueProfileScreenState();
}

class _VenueProfileScreenState extends State<VenueProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;

    final Color blueColor = const Color(0xFF5A6385);

    final Color iconColor = isDark ? const Color(0xf0B8A780) : blueColor;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subtitleColor =
        isDark ? Colors.grey.shade500 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 6.h),
              TitleBar(
                back: () => Get.back(),
                title: "Venue Profile",
                drawerCallback: () {},
              ),
              SizedBox(height: 2.h),



              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: EdgeInsets.all(2), // border thickness
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Color(0xFFCFB583) : AppColors.lightText,
                                // 🔥 dynamic color
                                width: 1.w,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 35.sp,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: AssetImage(
                                'assets/images/waveeLogoShort.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),


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
                              icon: Icons.person,
                              label: "VENUE NAME",
                              value: "Test Venue",
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
                            SizedBox(height: 1.h),

                            _buildSingleInfoCard(
                              icon: Icons.email_outlined,
                              label: "VENUE EMAIL",
                              value: "test001@gmail.com",
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
                            SizedBox(height: 1.h),

                            _buildSingleInfoCard(
                              icon: Icons.home,
                              label: "VENUE ADDRESS",
                              value: "test001@gmail.com",
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
                            SizedBox(height: 1.h),
                            _buildSingleInfoCard(
                              icon: Icons.phone,
                              label: "CONTACT",
                              value: "+1 234 567 890",
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
                            SizedBox(height: 1.h),

                            _buildSingleInfoCard(
                              icon: Icons.mail,
                              label: "EMAIL",
                              value: "test001@gmail.com",
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
                      ),

                      SizedBox(height: 2.h),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Venue Details",
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: titleColor,
                                fontFamily: AppConstants.manrope,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            _buildSingleInfoCard(
                              icon: Icons.local_shipping,
                              label: "LOADING / UNLOADING",
                              value: "LOADING / UNLOADING",
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

                            SizedBox(height: 1.h),

                            _buildSingleInfoCard(
                              icon: Icons.two_wheeler,
                              label: "PARKING",
                              value: "PARKING",
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

                            SizedBox(height: 1.h),
                            _buildSingleInfoCard(
                              icon: Icons.chair,
                              label: "FURNITURE",
                              value: "FURNITURE",
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

                            SizedBox(height: 1.h),
                            _buildSingleInfoCard(
                              icon: Icons.kitchen,
                              label: "KITCHEN / BAR",
                              value: "KITCHEN",
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

                            SizedBox(height: 1.h),

                            _buildSingleInfoCard(
                              icon: Icons.volume_up,
                              label: "SOUND RESTRICTIONS",
                              value: "SOUND",
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

                            SizedBox(height: 1.h),
                            _buildSingleInfoCard(
                              icon: Icons.local_fire_department,
                              label: "FIRESAFETY RESTRICTIONS",
                              value: "FIRESAFETY",
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
                            SizedBox(height: 1.h),
                            _buildSingleInfoCard(
                              icon: Icons.store,
                              label: "SUPPLIERS TIMINGS",
                              value: "SUPPLIERS",
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
                            SizedBox(height: 1.h),
                            _buildSingleInfoCard(
                              icon: Icons.group,
                              label: "GUEST TIMINGS",
                              value: "GUEST",
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
                            SizedBox(height: 1.h),
                            _buildSingleInfoCard(
                              icon: Icons.hotel,
                              label: "ACCOMMODATION DETAILS",
                              value: "ACCOMMODATION",
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
                            SizedBox(height: 1.h),
                            _buildSingleInfoCard(
                              icon: Icons.auto_awesome,
                              label: "RIGGING ALLOWED",
                              value: "RIGGING",
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).paddingOnly(left: 3.w, right: 3.w),
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
