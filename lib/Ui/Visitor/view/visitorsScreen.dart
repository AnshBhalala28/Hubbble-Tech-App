import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/ui/message_screen/modal/SendMessageModel.dart';
import 'package:wavee/ui/message_screen/provider/messageScreenProvider.dart';
import 'package:wavee/utils/checkInternetConnection.dart';
import 'package:wavee/utils/errorDialog.dart';
import 'package:wavee/utils/loader.dart';

import '../../../utils/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/customAppBar.dart';
import '../../../utils/customButton.dart';
import '../../home_screen/provider/homescreenProvider.dart';
import '../modal/latest_visitor_modal/latest_visitor_modal.dart';

class VisitorScreen extends StatefulWidget {
  final String? latestVisitor;

  const VisitorScreen({super.key, this.latestVisitor});

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final PagingController<int, Data1> _pagingController = PagingController(
    firstPageKey: 1,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(LatestVisitorApi);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> LatestVisitorApi(int pageKey) async {
    final params = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",

      "page": pageKey.toString(),
    };
    try {
      var response = await HomeProvider().visitorShowCountApi(params);
      final model = LatestVisitorModal.fromJson(response.data);
      final items = model.data?.data ?? [];
      final totalPages = model.data?.totalPages ?? 1;
      final isLast = pageKey >= totalPages;

      await Future.delayed(const Duration(milliseconds: 400));

      if (isLast) {
        _pagingController.appendLastPage(items);
      } else {
        _pagingController.appendPage(items, pageKey + 1);
      }
    } catch (e, stacktrace) {
      print("sss$stacktrace");
      _pagingController.error = e;
    }
  }

  String _formatCheckIn(String? date, String? time) {
    if (date?.isEmpty != false || time?.isEmpty != false) return "N/A";
    try {
      final dt = DateTime.parse("$date $time");
      return "${DateFormat('dd MMM yyyy').format(dt)}, ${DateFormat('hh:mm a').format(dt)}";
    } catch (_) {
      return "Invalid Date";
    }
  }

  String capitalizeEachWord(String? s) {
    if (s == null || s.isEmpty) return '';
    return s
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(' ');
  }

