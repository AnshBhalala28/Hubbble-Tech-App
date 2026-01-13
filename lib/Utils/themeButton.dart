// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wavee/Services/themeServices.dart';
//
// class ThemeToggleButton extends StatelessWidget {
//   const ThemeToggleButton({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = context.watch<ThemeController>();
//
//     return GestureDetector(
//       onTap: () => theme.toggleTheme(),
//       // 1. Define outer size using Sizer
//       child: Container(
//         margin: EdgeInsets.only(top: 1.5.h, right: 1.w),
//         height: 4.h, // e.g., 5% of screen height
//         width: 18.w, // e.g., 18% of screen width
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             // 2. Calculate dynamic sizes based on the actual box size
//             final height = constraints.maxHeight;
//             final width = constraints.maxWidth;
//
//             // Padding around the knob (10% of height)
//             final paddingGap = height * 0.10;
//
//             // Knob size is height minus top/bottom padding
//             final knobSize = height - (paddingGap * 2);
//
//             // Icon size relative to the knob (55% of knob size)
//             final iconSize = knobSize * 0.65;
//
//             return Container(
//               padding: EdgeInsets.all(paddingGap),
//               decoration: BoxDecoration(
//                 color: theme.isDark ? const Color(0xFF2B2B2B) : Colors.white,
//                 borderRadius: BorderRadius.circular(100),
//                 // High number for pill shape
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.25),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // --- Background Icons ---
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: width * 0.05),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Icon(
//                           Icons.wb_sunny,
//                           size: iconSize,
//                           color:
//                               theme.isDark ? Colors.grey : Colors.transparent,
//                         ),
//                         Icon(
//                           Icons.nightlight_outlined,
//                           size: iconSize,
//                           color:
//                               theme.isDark
//                                   ? Colors.transparent
//                                   : Colors.black54,
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // --- Sliding Knob ---
//                   AnimatedAlign(
//                     duration: const Duration(milliseconds: 250),
//                     curve: Curves.easeInOut,
//                     // Alignment moves from -1.0 (left) to 1.0 (right)
//                     alignment:
//                         theme.isDark
//                             ? Alignment.centerRight
//                             : Alignment.centerLeft,
//                     child: Container(
//                       height: knobSize,
//                       width: knobSize,
//                       decoration: BoxDecoration(
//                         color:
//                             theme.isDark
//                                 ? const Color(0xFF4B5D8A)
//                                 : const Color(0xFFC5B388),
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         theme.isDark ? Icons.nightlight_round : Icons.wb_sunny,
//                         size: iconSize, // Dynamic icon size
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // AA IMPORT JARURI CHE
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Utils/const.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return GestureDetector(
      onTap: () => theme.toggleTheme(),
      child: Container(
        margin: EdgeInsets.only(top: 1.5.h, right: 1.w),
        height: 4.h,
        width: 18.w,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final paddingGap = height * 0.10;
            final knobSize = height - (paddingGap * 2);
            final iconSize = knobSize * 0.65;

            return Container(
              padding: EdgeInsets.all(paddingGap),
              decoration: BoxDecoration(
                color: theme.isDark ? const Color(0xFF2B2B2B) : Colors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // --- Background SVG Icons ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SUN BACKGROUND SVG
                        SvgPicture.asset(
                          AppConstants.light,
                          height: iconSize,
                          width: iconSize,
                          colorFilter: ColorFilter.mode(
                            theme.isDark ? Colors.grey : Colors.transparent,
                            BlendMode.srcIn,
                          ),
                        ),
                        // MOON BACKGROUND SVG
                        SvgPicture.asset(
                          AppConstants.dark,
                          height: iconSize,
                          width: iconSize,
                          colorFilter: ColorFilter.mode(
                            theme.isDark ? Colors.transparent : Colors.black54,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment:
                        theme.isDark
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      height: knobSize,
                      width: knobSize,
                      decoration: BoxDecoration(
                        color:
                            theme.isDark
                                ? const Color(0xFF4B5D8A)
                                : const Color(0xFFC5B388),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          theme.isDark ? AppConstants.dark : AppConstants.light,
                          height: iconSize,
                          width: iconSize,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
