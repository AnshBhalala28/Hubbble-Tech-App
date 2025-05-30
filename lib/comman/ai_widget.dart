//
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wavee/comman/const.dart';
// import 'package:wavee/comman/video_player.dart';
//
// import '../Screen/open_ai_chatbot/view/open_ai_screen.dart';
// import 'colors.dart';
//
// class AIReplyWidget extends StatefulWidget {
//   final String aiReply;
//
//   const AIReplyWidget({super.key, required this.aiReply});
//
//   @override
//   State<AIReplyWidget> createState() => _AIReplyWidgetState();
// }
//
// class _AIReplyWidgetState extends State<AIReplyWidget> {
//   bool _isExpanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     const int charLimit = 300;
//
//     final mediaUrlRegex =
//     RegExp(r'(https?:\/\/[^\s]+(?:\.jpg|\.jpeg|\.png|\.mp4|\.jfif))');
//     final unwantedLineRegex =
//     RegExp(r'^(Tags:|Type:|🖼|https?:\/\/)', caseSensitive: false);
//
//     // Extract media URLs
//     final List<String> mediaUrls = mediaUrlRegex
//         .allMatches(widget.aiReply)
//         .map((match) => match.group(0)!)
//         .toList();
//
//     // Clean text lines by removing media URLs & unwanted lines like Tags, Type, etc.
//     List<String> lines = widget.aiReply.split('\n');
//     List<String> cleanedLines = lines.where((line) {
//       return !mediaUrlRegex.hasMatch(line) &&
//           !unwantedLineRegex.hasMatch(line.trim());
//     }).toList();
//
//     String cleanedText = cleanedLines.join('\n');
//     final bool shouldTrim = cleanedText.length > charLimit;
//     final String visibleText = shouldTrim && !_isExpanded
//         ? cleanedText.substring(0, charLimit) + "..."
//         : cleanedText;
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
//       padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
//       width: 70.w,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.grey[300],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TEXT
//           Text(
//             visibleText,
//             style: TextStyle(
//               fontSize: 16.sp,
//               color: Colors.black,
//               fontWeight: FontWeight.normal,
//               fontFamily: AppConstants.manrope,
//             ),
//           ),
//
//           /// MEDIA (only when expanded)
//           if (_isExpanded && mediaUrls.isNotEmpty) ...[
//             SizedBox(height: 2.h),
//             Text(
//               "📷 Posts",
//               style: TextStyle(
//                 fontSize: 17.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//                 fontFamily: AppConstants.manrope,
//               ),
//             ),
//             ...mediaUrls.map((url) {
//               String type = url.endsWith('.mp4') ? 'video' : 'image';
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 1.h),
//                   if (type == 'image')
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.network(
//                         url,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Center(child: CircularProgressIndicator());
//                         },
//                       ),
//                     )
//                   else if (type == 'video')
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: AiVideoPlayerWidget(videoUrl: url),
//                     ),
//                 ],
//               );
//             }).toList(),
//           ],
//
//           /// READ MORE / LESS
//           if (shouldTrim)
//             Row(
//               children: [
//                 Spacer(),
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isExpanded = !_isExpanded;
//                     });
//                   },
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 0.5.h),
//                     child: Text(
//                       _isExpanded ? "Read less" : "Read more",
//                       style: TextStyle(
//                         color: AppColors.maincolor,
//                         fontSize: 15.5.sp,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: AppConstants.manrope,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }
