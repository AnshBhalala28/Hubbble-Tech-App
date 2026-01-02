import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';

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

  // bool isDark = true;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),
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

                            // 2. મીડલ રો: અવતાર અને વિગતો
                            Row(
                              children: [
                                // સર્ક્યુલર પ્રોફાઇલ આઈકોન
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
                        (_) =>  Center(
                          child: CircularProgressIndicator(
                            color:theme.isDark?Colors.white: AppColors.maincolor,
                          ),
                        ),
                    newPageProgressIndicatorBuilder:
                        (_) =>  Center(
                          child: CircularProgressIndicator(
                            color:theme.isDark?Colors.white: AppColors.maincolor,
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
}
