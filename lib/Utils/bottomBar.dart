import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart'; // Ensure you have provider imported
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart'; // Import your ThemeController

import '../Ui/Chatscreen/View/chatScreen.dart';
import '../Ui/CommunityScreen/view/communityScreen.dart';
import '../Ui/HomeScreen/View/homePage.dart';
import '../Ui/cartScreen/view/cartViewScreen.dart';
import 'colors.dart';
import 'const.dart';

class BottomBar extends StatefulWidget {
  final int? selected;
  final int? chatCount;
  final VoidCallback? onChatCountUpdate;

  const BottomBar({
    super.key,
    this.selected,
    this.chatCount = 0,
    this.onChatCountUpdate,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _chatCount = 0;

  @override
  void initState() {
    super.initState();
    _chatCount = widget.chatCount ?? 0;
  }

  @override
  void didUpdateWidget(covariant BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chatCount != oldWidget.chatCount) {
      setState(() {
        _chatCount = widget.chatCount ?? 0;
      });
    }
  }

  void _navigateToScreen(Widget screen) {
    Get.offAll(() => screen, transition: Transition.fadeIn);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Access Theme
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;

    // 2. Define Colors based on Screenshot
    // LIGHT MODE
    final lightBg = Colors.white;
    final lightBorder = const Color(0xFFE0E0E0); // Light Grey
    final lightActiveFill = const Color(
      0xFFE8EAF6,
    ); // Very light blue/grey circle
    final lightIconActive = const Color(0xFF1E2B47); // Navy Blue
    final lightIconInactive = Colors.black87;

    // DARK MODE (Gold & Charcoal)
    final darkBg = const Color(0xFF1C1C1C); // Dark Charcoal
    final darkBorder = const Color(0xFFCDBA81); // Gold Border
    final darkActiveFill = const Color(
      0xFFCDBA81,
    ).withOpacity(0.2); // Semi-transparent Gold circle
    final darkIconActive = const Color(0xFFFFDF77); // Gold Icon
    final darkIconInactive = const Color(
      0xFFFFFFFF,
    ).withOpacity(0.5); // Dim Gold Icon

    return Container(
      // 3. Floating Pill Styling
      margin: EdgeInsets.only(left: 6.w, right: 6.w, bottom: 3.h, top: 1.h),
      height: 7.h, // Fixed height for the pill
      decoration: BoxDecoration(
        color: isDark ? darkBg : lightBg,
        borderRadius: BorderRadius.circular(100), // Fully rounded pill
        border: Border.all(color: isDark ? darkBorder : lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Even spacing
        children: [
          _buildNavItem(
            svgIconPath: AppConstants.bottomOne,
            index: 1,
            isDark: isDark,
            colors: (
              lightActiveFill,
              lightIconActive,
              lightIconInactive,
              darkActiveFill,
              darkIconActive,
              darkIconInactive,
            ),
            onTap: () => _navigateToScreen(HomePage(selected: 1, userName: "")),
          ),
          _buildNavItem(
            svgIconPath: AppConstants.bottomTwo,
            index: 2,
            isDark: isDark,
            colors: (
              lightActiveFill,
              lightIconActive,
              lightIconInactive,
              darkActiveFill,
              darkIconActive,
              darkIconInactive,
            ),
            onTap: () => _navigateToScreen(CommunityScreen(selected: 2)),
          ),
          _buildNavItemWithBadge(
            svgIconPath: AppConstants.bottomThree,
            index: 3,
            badgeCount: _chatCount,
            isDark: isDark,
            colors: (
              lightActiveFill,
              lightIconActive,
              lightIconInactive,
              darkActiveFill,
              darkIconActive,
              darkIconInactive,
            ),
            onTap: () => _navigateToScreen(ChatScreen(selected: 3)),
          ),
          _buildNavItem(
            svgIconPath: AppConstants.bottomFour,
            index: 4,
            isDark: isDark,
            colors: (
              lightActiveFill,
              lightIconActive,
              lightIconInactive,
              darkActiveFill,
              darkIconActive,
              darkIconInactive,
            ),
            onTap:
                () => _navigateToScreen(
                  AddToCartView(
                    selected: 4,
                    fromBottomBar: true,
                    isAmend: false,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // --- Helper to build Standard Items ---
  Widget _buildNavItem({
    required String svgIconPath,
    required int index,
    required bool isDark,
    required Function() onTap,
    // Passing all colors via a tuple/record for cleanliness, or just pass individual
    required var colors,
  }) {
    final isSelected = widget.selected == index;

    // Extract colors
    final (lFill, lActive, lInactive, dFill, dActive, dInactive) = colors;

    final activeFill = isDark ? dFill : lFill;
    final iconColor =
        isDark
            ? (isSelected ? dActive : dInactive)
            : (isSelected ? lActive : lInactive);

    return GestureDetector(
      onTap: () {
        if (!isSelected) onTap();
      },
      child: Container(
        height: 5.5.h,
        width: 5.5.h,
        // Perfect Circle
        decoration: BoxDecoration(
          color: isSelected ? activeFill : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(1.5.h),
        // Padding inside the circle
        child: SvgPicture.asset(svgIconPath, color: iconColor),
      ),
    );
  }

  // --- Helper to build Badge Items ---
  Widget _buildNavItemWithBadge({
    required String svgIconPath,
    required int index,
    required int badgeCount,
    required bool isDark,
    required Function() onTap,
    required var colors,
  }) {
    final isSelected = widget.selected == index;
    // Extract colors
    final (lFill, lActive, lInactive, dFill, dActive, dInactive) = colors;

    final activeFill = isDark ? dFill : lFill;
    final iconColor =
        isDark
            ? (isSelected ? dActive : dInactive)
            : (isSelected ? lActive : lInactive);

    return GestureDetector(
      onTap: () {
        if (!isSelected) onTap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            height: 5.5.h,
            width: 5.5.h,
            decoration: BoxDecoration(
              color: isSelected ? activeFill : Colors.transparent,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(1.5.h),
            child: SvgPicture.asset(svgIconPath, color: iconColor),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 6, // Adjusted for the new Circle layout
              right: 3,
              child: Container(
                padding: EdgeInsets.all(3.sp),
                decoration: BoxDecoration(
                  color: AppColors.goldDateColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
                    width: 1.5,
                  ),
                ),
                constraints: BoxConstraints(minWidth: 17.sp, minHeight: 17.sp),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 12.sp,
                      fontFamily: AppConstants.manrope,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
