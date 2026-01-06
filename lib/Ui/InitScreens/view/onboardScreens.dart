// import 'dart:ui';
//
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wavee/Ui/Authentication/View/loginscreen.dart';
// import 'package:wavee/Utils/const.dart';
//
// // TODO: Ensure AppConstants.manrope is available in your Utils/const.dart
//
// class OnboardingScreens extends StatefulWidget {
//   const OnboardingScreens({super.key});
//
//   @override
//   State<OnboardingScreens> createState() => _OnboardingScreensState();
// }
//
// class _OnboardingScreensState extends State<OnboardingScreens>
//     with SingleTickerProviderStateMixin {
//   final PageController _pageController = PageController();
//   late AnimationController _progressController;
//   int _currentPage = 0;
//
//   // Exact Gold Color extracted from image
//   final Color _goldColor = const Color(0xFFD5C597);
//
//   // --- DATA ---
//   final List<SlideData> _slides = [
//     SlideData(
//       imagePath: 'assets/onboardImages/onboard-one.jpg',
//       title: 'London Living Redefined',
//       subtitle: 'Luxury services for modern city life',
//       icon: Icons.auto_awesome_outlined, // Sparkle icon
//     ),
//     SlideData(
//       imagePath: 'assets/onboardImages/onboard-two.jpg',
//       title: '24/7 Concierge',
//       subtitle: 'Dedicated service, whenever you need it',
//       icon: Icons.notifications_none_rounded, // Bell icon
//     ),
//     SlideData(
//       imagePath: 'assets/onboardImages/onboard-three.jpg',
//       title: 'Knightsbridge Lifestyle',
//       subtitle: 'World-class shopping at your door',
//       icon: Icons.location_on_outlined, // Pin icon
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _progressController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 4),
//     );
//
//     _progressController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _goToNextPage();
//       }
//     });
//
//     _progressController.forward();
//   }
//
//   void _goToNextPage() {
//     if (_currentPage < _slides.length - 1) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _pageController.animateToPage(
//         0,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _progressController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   void _onPageChanged(int index) {
//     setState(() {
//       _currentPage = index;
//     });
//     _progressController.reset();
//     _progressController.forward();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Set status bar text to light (white)
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTap: _goToNextPage,
//         behavior: HitTestBehavior.translucent,
//         child: Stack(
//           children: [
//             // 1. BACKGROUND IMAGE
//             PageView.builder(
//               controller: _pageController,
//               onPageChanged: _onPageChanged,
//               itemCount: _slides.length,
//               physics: const ClampingScrollPhysics(),
//               itemBuilder: (context, index) {
//                 return Image.asset(
//                   _slides[index].imagePath,
//                   fit: BoxFit.cover,
//                   height: double.infinity,
//                   width: double.infinity,
//                   errorBuilder:
//                       (context, error, stackTrace) =>
//                           Container(color: const Color(0xFF1A1A1A)),
//                 );
//               },
//             ),
//
//             // 2. GRADIENT OVERLAY (Readability)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.0),
//                       Colors.black.withOpacity(0.2),
//                       Colors.black.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // 3. BOTTOM UI CONTENT
//             Positioned(
//               left: 4.w,
//               right: 4.w,
//               bottom: 5.h, // Bottom safe margin
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // --- GLASS CARD ---
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(20),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                       child: Container(
//                         width: double.infinity,
//                         // Padding inside the glass card
//                         padding: EdgeInsets.symmetric(
//                           vertical: 2.h,
//                           horizontal: 5.w,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF252525).withOpacity(0.40),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.12),
//                             width: 1.0,
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // ROW: ICON + TEXT
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Icon Circle
//                                 Container(
//                                   width: 11.w,
//                                   height: 11.w,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.1),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   alignment: Alignment.center,
//                                   child: Icon(
//                                     _slides[_currentPage].icon,
//                                     color: Colors.white.withOpacity(0.9),
//                                     // Icon is white/light
//                                     size: 18.sp,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//
//                                 // Text Column
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       AnimatedSwitcher(
//                                         duration: const Duration(
//                                           milliseconds: 300,
//                                         ),
//                                         child: Text(
//                                           _slides[_currentPage].title,
//                                           key: ValueKey(
//                                             _slides[_currentPage].title,
//                                           ),
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 15.5.sp,
//                                             fontWeight: FontWeight.w700,
//                                             letterSpacing: 0.3,
//                                             fontFamily:
//                                                 AppConstants.manropeBold,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: 0.3.h),
//                                       AnimatedSwitcher(
//                                         duration: const Duration(
//                                           milliseconds: 300,
//                                         ),
//                                         child: Text(
//                                           _slides[_currentPage].subtitle,
//                                           key: ValueKey(
//                                             _slides[_currentPage].subtitle +
//                                                 "s",
//                                           ),
//                                           style: TextStyle(
//                                             color: Colors.white.withOpacity(
//                                               0.7,
//                                             ),
//                                             fontSize: 14.5.sp,
//                                             height: 1.3,
//                                             fontWeight: FontWeight.w400,
//                                             fontFamily:
//                                                 AppConstants.manropeBold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 8.h),
//                   Center(
//                     child: SizedBox(
//                       width: 28.w,
//                       child: AnimatedBuilder(
//                         animation: _progressController,
//                         builder: (context, child) {
//                           return Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(_slides.length, (index) {
//                               return Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 2.0,
//                                   ),
//                                   child: LayoutBuilder(
//                                     builder: (context, constraints) {
//                                       double fillPercent = 0.0;
//                                       if (index < _currentPage) {
//                                         fillPercent = 1.0;
//                                       } else if (index == _currentPage) {
//                                         fillPercent = _progressController.value;
//                                       }
//                                       return Stack(
//                                         children: [
//                                           // Track (Inactive)
//                                           Container(
//                                             height: 0.3.h,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(
//                                                 0.3,
//                                               ),
//                                               borderRadius:
//                                                   BorderRadius.circular(2),
//                                             ),
//                                           ),
//                                           // Fill (Active)
//                                           Container(
//                                             height: 0.3.h,
//                                             width:
//                                                 constraints.maxWidth *
//                                                 fillPercent,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(2),
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               );
//                             }),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 5.h),
//
//                   SizedBox(
//                     width: double.infinity,
//                     height: 6.h,
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         Get.offAll(
//                           () => const LoginScreen(),
//                           transition: Transition.fade,
//                         );
//                       },
//                       icon: const Icon(
//                         Icons.email_outlined,
//                         color: Color(0xFF2C2C2C),
//                         size: 20,
//                       ),
//                       label: Text(
//                         "Continue with Email",
//                         style: TextStyle(
//                           color: const Color(0xFF2C2C2C),
//                           fontSize: 15.5.sp,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: AppConstants.manrope,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _goldColor,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   SizedBox(height: 2.h),
//
//                   // --- TERMS & PRIVACY ---
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                     child: RichText(
//                       textAlign: TextAlign.center,
//                       text: TextSpan(
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.5),
//                           fontSize: 13.5.sp,
//                           height: 1.5,
//                           fontFamily: AppConstants.manrope,
//                         ),
//                         children: [
//                           const TextSpan(
//                             text: "By continuing, you accept Wavee's ",
//                           ),
//                           TextSpan(
//                             text: "Terms of Service",
//                             style: TextStyle(
//                               color: _goldColor,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: AppConstants.manrope,
//                             ),
//                             recognizer: TapGestureRecognizer()..onTap = () {},
//                           ),
//                           const TextSpan(text: "\nand acknowledge our "),
//                           TextSpan(
//                             text: "Privacy Policy",
//                             style: TextStyle(
//                               color: _goldColor,
//                               fontWeight: FontWeight.w600,
//                               fontFamily: AppConstants.manrope,
//                             ),
//                             recognizer: TapGestureRecognizer()..onTap = () {},
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 3.h),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Data Model
// class SlideData {
//   final String imagePath;
//   final String title;
//   final String subtitle;
//   final IconData icon;
//
//   SlideData({
//     required this.imagePath,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//   });
// }
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Ui/Authentication/View/loginscreen.dart';
import 'package:wavee/Utils/const.dart';
import 'package:wavee/Utils/inAppWebView.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _progressController;
  int _currentPage = 0;

  // ક્લિકને ફાસ્ટ બનાવવા માટે Recognizers
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  final Color _goldColor = const Color(0xFFD5C597);
  String supportURL = "https://wavee.ai/legal/terms-of-service";

  final List<SlideData> _slides = [
    SlideData(
      imagePath: 'assets/onboardImages/onboard-one.jpg',
      title: 'London Living Redefined',
      subtitle: 'Luxury services for modern city life',
      icon: Icons.auto_awesome_outlined,
    ),
    SlideData(
      imagePath: 'assets/onboardImages/onboard-two.jpg',
      title: '24/7 Concierge',
      subtitle: 'Dedicated service, whenever you need it',
      icon: Icons.notifications_none_rounded,
    ),
    SlideData(
      imagePath: 'assets/onboardImages/onboard-three.jpg',
      title: 'Knightsbridge Lifestyle',
      subtitle: 'World-class shopping at your door',
      icon: Icons.location_on_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Tap logic initialization
    _termsRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            Get.to(
              () => WebViewScreen(url: supportURL),
              transition: Transition.rightToLeft,
            );
          };
    _privacyRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            Get.to(
              () =>
                  WebViewScreen(url: "https://wavee.ai/legal/privacy-security"),
              transition: Transition.rightToLeft,
            );
          };

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNextPage();
      }
    });

    _progressController.forward();
  }

  void _goToNextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _progressController.reset();
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. BACKGROUND LAYER (PageView & Gesture for Slide)
          GestureDetector(
            onTap: _goToNextPage,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _slides.length,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return Image.asset(
                  _slides[index].imagePath,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Container(color: const Color(0xFF1A1A1A)),
                );
              },
            ),
          ),

          // 2. GRADIENT OVERLAY
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. UI CONTENT LAYER (બટન્સ અને લિંક્સ હવે સૌથી ઉપર છે)
          Positioned(
            left: 4.w,
            right: 4.w,
            bottom: 5.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // GLASS CARD
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                        horizontal: 5.w,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525).withOpacity(0.40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 11.w,
                            height: 11.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _slides[_currentPage].icon,
                              color: Colors.white.withOpacity(0.9),
                              size: 18.sp,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _slides[_currentPage].title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.5.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    fontFamily:
                                        AppConstants
                                            .manropeBold, // Original Font
                                  ),
                                ),
                                SizedBox(height: 0.3.h),
                                Text(
                                  _slides[_currentPage].subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14.5.sp,
                                    height: 1.3,
                                    fontWeight: FontWeight.w400,
                                    fontFamily:
                                        AppConstants
                                            .manropeBold, // Original Font
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

                SizedBox(height: 8.h),

                // PROGRESS BAR
                Center(
                  child: SizedBox(
                    width: 28.w,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_slides.length, (index) {
                            double fillPercent =
                                (index < _currentPage)
                                    ? 1.0
                                    : (index == _currentPage
                                        ? _progressController.value
                                        : 0.0);
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0,
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 0.3.h,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: fillPercent,
                                      child: Container(
                                        height: 0.3.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: 5.h),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton.icon(
                    onPressed:
                        () => Get.offAll(
                          () => const LoginScreen(),
                          transition: Transition.fade,
                        ),
                    icon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF2C2C2C),
                      size: 20,
                    ),
                    label: Text(
                      "Continue with Email",
                      style: TextStyle(
                        color: const Color(0xFF2C2C2C),
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppConstants.manrope, // Original Font
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // TERMS & PRIVACY (Fixed Tap)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13.5.sp,
                        height: 1.5,
                        fontFamily: AppConstants.manrope, // Original Font
                      ),
                      children: [
                        const TextSpan(
                          text: "By continuing, you accept Wavee's ",
                        ),
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(
                            color: _goldColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
                          recognizer: _termsRecognizer, // Fast Navigation
                        ),
                        const TextSpan(text: "\nand acknowledge our "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                            color: _goldColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manrope,
                          ),
                          recognizer: _privacyRecognizer, // Fast Navigation
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SlideData {
  final String imagePath, title, subtitle;
  final IconData icon;

  SlideData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
