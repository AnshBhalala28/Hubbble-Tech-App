// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
// import 'package:wavee/comman/const.dart';
// import 'package:wavee/comman/custom_batan.dart';
//
// import '../../../comman/colors.dart';
//
// class ThankYouPage extends StatefulWidget {
//   const ThankYouPage({super.key});
//
//   @override
//   State<ThankYouPage> createState() => _ThankYouPageState();
// }
//
// class _ThankYouPageState extends State<ThankYouPage> {
//   String? orderNumber;
//   String? collectionCode;
//
//   @override
//   void initState() {
//     super.initState();
//     orderNumber =
//         "#ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
//     collectionCode = Random().nextInt(9999).toString().padLeft(4, '0');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: PopScope(
//         canPop: false,
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 6.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Lottie.asset(
//                   'assets/images/sucess_lotie1.json',
//                   height: 22.h,
//                   repeat: false,
//                 ),
//                 SizedBox(height: 3.h),
//                 Text(
//                   "Order Placed Successfully!",
//                   style: TextStyle(
//                     fontSize: 19.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   "Order Number: $orderNumber",
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w600,
//                     fontFamily: AppConstants.manrope,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 2.5.h),
//                 Text(
//                   "Thanks for your order! It’s waiting for approval. We’ll notify you as soon as the business responds.",
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     color: Colors.grey.shade700,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 6.h),
//                 batan(
//                   title: "Continue Shopping",
//                   route: () {
//                     Get.to(CommunityScreen());
//                   },
//                   color: AppColors.maincolor,
//                   fontcolor: Colors.white,
//                   height: 5.5.h,
//                   fontsize: 17.sp,
//                   width: double.infinity,
//                   radius: 12.0,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../Community Screen/Community Screen/view/community_screen.dart';

class ThankYouPage extends StatefulWidget {
  const ThankYouPage({super.key});

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage>
    with SingleTickerProviderStateMixin {
  String? orderNumber;
  String? collectionCode;

  late AnimationController _controller;
  late Animation<double> _drawAnimation;

  @override
  void initState() {
    super.initState();
    orderNumber =
        "#ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    collectionCode = Random().nextInt(9999).toString().padLeft(6, '0');

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _drawAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Custom Paint Checkmark
  Widget _buildSuccessCircle() {
    return AnimatedBuilder(
      animation: _drawAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(18.h, 18.h),
          painter: _CheckPainter(progress: _drawAnimation.value),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,

      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSuccessCircle(),
                  SizedBox(height: 3.h),

                  // Title
                  Text(
                    "Order Placed Successfully!",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: AppConstants.manropeBold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 3.h),
                  Column(
                    children: [
                      Text(
                        "Order Number: $orderNumber",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: AppConstants.manropeBold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Collection Token: $collectionCode",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.maincolor,
                          fontFamily: AppConstants.manropeBold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Button
                  batan(
                    title: "Continue Shopping",
                    route: () {
                      Get.offAll(CommunityScreen());
                    },
                    color: Colors.black,
                    fontcolor: Colors.white,
                    height: 5.5.h,
                    fontsize: 17.sp,
                    width: double.infinity,
                    radius: 12.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;

  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black
          ..strokeWidth = 5;

    final Paint checkPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.black
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round;

    // Draw circle
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.2, circlePaint);

    // Draw animated check mark
    Path path = Path();
    path.moveTo(size.width * 0.28, size.height * 0.55);
    path.lineTo(size.width * 0.45, size.height * 0.72);
    path.lineTo(size.width * 0.75, size.height * 0.35);

    PathMetrics pm = path.computeMetrics();
    for (PathMetric metric in pm) {
      Path extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
