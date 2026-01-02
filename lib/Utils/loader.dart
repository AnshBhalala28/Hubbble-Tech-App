import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';

import 'colors.dart'; // Ensure this path is correct for your project

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final bool isDark = theme.isDark;

    final Color goldColor = const Color(0xFFC7B283);
    final Color blueColor = const Color(0xFF5A6385);

    // Apply the logic from your snippet
    final Color iconBgColor =
        isDark
            ? goldColor.withOpacity(
              0.15,
            ) // .withValues(alpha: 0.2) if using newer Flutter
            : blueColor;

    final Color iconColor = isDark ? goldColor : AppColors.white;

    return Center(
      child: Material(
        elevation: 0,
        // Removed elevation as transparent backgrounds look better flat
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 9.h,
          width: 18.w,
          decoration: BoxDecoration(
            color: iconBgColor, // Dynamic background color
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: SizedBox(
              height: 4.5.h,
              width: 4.5.h,
              child: CircularProgressIndicator(
                color: iconColor, // Dynamic spinner color
                strokeWidth: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
