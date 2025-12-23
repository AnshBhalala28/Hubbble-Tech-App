import 'package:flutter/material.dart';

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

    // 1. Setup the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600), // Smooth entry duration
      vsync: this,
    );

    // 2. Define the Slide Animation (From top -1.0 to normal 0.0)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // Makes it slide in smoothly
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // 3. Define Fade Animation
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // 4. Start Animation and set Auto-Dismiss Timer
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      _dismiss();
    });
  }

  // Helper to reverse animation before removing from Overlay
  Future<void> _dismiss() async {
    if (mounted) {
      await _controller.reverse(); // Wait for exit animation
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
                color: widget.backgoundColor ?? Colors.blue,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: InkWell(
                onTap: () {
                  widget.ontap?.call();
                  _dismiss(); // Animate out on tap
                },
                child: Row(
                  children: [
                    Icon(
                      widget.IconName ?? Icons.error,
                      color: widget.IconColor ?? Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: widget.ColorText ?? Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.ColorText ?? Colors.white,
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
