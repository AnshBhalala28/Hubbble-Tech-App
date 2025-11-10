import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/customBatan.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../../HomeScreen/View/homePage.dart';
import '../Provider/bookingsProvider.dart';
import '../modal/bookingModel.dart';
import 'amenitiesDetailsScreen.dart';

class BookAmenities_Screen extends StatefulWidget {
  final String? id;

  const BookAmenities_Screen({super.key, this.id});

  @override
  State<BookAmenities_Screen> createState() => _BookAmenities_ScreenState();
}

class _BookAmenities_ScreenState extends State<BookAmenities_Screen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyBookAmenities =
      GlobalKey<ScaffoldState>();
  final PagingController<int, Data1> _pagingController = PagingController(
    firstPageKey: 1,
  );

  String? userId;
  bool isGlobalLoading = false;

  @override
  void initState() {
    super.initState();
    userId = loginModel?.data?.user?.id.toString() ?? '';
    _pagingController.addPageRequestListener((pageKey) {
      fetchAmenitiesPage(pageKey);
    });
  }

  Future<void> fetchAmenitiesPage(int pageKey) async {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await AmenitiesProvider().amenitiesApi(
            userId!,
            "",
            "",
            pageKey.toString(),
          );
          var model = AmenitiesModel.fromJson(response.data);

          final newItems = model.data?.data ?? [];
          final isLastPage = (model.data?.lastPage ?? 1) <= pageKey;

          if (isLastPage) {
            _pagingController.appendLastPage(newItems);
          } else {
            _pagingController.appendPage(newItems, pageKey + 1);
          }
        } catch (e) {
          _pagingController.error = e;
        }
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            child: Column(
              children: [
                SizedBox(height: 4.h),
                TitleBar(
                  back: () => Get.to(HomePage(userName: "", selected: 1)),
                  title: 'Amenities',
                  drawerCallback: () {},
                ),
                SizedBox(height: 3.h),
                Expanded(
                  child: PagedListView<int, Data1>(
                    pagingController: _pagingController,
                    reverse: false,
                    padding: EdgeInsets.zero,
                    builderDelegate: PagedChildBuilderDelegate<Data1>(
                      noItemsFoundIndicatorBuilder:
                          (_) => Center(
                            child: Text(
                              "No Amenities Available",
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                                fontFamily: AppConstants.manrope,
                              ),
                            ).paddingOnly(bottom: 10.h),
                          ),
                      itemBuilder:
                          (context, booking, index) => Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(12),
                                child: GestureDetector(
                                  onTap:
                                      () => Get.to(
                                        () => Form_Screen(
                                          amenites_id: booking.id.toString(),
                                          isPage: false,
                                        ),
                                      ),
                                  child: Container(
                                    height: 33.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            topRight: Radius.circular(12),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                (booking.imageUrl != null &&
                                                        booking
                                                            .imageUrl!
                                                            .isNotEmpty)
                                                    ? booking.imageUrl!.first
                                                    : "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png",
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 20.h,
                                            placeholder:
                                                (context, url) => const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Image.network(
                                                  "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png",
                                                ),
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                          ),
                                          child: Text(
                                            booking.name ?? "No Title",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                          ),
                                          child: Text(
                                            booking.description ??
                                                "No Description",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.grey[700],
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: 2.w,
                                            bottom: 1.h,
                                          ),
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: Icon(
                                              Icons.arrow_forward,
                                              size: 18.sp,
                                              color: AppColors.maincolor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).marginOnly(bottom: 1.h),
                              Positioned(
                                top: 1.h,
                                right: 1.w,
                                child: batan(
                                  title: "Book Now",
                                  route:
                                      () => Get.to(
                                        () => Form_Screen(
                                          amenites_id: booking.id.toString(),
                                          isPage: false,
                                        ),
                                      ),
                                  color: AppColors.maincolor,
                                  fontcolor: Colors.white,
                                  height: 4.h,
                                  width: 22.w,
                                  fontsize: 15.sp,
                                  radius: 7.0,
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
          if (isGlobalLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
