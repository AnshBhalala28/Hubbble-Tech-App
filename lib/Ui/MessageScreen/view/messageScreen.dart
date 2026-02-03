
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../../../Utils/viewPdfFunction.dart';
import '../../CommunityDetailsPage/view/communityDetailPage.dart';
import '../../MessageScreen/modal/OrderSendMessageModel.dart';
import '../../MessageScreen/modal/SendMessageModel.dart';
import '../../MessageScreen/modal/messagescreen_model.dart';
import '../../messageBoard/View/appUserFriendProfileScreen.dart';
import '../../messageScreen/View/videosUrlScreen.dart';
import '../Provider/messageScreenProvider.dart';
import 'userProfileScreen.dart';

class MessageScreen extends StatefulWidget {
  String? chatName;
  String? image;
  String? conciergeID;
  String? senderid;
  String? lat;
  String? long;
  String? type;
  int? chatStatus;
  final String? address;
  final String? phone;
  final String? dob;
  final String? email;
  String? orderproductID;
  String? businessID;

  MessageScreen({
    super.key,
    required this.chatName,
    this.conciergeID,
    this.type,
    this.image,
    this.address,
    this.phone,
    this.dob,
    this.email,
    this.senderid,
    this.orderproductID,
    this.businessID,
    this.chatStatus,
    this.lat,
    this.long,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  File? selectedImage;
  String profileImage = "";
  Timer? _timer;
  final ImagePicker _picker = ImagePicker();
  File? _pickedFile;
  var photo = "";
  int type = 0;
  bool isSending = false;
  String loadingMessage = '';

  // નવું સ્ટેટ: ઈમેજ પસંદ કર્યા પછી પ્રિવ્યૂ માટે
  File? _previewFile;
  String? _previewFileName;
  int? _previewFileType; // 2: Image, 3: Video, 4: PDF

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _getCurrentLocation();
    MessageApi();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      MessageApi();
    });
    log("Business ID AVE CE ${widget.conciergeID}");
    log("Business ID AVE CE ${widget.senderid}");
    log("Business ID AVE CE ${widget.businessID}");
    log("Business ID AVE CE ${widget.lat}");
    log("Business ID AVE CE ${widget.long}");
    log(
      "Business ID AVE CE ${widget.businessID == null ? widget.businessID : widget.senderid}",
    );
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      DateTime now = DateTime.now();

      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime dateToCompare = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      String time = DateFormat("hh:mm a").format(parsedDate);

