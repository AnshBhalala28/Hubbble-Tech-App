import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/utils/const.dart';

class LogoutDialogWidget extends StatefulWidget {


  final String title;
  final String message;
  final String yesText;
  final String noText;
  final VoidCallback? onNoTap;
  final Future<void> Function()? onYesTap;

  const LogoutDialogWidget({
    this.onYesTap,
    this.onNoTap,
    required this.title,
    required this.message,
    this.yesText = "Yes",
    this.noText = "No",
  });

  @override
  State<LogoutDialogWidget> createState() => LogoutDialogWidgetState();
}

class LogoutDialogWidgetState extends State<LogoutDialogWidget> {
  bool isDialogLoading = false; // Local state for the button loader

  @override
  Widget build(BuildContext context) {
    // 1. Theme Configuration
    final theme = context.watch<ThemeController>();
    final bool isDark = theme.isDark;

    // Colors for Dialog
    final Color dialogBgColor = isDark ? const Color(0xFF1D1D1F) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final Color subtitleColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade800;

    // Button Colors
    final Color yesBtnColor =
        isDark
            ? const Color(0xFFC7B283) // Gold
            : const Color(0xFF5A6385); // Blue
    final Color yesBtnTextColor = isDark ? Colors.black : Colors.white;

    final Color noBtnBgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color noBtnTextColor = isDark ? Colors.white : Colors.black;
    final Color noBtnBorderColor =
        isDark ? Colors.transparent : Colors.grey.shade300;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: PopScope(
        canPop: !isDialogLoading, // Prevent back button while loading
        child: Container(
          width: 73.w,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: dialogBgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 1.h),

              // TITLE
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontFamily: AppConstants.manrope,
                ),
              ),

              SizedBox(height: 1.5.h),

              // SUBTITLE
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: subtitleColor,
                  fontFamily: AppConstants.manrope,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 3.h),

              // BUTTONS ROW
              Row(
                children: [
                  // NO BUTTON
                  Expanded(
                    child: _buildDialogButton(
                      label: "No",
                      bgColor: noBtnBgColor,
                      textColor: noBtnTextColor,
                      borderColor: noBtnBorderColor,
                      onTap: () {
                        if (!isDialogLoading) {
                          if (widget.onNoTap != null) {
                            widget.onNoTap!();
                          } else {
                            Navigator.pop(context); // default
                          }
                        }
                      },
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // YES BUTTON
                  Expanded(
                    child: _buildDialogButton(
                      label: "Yes",
                      bgColor: yesBtnColor,
                      textColor: yesBtnTextColor,
                      borderColor: Colors.transparent,
                      isLoading: isDialogLoading,
                      // Pass loading state
                      onTap: () async {
                        setState(() => isDialogLoading = true);

                        if (widget.onYesTap != null) {
                          await widget.onYesTap!();
                        }

                        if (mounted) {
                          setState(() => isDialogLoading = false);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap, // Disable tap while loading
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 4.5.h,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              if (borderColor == Colors.transparent)
                BoxShadow(
                  color: bgColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          alignment: Alignment.center,
          child:
              isLoading
                  ? SizedBox(
                    height: 18.sp,
                    width: 18.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                  : Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
        ),
      ),
    );
  }
}
