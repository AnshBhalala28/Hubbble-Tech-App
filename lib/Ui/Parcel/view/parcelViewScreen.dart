import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Ui/MessageScreen/modal/SendMessageModel.dart';
import 'package:wavee/Utils/checkInternetConnection.dart';
import 'package:wavee/Utils/colors.dart';
import 'package:wavee/Utils/errorDialog.dart';
import 'package:wavee/Utils/loader.dart';

import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/customButton.dart' show batan;
import '../../MessageScreen/Provider/messageScreenProvider.dart';
import '../../MessageScreen/view/messageScreen.dart';
import '../Provider/parcelProvider.dart';
import '../modal/parcel_model.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  final PagingController<int, Data1> _pagingController = PagingController(
    firstPageKey: 1,
  );
  int selectedCategory = 0;
  final List<String> categories = ['All', 'Collected', 'Awaiting'];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(
      (pageKey) => ParselViewApi(pageKey),
    );
  }

  // bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 6.h),
              TitleBar(
                back: () => Get.back(),
                title: "Parcels",
                drawerCallback: () {},
              ),
              SizedBox(height: 3.h),

              // --- UPDATED CATEGORY TABS ---
              SizedBox(
                height: 5.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedCategory == index;
                    return GestureDetector(
                      onTap: () {
                        if (selectedCategory != index) {
                          setState(() => selectedCategory = index);
                          _pagingController.refresh();
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 3.w),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? isSelected
                                      ? AppColors.white
                                      : const Color(0xFF212121)
                                  : isSelected
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            fontSize: 15.sp,
                            color:
                                isDark
                                    ? isSelected
                                        ? Colors.black
                                        : Colors.grey[600]
                                    : isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontFamily: AppConstants.manropeBold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 3.h),

              // --- UPDATED LIST ---
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 2.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkOptional : AppColors.white,

                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: PagedListView<int, Data1>(
                    pagingController: _pagingController,
                    padding: EdgeInsets.zero,

                    builderDelegate: PagedChildBuilderDelegate<Data1>(
                      itemBuilder: (context, parcel, index) {
                        // Status Logic
                        bool isCollected =
                            parcel.deliveryStatus?.toLowerCase() == "collected";
                        Color statusColor =
                            isCollected
                                ? const Color(0xFF00A67E)
                                : isDark
                                ? Color(0xf0CBB88C)
                                : const Color(0xFF4A6FA5);
                        IconData statusIcon =
                            isCollected
                                ? Icons.check_circle_outline
                                : Icons.access_time;

                        return Container(
                          margin: EdgeInsets.only(bottom: 2.h),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xf0252525) : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Status Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isCollected ? "Collected" : "Awaiting",
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    formatDateTime(parcel.createdAt),
                                    // Ensure this helper exists
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.sp,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),

                              // Content Row (Icon + Text)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Circular Box Icon
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? Color(0xf036342F)
                                              : const Color(0xFFF0F2F5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AppConstants.parcel,
                                      width: 8.w,
                                      color:
                                          isDark
                                              ? Color(0xf0CBB88C)
                                              : AppColors.lightText,
                                    ),
                                  ),
                                  const SizedBox(width: 15),

                                  // Merchant Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          parcel.comment ?? "Merchant Name",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isDark
                                                    ? AppColors.white
                                                    : Colors.black,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                        SizedBox(height: 1.5.h),
                                        Row(
                                          children: [
                                            Text(
                                              "ID-${parcel.id ?? '0000'}",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13.sp,
                                                fontFamily: AppConstants.manrope,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isCollected
                                                  ? "Concierge Desk"
                                                  : "In Transit",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13.sp,
                                                fontFamily: AppConstants.manrope,
                                              ),
                                            ),
                                            Spacer(),
                                            // GestureDetector(
                                            //   onTap: () {
                                            //     Get.to(
                                            //             () =>
                                            //             MessageScreen(
                                            //               chatName: "",
                                            //               type: "parcels",
                                            //               conciergeID: parcel
                                            //                   .collectedBy ?? "",
                                            //               parcelNumber: "${parcel
                                            //                   .id ?? "N/A"}",
                                            //               parcelName: parcel
                                            //                   .comment ?? "",
                                            //               parcelStatus: isCollected
                                            //                   ? "Concierge Desk"
                                            //                   : "In Transit",
                                            //             )
                                            //     );
                                            //   },
                                            //   child: Container(
                                            //     padding: EdgeInsets.all(10),
                                            //     decoration: BoxDecoration(
                                            //         color: AppColors.lightText
                                            //             .withValues(alpha: .2),
                                            //         shape: BoxShape.circle
                                            //     ),
                                            //     child: SvgPicture.asset(
                                            //       AppConstants.chatHomeIcon,
                                            //       width: 6.w, height: 6.w,
                                            //
                                            //       color: theme.isDark ? const Color(
                                            //           0xFF4B5D8A) : AppColors
                                            //           .lightText,
                                            //     ),
                                            //   ),
                                            // )

                                            GestureDetector(
                                              onTap: () {
                                                _openReplyBottomSheet(parcel, isCollected
                                                                      ? "Concierge Desk"
                                                                      : "In Transit");
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: AppColors.lightText.withValues(alpha: .2),
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
                        );
                      },
                      firstPageProgressIndicatorBuilder:
                          (_) => Center(
                            child: CircularProgressIndicator(
                              color: isDark ? Colors.white : AppColors.maincolor,
                            ),
                          ),
                      newPageProgressIndicatorBuilder:
                          (_) => Center(
                            child: CircularProgressIndicator(
                              color: isDark ? Colors.white : AppColors.maincolor,
                            ),
                          ),
                    ),
                  ),
                ).paddingOnly(bottom: 1.h),
              ),
            ],
          ).paddingOnly(left: 3.w, right: 3.w),
          if (isSending)
            Container(decoration: BoxDecoration(color: Colors.black.withValues(alpha: .2)),child: Loader(),)
        ],
      ),
    );
  }

  // API Call Logic (Filtered to match tabs)
  Future<void> ParselViewApi(int pageKey) async {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "page": pageKey.toString(),
    };
    try {
      final response = await ParcelProvider().getParcelApi(data);
      final parcelViewModal = ParcelViewModal.fromJson(response.data);
      final allItems = parcelViewModal.data?.data ?? [];

      // Filter logic based on tab index
      final filteredItems =
          allItems.where((parcel) {
            if (selectedCategory == 1)
              return parcel.deliveryStatus?.toLowerCase() == "collected";
            if (selectedCategory == 2)
              return parcel.deliveryStatus?.toLowerCase() ==
                  "pending"; // or your 'awaiting' status
            return true;
          }).toList();

      final isLastPage = pageKey >= (parcelViewModal.data?.totalPages ?? 1);
      if (isLastPage) {
        _pagingController.appendLastPage(filteredItems);
      } else {
        _pagingController.appendPage(filteredItems, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
  final TextEditingController msgController = TextEditingController();

  void _openReplyBottomSheet(Data1 visitor, String isCheckedIn) {
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
                                "Parcel ID: #ID-${visitor.id}",
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
                              SendMessagApi(visitor.collectedBy, visitor.id.toString());
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
      "msg_to":'parcels',
      "parcel_id":parcelID??"" ,

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