      if (dateToCompare == today) {
        return "Today • $time";
      } else if (dateToCompare == yesterday) {
        return "Yesterday • $time";
      } else {
        return "${DateFormat("dd-MM-yyyy").format(parsedDate)} • $time";
      }
    } catch (e) {
      return "N/A";
    }
  }

  String formatMessageTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat("HH:mm").format(parsedDate);
    } catch (e) {
      return "";
    }
  }

  void _scrollToBottom({bool forceScroll = false}) {
    Future.delayed(const Duration(seconds: 0), () {
      if (_scrollController.hasClients) {
        if (forceScroll) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(seconds: 0),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: 'refresh');
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),

        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with user info
                  Container(
                    height: 100,
                    padding: const EdgeInsets.only(top: 20, left: 5),
                    decoration: BoxDecoration(
                      color:
                      theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color:
                            theme.isDark ? AppColors.white : Colors.black,
                            size: 24,
                          ),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        InkWell(
                          onTap: () {
                            String friendid =
                            (widget.conciergeID.toString() ==
                                (loginModel?.data?.user?.id
                                    .toString() ??
                                    ""))
                                ? (widget.senderid?.toString() ?? "")
                                : (widget.conciergeID?.toString() ?? "");

                            if (widget.type == "concierge") {
                              _timer?.cancel();
                              Get.to(
                                    () => UserProfileScreen(id: widget.conciergeID),
                              );
                            } else if (widget.type == "residents") {
                              _timer?.cancel();

                              Get.to(
                                    () => AppUserFriendProfileScreen(id: friendid),
                              );
                            } else if (widget.type == "business") {
                              Get.to(
                                BusinessDetailPage(
                                  businessID: widget.businessID,
                                  lat: widget.lat ?? "$AppLat",
                                  long: widget.long ?? "$AppLon",
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: widget.image ?? "",
                                placeholder:
                                    (context, url) =>
                                    Container(color: Colors.grey[200]),
                                errorWidget:
                                    (context, url, error) => const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.chatName ?? "",
                                style: TextStyle(
                                  fontFamily: AppConstants.manropeBold,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                  theme.isDark
                                      ? AppColors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                "Active now",
                                style: TextStyle(
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.type == "concierge")
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                              theme.isDark
                                  ? Color(0xf035332F)
                                  : AppColors.maincolor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.maincolor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              "Personal Concierge",
                              style: TextStyle(
                                fontFamily: AppConstants.manrope,
                                fontSize: 14.sp,
                                color:
                                theme.isDark
                                    ? Color(0xf0CBB880)
                                    : AppColors.maincolor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ).paddingOnly(right: 2.w),
                      ],
                    ),
                  ),

                  // Messages List
                  Expanded(
                    child:
                    isLoading
                        ? Center(child: Loader())
                        : messageModel?.data?.isEmpty ?? true
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No messages yet",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Start a conversation",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messageModel?.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final message = messageModel?.data?[index];
                        bool isMe =
                            message?.sender?.id ==
                                loginModel?.data?.user?.id;
                        final messageTime = formatMessageTime(
                          message?.createdAt,
                        );

                        // build date separator widget
                        Widget dateWidget = const SizedBox.shrink();
                        final int len = messageModel?.data?.length ?? 0;
                        if (index == (len - 1)) {
                          dateWidget = Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            child: Text(
                              formatDateTime(
                                message?.createdAt,
                              ).split('•')[0].trim(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: AppConstants.manrope,
                              ),
                            ),
                          );
                        } else if (index < len - 1) {
                          final currentDate =
                          message?.createdAt != null
                              ? DateTime.parse(
                            message!.createdAt!,
                          ).toLocal()
                              : null;
                          final nextDate =
                          messageModel
                              ?.data?[index + 1]
                              .createdAt !=
                              null
                              ? DateTime.parse(
                            messageModel!
                                .data![index + 1]
                                .createdAt!,
                          ).toLocal()
                              : null;

                          if (currentDate != null &&
                              nextDate != null &&
                              currentDate.day != nextDate.day) {
                            dateWidget = Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              child: Text(
                                DateFormat(
                                  "dd MMMM yyyy",
                                ).format(nextDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            );
                          }
                        }

                        // Message bubble
                        return Column(
                          children: [
                            dateWidget,
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.end,
                                children: [
                                  // Sender's avatar (only for received messages)
                                  if (!isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8,
                                      ),
                                      child: CircleAvatar(
                                        radius: 17,
                                        backgroundColor:
                                        Colors.grey[200],
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                            widget.image ?? '',
                                            width: 15.h,
                                            height: 15.h,
                                            fit: BoxFit.fill,
                                            placeholder:
                                                (
                                                context,
                                                url,
                                                ) => Container(
                                              color:
                                              Colors.grey[200],
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                            const Icon(
                                              Icons.person,
                                              size: 16,
                                              color:
                                              Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Message bubble
                                  Flexible(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 75.w,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        isMe
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment
                                            .start,
                                        children: [
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                              theme.isDark
                                                  ? isMe
                                                  ? Color(
                                                0xf0CBB880,
                                              )
                                                  : Color(
                                                0xf0242424,
                                              )
                                                  : isMe
                                                  ? AppColors
                                                  .lightText
                                                  : Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft:
                                                const Radius.circular(
                                                  20,
                                                ),
                                                topRight:
                                                const Radius.circular(
                                                  20,
                                                ),
                                                bottomLeft:
                                                isMe
                                                    ? const Radius.circular(
                                                  20,
                                                )
                                                    : const Radius.circular(
                                                  4,
                                                ),
                                                bottomRight:
                                                isMe
                                                    ? const Radius.circular(
                                                  4,
                                                )
                                                    : const Radius.circular(
                                                  20,
                                                ),
                                              ),
                                            ),
                                            child: getMessageWidget(
                                              message,
                                              isMe,
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                              top: 4,
                                              right: 8,
                                              left: 8,
                                            ),
                                            child: Text(
                                              messageTime,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                                fontFamily:
                                                AppConstants
                                                    .manrope,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // User's avatar (only for sent messages)
                                  if (isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                      ),
                                      child: CircleAvatar(
                                        radius: 17,
                                        backgroundColor:
                                        Colors.grey[200],
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                            message
                                                ?.sender
                                                ?.profile ??
                                                "",
                                            width: 15.w,
                                            height: 15.w,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (
                                                context,
                                                url,
                                                ) => Container(
                                              color:
                                              Colors.grey[200],
                                            ),
                                            errorWidget:
                                                (
                                                context,
                                                url,
                                                error,
                                                ) => Image.asset(
                                              "assets/images/Applogo_remove_background.png",
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // File Preview Section (નવું ઍડ કરેલું)
                  if (_previewFile != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.isDark
                            ? Color(0xf0242424)
                            : Colors.grey[100],
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // File Preview
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.isDark
                                    ? Color(0xf035332F)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.maincolor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // File Icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.maincolor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _previewFileType == 2
                                          ? Icons.image
                                          : _previewFileType == 4
                                          ? Icons.picture_as_pdf
                                          : Icons.videocam,
                                      color: AppColors.maincolor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // File Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _previewFileName ?? 'File',
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: theme.isDark
                                                ? AppColors.white
                                                : Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _previewFileType == 2
                                              ? 'Image'
                                              : _previewFileType == 4
                                              ? 'PDF Document'
                                              : 'Video',
                                          style: TextStyle(
                                            fontFamily: AppConstants.manrope,
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Cancel Button
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _previewFile = null;
                                        _previewFileName = null;
                                        _previewFileType = null;
                                        _pickedFile = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Send Button for preview
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.maincolor,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                _sendSelectedFile();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Chat disabled warning
                  if (!isLoading &&
                      widget.chatStatus == 0 &&
                      (messageModel?.data?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.redColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.redColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.redColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Chat is temporarily unavailable as the ${widget.chatName!} has paused messages.",
                                style: const TextStyle(
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.redColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Message input field (only if chat is enabled)
                  if (widget.chatStatus != 0)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color:
                        theme.isDark
                            ? Color(0xf01A1A1A)
                            : Color(0xFFF0F2F5),
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Add attachment button
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                color:
                                theme.isDark
                                    ? Color(0xf0CBB880)
                                    : Color(0xf0242424),
                                size: 24,
                              ),
                              onPressed: () {
                                selectfile();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Text field
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                theme.isDark
                                    ? Color(0xf01A1A1A)
                                    : Color(0xFFF0F2F5),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      textInputAction: TextInputAction.send,
                                      keyboardType: TextInputType.multiline,
                                      minLines: 1,
                                      maxLines: 5,
                                      onSubmitted: (value) {
                                        _sendMessage();
                                      },
                                      decoration: const InputDecoration(
                                        hintText: "Type a message...",
                                        hintStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color:
                                      theme.isDark
                                          ? Color(0xf0CBB880)
                                          : Color(0xf0242424),
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      _sendMessage();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Loading overlay
              if (isSending)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Loader(),
                          const SizedBox(height: 16),
                          Text(
                            loadingMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message cannot be empty'),
          backgroundColor: AppColors.redColor,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      type = 1;
    });

    if (isLoading) return;

    if (widget.type == "order") {
      SendOrderChatApi();
    } else {
      SendMessagApi();
    }

    _scrollToBottom();
  }

  // નવી મેથડ: પસંદ કરેલ ફાઈલ મોકલવા માટે
  void _sendSelectedFile() {
    if (_previewFile == null) return;

    // Set the actual file and type for sending
    setState(() {
      _pickedFile = _previewFile;
      type = _previewFileType ?? 2;
    });

    // Now send the message
    if (widget.type == "order") {
      SendOrderChatApi();
    } else {
      SendMessagApi();
    }

    // Clear preview after sending
    setState(() {
      _previewFile = null;
      _previewFileName = null;
      _previewFileType = null;
    });

    _scrollToBottom();
  }

  Widget getMessageWidget(message, bool isMe) {
    final theme = context.watch<ThemeController>();

    if (message == null) return const SizedBox.shrink();

    final messageText = message.message ?? "";

    switch (message.messageType) {
      case '1': // Text message
        return Text(
          messageText,
          style: TextStyle(
            fontFamily: AppConstants.manrope,
            color:
            theme.isDark
                ? isMe
                ? Colors.black
                : Colors.white
                : isMe
                ? Colors.white
                : Colors.black,
            fontSize: 16,
          ),
        );

      case '2': // Image
        return GestureDetector(
          onTap: () {
            log(
                "getFullFileUrl(message.file)getFullFileUrl(message.file)${getFormattedImageUrl(
                    message.file)}");
            Get.to(PdfView(link: getFormattedImageUrl(message.file)));

          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: getFormattedImageUrl(message.file),

              width: 200,
              height: 200,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget:
                  (context, url, error) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 40),
              ),
            ),
          ),
        );

      case '3': // Video
        return GestureDetector(
          onTap: () {
            Get.to(VideoView(videoUrl: message.file ?? ""));
          },
          child: Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                if (message.file != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: message.file!,
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      case '4': // PDF
        return GestureDetector(
          onTap: () async {
            Get.to(PdfView(link: message.file ?? ""));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                isMe
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PDF Document",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Click to view",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 12,
                          color:
                          isMe
                              ? Colors.white.withOpacity(0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Unsupported message type",
            style: TextStyle(
              fontFamily: AppConstants.manrope,
              color: Colors.orange[800],
            ),
          ),
        );
    }
  }

  String getFormattedImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    // જો પાથ પહેલેથી http થી શરૂ થતો હોય તો ડાયરેક્ટ રિટર્ન કરો
    if (path.startsWith("http")) return path;

    // પાથની શરૂઆત જો '/' થી થતી હોય તો તેને વ્યવસ્થિત રીતે જોડો
    String cleanPath = path.startsWith("/") ? path : "/$path";

    return "https://portal.wavee.ai$cleanPath";
  }


  void MessageApi() async {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          String userId = loginModel?.data?.user?.id.toString() ?? '';
          String conciergeId =
          (widget.conciergeID.toString() ==
              (loginModel?.data?.user?.id.toString() ?? ""))
              ? (widget.senderid?.toString() ?? "")
              : (widget.conciergeID?.toString() ?? "");

          String type =
          widget.type?.isNotEmpty == true
              ? widget.type.toString() ?? ""
              : 'business';

          var response = await MessageProvider().messageApi(
            userId,
            conciergeId,
            type,
            (widget.orderproductID).toString(),
          );

          if (response.statusCode == 200) {
            messageModel = MessageModel.fromJson(response.data);
            log("response ${response.data}");

          log("====================================");

          } else {
            // Handle error
          }

          setState(() {
            isLoading = false;
          });
        } catch (e) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void SendMessagApi() {
    if (type == 2 || type == 3 || type == 4 || type == 1) {
      setState(() {
        isSending = true;
        loadingMessage =
        type == 2
            ? 'Sending Photo'
            : type == 3
            ? 'Sending Video'
            : type == 1
            ? 'Sending Message'
            : 'Sending File';
      });
    }
    String conciergeId =
    (widget.conciergeID.toString() ==
        (loginModel?.data?.user?.id.toString() ?? ""))
        ? (widget.senderid?.toString() ?? "")
        : (widget.conciergeID?.toString() ?? "");
    final Map<String, String> data = {
      "message": _messageController.text.trim(),
      "sender_id": loginModel?.data?.user?.id.toString() ?? '',
      "receiver_id": conciergeId.toString() ?? "",
      "msg_to": widget.type ?? '',
      "type": "1",
      "files": type == 1 ? '' : _pickedFile!.path,
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await MessageProvider().sendMessageApi(data);
          sendMessageModel = SendMessageModel.fromJson(response.data);

          if (response.statusCode == 200 && sendMessageModel?.status == 200) {
            setState(() {
              isSending = false;
              _messageController.clear();
            });
            MessageApi();
          } else {
            // Handle error
          }
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
        setState(() {
          isLoading = false;
          isSending = false;
        });
      }
    });
  }

  void selectfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choose File Type",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFileTypeButton(
                      icon: Icons.photo,
                      label: "Photo",
                      onTap: () async {
                        final XFile? photo = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (photo != null) {
                          setState(() {
                            // Store file for preview instead of sending immediately
                            _previewFile = File(photo.path);
                            _previewFileName = photo.name;
                            _previewFileType = 2;
                          });
                          Navigator.pop(context);
                        }
                      },
                    ),
                    _buildFileTypeButton(
                      icon: Icons.picture_as_pdf,
                      label: "PDF",
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null) {
                          setState(() {
                            // Store file for preview instead of sending immediately
                            _previewFile = File(
                              result.files.single.path.toString(),
                            );
                            _previewFileName = result.files.single.name;
                            _previewFileType = 4;
                          });
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileTypeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.maincolor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.maincolor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: AppColors.maincolor, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppConstants.manrope,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String AppLat = '';
  String AppLon = '';

  void SendOrderChatApi() {
    setState(() {
      isSending = true;
      loadingMessage =
      type == 2
          ? 'Sending Photo'
          : type == 3
          ? 'Sending Video'
          : type == 1
          ? 'Sending Message'
          : 'Sending File';
    });

    Map<String, String> data = {
      "order_product_id": widget.orderproductID ?? '',
      "business_id": widget.conciergeID ?? '',
      "user_id": loginModel?.data?.user?.id.toString() ?? '',
      "message": _messageController.text.trim(),
      "sent_by": "user",
    };

    File? fileToSend;
    if (type != 1 && _pickedFile != null) {
      fileToSend = File(_pickedFile!.path);
    }

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await MessageProvider().sendMessageOrderApi(
            data,
            fileToSend,
          );

          ordersendmessagemodel = OrdersendMessageModel.fromJson(response.data);

          if (response.statusCode == 200 &&
              ordersendmessagemodel?.status == 200) {
            setState(() {
              isSending = false;
            });
            _messageController.clear();
            MessageApi();
            _scrollToBottom();
          } else {
            setState(() {
              isSending = false;
            });
          }
        } catch (e) {
          setState(() {
            isSending = false;
          });
        }
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        AppLat = position.latitude.toString();
        AppLon = position.longitude.toString();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}