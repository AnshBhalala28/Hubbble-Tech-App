import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // ૧. પહેલું મોટું તરંગ (Outer Ripple)
            _buildRipple(
              scale: 1.0 + (_controller.value * 1.5),
              opacity: (1 - _controller.value),
            ),

            // ૨. બીજું નાનું તરંગ (Inner Ripple - થોડું મોડું શરૂ થાય તેવું લાગે)
            _buildRipple(
              scale: 1.0 + (((_controller.value + 0.5) % 1.0) * 1.2),
              opacity: (1 - ((_controller.value + 0.5) % 1.0)) * 0.5,
            ),

            // ૩. મુખ્ય ગ્રીન ડોટ (સ્થિર અને Glow સાથે)
            Container(
              height: 2.8.w,
              width: 2.8.w,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // રિપલ વિજેટ બનાવવા માટેનું હેલ્પર ફંક્શન
  Widget _buildRipple({required double scale, required double opacity}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        height: 2.5.w,
        width: 2.5.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00C853).withOpacity(opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}
