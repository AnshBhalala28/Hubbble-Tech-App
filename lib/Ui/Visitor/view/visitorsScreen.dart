import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../HomeScreen/Provider/homescreenProvider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
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
              child: PagedListView<int, Data1>(
                padding: EdgeInsets.zero,
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Data1>(
                  itemBuilder:
                      (ctx, visitor, _) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          elevation: 0.5,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Checked In: ${_formatCheckIn(visitor.checkInDate, visitor.checkInTime)}",
                                  style: TextStyle(
                                    fontSize: 16.5.sp,
                                    color: Colors.green,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                                if (visitor.checkOutDate?.isNotEmpty == true)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.5.h),
                                    child: Text(
                                      "Checked Out: ${_formatCheckIn(visitor.checkOutDate, visitor.checkOutTime)}",
                                      style: TextStyle(
                                        letterSpacing: 1,
                                        color: AppColors.redColor,
                                        fontSize: 16.5.sp,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0.5.h),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 22,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Name: ${capitalizeEachWord(visitor.visitorName?? '')}",
                                        style: TextStyle(
                                          fontSize: 16.5.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (visitor.isContractors?.isNotEmpty == true)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.5.h),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.badge,
                                          size: 22,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          "Type: ${capitalizeEachWord(visitor.isContractors)}",
                                          style: TextStyle(
                                            fontSize: 16.5.sp,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0.5.h),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.vpn_key,
                                        size: 22,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        (visitor.keyLog != null &&
                                                int.tryParse(visitor.keyLog!) !=
                                                    null)
                                            ? (int.parse(visitor.keyLog!) >= 0
                                                ? "Key: Yes"
                                                : "Key: No")
                                            : "Key: No",
                                        style: TextStyle(
                                          fontSize: 16.5.sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // if (visitor.inNote?.isNotEmpty == true)
                                //   Padding(
                                //     padding: EdgeInsets.only(top: 0.5.h),
                                //     child: Row(
                                //       children: [
                                //         const Icon(
                                //           Icons.note,
                                //           size: 22,
                                //           color: Colors.black54,
                                //         ),
                                //         SizedBox(width: 2.w),
                                //         Expanded(
                                //           child: Text(
                                //             "Note: ${visitor.inNote}",
                                //             style: TextStyle(
                                //               fontSize: 16.5.sp,
                                //               fontWeight: FontWeight.w500,
                                //               fontFamily: AppConstants.manrope,
                                //             ),
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                if (visitor.inNote?.isNotEmpty == true)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.5.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.note,
                                          size: 22,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(width: 2.w),

                                        Expanded(
                                          child: ReadMoreText(
                                            "Note: ${visitor.inNote}",
                                            trimLines: 2,
                                            colorClickableText: Colors.black,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: " Read more",
                                            trimExpandedText: " Read less",
                                            moreStyle: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppConstants.manropeBold,
                                              color:AppColors.maincolor,
                                            ),
                                            lessStyle: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.maincolor,
                                              fontFamily: AppConstants.manropeBold,

                                            ),
                                            style: TextStyle(
                                              fontSize: 16.5.sp,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (visitor.reason?.reason?.isNotEmpty == true)
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.5.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.help_outline,
                                          size: 22,
                                          color: Colors.black54,
                                        ),
                                        SizedBox(width: 2.w),
                                        Expanded(
                                          child: ReadMoreText(
                                            "Reason: ${visitor.reason?.reason}",
                                            trimLines: 2,
                                            colorClickableText: Colors.blue,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: ' Read More',
                                            trimExpandedText: ' Read Less',
                                            style: TextStyle(
                                              fontSize: 16.5.sp,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppConstants.manrope,
                                            ),
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
                  firstPageProgressIndicatorBuilder:
                      (_) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.maincolor,
                        ),
                      ),
                  newPageProgressIndicatorBuilder:
                      (_) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.maincolor,
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
          ],
        ),
      ),
    );
  }
}
