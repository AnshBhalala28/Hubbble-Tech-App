// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:video_player/video_player.dart';
// import 'package:wavee/Ui/OpenAiChatbot/modal/chat_bot_data_modal.dart';
// import 'package:wavee/Ui/OpenAiChatbot/modal/send_data_model.dart';
//
// import '../../../Utils/checkInternetConnection.dart';
// import '../../../Utils/colors.dart';
// import '../../../Utils/const.dart';
// import '../../../Utils/customInputDecoration.dart';
// import '../../../Utils/errorDialog.dart';
// import '../../../Utils/loader.dart';
// import '../provider/openAiProvider.dart';
//
// class ChatBotScreen extends StatefulWidget {
//   const ChatBotScreen({super.key});
//
//   @override
//   State<ChatBotScreen> createState() => _ChatBotScreenState();
// }
//
// class _ChatBotScreenState extends State<ChatBotScreen>
//     with WidgetsBindingObserver {
//   final GlobalKey<ScaffoldState> scaffoldChatbot = GlobalKey<ScaffoldState>();
//   final TextEditingController _msg = TextEditingController();
//   bool isLoading = false;
//   bool isSending = false;
//   String AppLat = '';
//   String AppLon = '';
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     setState(() {
//       isLoading = true;
//     });
//
//     _getCurrentLocation();
//
//     sendQueryApi();
//     chatBotReceiveDataApi();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.detached ||
//         state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       clearChatBotData();
//       chatBotReceiveDataApi();
//     } else {}
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         title: Row(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 Get.back();
//                 clearChatBotData();
//               },
//               child: Container(
//                 padding: EdgeInsets.all(3.w),
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.maincolor,
//                 ),
//                 child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
//               ),
//             ),
//             SizedBox(width: 3.w),
//             Image.asset('assets/images/waveeLogoShort.png', height: 12.w),
//             SizedBox(width: 3.w),
//             Text(
//               "Wavee AI",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18.sp,
//                 fontFamily: AppConstants.manrope,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: PopScope(
//         canPop: false,
//         child: Column(
//           children: [
//             Expanded(
//               child:
//                   isLoading
//                       ? Center(child: Loader())
//                       : chatbotDataModal?.conversations?.isEmpty ?? true
//                       ? Center(
//                         child: Text(
//                           'What can i help you?',
//                           style: TextStyle(
//                             fontSize: 18.sp,
//                             color: Colors.black,
//                             fontFamily: AppConstants.manrope,
//                           ),
//                         ),
//                       )
//                       : ListView.builder(
//                         controller: _scrollController,
//                         padding: EdgeInsets.symmetric(vertical: 1.h),
//                         itemCount: chatbotDataModal!.conversations!.length,
//                         itemBuilder: (context, index) {
//                           final message =
//                               chatbotDataModal!.conversations![index];
//
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (message.userMessage != null)
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Align(
//                                           alignment: Alignment.topRight,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.end,
//                                             children: [
//                                               Container(
//                                                 margin: EdgeInsets.symmetric(
//                                                   horizontal: 1.h,
//                                                   vertical: 1.5.w,
//                                                 ),
//                                                 alignment: Alignment.centerLeft,
//                                                 padding: EdgeInsets.symmetric(
//                                                   horizontal: 1.h,
//                                                   vertical: 3.w,
//                                                 ),
//                                                 width: 65.w,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius:
//                                                       BorderRadius.circular(12),
//                                                   color: Colors.blueAccent,
//                                                 ),
//                                                 child: Text(
//                                                   message.userMessage!,
//                                                   style: TextStyle(
//                                                     fontSize: 16.sp,
//                                                     color: Colors.white,
//                                                     fontWeight:
//                                                         FontWeight.normal,
//                                                     letterSpacing: 1.5,
//                                                     fontFamily:
//                                                         AppConstants.manrope,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               if (message.aiReply != null)
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Align(
//                                       alignment: Alignment.topLeft,
//                                       child: AIReplyWidget(
//                                         aiReply: message.aiReply!,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                             ],
//                           );
//                         },
//                       ),
//             ),
//             SafeArea(
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//                 color: Colors.white,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _msg,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontFamily: AppConstants.manrope,
//                         ),
//                         maxLength: 500,
//                         // Bound input length
//                         inputFormatters: [
//                           LengthLimitingTextInputFormatter(500),
//                         ],
//                         decoration: inputDecoration(
//                           hintText: "Type a message...",
//                         ).copyWith(counterText: ""),
//                       ),
//                     ),
//                     SizedBox(width: 2.w),
//                     GestureDetector(
//                       onTap: () {
//                         String sanitizedMsg = _msg.text.trim();
//
//                         if (sanitizedMsg.isEmpty) {
//                           Fluttertoast.showToast(
//                             msg: "Please Ask Something",
//                             backgroundColor: Colors.white,
//                             textColor: Colors.black,
//                           );
//                           return;
//                         }
//
//                         // Additional guardrails for AI/LLM forwarding
//                         if (sanitizedMsg.length > 500) {
//                           Fluttertoast.showToast(
//                             msg: "Message too long (max 500 characters)",
//                             backgroundColor: Colors.red,
//                             textColor: Colors.white,
//                           );
//                           return;
//                         }
//
//                         // Simple sanitization to prevent common injection/jailbreak attempts
//                         sanitizedMsg =
//                             sanitizedMsg
//                                 .replaceAll(
//                                   RegExp(r'[<>/{}\[\]]'),
//                                   '',
//                                 ) // Remove common structural chars
//                                 .trim();
//
//                         if (sanitizedMsg.isEmpty) {
//                           Fluttertoast.showToast(
//                             msg: "Invalid message content",
//                             backgroundColor: Colors.white,
//                             textColor: Colors.black,
//                           );
//                           return;
//                         }
//
//                         FocusScope.of(context).unfocus();
//                         sendQueryApi(sanitizedText: sanitizedMsg);
//                       },
//                       child: Container(
//                         height: 12.w,
//                         width: 12.w,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColors.maincolor),
//                           shape: BoxShape.circle,
//                           color: Colors.white,
//                         ),
//                         child: const Icon(Icons.send, color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton:
//           isSending ? Container(child: Center(child: Loader())) : null,
//     );
//   }
//
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() {
//         isLoading = false;
//         isSending = false;
//       });
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() {
//           isLoading = false;
//           isSending = false;
//         });
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       setState(() {
//         isLoading = false;
//         isSending = false;
//       });
//       return;
//     }
//
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     if (mounted) {
//       setState(() {
//         AppLat = position.latitude.toString();
//         AppLon = position.longitude.toString();
//       });
//     }
//   }
//
//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.bounceIn,
//         );
//       }
//     });
//   }
//
//   sendQueryApi({String? sanitizedText}) {
//     String finalMsg = sanitizedText ?? _msg.text.trim();
//     if (finalMsg.isEmpty) {
//       return;
//     }
//     setState(() {
//       isSending = true;
//     });
//     Map<String, String> data = {
//       "message": finalMsg,
//       "user_id": loginModel?.data?.user?.id.toString() ?? '',
//       "longitude": AppLon ?? "0.0",
//       "latitude": AppLat ?? "0.0",
//     };
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         ChatBotAiProvider().chatbotDataApi(data).then((response) async {
//           sendChatModal = SendChatModal.fromJson(json.decode(response.body));
//           if (response.statusCode == 200) {
//             setState(() {
//               isSending = false;
//               isLoading = false;
//             });
//
//             chatBotReceiveDataApi();
//             _msg.clear();
//             _scrollToBottom();
//           } else {
//             setState(() {
//               isSending = false;
//               isLoading = false;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isSending = false;
//           isLoading = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   clearChatBotData() {
//     Map<String, String> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? '',
//     };
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         ChatBotAiProvider().clearChatBotData(data).then((response) async {
//           if (response.statusCode == 200) {
//             if (mounted) {
//               setState(() {
//                 isLoading = false;
//               });
//             }
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   chatBotReceiveDataApi() {
//     checkInternet().then((internet) async {
//       if (internet) {
//         ChatBotAiProvider()
//             .chatBotReceiveData(loginModel?.data?.user?.id.toString() ?? '')
//             .then((response) async {
//               chatbotDataModal = ChatbotDataModal.fromJson(
//                 json.decode(response.body),
//               );
//               if (response.statusCode == 200) {
//                 if (mounted) {
//                   setState(() {
//                     isLoading = false;
//                   });
//                 }
//
//                 _scrollToBottom();
//               } else if (response.statusCode == 422) {
//                 setState(() {
//                   isLoading = false;
//                 });
//               } else {
//                 EasyLoading.showError("Internal Server Error");
//               }
//             });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
// }
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
//     final mediaUrlRegex = RegExp(
//       r'(https?:\/\/[^\s]+(?:\.jpg|\.jpeg|\.png|\.mp4|\.jfif))',
//     );
//     final List<String> mediaUrls =
//         mediaUrlRegex
//             .allMatches(widget.aiReply)
//             .map((match) => match.group(0)!)
//             .toList();
//
//     List<String> lines = widget.aiReply.split('\n');
//
//     List<String> cleanedLines =
//         lines.where((line) => !mediaUrlRegex.hasMatch(line)).toList();
//
//     String cleanedText = cleanedLines.join('\n');
//     final bool shouldTrim = cleanedText.length > charLimit;
//     final String visibleText =
//         shouldTrim && !_isExpanded
//             ? "${cleanedText.substring(0, charLimit)}..."
//             : cleanedText;
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
//       padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
//       width: 70.w,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.grey[200],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             visibleText,
//             style: TextStyle(
//               fontSize: 16.sp,
//               color: Colors.black,
//               fontWeight: FontWeight.normal,
//               fontFamily: AppConstants.manrope,
//             ),
//           ),
//           if (_isExpanded && mediaUrls.isNotEmpty) ...[
//             ...mediaUrls.map((url) {
//               String type = url.endsWith('.mp4') ? 'video' : 'image';
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 1.h),
//                   Text(
//                     "Type: ${type.capitalizeFirst}",
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   SizedBox(height: 0.5.h),
//                   if (type == 'image' || type == 'jfif  ')
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.network(
//                         url,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return const Center(
//                             child: CircularProgressIndicator(
//                               color: AppColors.maincolor,
//                             ),
//                           );
//                         },
//                       ),
//                     )
//                   else if (type == 'video')
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: VideoPlayerWidget(videoUrl: url),
//                     ),
//                 ],
//               );
//             }),
//           ],
//           if (shouldTrim)
//             Row(
//               children: [
//                 const Spacer(),
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
//
// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;
//
//   const VideoPlayerWidget({super.key, required this.videoUrl});
//
//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }
//
// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _controller.value.isInitialized
//         ? AspectRatio(
//           aspectRatio: _controller.value.aspectRatio,
//           child: Stack(
//             children: [
//               VideoPlayer(_controller),
//               Positioned(
//                 bottom: 10,
//                 left: 10,
//                 child: IconButton(
//                   icon: Icon(
//                     _controller.value.isPlaying
//                         ? Icons.pause
//                         : Icons.play_arrow,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _controller.value.isPlaying
//                           ? _controller.pause()
//                           : _controller.play();
//                     });
//                   },
//                 ),
//               ),
//             ],
//           ),
//         )
//         : const Center(
//           child: CircularProgressIndicator(color: AppColors.maincolor),
//         );
//   }
// }