  // bool isDark = true;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            child: Column(
              children: [
                SizedBox(height: 4.h),
                TitleBar(
                  back: () => Get.back(),
                  title: 'Visitors',
                  drawerCallback: () {},
                ),
                SizedBox(height: 1.5.h),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 2.w, right: 2.w),
                    decoration: BoxDecoration(
                      color:
                      theme.isDark ? AppColors.darkOptional : AppColors.white,

                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: PagedListView<int, Data1>(
                      padding: EdgeInsets.zero,
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Data1>(
                        itemBuilder: (ctx, visitor, _) {
                          bool isCheckedIn = visitor.checkOutDate?.isEmpty ?? true;

                          return Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 2,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                              theme.isDark ? Color(0xFF252525) : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color:
                                theme.isDark
                                    ? Color(0xf0313131)
                                    : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isCheckedIn
                                              ? Icons.check_circle_outline
                                              : Icons.access_time,
                                          size: 20,
                                          color:
                                          isCheckedIn
                                              ? const Color(0xFF27AE60)
                                              : Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isCheckedIn
                                              ? "Checked In"
                                              : "Checked Out",
                                          style: TextStyle(
                                            color:
                                            isCheckedIn
                                                ? const Color(0xFF27AE60)
                                                : Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.sp,
                                            fontFamily: AppConstants.manropeBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatDateTimeDesign(
                                        isCheckedIn
                                            ? visitor.checkInDate
                                            : visitor.checkOutDate,
                                        isCheckedIn
                                            ? visitor.checkInTime
                                            : visitor.checkOutTime,
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14.sp,

                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),


                                Row(
                                  children: [

                                    Container(
                                      padding: EdgeInsets.all(12),

                                      decoration: BoxDecoration(
                                        color:
                                        theme.isDark
                                            ? Color(0xf036342F)
                                            : const Color(0xFFF0F2F5),
                                        // લાઈટ બ્લુઈશ ગ્રે બેકગ્રાઉન્ડ
                                        shape: BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/Svg/visitor1.svg",
                                        width: 8.w,
                                        color:
                                        theme.isDark
                                            ? Color(0xf0CBB88C)
                                            : AppColors.lightText,
                                      ),
                                    ),
                                    const SizedBox(width: 15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            capitalizeEachWord(
                                              visitor.visitorName ?? '',
                                            ),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color:
                                              theme.isDark
                                                  ? AppColors.white
                                                  : Color(0xFF2D3748),
                                              fontFamily: AppConstants.manropeBold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            capitalizeEachWord(
                                              visitor.isContractors ?? 'Visitor',
                                            ),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey.shade500,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                          const SizedBox(height: 6),

                                          // કી આઈકોન અને ટેક્સ્ટ
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.vpn_key_outlined,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                (visitor.keyLog != null &&
                                                    int.tryParse(
                                                      visitor.keyLog!,
                                                    ) !=
                                                        null &&
                                                    int.parse(
                                                      visitor.keyLog!,
                                                    ) >=
                                                        0)
                                                    ? "Key: Yes"
                                                    : "Key: No",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey.shade400,
                                                  fontFamily: AppConstants.manrope,
                                                ),
                                              ),
                                              Spacer(),
                                              // GestureDetector(
                                              //   onTap: () {
                                              //     Get.to(
                                              //             ()=>MessageScreen(
                                              //           chatName: "",
                                              //           type: "visitors",
                                              //           conciergeID: visitor.concigereId??"",
                                              //               visitorName:visitor.visitorName??"N/A" ,
                                              //               visitorStatus:  isCheckedIn
                                              //                   ? "Checked In"
                                              //                   : "Checked Out",
                                              //               visitorPurpose: visitor.reason?.reason??"N/A" ,
                                              //               visitorID:visitor.id.toString()??"N/A" ,
                                              //         )
                                              //
                                              //     );
                                              //   },
                                              //   child: SvgPicture.asset(
                                              //     AppConstants.chatHomeIcon,
                                              //     width: 6.w, height: 6.w,
                                              //
                                              //     color: theme.isDark ? const Color(
                                              //         0xFF4B5D8A) : AppColors.lightText,
                                              //   ),
                                              // ),
                                              GestureDetector(
                                                onTap: () {
                                                  // Get.to(
                                                  //         ()=>MessageScreen(
                                                  //       chatName: "",
                                                  //       type: "visitors",
                                                  //       conciergeID: visitor.concigereId??"",
                                                  //       visitorName:visitor.visitorName??"N/A" ,
                                                  //       visitorStatus:  isCheckedIn
                                                  //           ? "Checked In"
                                                  //           : "Checked Out",
                                                  //       visitorPurpose: visitor.reason?.reason??"N/A" ,
                                                  //       visitorID:visitor.id.toString()??"N/A" ,
                                                  //     )
                                                  //
                                                  // );
                                                  _openReplyBottomSheet(
                                                      visitor, isCheckedIn);
                                                },

                                                child: Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.lightText
                                                        .withValues(alpha: .2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    AppConstants.chatHomeIcon,
                                                    width: 6.w,
                                                    height: 6.w,
                                                    color: theme.isDark
                                                        ? const Color(0xFF4B5D8A)
                                                        : AppColors.lightText,
                                                  ),
                                                ),
                                              ),


                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).paddingOnly(top: 1.h);
                        },

                        firstPageProgressIndicatorBuilder:
                            (_) => Center(
                          child: CircularProgressIndicator(
                            color:
                            theme.isDark
                                ? Colors.white
                                : AppColors.maincolor,
                          ),
                        ),
                        newPageProgressIndicatorBuilder:
                            (_) => Center(
                          child: CircularProgressIndicator(
                            color:
                            theme.isDark
                                ? Colors.white
                                : AppColors.maincolor,
                          ),
                        ),
                        noItemsFoundIndicatorBuilder:
                            (_) => Center(
                          child: Text(
                            'No Visitors Available',
                            style: TextStyle(
                              fontFamily: AppConstants.manrope,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        firstPageErrorIndicatorBuilder:
                            (_) => Center(
                          child: Text(
                            'No Visitors Available',
                            style: TextStyle(
                              fontFamily: AppConstants.manrope,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        newPageErrorIndicatorBuilder:
                            (_) => Center(
                          child: Text(
                            'Failed to load more',
                            style: TextStyle(
                              fontFamily: AppConstants.manrope,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isSending)
            Container(decoration: BoxDecoration(color: Colors.black.withValues(alpha: .2)),child: Loader(),),
        ],
      ),
    );
  }

  String _formatDateTimeDesign(String? date, String? time) {
    if (date == null || time == null || date.isEmpty) return "";
    try {
      final dt = DateTime.parse("$date $time");
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (_) {
      return "";
    }
  }
  final TextEditingController msgController = TextEditingController();

  void _openReplyBottomSheet(Data1 visitor, bool isCheckedIn) {
    final theme = Provider.of<ThemeController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.isDark ? Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // પકડવા માટેની ઉપરની લીટી (Handle)
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: theme.isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // હેડર સેક્શન
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.lightText.withOpacity(0.1),
                            child: Icon(Icons.reply_rounded, color: AppColors.lightText),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reply to Concierge",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: theme.isDark ? Colors.white : Colors.black87,
                                  fontFamily: AppConstants.manropeBold,
                                ),
                              ),
                              Text(
                                "Regarding: ${visitor.visitorName}",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // મેસેજ ઇનપુટ ફિલ્ડ
                      Container(
                        decoration: BoxDecoration(
                          color: theme.isDark ? Color(0xFF2A2A2A) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.isDark ? Colors.white10 : Colors.grey.shade200,
                          ),
                        ),
                        child: TextField(
                          controller: msgController,
                          maxLines: 4,
                          minLines: 1,
                          style: TextStyle(
                            color: theme.isDark ? Colors.white : Colors.black,
                            fontFamily: AppConstants.manrope,
                          ),
                          decoration: InputDecoration(
                            hintText: "Write your message here...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15.sp,
                            ),
                            contentPadding: const EdgeInsets.all(18),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // સેન્ડ બટન
                      SizedBox(
                        width: double.infinity,
                        child: batan(
                          title: "Send Message",
                          route: () {
                            if (msgController.text.trim().isNotEmpty) {
                              SendMessagApi(visitor.concigereId, visitor.id.toString());
                              Get.back();

                            } else{
                              Get.snackbar(
                                icon: Icon(Icons.info,color: AppColors.white,),
                                "Info",
                                "Message cannot be empty",
                                backgroundColor: Colors.red.withOpacity(0.8),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                            }
                          },
                          color: AppColors.lightText,
                          fontcolor: AppColors.white,
                          fontFamily: AppConstants.manropeBold,
                          height: 5.h,
                          radius: 15.0,
                          fontsize: 16.sp,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool isSending=false;
  void SendMessagApi(String conciergeID,parcelID) {
    setState(() {
      isSending = true;
    });

    final Map<String, String> data = {
      "message": msgController.text.trim(),
      "sender_id": loginModel?.data?.user?.id.toString() ?? '',
      "receiver_id":conciergeID.toString() ,
      "msg_to":'visitors',
      "visitor_id":parcelID??"" ,

      "type": "1",

    };
    log('Message sent data ${data}');

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await MessageProvider().sendMessageApi(data);
          sendMessageModel = SendMessageModel.fromJson(response.data);

          if (response.statusCode == 200 && sendMessageModel?.status == 200) {
            log('✅ Message sent successfully!');
            setState(() {
              isSending = false;
              msgController.clear();
            });
            Get.snackbar(
              "Success",
              "Message sent to concierge",
              backgroundColor: Colors.green.withOpacity(0.8),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            log('❌ Failed to send message: ${response.data}');
            setState(() {
              isSending = false;
            });
            buildErrorDialog(context, 'Error',
                sendMessageModel?.message ?? 'Failed to send message');
          }
        } catch (e, stackTrace) {
          log('❌ Exception in SendMessagApi: $e');
          log('📚 StackTrace: $stackTrace');
          setState(() {
            isSending = false;
          });
          buildErrorDialog(
              context, 'Error', 'Something went wrong: ${e.toString()}');
        }
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}