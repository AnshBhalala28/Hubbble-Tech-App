import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../Provider/parcelProvider.dart';
import '../modal/parcel_model.dart';

class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyParcel =
      GlobalKey<ScaffoldState>();
  final PagingController<int, Data1> _pagingController = PagingController(
    firstPageKey: 1,
  );

  int selectedCategory = 0;

  final List<String> categories = ['All', 'Collected', 'Awaiting Collection'];

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      ParselViewApi(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
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
              title: "Parcels",
              drawerCallback: () {},
            ),
            SizedBox(height: 3.h),
            SizedBox(
              height: 5.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (selectedCategory != index) {
                        setState(() {
                          selectedCategory = index;
                        });
                        _pagingController.refresh(); // Reload data
                      }
                    },
                    child: Container(
                      height: 5.h,
                      padding: EdgeInsets.symmetric(
                        vertical: 1.h,
                        horizontal: 7.w,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.grey),
                        color:
                            selectedCategory == index
                                ? AppColors.maincolor
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          fontSize: 17.sp,
                          color:
                              selectedCategory == index
                                  ? Colors.white
                                  : Colors.black,
                          fontFamily:
                              selectedCategory == index
                                  ? AppConstants.manropeBold
                                  : AppConstants.manrope,
                          // fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: PagedListView<int, Data1>(
                pagingController: _pagingController,
                padding: EdgeInsets.zero,

                builderDelegate: PagedChildBuilderDelegate<Data1>(
                  itemBuilder: (context, parcel, index) {
                    if (!_isParcelVisible(parcel)) return const SizedBox();

                    Map<String, Color> statusColors = {
                      "Pending": Colors.orange,
                      "Collected": Colors.green,
                      "Cancelled": Colors.red,
                      "Shipped": Colors.blue,
                      "Processing": Colors.purple,
                    };

                    String status = parcel.deliveryStatus ?? "Pending";
                    Color statusColor = statusColors[status] ?? Colors.grey;

                    return Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(20),

                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.pending_rounded,
                                  color: statusColor,
                                  size: 18.sp,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${status[0].toUpperCase()}${status.substring(1)}',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            ReadMoreText(
                              parcel.comment?.isNotEmpty == true
                                  ? '${parcel.comment![0].toUpperCase()}${parcel.comment!.substring(1)}'
                                  : '',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppConstants.manrope,
                              ),
                              trimLines: 2,
                              colorClickableText: Colors.blue,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: ' Show More',
                              trimExpandedText: ' Show Less',
                              moreStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.maincolor,
                              ),
                              lessStyle: const TextStyle(
                                fontSize: 16,
                                fontFamily: AppConstants.manrope,
                                fontWeight: FontWeight.bold,
                                color: AppColors.maincolor,
                              ),
                            ),
                            if (parcel.unitsnumber != null)
                              Text(
                                'Apartment No: ${parcel.unitsnumber?.blockNumber ?? ""}-${parcel.unitsnumber?.flatNumber ?? ""}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            SizedBox(height: 2.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ' ${parcel.amount ?? ""}',
                                  style: const TextStyle(
                                    fontFamily: AppConstants.manrope,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formatDateTime(parcel.createdAt),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).paddingOnly(bottom: 16);
                  },
                  noItemsFoundIndicatorBuilder:
                      (context) => Center(
                        child: Text(
                          'No Parcels Available',
                          style: TextStyle(
                            fontFamily: AppConstants.manrope,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  firstPageProgressIndicatorBuilder:
                      (context) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.maincolor,
                        ),
                      ),
                  newPageProgressIndicatorBuilder:
                      (context) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.maincolor,
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

  bool _isParcelVisible(Data1 parcel) {
    if (selectedCategory == 1 && parcel.deliveryStatus != "Collected") {
      return false;
    }
    if (selectedCategory == 2 && parcel.deliveryStatus != "Pending") {
      return false;
    }
    return true;
  }

  Future<void> ParselViewApi(int pageKey) async {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "page": pageKey.toString(),
    };
    try {
      final response = await ParcelProvider().getParcelApi(data);
      final parcelViewModal = ParcelViewModal.fromJson(response.data);
      final allItems = parcelViewModal.data?.data ?? [];
      final newItems =
          allItems.where((parcel) {
            if (selectedCategory == 1) {
              return parcel.deliveryStatus == "Collected";
            }
            if (selectedCategory == 2) {
              return parcel.deliveryStatus == "Pending";
            }
            return true;
          }).toList();

      final totalPages = parcelViewModal.data?.totalPages ?? 1;
      final isLastPage = pageKey >= totalPages;

      await Future.delayed(const Duration(milliseconds: 600));

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
      if (pageKey == 1 && newItems.isEmpty) {
        _pagingController.appendLastPage([]);
      }
    } catch (error,stacktrace) {
      _pagingController.error = error;
      print("errorerrorerror$stacktrace");
    }
  }
}
