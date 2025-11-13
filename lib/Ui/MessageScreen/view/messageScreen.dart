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
import 'package:sizer/sizer.dart';

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

  // List<String> messages = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    MessageApi();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      MessageApi();
    });
    log("Business ID AVE CE ${widget.conciergeID}");
    log("Business ID AVE CE ${widget.senderid}");
    log("Business ID AVE CE ${widget.businessID}");
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
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: 'refresh');
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 100,
                    padding: const EdgeInsets.only(top: 20, left: 5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        String friendid =
                            (widget.conciergeID.toString() ==
                                    (loginModel?.data?.user?.id.toString() ??
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
                              lat: AppLat,
                              long: AppLon,
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 30,
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
                                  () =>
                                      UserProfileScreen(id: widget.conciergeID),
                                );
                              } else if (widget.type == "residents") {
                                _timer?.cancel();

                                Get.to(
                                  () =>
                                      AppUserFriendProfileScreen(id: friendid),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.sp),
                              child: CachedNetworkImage(
                                imageUrl: widget.image ?? "",
                                placeholder:
                                    (context, url) => CircleAvatar(
                                      radius: 20.sp,
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                errorWidget:
                                    (context, url, error) => CircleAvatar(
                                      radius: 20.sp,
                                      child: Image.asset(
                                        "assets/images/waveeLogoShort.png",
                                      ),
                                    ),
                                width: 26.sp,
                                height: 26.sp,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 70.w,
                            child: Text(
                              widget.chatName ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppConstants.manrope,
                                fontSize: 19.sp,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  isLoading
                      ? Center(
                        child: Center(child: Loader()),
                      ).paddingOnly(top: 30.h)
                      : messageModel?.data?.length == 0 ||
                          messageModel?.data?.length == null
                      ? Expanded(
                        child: Center(
                          child: Text(
                            "No Messages available",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        ),
                      )
                      : Expanded(
                        child: ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          itemCount: messageModel?.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            bool isMe =
                                messageModel?.data?[index].sender?.id ==
                                loginModel?.data?.user?.id;

                            DateTime? currentMessageDate;
                            try {
                              final created = DateTime.parse(
                                messageModel?.data?[index].createdAt ?? "",
                              );
                              currentMessageDate = DateTime(
                                created.year,
                                created.month,
                                created.day,
                              );
                            } catch (_) {}

                            bool showDateSeparator = false;
                            if (index == messageModel!.data!.length - 1) {
                              showDateSeparator = true;
                            } else {
                              try {
                                final nextMessageDate = DateTime.parse(
                                  messageModel?.data?[index + 1].createdAt ??
                                      "",
                                );
                                final nextDate = DateTime(
                                  nextMessageDate.year,
                                  nextMessageDate.month,
                                  nextMessageDate.day,
                                );

                                if (currentMessageDate != null &&
                                    currentMessageDate != nextDate) {
                                  showDateSeparator = true;
                                }
                              } catch (_) {}
                            }

                            return Column(
                              children: [
                                if (showDateSeparator)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Center(
                                      child: Text(
                                        formatDateTime(
                                          messageModel
                                                  ?.data?[index]
                                                  .createdAt ??
                                              "",
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        isMe
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (!isMe)
                                        CircleAvatar(
                                          radius: 19.sp,
                                          backgroundColor: Colors.grey.shade300,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: widget.image ?? '',
                                              fit: BoxFit.contain,
                                              width: 38.sp,
                                              height: 38.sp,
                                              placeholder:
                                                  (context, url) =>
                                                      const CircularProgressIndicator(
                                                        strokeWidth: 1,
                                                      ),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Image.asset(
                                                    'assets/images/waveeLogoShort.png',
                                                    fit: BoxFit.contain,
                                                    width: 38.sp,
                                                    height: 38.sp,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      if (!isMe) const SizedBox(width: 8),
                                      Flexible(
                                        child: Container(
                                          constraints: BoxConstraints(
                                            minWidth: 60.w,
                                            maxWidth: 80.w,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 1.h,
                                            horizontal: 3.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isMe
                                                    ? AppColors.maincolor
                                                    : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: getMessageWidget(
                                            messageModel?.data?[index],
                                            isMe,
                                          ),
                                        ),
                                      ),
                                      if (isMe) const SizedBox(width: 8),
                                      if (isMe)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            25.sp,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                messageModel
                                                    ?.data?[index]
                                                    .sender
                                                    ?.profile ??
                                                "",
                                            placeholder:
                                                (context, url) => CircleAvatar(
                                                  radius: 18.sp,
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => CircleAvatar(
                                                  radius: 18.sp,
                                                  child: Image.asset(
                                                    "assets/images/waveeLogoShort.png",
                                                  ),
                                                ),
                                            width: 26.sp,
                                            height: 26.sp,
                                            fit: BoxFit.contain,
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
                  isLoading
                      ? const Center(child: Text(""))
                      : widget.chatStatus == 0
                      ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
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
                      )
                      : Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.maincolor,
                              radius: 22,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  selectfile();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  textInputAction: TextInputAction.send,
                                  keyboardType: TextInputType.multiline,

                                  minLines: 1,
                                  // Start with one line
                                  maxLines: 5,
                                  // Expand up to 5 lines (you can increase if needed)
                                  // onSubmitted: (text) {
                                  //   if (text.isNotEmpty) {
                                  //     setState(() {
                                  //       messages.add(text);
                                  //       _messageController.clear();
                                  //     });
                                  //   }
                                  // },
                                  onSubmitted: (value) {
                                    if (_messageController.text
                                        .trim()
                                        .isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Message cannot be empty',
                                          ),
                                          backgroundColor: AppColors.redColor,
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    } else {
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
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Type a message...",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: AppColors.maincolor,
                              radius: 22,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onPressed: () {
                                  if (_messageController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Message cannot be empty',
                                        ),
                                        backgroundColor: AppColors.redColor,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
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
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
              isSending
                  ? Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: Center(child: Loader()),
                    ),
                  )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMessageWidget(message, bool isMe) {
    if (message == null) return const SizedBox.shrink();

    switch (message.messageType) {
      case '1':
        return Text(
          message.message ?? "",
          style: TextStyle(
            fontFamily: AppConstants.manrope,
            color: isMe ? Colors.white : Colors.black,
          ),
        );

      case '2':
        return ClipRRect(
          child: InkWell(
            onTap: () {
              Get.to(PdfView(link: message.file ?? ""));
            },
            child: CachedNetworkImage(
              imageUrl: message.file ?? "",
              // height: 30.h,
              width: 30.w,
              placeholder:
                  (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              errorWidget: (context, url, error) => const Icon(Icons.photo),
            ),
          ),
        );

      case '3':
        return GestureDetector(
          onTap: () {
            Get.to(VideoView(videoUrl: message.file ?? ""));
          },
          child: const Column(
            children: [
              Icon(Icons.play_circle_fill, size: 50, color: Colors.black),
              Text(
                "Play Video",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: AppConstants.manrope,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );

      case '4':
        return GestureDetector(
          onTap: () async {
            Get.to(PdfView(link: message.file ?? ""));
          },
          child: const SizedBox(
            width: 78,
            height: 60,
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, size: 70, color: Colors.white),
                SizedBox(width: 8),
              ],
            ),
          ),
        );

      default:
        return const Text("Unsupported Message Type");
    }
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
          } else {}

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
            setState(() {
              isLoading = false;
              _messageController.clear();
            });
            MessageApi();
          } else {}
        } finally {
          isLoading = false;
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
        isLoading = false;
      }
    });
  }

  selectfile() {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 1.h),
                Text(
                  "Select File Type",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 1.h),
                const Divider(color: Colors.black),
                SizedBox(height: 1.h),
                SizedBox(
                  width: 80.w,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () async {
                              final XFile? photo = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              setState(() {
                                _pickedFile = File(photo!.path);
                                type = 2;
                              });

                              widget.type == "order"
                                  ? SendOrderChatApi()
                                  : SendMessagApi();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 13.w,
                              width: 13.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(80),
                                color: AppColors.maincolor,
                              ),
                              child: Icon(
                                Icons.photo,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            "Photo",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13.sp,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        ],
                      ),
                      // Column(
                      //   children: [
                      //     InkWell(
                      //       onTap: () async {
                      //         final XFile? photo = await _picker.pickVideo(
                      //             source: ImageSource.gallery);
                      //         setState(() {
                      //           type = 3;
                      //           _pickedFile = File(photo!.path);
                      //
                      //
                      //         });
                      //
                      //         widget.type == "order"
                      //             ? SendOrderChatApi()
                      //             : SendMessagApi();
                      //
                      //         Navigator.of(context).pop();
                      //       },
                      //       child: Container(
                      //         height: 13.w,
                      //         width: 13.w,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(80),
                      //           color: AppColors.maincolor,
                      //         ),
                      //         child: Icon(
                      //           CupertinoIcons.videocam_circle_fill,
                      //           color: Colors.white,
                      //           size: 20.sp,
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       height: 0.5.h,
                      //     ),
                      //     Text(
                      //       "Video",
                      //       style: TextStyle(
                      //         color: Colors.black87,
                      //         fontSize: 13.sp,
                      //         fontFamily: AppConstants.manrope,
                      //       ),
                      //     )
                      //   ],
                      // ),
                      // Column(
                      //   children: [
                      //     InkWell(
                      //       onTap: () async {
                      //
                      //         FilePickerResult? result =
                      //             await FilePicker.platform.pickFiles();
                      //         if (result != null) {
                      //           setState(() {
                      //             type = 4;
                      //             _pickedFile =
                      //                 File(result.files.single.path.toString());
                      //
                      //
                      //             widget.type == "order"
                      //                 ? SendOrderChatApi()
                      //                 : SendMessagApi();
                      //           });
                      //         } else {}
                      //         Navigator.of(context).pop();
                      //       },
                      //       child: Container(
                      //         height: 13.w,
                      //         width: 13.w,
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(80),
                      //           color: AppColors.maincolor,
                      //         ),
                      //         child: Icon(
                      //           Icons.file_present_outlined,
                      //           color: Colors.white,
                      //           size: 20.sp,
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(height: 0.5.h),
                      //     Text(
                      //       "File",
                      //       style: TextStyle(
                      //         color: Colors.black87,
                      //         fontSize: 13.sp,
                      //         fontFamily: AppConstants.manrope,
                      //       ),
                      //     )
                      //   ],
                      // ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'pdf',
                                    ], // ✅ Only allow PDF files
                                  );

                              if (result != null) {
                                setState(() {
                                  type = 4;
                                  _pickedFile = File(
                                    result.files.single.path.toString(),
                                  );

                                  widget.type == "order"
                                      ? SendOrderChatApi()
                                      : SendMessagApi();
                                });

                                Navigator.of(context).pop();
                              }
                            },
                            child: Container(
                              height: 13.w,
                              width: 13.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(80),
                                color: AppColors.maincolor,
                              ),
                              child: Icon(
                                Icons.file_present_outlined,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            "PDF",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13.sp,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: 8.w,
                width: 8.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
    showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
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
              isLoading = false;
            });
            _messageController.clear();
            MessageApi();
            _scrollToBottom();
          } else {
            setState(() {
              isSending = false;
              isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            isSending = false;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isSending = false;
          isLoading = false;
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
    _timer!.cancel();
    super.dispose();
  }
}
