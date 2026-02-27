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
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/ui/message_screen/modal/OrderSendMessageModel.dart';
import 'package:wavee/ui/message_screen/modal/SendMessageModel.dart';
import 'package:wavee/ui/message_screen/modal/messagescreen_model.dart';

import '../../../utils/checkInternetConnection.dart';
import '../../../utils/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/errorDialog.dart';
import '../../../utils/loader.dart';
import '../../../utils/viewPdfFunction.dart';
import '../../community_details_page/view/communityDetailPage.dart';
import '../../message_board/view/appUserFriendProfileScreen.dart';
import '../../message_screen/view/videosUrlScreen.dart';
import '../provider/messageScreenProvider.dart';
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

  File? _previewFile;
  String? _previewFileName;
  int? _previewFileType;

  // Reply functionality variables
  MessageData? _replyToMessage;
  bool _isReplying = false;

  // Track if user manually scrolled
  bool _userScrolled = false;

  @override
  void initState() {
    super.initState();
    log('🚀 INITIALIZING MESSAGE SCREEN');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('📱 Chat Name: ${widget.chatName}');
    log('👤 Concierge ID: ${widget.conciergeID}');
    log('📨 Sender ID: ${widget.senderid}');
    log('🏢 Business ID: ${widget.businessID}');
    log('📋 Type: ${widget.type}');
    log('📍 Latitude: ${widget.lat}');
    log('📍 Longitude: ${widget.long}');
    log('📊 Chat Status: ${widget.chatStatus}');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Add scroll listener to detect user scrolling
    _scrollController.addListener(_scrollListener);

    setState(() {
      isLoading = true;
    });
    _getCurrentLocation();
    MessageApi();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      log('🔄 Auto-refreshing messages...');
      MessageApi();
    });
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      // Detect if user is scrolling manually
      if (_scrollController.position.isScrollingNotifier.value) {
        _userScrolled = true;
      }
    }
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
      log('❌ Error formatting date: $e');
      return "N/A";
    }
  }

  String formatMessageTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat("HH:mm").format(parsedDate);
    } catch (e) {
      log('❌ Error formatting time: $e');
      return "";
    }
  }

  void _scrollToBottom({bool forceScroll = false}) {
    // Don't auto-scroll if user has manually scrolled or if we're in reply mode
    if (_userScrolled || _isReplying) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        if (forceScroll) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(0);
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
        backgroundColor: theme.isDark ? const Color(0xf01A1A1A) : const Color(0xFFF0F2F5),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 3.h,),
                  _buildHeader(theme),

                  // Messages List
                  Expanded(
                    child: isLoading
                        ? const Center(child: Loader())
                        : messageModel?.data?.isEmpty ?? true
                        ? _buildEmptyState()
                        : ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messageModel?.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final message = messageModel?.data?[index];
                        bool isMe = message?.sender?.id == loginModel?.data?.user?.id;

                        // Build date separator
                        Widget dateWidget = _buildDateSeparator(message, index);

                        return Column(
                          children: [
                            dateWidget,
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isMe) _buildSenderAvatar(),

                                  // Message bubble with reply button
                                  _buildMessageWithReplyButton(message, isMe, theme),

                                  if (isMe) _buildSenderAvatar(isMe: true),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // File Preview Section
                  if (_previewFile != null) _buildFilePreview(theme),

                  // Reply Preview Section
                  if (_isReplying && _replyToMessage != null)
                    _buildReplyPreview(theme),

                  // Chat disabled warning
                  if (!isLoading &&
                      widget.chatStatus == 0 &&
                      (messageModel?.data?.isNotEmpty ?? false))
                    _buildChatDisabledWarning(),

                  // Message input field
                  if (widget.chatStatus != 0) _buildMessageInput(theme),
                ],
              ),

              // Loading overlay
              if (isSending) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // Message with Reply Button Widget
  Widget _buildMessageWithReplyButton(MessageData? message, bool isMe, ThemeController theme) {
    if (message == null) return const SizedBox.shrink();

    // Check if message has parcel or visitor info
    bool hasReplyOption = message.parcelInfo != null || message.visitorInfo != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reply button for parcel/visitor messages (appears on the left for their messages, right for our messages)
        if (hasReplyOption && !isMe)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildReplyButton(message),
          ),

        // Message bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 65.w, // Slightly smaller to accommodate reply button
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Show reply icon for messages that are replies
                if (message.replyTo != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.reply,
                          size: 14,
                          color: AppColors.maincolor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Replied',
                          style: TextStyle(
                            fontFamily: AppConstants.manrope,
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main message content
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.isDark
                        ? isMe
                        ? const Color(0xf0CBB880)
                        : const Color(0xf0242424)
                        : isMe
                        ? AppColors.lightText
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reply indicator if this message is a reply
                      if (message.replyTo != null)
                        _buildReplyIndicator(message.replyTo!, isMe, theme),

                      // Message content
                      getMessageWidget(message, isMe),
                    ],
                  ),
                ),

                // Time stamp
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    right: 8,
                    left: 8,
                  ),
                  child: Text(
                    formatMessageTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Reply button for parcel/visitor messages (appears on the right for our messages)
        if (hasReplyOption && isMe)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildReplyButton(message),
          ),
      ],
    );
  }

  // Reply Button Widget
  Widget _buildReplyButton(MessageData message) {
    return GestureDetector(
      onTap: () {
        _setReplyMessage(message);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: message.parcelInfo != null
              ? Colors.blue.withOpacity(0.1)
              : message.visitorInfo != null
              ? Colors.green.withOpacity(0.1)
              : AppColors.maincolor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: message.parcelInfo != null
                ? Colors.blue.withOpacity(0.3)
                : message.visitorInfo != null
                ? Colors.green.withOpacity(0.3)
                : AppColors.maincolor.withOpacity(0.3),
          ),
        ),
        child: Icon(
          message.parcelInfo != null
              ? Icons.inventory_2
              : message.visitorInfo != null
              ? Icons.person
              : Icons.reply,
          size: 20,
          color: message.parcelInfo != null
              ? Colors.blue
              : message.visitorInfo != null
              ? Colors.green
              : AppColors.maincolor,
        ),
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(ThemeController theme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 20, left: 5),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0xf01A1A1A) : const Color(0xFFF0F2F5),
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
              color: theme.isDark ? AppColors.white : Colors.black,
              size: 24,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          InkWell(
            onTap: () {
              String friendid = (widget.conciergeID.toString() ==
                  (loginModel?.data?.user?.id.toString() ?? ""))
                  ? (widget.senderid?.toString() ?? "")
                  : (widget.conciergeID?.toString() ?? "");

              if (widget.type == "concierge" ||
                  widget.type == "parcels" ||
                  widget.type == "visitors") {
                _timer?.cancel();
                Get.to(() => UserProfileScreen(id: widget.conciergeID));
              } else if (widget.type == "residents") {
                _timer?.cancel();
                Get.to(() => AppUserFriendProfileScreen(id: friendid));
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
                  imageUrl:  widget.image ?? "",
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(
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
                  widget.type == "parcels" || widget.type == "visitors"
                      ? "${userpersonalInfoModel?.data?.firstName ?? "Unknown"} ${userpersonalInfoModel?.data?.lastName ?? ""}"
                      : widget.chatName ?? "",
                  style: TextStyle(
                    fontFamily: AppConstants.manropeBold,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.isDark ? AppColors.white : Colors.black,
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
                color: theme.isDark ? const Color(0xf035332F) : AppColors.maincolor.withOpacity(0.1),
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
                  color: theme.isDark ? const Color(0xf0CBB880) : AppColors.maincolor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ).paddingOnly(right: 2.w),
        ],
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return Center(
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
    );
  }

  // Date Separator Widget
  Widget _buildDateSeparator(MessageData? message, int index) {
    if (message == null) return const SizedBox.shrink();

    final int len = messageModel?.data?.length ?? 0;
    if (index == (len - 1)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          formatDateTime(message.createdAt).split('•')[0].trim(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: AppConstants.manrope,
          ),
        ),
      );
    } else if (index < len - 1) {
      final currentDate = message.createdAt != null
          ? DateTime.parse(message.createdAt!).toLocal()
          : null;
      final nextDate = messageModel?.data?[index + 1].createdAt != null
          ? DateTime.parse(messageModel!.data![index + 1].createdAt!).toLocal()
          : null;

      if (currentDate != null && nextDate != null && currentDate.day != nextDate.day) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            DateFormat("dd MMMM yyyy").format(nextDate),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: AppConstants.manrope,
            ),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  // Sender Avatar Widget
  Widget _buildSenderAvatar({bool isMe = false}) {
    return Padding(
      padding: EdgeInsets.only(right: isMe ? 0 : 8, left: isMe ? 8 : 0),
      child: CircleAvatar(
        radius: 17,
        backgroundColor: Colors.grey[200],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: isMe
                ? loginModel?.data?.user?.profile ?? ""
                :  widget.image ?? '',
            width: 15.h,
            height: 15.h,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) => isMe
                ? Image.asset(
              "assets/images/Applogo_remove_background.png",
              fit: BoxFit.fill,
            )
                : const Icon(
              Icons.person,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Reply Indicator Widget for messages that are replies
  Widget _buildReplyIndicator(MessageData replyTo, bool isMe, ThemeController theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.1)
            : theme.isDark
            ? const Color(0xf035332F)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.maincolor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Show different icon based on replied message type
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: replyTo.parcelInfo != null
                  ? Colors.blue.withOpacity(0.1)
                  : replyTo.visitorInfo != null
                  ? Colors.green.withOpacity(0.1)
                  : AppColors.maincolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              replyTo.parcelInfo != null
                  ? Icons.inventory_2
                  : replyTo.visitorInfo != null
                  ? Icons.person
                  : Icons.reply,
              size: 14,
              color: replyTo.parcelInfo != null
                  ? Colors.blue
                  : replyTo.visitorInfo != null
                  ? Colors.green
                  : AppColors.maincolor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getReplyTitle(replyTo),
                  style: TextStyle(
                    fontFamily: AppConstants.manrope,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.maincolor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getReplyPreview(replyTo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppConstants.manrope,
                    fontSize: 12,
                    color: isMe
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Add reply button to replied message preview
          GestureDetector(
            onTap: () {
              _setReplyMessage(replyTo);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: replyTo.parcelInfo != null
                    ? Colors.blue.withOpacity(0.1)
                    : replyTo.visitorInfo != null
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.maincolor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.reply,
                size: 14,
                color: replyTo.parcelInfo != null
                    ? Colors.blue
                    : replyTo.visitorInfo != null
                    ? Colors.green
                    : AppColors.maincolor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get reply title based on type
  String _getReplyTitle(MessageData replyTo) {
    if (replyTo.parcelInfo != null) {
      return 'Replying to Parcel: ${replyTo.parcelInfo?.description ?? 'Parcel'}';
    } else if (replyTo.visitorInfo != null) {
      return 'Replying to Visitor: ${replyTo.visitorInfo?.name ?? 'Visitor'}';
    }
    return 'Replying to message';
  }

  // Get reply preview content
  String _getReplyPreview(MessageData replyTo) {
    if (replyTo.parcelInfo != null) {
      return '📦 ${replyTo.parcelInfo?.description ?? 'Parcel'}';
    } else if (replyTo.visitorInfo != null) {
      return '👤 ${replyTo.visitorInfo?.name ?? 'Visitor'} - ${replyTo.visitorInfo?.purpose ?? ''}';
    }

    switch (replyTo.messageType) {
      case '1':
        return replyTo.message ?? 'Message';
      case '2':
        return '📷 Photo';
      case '3':
        return '🎥 Video';
      case '4':
        return '📄 PDF';
      default:
        return 'Message';
    }
  }

  // File Preview Widget
  Widget _buildFilePreview(ThemeController theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0xf0242424) : Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.isDark ? const Color(0xf035332F) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.maincolor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
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
                          : _previewFileType == 3
                          ? Icons.videocam
                          : _previewFileType == 4
                          ? Icons.picture_as_pdf
                          : Icons.insert_drive_file,
                      color: AppColors.maincolor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                            color: theme.isDark ? AppColors.white : Colors.black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _previewFileType == 2
                              ? 'Image'
                              : _previewFileType == 3
                              ? 'Video'
                              : _previewFileType == 4
                              ? 'PDF Document'
                              : 'File',
                          style: TextStyle(
                            fontFamily: AppConstants.manrope,
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
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
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.maincolor,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _sendSelectedFile,
            ),
          ),
        ],
      ),
    );
  }

  // Reply Preview Widget
  Widget _buildReplyPreview(ThemeController theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0xf0242424) : Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
          left: BorderSide(
            color: AppColors.maincolor,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: AppColors.maincolor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getReplyPreviewTitle(),
                      style: TextStyle(
                        fontFamily: AppConstants.manrope,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.maincolor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.isDark ? const Color(0xf035332F) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getReplyPreviewIcon(),
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getReplyPreviewContent(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppConstants.manrope,
                            fontSize: 13,
                            color: theme.isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.grey[600],
              size: 20,
            ),
            onPressed: _cancelReply,
          ),
        ],
      ),
    );
  }

  // Helper methods for reply preview
  String _getReplyPreviewTitle() {
    if (_replyToMessage == null) return 'Replying';

    if (_replyToMessage!.parcelInfo != null) {
      return 'Replying to Parcel';
    } else if (_replyToMessage!.visitorInfo != null) {
      return 'Replying to Visitor';
    }
    return 'Replying';
  }

  IconData _getReplyPreviewIcon() {
    if (_replyToMessage == null) return Icons.message;

    if (_replyToMessage!.parcelInfo != null) {
      return Icons.inventory_2;
    } else if (_replyToMessage!.visitorInfo != null) {
      return Icons.person;
    }
    return Icons.message;
  }

  String _getReplyPreviewContent() {
    if (_replyToMessage == null) return '';

    if (_replyToMessage!.parcelInfo != null) {
      return '📦 ${_replyToMessage!.parcelInfo?.description ?? 'Parcel'}';
    } else if (_replyToMessage!.visitorInfo != null) {
      return '👤 ${_replyToMessage!.visitorInfo?.name ?? 'Visitor'}\nPurpose: ${_replyToMessage!.visitorInfo?.purpose ?? ''}';
    }
    return _replyToMessage!.message ?? 'Message';
  }

  // Chat Disabled Warning
  Widget _buildChatDisabledWarning() {
    return Padding(
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
                "Chat is temporarily unavailable as ${widget.chatName!} has paused messages.",
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
    );
  }

  // Message Input Widget
  Widget _buildMessageInput(ThemeController theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0xf01A1A1A) : const Color(0xFFF0F2F5),
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
                color: theme.isDark ? const Color(0xf0CBB880) : const Color(0xf0242424),
                size: 24,
              ),
              onPressed: selectfile,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.isDark ? const Color(0xf01A1A1A) : const Color(0xFFF0F2F5),
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
                      decoration: InputDecoration(
                        hintText: _isReplying ? "Reply to message..." : "Type a message...",
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
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
                      color: theme.isDark ? const Color(0xf0CBB880) : const Color(0xf0242424),
                      size: 24,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Loading Overlay
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Loader(),
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
    );
  }

  // Set reply message
  void _setReplyMessage(MessageData message) {
    setState(() {
      _replyToMessage = message;
      _isReplying = true;
    });

    // Focus on text field
    FocusScope.of(context).requestFocus(FocusNode());

    log('💬 Reply set to message ID: ${message.id}');
    if (message.parcelInfo != null) {
      log('   - Replying to Parcel: ${message.parcelInfo?.description}');
    } else if (message.visitorInfo != null) {
      log('   - Replying to Visitor: ${message.visitorInfo?.name}');
    }
  }

  // Cancel reply
  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
      _isReplying = false;
    });
    log('💬 Reply cancelled');
  }

  // Send text message
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

    log('📤 Sending text message: ${_messageController.text.trim()}');
    if (_replyToMessage != null) {
      log('💬 In reply to: ${_replyToMessage!.id}');
    }

    if (widget.type == "order") {
      SendOrderChatApi();
    } else {
      SendMessagApi();
    }
  }

  // Send selected file
  void _sendSelectedFile() {
    if (_previewFile == null) return;

    log('📤 Sending selected file');
    log('   - Type: $_previewFileType');
    log('   - Name: $_previewFileName');
    if (_replyToMessage != null) {
      log('   - In reply to: ${_replyToMessage!.id}');
    }

    setState(() {
      _pickedFile = _previewFile;
      type = _previewFileType ?? 2;
    });

    if (widget.type == "order") {
      SendOrderChatApi();
    } else {
      SendMessagApi();
    }

    setState(() {
      _previewFile = null;
      _previewFileName = null;
      _previewFileType = null;
    });
  }

  Widget getMessageWidget(MessageData message, bool isMe) {
    final theme = context.watch<ThemeController>();

    if (message == null) return const SizedBox.shrink();

    // If message has parcel info, show parcel details + message
    if (message.parcelInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parcel Info Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withOpacity(0.1)
                  : theme.isDark
                  ? const Color(0xf035332F)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📦 Parcel',
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.parcelInfo?.description ?? 'Parcel',
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.isDark
                              ? isMe
                              ? Colors.black
                              : Colors.white
                              : isMe
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      if (message.parcelInfo?.trackingNumber != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Tracking: ${message.parcelInfo?.trackingNumber}',
                            style: TextStyle(
                              fontFamily: AppConstants.manrope,
                              fontSize: 12,
                              color: theme.isDark
                                  ? isMe
                                  ? Colors.black.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.6)
                                  : isMe
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message Content (if any)
          if (message.message != null && message.message!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.message!,
                style: TextStyle(
                  fontFamily: AppConstants.manrope,
                  color: theme.isDark
                      ? isMe
                      ? Colors.black
                      : Colors.white
                      : isMe
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      );
    }

    // If message has visitor info, show visitor details + message
    if (message.visitorInfo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visitor Info Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withOpacity(0.1)
                  : theme.isDark
                  ? const Color(0xf035332F)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👤 Visitor',
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.visitorInfo?.name ?? 'Visitor',
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.isDark
                              ? isMe
                              ? Colors.black
                              : Colors.white
                              : isMe
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      if (message.visitorInfo?.purpose != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Purpose: ${message.visitorInfo?.purpose}',
                            style: TextStyle(
                              fontFamily: AppConstants.manrope,
                              fontSize: 12,
                              color: theme.isDark
                                  ? isMe
                                  ? Colors.black.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.6)
                                  : isMe
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message Content (if any)
          if (message.message != null && message.message!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.message!,
                style: TextStyle(
                  fontFamily: AppConstants.manrope,
                  color: theme.isDark
                      ? isMe
                      ? Colors.black
                      : Colors.white
                      : isMe
                      ? Colors.white
                      : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      );
    }

    // Regular text/image/video/pdf messages (existing code)
    final messageText = message.message ?? "";

    switch (message.messageType) {
      case '1': // Text message
        return Text(
          messageText,
          style: TextStyle(
            fontFamily: AppConstants.manrope,
            color: theme.isDark
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
            log('🖼️ Opening image: ${message.file}');
            Get.to(PdfView(link: message.file ?? ""));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: message.file ?? "",
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) {
                log('❌ Error loading image: $error');
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
        );

      case '3': // Video
        return GestureDetector(
          onTap: () {
            log('🎥 Opening video: ${message.file}');
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
                      errorWidget: (context, url, error) {
                        log('❌ Error loading video thumbnail: $error');
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.video_library, size: 40),
                        );
                      },
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
            log('📄 Opening PDF: ${message.file}');
            Get.to(PdfView(link: message.file ?? ""));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isMe
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
                          color: isMe
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

  // API Methods
  void MessageApi() async {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          String userId = loginModel?.data?.user?.id.toString() ?? '';
          String conciergeId = (widget.conciergeID.toString() ==
              (loginModel?.data?.user?.id.toString() ?? ""))
              ? (widget.senderid?.toString() ?? "")
              : (widget.conciergeID?.toString() ?? "");

          String type = widget.type?.isNotEmpty == true
              ? widget.type.toString() ?? ""
              : 'business';

          log('📡 FETCHING MESSAGES');
          log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          log('👤 User ID: $userId');
          log('👥 Concierge ID: $conciergeId');
          log('📋 Type: $type');
          log('🆔 Order Product ID: ${widget.orderproductID.toString()}');

          var response = await MessageProvider().messageApi(
            userId,
            conciergeId,
            type,
            (widget.orderproductID).toString(),
          );

          if (response.statusCode == 200) {
            messageModel = MessageModel.fromJson(response.data);
            log('✅ Messages fetched successfully');
            log('📊 Total messages: ${messageModel?.data?.length ?? 0}');

            // Only auto-scroll to bottom if we're not in reply mode and user hasn't scrolled manually
            if (!_isReplying && !_userScrolled && (messageModel?.data?.isNotEmpty ?? false)) {
              _scrollToBottom(forceScroll: true);
            }
          } else {
            log('❌ Failed to fetch messages. Status code: ${response.statusCode}');
          }
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e, stackTrace) {
          log('❌ Exception in MessageApi: $e');
          log('📚 StackTrace: $stackTrace');
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
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void SendMessagApi() {
    if (type == 2 || type == 3 || type == 4 || type == 1) {
      setState(() {
        isSending = true;
        loadingMessage = type == 2
            ? 'Sending Photo...'
            : type == 3
            ? 'Sending Video...'
            : type == 4
            ? 'Sending PDF...'
            : type == 1
            ? 'Sending Message...'
            : 'Sending File...';
      });
    }

    String conciergeId = (widget.conciergeID.toString() ==
        (loginModel?.data?.user?.id.toString() ?? ""))
        ? (widget.senderid?.toString() ?? "")
        : (widget.conciergeID?.toString() ?? "");

    log('📤 SENDING MESSAGE');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('📍 Type: ${type == 1 ? 'Text' : type == 2 ? 'Image' : type == 3 ? 'Video' : type == 4 ? 'PDF' : 'Unknown'}');
    log('👤 Sender ID: ${loginModel?.data?.user?.id.toString()}');
    log('👥 Receiver ID: $conciergeId');
    log('💬 Message: ${_messageController.text.trim()}');

    if (_replyToMessage != null) {
      log('💬 REPLYING TO MESSAGE ID: ${_replyToMessage!.id}');

      // Check if replying to a parcel message
      if (_replyToMessage!.parcelInfo != null) {
        log('📦 Replying to Parcel ID: ${_replyToMessage!.parcelInfo?.id}');
        log('📦 Parcel Description: ${_replyToMessage!.parcelInfo?.description}');
      }

      // Check if replying to a visitor message
      if (_replyToMessage!.visitorInfo != null) {
        log('👤 Replying to Visitor ID: ${_replyToMessage!.visitorInfo?.id}');
        log('👤 Visitor Name: ${_replyToMessage!.visitorInfo?.name}');
      }
    }

    if (_pickedFile != null && type != 1) {
      log('📎 File Path: ${_pickedFile!.path}');
      log('📏 File Exists: ${File(_pickedFile!.path).existsSync()}');
      log('📦 File Size: ${File(_pickedFile!.path).lengthSync()} bytes');
    }

    // Create base data map
    Map<String, String> data = {
      "message": _messageController.text.trim(),
      "sender_id": loginModel?.data?.user?.id.toString() ?? '',
      "receiver_id": conciergeId.toString() ?? "",
      "msg_to": widget.type ?? '',
      "type": type.toString(),
      "files": type == 1 ? '' : _pickedFile!.path,
    };

    // Add reply information based on message type
    if (_replyToMessage != null) {
      // Always add reply_to_id for reference
      data["reply_to_id"] = _replyToMessage!.id.toString();

      // Check if replying to a parcel message
      if (_replyToMessage!.parcelInfo != null) {
        // Send parcel_id for parcel replies
        data["parcel_id"] = _replyToMessage!.parcelInfo!.id.toString();
        log('📦 Added parcel_id: ${_replyToMessage!.parcelInfo!.id}');
      }

      // Check if replying to a visitor message
      if (_replyToMessage!.visitorInfo != null) {
        // Send visitor_id for visitor replies
        data["visitor_id"] = _replyToMessage!.visitorInfo!.id.toString();
        log('👤 Added visitor_id: ${_replyToMessage!.visitorInfo!.id}');
      }
    }

    log('📦 Final Message data: $data');

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await MessageProvider().sendMessageApi(data);
          sendMessageModel = SendMessageModel.fromJson(response.data);

          if (response.statusCode == 200 && sendMessageModel?.status == 200) {
            log('✅ Message sent successfully!');

            // Store current scroll position before clearing reply
            double currentScrollPosition = _scrollController.hasClients
                ? _scrollController.offset
                : 0;

            setState(() {
              isSending = false;
              _messageController.clear();
              _pickedFile = null;
              _previewFile = null;
              _previewFileName = null;
              _previewFileType = null;
              _replyToMessage = null; // Clear reply
              _isReplying = false; // Clear reply flag
            });

            MessageApi(); // Refresh messages

            // Restore scroll position after messages refresh
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(currentScrollPosition);
              }
            });
          } else {
            log('❌ Failed to send message: ${response.data}');
            setState(() {
              isSending = false;
            });
            buildErrorDialog(
                context, 'Error', sendMessageModel?.message ?? 'Failed to send message');
          }
        } catch (e, stackTrace) {
          log('❌ Exception in SendMessagApi: $e');
          log('📚 StackTrace: $stackTrace');
          setState(() {
            isSending = false;
          });
          buildErrorDialog(context, 'Error', 'Something went wrong: ${e.toString()}');
        }
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void SendOrderChatApi() {
    setState(() {
      isSending = true;
      loadingMessage = type == 2
          ? 'Sending Photo...'
          : type == 3
          ? 'Sending Video...'
          : type == 4
          ? 'Sending PDF...'
          : type == 1
          ? 'Sending Message...'
          : 'Sending File...';
    });

    log('📤 SENDING ORDER CHAT MESSAGE');
    log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    log('📍 Order Product ID: ${widget.orderproductID}');
    log('🏢 Business ID: ${widget.conciergeID}');
    log('👤 User ID: ${loginModel?.data?.user?.id.toString()}');
    log('💬 Message: ${_messageController.text.trim()}');
    log('📋 Type: $type');

    Map<String, String> data = {
      "order_product_id": widget.orderproductID ?? '',
      "business_id": widget.conciergeID ?? '',
      "user_id": loginModel?.data?.user?.id.toString() ?? '',
      "message": _messageController.text.trim(),
      "sent_by": "user",
      if (_replyToMessage != null) "reply_to_id": _replyToMessage!.id.toString(),
    };

    File? fileToSend;
    if (type != 1 && _pickedFile != null) {
      fileToSend = File(_pickedFile!.path);
      log('📎 File: ${fileToSend.path}');
      log('📏 File Size: ${fileToSend.lengthSync()} bytes');
    }

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await MessageProvider().sendMessageOrderApi(
            data,
            fileToSend,
          );

          ordersendmessagemodel = OrdersendMessageModel.fromJson(response.data);

          if (response.statusCode == 200 && ordersendmessagemodel?.status == 200) {
            log('✅ Order message sent successfully!');

            // Store current scroll position before clearing reply
            double currentScrollPosition = _scrollController.hasClients
                ? _scrollController.offset
                : 0;

            setState(() {
              isSending = false;
              _messageController.clear();
              _pickedFile = null;
              _previewFile = null;
              _previewFileName = null;
              _previewFileType = null;
              _replyToMessage = null; // Clear reply
              _isReplying = false; // Clear reply flag
            });
            MessageApi();

            // Restore scroll position after messages refresh
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(currentScrollPosition);
              }
            });
          } else {
            log('❌ Failed to send order message: ${response.data}');
            setState(() {
              isSending = false;
            });
          }
        } catch (e, stackTrace) {
          log('❌ Exception in SendOrderChatApi: $e');
          log('📚 StackTrace: $stackTrace');
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

  void selectfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                        try {
                          final XFile? photo = await _picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1920,
                            maxHeight: 1080,
                            imageQuality: 85,
                          );

                          if (photo != null) {
                            File file = File(photo.path);
                            int fileSize = await file.length();

                            log('📸 Image Selected:');
                            log('   - Path: ${photo.path}');
                            log('   - Name: ${photo.name}');
                            log('   - Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

                            if (fileSize > 10 * 1024 * 1024) {
                              buildErrorDialog(
                                  context, 'Error', 'Image size should be less than 10MB');
                              return;
                            }

                            setState(() {
                              _previewFile = file;
                              _previewFileName = photo.name;
                              _previewFileType = 2;
                            });
                            Navigator.pop(context);
                          }
                        } catch (e, stackTrace) {
                          log('❌ Error picking image: $e');
                          log('📚 StackTrace: $stackTrace');
                          buildErrorDialog(context, 'Error', 'Failed to pick image');
                        }
                      },
                    ),
                    _buildFileTypeButton(
                      icon: Icons.videocam,
                      label: "Video",
                      onTap: () async {
                        try {
                          final XFile? video = await _picker.pickVideo(
                            source: ImageSource.gallery,
                            maxDuration: const Duration(minutes: 5),
                          );

                          if (video != null) {
                            File file = File(video.path);
                            int fileSize = await file.length();

                            log('🎥 Video Selected:');
                            log('   - Path: ${video.path}');
                            log('   - Name: ${video.name}');
                            log('   - Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

                            if (fileSize > 50 * 1024 * 1024) {
                              buildErrorDialog(
                                  context, 'Error', 'Video size should be less than 50MB');
                              return;
                            }

                            setState(() {
                              _previewFile = file;
                              _previewFileName = video.name;
                              _previewFileType = 3;
                            });
                            Navigator.pop(context);
                          }
                        } catch (e, stackTrace) {
                          log('❌ Error picking video: $e');
                          log('📚 StackTrace: $stackTrace');
                          buildErrorDialog(context, 'Error', 'Failed to pick video');
                        }
                      },
                    ),
                    _buildFileTypeButton(
                      icon: Icons.picture_as_pdf,
                      label: "PDF",
                      onTap: () async {
                        try {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                            allowMultiple: false,
                          );

                          if (result != null) {
                            File file = File(result.files.single.path.toString());
                            int fileSize = result.files.single.size;

                            log('📄 PDF Selected:');
                            log('   - Path: ${result.files.single.path}');
                            log('   - Name: ${result.files.single.name}');
                            log('   - Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

                            if (fileSize > 10 * 1024 * 1024) {
                              buildErrorDialog(
                                  context, 'Error', 'PDF size should be less than 10MB');
                              return;
                            }

                            setState(() {
                              _previewFile = file;
                              _previewFileName = result.files.single.name;
                              _previewFileType = 4;
                            });
                            Navigator.pop(context);
                          }
                        } catch (e, stackTrace) {
                          log('❌ Error picking PDF: $e');
                          log('📚 StackTrace: $stackTrace');
                          buildErrorDialog(context, 'Error', 'Failed to pick PDF');
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

  Future<void> _getCurrentLocation() async {
    log('📍 Getting current location...');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log('⚠️ Location services are disabled');
      setState(() {
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log('⚠️ Location permission denied');
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      log('⚠️ Location permissions permanently denied');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          AppLat = position.latitude.toString();
          AppLon = position.longitude.toString();
        });
        log('✅ Location obtained - Lat: $AppLat, Lon: $AppLon');
      }
    } catch (e, stackTrace) {
      log('❌ Error getting location: $e');
      log('📚 StackTrace: $stackTrace');
    }
  }

  @override
  void dispose() {
    log('🗑️ Disposing MessageScreen');
    _scrollController.removeListener(_scrollListener);
    _messageController.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
