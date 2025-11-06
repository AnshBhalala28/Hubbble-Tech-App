// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:sizer/sizer.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:wavee/Screen/HomeNewPage/View/homenewpage.dart';
// import 'package:wavee/comman/loader.dart';
//
// import '../../../comman/Custom_AppBar.dart';
// import '../../../comman/SideMenu.dart';
// import '../../../comman/check_inernet_connecty.dart';
// import '../../../comman/colors.dart';
// import '../../../comman/const.dart';
// import '../../../comman/custom_batan.dart';
// import '../../../comman/error_dialog.dart';
// import '../Model/booking_model.dart';
// import '../Provider/booking_provider.dart';
// import 'booking_screen.dart';
// import 'form_screen.dart';
//
// class BookAmenities_Screen extends StatefulWidget {
//   final String? id;
//
//   const BookAmenities_Screen({super.key, this.id});
//
//   @override
//   State<BookAmenities_Screen> createState() => _BookAmenities_ScreenState();
// }
//
// class _BookAmenities_ScreenState extends State<BookAmenities_Screen> {
//   final GlobalKey<ScaffoldState> _scaffoldKeyBookAmenities =
//       GlobalKey<ScaffoldState>();
//   bool isLoading = false;
//   List<Map<String, dynamic>> dates = [];
//   String selectedValue = 'days';
//   int selectedIndex = 0;
//   String? selectedDate;
//   DateTime now = DateTime.now();
//   DateTime selectedDay = DateTime.now();
//   DateTime? selectedYear;
//   bool load = false;
//   bool isGlobalLoading = false;
//
//   @override
//   void initState() {
//     _generateDatesBasedOnSelection();
//     setState(() {
//       isLoading = true;
//       load = true;
//     });
//     AmenitiesApi();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: SideMenu(),
//       key: _scaffoldKeyBookAmenities,
//       backgroundColor: AppColors.bgcolor,
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
//               child: Column(
//                 children: [
//                   SizedBox(height: 4.h),
//                   TitleBar(
//                     back: () {
//                       Get.to(HomePage(userName: "", selected: 1));
//                     },
//                     title: 'Amenities',
//                     drawerCallback: () {
//                       _scaffoldKeyBookAmenities.currentState?.openDrawer();
//                     },
//                   ),
//                   SizedBox(height: 3.h),
//                   isLoading
//                       ? Loader().paddingOnly(top: 35.h)
//                       : aneminitiesDataModel?.data?.data == null
//                       ? Center(
//                         child: Text(
//                           "No Amenities Available",
//                           style: TextStyle(
//                             fontSize: 17.sp,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.black,
//                             fontFamily: AppConstants.manrope,
//                           ),
//                         ).paddingOnly(top: 35.h),
//                       )
//                       : SizedBox(
//                         child: ListView.builder(
//                           shrinkWrap: true,
//                           scrollDirection: Axis.vertical,
//                           physics: NeverScrollableScrollPhysics(),
//                           padding: EdgeInsets.zero,
//                           itemCount:
//                               aneminitiesDataModel?.data?.data?.length ?? 0,
//                           itemBuilder: (context, index) {
//                             var booking =
//                                 aneminitiesDataModel?.data?.data?[index];
//
//                             return Stack(
//                               alignment: Alignment.topRight,
//                               children: [
//                                 Material(
//                                   elevation: 1,
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Get.to(
//                                         () => Form_Screen(
//                                           amenites_id:
//                                               booking?.id.toString() ?? '',
//                                           isPage: false,
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       height: 33.h,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(12),
//                                         color: Colors.white,
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           ClipRRect(
//                                             borderRadius: BorderRadius.only(
//                                               topLeft: Radius.circular(12),
//                                               topRight: Radius.circular(12),
//                                             ),
//                                             child: CachedNetworkImage(
//                                               imageUrl:
//                                                   (booking?.imageUrl != null &&
//                                                           booking!
//                                                               .imageUrl!
//                                                               .isNotEmpty)
//                                                       ? booking!.imageUrl!.first
//                                                       : "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png",
//                                               fit: BoxFit.cover,
//                                               width: double.infinity,
//                                               height: 20.h,
//                                               placeholder:
//                                                   (context, url) => Center(
//                                                     child:
//                                                         CircularProgressIndicator(),
//                                                   ),
//                                               errorWidget:
//                                                   (
//                                                     context,
//                                                     url,
//                                                     error,
//                                                   ) => Image(
//                                                     image: NetworkImage(
//                                                       "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png",
//                                                     ),
//                                                   ),
//                                             ),
//                                           ),
//                                           SizedBox(height: 1.h),
//                                           Padding(
//                                             padding: EdgeInsets.symmetric(
//                                               horizontal: 2.w,
//                                             ),
//                                             child: Text(
//                                               booking?.name ?? "No Title",
//                                               maxLines: 1,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                 fontSize: 16.sp,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily:
//                                                     AppConstants.manrope,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(height: 0.5.h),
//                                           Padding(
//                                             padding: EdgeInsets.symmetric(
//                                               horizontal: 2.w,
//                                             ),
//                                             child: Text(
//                                               booking?.description ??
//                                                   "No Description",
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                 fontSize: 15.sp,
//                                                 color: Colors.grey[700],
//                                                 fontFamily:
//                                                     AppConstants.manrope,
//                                               ),
//                                             ),
//                                           ),
//                                           Spacer(),
//                                           Padding(
//                                             padding: EdgeInsets.only(
//                                               right: 2.w,
//                                               bottom: 1.h,
//                                             ),
//                                             child: Align(
//                                               alignment: Alignment.bottomRight,
//                                               child: Icon(
//                                                 Icons.arrow_forward,
//                                                 size: 18.sp,
//                                                 color: AppColors.maincolor,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ).marginOnly(bottom: 1.h),
//                                 Positioned(
//                                   top: 1.h,
//                                   right: 1.w,
//                                   child: batan(
//                                     title: "Book Now",
//                                     route: () {
//                                       Get.to(
//                                         () => Form_Screen(
//                                           amenites_id:
//                                               booking?.id.toString() ?? '',
//                                           isPage: false,
//                                         ),
//                                       );
//                                     },
//                                     color: AppColors.maincolor,
//                                     fontcolor: Colors.white,
//                                     height: 4.h,
//                                     width: 22.w,
//                                     fontsize: 15.sp,
//                                     radius: 7.0,
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       ),
//                 ],
//               ),
//             ),
//           ),
//           if (isGlobalLoading)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: Center(child: Loader()),
//             ),
//         ],
//       ),
//     );
//   }
//
//
//   AmenitiesApi() async {
//     checkInternet().then((internet) async {
//       if (internet) {
//         try {
//           var response = await AmenitiesProvider().amenitiesApi(
//             loginModel?.data?.user?.id.toString() ?? '',
//             "",
//             "",
//           );
//           aneminitiesDataModel = AmenitiesModel.fromJson(response.data);
//           if (response.statusCode == 200) {
//             setState(() {
//               aneminitiesDataModel = aneminitiesDataModel;
//               isLoading = false;
//             });
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         } catch (e, stackTrace) {
//
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
//   String formatDate(String? rawDate) {
//     if (rawDate == null || rawDate.isEmpty) return "N/A";
//     try {
//       DateTime parsedDate = DateTime.parse(rawDate);
//       return DateFormat('dd-MM-yyyy').format(parsedDate);
//     } catch (e) {
//       return "Invalid date";
//     }
//   }
//
//   void _generateDatesBasedOnSelection() {
//     DateTime today = DateTime.now();
//     dates.clear();
//
//     if (selectedValue == "days") {
//       DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
//       for (int i = 0; i < 7; i++) {
//         DateTime date = startOfWeek.add(Duration(days: i));
//         dates.add({
//           'day': date.day.toString(),
//           'weekday': _getWeekday(date.weekday),
//           'fullDate': date,
//         });
//
//         if (date.day == today.day &&
//             date.month == today.month &&
//             date.year == today.year) {
//           selectedIndex = i;
//         }
//       }
//     }
//
//     setState(() {});
//   }
//
//   DateTime? selectedCalendarDate;
//
//   String _getWeekday(int weekday) {
//     switch (weekday) {
//       case 1:
//         return 'Mon';
//       case 2:
//         return 'Tue';
//       case 3:
//         return 'Wed';
//       case 4:
//         return 'Thu';
//       case 5:
//         return 'Fri';
//       case 6:
//         return 'Sat';
//       case 7:
//         return 'Sun';
//       default:
//         return '';
//     }
//   }
//
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sizer/sizer.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../../homePage/View/homenewpage.dart';
import '../Model/booking_model.dart';
import '../Provider/booking_provider.dart';
import 'form_screen.dart';

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
