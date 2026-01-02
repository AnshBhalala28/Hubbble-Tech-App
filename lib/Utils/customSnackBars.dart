import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wavee/Services/themeServices.dart';

void showSnackBar({
  required BuildContext context,
  void Function()? ontap,
  required String title,
  required String message,
  Color? backgoundColor,
  Color? ColorText,
  Color? IconColor,
  IconData? IconName,
}) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder:
        (context) => _TopSnackBar(
          onDismiss: () {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          },
          ontap: ontap,
          title: title,
          message: message,
          backgoundColor: backgoundColor,
          ColorText: ColorText,
          IconColor: IconColor,
          IconName: IconName,
        ),
  );

  Overlay.of(context).insert(overlayEntry);
}

class _TopSnackBar extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? ontap;
  final String title;
  final String message;
  final Color? backgoundColor;
  final Color? ColorText;
  final Color? IconColor;
  final IconData? IconName;

  const _TopSnackBar({
    Key? key,
    required this.onDismiss,
    this.ontap,
    required this.title,
    required this.message,
    this.backgoundColor,
    this.ColorText,
    this.IconColor,
    this.IconName,
  }) : super(key: key);

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (mounted) {
      await _controller.reverse();
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME LOGIC ---
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDark;

    // Define your dynamic accent colors
    final Color accentColor =
        isDark
            ? const Color(0xFFCFB583) // Gold/Beige for Dark Mode
            : const Color(0xFF4C5588); // Blue for Light Mode

    // Determine final colors (Argument overrides Theme, Theme overrides Default)
    final Color finalBackgroundColor = widget.backgoundColor ?? accentColor;
    final Color finalTextColor = widget.ColorText ?? Colors.white;
    final Color finalIconColor = widget.IconColor ?? Colors.white;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      right: 10,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: finalBackgroundColor, // Uses dynamic color
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    // Updated from withValues for broader compatibility
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: InkWell(
                onTap: () {
                  widget.ontap?.call();
                  _dismiss();
                },
                child: Row(
                  children: [
                    Icon(widget.IconName ?? Icons.error, color: finalIconColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: finalTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: finalTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
