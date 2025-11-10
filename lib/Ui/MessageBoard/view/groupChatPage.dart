// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../../comman/check_inernet_connecty.dart';
// import '../../../comman/colors.dart';
// import '../../../comman/const.dart';
// import '../../../comman/error_dialog.dart';
// import '../../../comman/loader.dart';
// import '../../Message_screen/View/videourlscreen.dart';
// import '../Model/GetGroupListModel.dart';
// import '../Model/GetMsgModel.dart';
// import '../Provider/messsage_board_provider.dart';
// import 'GroupProfileScreen.dart';
//
// class GroupChatPage extends StatefulWidget {
//   final String chatname;
//   final String? image;
//   final String groupid;
//   final String type;
//
//   const GroupChatPage({
//     Key? key,
//     required this.chatname,
//     this.image,
//     required this.groupid,
//     required this.type,
//   }) : super(key: key);
//
//   @override
//   _GroupChatPageState createState() => _GroupChatPageState();
// }
//
// class _GroupChatPageState extends State<GroupChatPage> {
//   final TextEditingController _messageController = TextEditingController();
//
//   final ScrollController _scrollController = ScrollController();
//
//   String get currentUserId => loginModel?.data?.user?.id.toString() ?? '';
//
//   String get currentUserImage => loginModel?.data?.user?.profile ?? '';
//
//   String get currentUserName => loginModel?.data?.user?.fullName ?? '';
//
//   final ImagePicker _picker = ImagePicker();
//   File? _pickedFile;
//   int type = 1;
//   bool isSending = false;
//   String loadingMessage = '';
//   bool isLoading = true;
//
//   Timer? _messagePollingTimer;
//   int _lastMessageCount = 0;
//   int _lastMessageId = 0;
//   bool _userScrolling = false;
//   bool _hasNewMessages = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _loadMessages();
//     _setupMessagePolling();
//     _scrollController.addListener(_onScrollChanged);
//   }
//
//   void _onScrollChanged() {
//     if (_scrollController.hasClients) {
//       _userScrolling = true;
//
//       Future.delayed(Duration(seconds: 2), () {
//         _userScrolling = false;
//
//         if (_hasNewMessages && _isAtBottom()) {
//           _scrollToBottom();
//           _hasNewMessages = false;
//         }
//       });
//     }
//   }
//
//   bool _isAtBottom() {
//     if (!_scrollController.hasClients) return true;
//
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll < 10;
//   }
//
//   void _setupMessagePolling() {
//     _messagePollingTimer = Timer.periodic(Duration(seconds: 2), (timer) {
//       _checkForNewMessages();
//     });
//   }
//
//   void _checkForNewMessages() async {
//     checkInternet().then((internet) async {
//       if (internet) {
//         try {
//           var response = await MessageBoardProvider().groupMessageApi(
//             widget.groupid,
//             loginModel?.data?.user?.id.toString(),
//           );
//
//           if (response.statusCode == 200) {
//             var newMsgModel = GetMsgModel.fromJson(response.data);
//
//             int newCount = newMsgModel.data?.length ?? 0;
//             int? latestMsgId =
//                 newMsgModel.data?.isNotEmpty == true
//                     ? newMsgModel.data?.first?.id
//                     : null;
//
//             bool hasNewContent =
//                 newCount > _lastMessageCount ||
//                 (latestMsgId != null && latestMsgId > _lastMessageId);
//
//             if (hasNewContent) {
//               setState(() {
//                 getmsgModel = newMsgModel;
//                 _lastMessageCount = newCount;
//
//                 if (newMsgModel.data?.isNotEmpty == true) {
//                   _lastMessageId = newMsgModel.data!.first.id ?? _lastMessageId;
//                 }
//
//                 _hasNewMessages = true;
//               });
//
//               if (_isAtBottom() && !_userScrolling) {
//                 _scrollToBottom();
//                 _hasNewMessages = false;
//               } else {}
//             }
//           }
//         } catch (e) {}
//       }
//     });
//   }
//
//   void _loadMessages() {
//     setState(() {
//       isLoading = true;
//     });
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         try {
//           var response = await MessageBoardProvider().groupMessageApi(
//             widget.groupid,
//             loginModel?.data?.user?.id.toString(),
//           );
//
//           if (response.statusCode == 200) {
//             var msgModel = GetMsgModel.fromJson(response.data);
//
//             setState(() {
//               getmsgModel = msgModel;
//               _lastMessageCount = msgModel.data?.length ?? 0;
//
//               if (msgModel.data?.isNotEmpty == true) {
//                 _lastMessageId = msgModel.data!.first.id ?? 0;
//               }
//
//               isLoading = false;
//             });
//
//             Future.delayed(Duration(milliseconds: 300), () {
//               _scrollToBottom();
//             });
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         } catch (e) {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   String _formatTime(String dateTimeString) {
//     try {
//       DateTime dateTime = DateTime.parse(dateTimeString);
//       return DateFormat('HH:mm').format(dateTime);
//     } catch (e) {
//       return '';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Get.back(result: 'refresh');
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, size: 30, color: Colors.black),
//             onPressed: () {
//               Get.back(result: 'refresh');
//             },
//           ),
//           title: InkWell(
//             onTap: () {
//               _messagePollingTimer!.cancel();
//               Get.to(
//                 () => GroupProfileScreen(
//                   groupName: widget.chatname,
//                   groupImage: widget.image,
//                   groupid: widget.groupid,
//                 ),
//               );
//             },
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   backgroundImage:
//                       widget.image != null && widget.image!.isNotEmpty
//                           ? NetworkImage(widget.image!)
//                           : NetworkImage(
//                             "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
//                           ),
//                   radius: 20,
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     widget.chatname,
//                     style: TextStyle(
//                       fontFamily: AppConstants.manrope,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16.sp,
//                       color: Colors.black,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           bottom: PreferredSize(
//             preferredSize: Size.fromHeight(1),
//             child: Container(color: Colors.grey.shade300, height: 1),
//           ),
//         ),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Expanded(
//                   child:
//                       isLoading
//                           ? Center(child: CircularProgressIndicator())
//                           : getmsgModel?.data?.isEmpty ?? true
//                           ? Center(child: Text("No messages yet!"))
//                           : ListView.builder(
//                             controller: _scrollController,
//                             padding: EdgeInsets.all(5),
//                             itemCount: getmsgModel?.data?.length ?? 0,
//                             reverse: true,
//                             itemBuilder: (context, index) {
//                               final message = getmsgModel?.data?[index];
//                               String loggedInUserId =
//                                   loginModel?.data?.user?.id.toString() ?? "";
//                               String senderId =
//                                   message?.sender?.id?.toString() ?? "";
//                               final bool isCurrentUser =
//                                   senderId == loggedInUserId;
//
//
//
//                               return Padding(
//                                 padding: EdgeInsets.only(bottom: 10),
//                                 child: Column(
//                                   crossAxisAlignment:
//                                       isCurrentUser
//                                           ? CrossAxisAlignment.end
//                                           : CrossAxisAlignment.start,
//                                   children: [
//                                     if (!isCurrentUser)
//                                       Text(
//                                         message?.sender?.firstName ?? "",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16.sp,
//                                           fontFamily: AppConstants.manrope,
//                                         ),
//                                       ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           isCurrentUser
//                                               ? MainAxisAlignment.end
//                                               : MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         if (isCurrentUser)
//                                           Text(
//                                             _formatTime(
//                                               message?.createdAt?.toString() ??
//                                                   "",
//                                             ),
//                                             style: TextStyle(
//                                               fontSize: 16.sp,
//                                               color: Colors.grey[600],
//                                               fontFamily: AppConstants.manrope,
//                                             ),
//                                           ),
//                                         SizedBox(width: 8),
//                                         if (!isCurrentUser)
//                                           CircleAvatar(
//                                             backgroundImage:
//                                                 CachedNetworkImageProvider(
//                                                   message?.sender?.profile ??
//                                                       "",
//                                                 ),
//                                             radius: 16,
//                                             onBackgroundImageError:
//                                                 (_, __) => Icon(Icons.person),
//                                           ),
//                                         SizedBox(width: 8),
//                                         Expanded(
//                                           child: Container(
//                                             constraints: BoxConstraints(
//                                               minWidth: 50.w,
//                                               maxWidth: 70.w,
//                                             ),
//                                             padding: EdgeInsets.all(12),
//                                             decoration: BoxDecoration(
//                                               color:
//                                                   isCurrentUser
//                                                       ? AppColors.maincolor
//                                                       : Colors.grey[200],
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             child: getMessageWidget(
//                                               message,
//                                               isCurrentUser,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(width: 8),
//                                         if (!isCurrentUser)
//                                           Text(
//                                             _formatTime(
//                                               message?.createdAt?.toString() ??
//                                                   "",
//                                             ),
//                                             style: TextStyle(
//                                               fontSize: 16.sp,
//                                               color: Colors.grey[600],
//                                               fontFamily: AppConstants.manrope,
//                                             ),
//                                           ),
//                                         if (isCurrentUser) ...[
//                                           SizedBox(width: 8),
//                                           CircleAvatar(
//                                             backgroundImage:
//                                                 CachedNetworkImageProvider(
//                                                   currentUserImage,
//                                                 ),
//                                             radius: 16,
//                                             onBackgroundImageError:
//                                                 (_, __) => Icon(Icons.person),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//                   decoration: BoxDecoration(color: Colors.white),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         height: 44,
//                         width: 44,
//                         decoration: BoxDecoration(
//                           color: AppColors.maincolor,
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           icon: Icon(Icons.add, color: Colors.white, size: 22),
//                           onPressed: selectfile,
//                           padding: EdgeInsets.zero,
//                           splashRadius: 22,
//                         ),
//                       ),
//                       SizedBox(width: 3.w),
//                       Expanded(
//                         child: Container(
//                           height: 6.h,
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade50,
//                             borderRadius: BorderRadius.circular(24),
//                             border: Border.all(
//                               color: Colors.grey.shade300,
//                               width: 1,
//                             ),
//                           ),
//                           child: TextField(
//                             controller: _messageController,
//                             onSubmitted:
//                                 (_) =>
//                                     _messageController.text.trim().isNotEmpty
//                                         ? sendMessage()
//                                         : null,
//                             textInputAction: TextInputAction.send,
//                             decoration: InputDecoration(
//                               hintText: "Type a message...",
//                               hintStyle: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 16.sp,
//                                 fontFamily: AppConstants.manrope,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(
//                                 vertical: 1.3.h,
//                               ),
//                               isDense: true,
//                             ),
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontFamily: AppConstants.manrope,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                             ),
//                             textAlignVertical: TextAlignVertical.center,
//                             maxLines: 1,
//                             cursorColor: AppColors.maincolor,
//                             cursorWidth: 1.5,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 3.w),
//                       Container(
//                         height: 44,
//                         width: 44,
//                         decoration: BoxDecoration(
//                           color: AppColors.maincolor,
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           icon: Icon(Icons.send, color: Colors.white, size: 20),
//                           onPressed: () {
//                             if (_messageController.text.trim().isEmpty &&
//                                 _pickedFile == null) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Message cannot be empty'),
//                                   backgroundColor: AppColors.redColor,
//                                   duration: Duration(seconds: 1),
//                                 ),
//                               );
//                             } else {
//                               setState(() {
//                                 if (_pickedFile == null) {
//                                   type = 1;
//                                 }
//                               });
//                               isLoading ? null : sendMessage();
//                             }
//                           },
//                           padding: EdgeInsets.zero,
//                           splashRadius: 22,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             if (isSending)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black.withOpacity(0.1),
//                   child: Center(child: Loader()),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget getMessageWidget(dynamic message, bool isCurrentUser) {
//     if (message == null) return SizedBox.shrink();
//
//     String messageType = message.messageType ?? '1';
//
//     switch (messageType) {
//       case '1':
//         return Text(
//           message.message ?? "",
//           style: TextStyle(
//             fontFamily: AppConstants.manrope,
//             color: isCurrentUser ? Colors.white : Colors.black,
//             fontSize: 16.sp,
//           ),
//           softWrap: true,
//           overflow: TextOverflow.visible,
//         );
//
//       case '2':
//         return GestureDetector(
//           onTap:
//               () => showDialog(
//                 context: context,
//                 builder:
//                     (_) => Dialog(
//                       backgroundColor: Colors.transparent,
//                       child: InteractiveViewer(
//                         child: CachedNetworkImage(
//                           imageUrl: message.file ?? "",
//                           placeholder: (_, __) => CircularProgressIndicator(),
//                           errorWidget: (_, __, ___) => Icon(Icons.error),
//                         ),
//                       ),
//                     ),
//               ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: CachedNetworkImage(
//               imageUrl: message.file ?? "",
//               height: 150,
//               width: 200,
//               fit: BoxFit.cover,
//             ),
//           ),
//         );
//
//       case '3':
//         return GestureDetector(
//           onTap:
//               () =>
//                   Get.to(() => VideoPlayerScreen(videoUrl: message.file ?? "")),
//           child: Container(
//             height: 150,
//             width: 200,
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.play_circle_fill,
//                   size: 50,
//                   color: AppColors.maincolor,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   "Play Video",
//                   style: TextStyle(fontFamily: AppConstants.manrope),
//                 ),
//               ],
//             ),
//           ),
//         );
//
//       case '4':
//         return GestureDetector(
//           onTap: () async {
//             if (await canLaunch(message.file ?? "")) {
//               await launch(message.file ?? "");
//             } else {
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(SnackBar(content: Text("Cannot open file")));
//             }
//           },
//           child: Container(
//             width: 200,
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.insert_drive_file,
//                   size: 40,
//                   color: AppColors.maincolor,
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Document",
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text("Tap to open", style: TextStyle(fontSize: 10.sp)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//
//       default:
//         return Text(message.message ?? "Unsupported Message Type");
//     }
//   }
//
//   void sendMessage() async {
//     final String currentMessage = _messageController.text.trim();
//     final File? currentFile = _pickedFile;
//     final int currentType = type;
//
//     setState(() {
//       _messageController.clear();
//       isSending = true;
//       loadingMessage =
//           currentType == 2
//               ? 'Sending Photo'
//               : currentType == 3
//               ? 'Sending Video'
//               : currentType == 4
//               ? 'Sending File'
//               : 'Sending Message';
//     });
//
//     final Map<String, String> data = {
//       "message": currentMessage,
//       "sender_id": currentUserId,
//       "receiver_id": widget.groupid,
//       "msg_to": widget.type,
//       "type": "2",
//       "group_id": widget.groupid,
//     };
//
//     if (currentType != 1 && currentFile != null) {
//       data["files"] = currentFile.path;
//     }
//
//     try {
//       final internet = await checkInternet();
//       if (!internet) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Internet Required")));
//         return;
//       }
//
//       final response = await MessageBoardProvider().sendMessageApi(data);
//       ;
//
//       if (response.statusCode == 200) {
//         setState(() {
//           isSending = false;
//         });
//
//         _loadMessages();
//       } else {}
//     } catch (e, stackTrace) {
//     } finally {
//       setState(() {
//         isSending = false;
//         _pickedFile = null;
//         type = 1;
//       });
//     }
//   }
//
//   selectfile() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           alignment: Alignment.center,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           content: Stack(
//             children: [
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(height: 1.h),
//                     Text(
//                       "Select File Type",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 15.sp,
//                         fontFamily: AppConstants.manrope,
//                       ),
//                     ),
//                     SizedBox(height: 1.h),
//                     Divider(color: Colors.black),
//                     SizedBox(height: 1.h),
//                     SizedBox(
//                       width: 80.w,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               InkWell(
//                                 onTap: () async {
//                                   final XFile? photo = await _picker.pickImage(
//                                     source: ImageSource.gallery,
//                                     imageQuality: 70,
//                                   );
//                                   if (photo != null) {
//                                     setState(() {
//                                       _pickedFile = File(photo.path);
//                                       type = 2;
//                                     });
//                                     Get.back();
//                                     sendMessage();
//                                   }
//                                 },
//                                 child: Container(
//                                   height: 13.w,
//                                   width: 13.w,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(80),
//                                     color: AppColors.maincolor,
//                                   ),
//                                   child: Icon(
//                                     Icons.photo,
//                                     size: 20.sp,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 0.5.h),
//                               Text(
//                                 "Photo",
//                                 style: TextStyle(
//                                   color: Colors.black87,
//                                   fontSize: 13.sp,
//                                   fontFamily: AppConstants.manrope,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Column(
//                             children: [
//                               InkWell(
//                                 onTap: () async {
//                                   final XFile? video = await _picker.pickVideo(
//                                     source: ImageSource.gallery,
//                                     maxDuration: Duration(minutes: 5),
//                                   );
//                                   if (video != null) {
//                                     setState(() {
//                                       _pickedFile = File(video.path);
//                                       type = 3;
//                                     });
//                                     Get.back();
//                                     sendMessage();
//                                   }
//                                 },
//                                 child: Container(
//                                   height: 13.w,
//                                   width: 13.w,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(80),
//                                     color: AppColors.maincolor,
//                                   ),
//                                   child: Icon(
//                                     CupertinoIcons.videocam_circle_fill,
//                                     color: Colors.white,
//                                     size: 20.sp,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 0.5.h),
//                               Text(
//                                 "Video",
//                                 style: TextStyle(
//                                   color: Colors.black87,
//                                   fontSize: 13.sp,
//                                   fontFamily: AppConstants.manrope,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Column(
//                             children: [
//                               InkWell(
//                                 onTap: () async {
//                                   FilePickerResult? result =
//                                       await FilePicker.platform.pickFiles();
//                                   if (result != null) {
//                                     setState(() {
//                                       _pickedFile = File(
//                                         result.files.single.path!,
//                                       );
//                                       type = 4;
//                                     });
//                                     Get.back();
//                                     sendMessage();
//                                   }
//                                 },
//                                 child: Container(
//                                   height: 13.w,
//                                   width: 13.w,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(80),
//                                     color: AppColors.maincolor,
//                                   ),
//                                   child: Icon(
//                                     Icons.file_present_outlined,
//                                     color: Colors.white,
//                                     size: 20.sp,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 0.5.h),
//                               Text(
//                                 "File",
//                                 style: TextStyle(
//                                   color: Colors.black87,
//                                   fontSize: 13.sp,
//                                   fontFamily: AppConstants.manrope,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Positioned(
//                 right: 0,
//                 child: InkWell(
//                   onTap: () {
//                     Get.back();
//                   },
//                   child: Container(
//                     height: 8.w,
//                     width: 8.w,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.close, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   getgrouplistdAp() {
//     final Map<String, String> data = {
//       'created_by': (loginModel?.data?.user?.id).toString(),
//     };
//
//     setState(() {
//       isSending = true;
//     });
//     checkInternet().then((internet) async {
//       if (internet) {
//         MessageBoardProvider().getGroupApi(data).then((response) async {
//           if (response.statusCode == 200) {
//             getgrouplistmodel = GetGroupListModel.fromJson(response.data);
//             setState(() {});
//             isSending = false;
//           } else if (response.statusCode == 429) {
//             isSending = false;
//           } else {
//             isSending = false;
//           }
//         });
//       } else {
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _messagePollingTimer?.cancel();
//     super.dispose();
//   }
// }
