import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Product%20Detail%20Page/view/product_detail_page.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../../Add to Cart/model/add_to_cart_model.dart';
import '../../Add to Cart/provider/add_to_cart_provider.dart';
import '../../Add to Cart/view/add_to_cart_view.dart';
import '../../Buy Product/view/buy_product_view.dart';
import '../../Product Detail Page/provider/product_provider.dart';
import '../Model/ServiceDetailsModel.dart';
import '../Provider/service_provider.dart';

class ServiceDetailsPage extends StatefulWidget {
  final String? serviceID;
  final String? businessID;

  const ServiceDetailsPage({super.key, this.serviceID, this.businessID});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  final GlobalKey<ScaffoldState> serviceDetailKey = GlobalKey<ScaffoldState>();
  final CarouselSliderController _controller = CarouselSliderController();
  bool isLoading = false;
  bool isAddReviewLoading = false;
  int _currentIndex = 0;
  final TextEditingController reviewController = TextEditingController();
  double tempRating = 4.0;
  ServiceDetailsModel? servicedetailsmodel;
  List<String> imageList = [];
  List<String> featuresList = [];
  List<String> benefitsList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    ServiceDetail();
  }

  String formatPricingType(String? pricingType) {
    if (pricingType == null) return "";
    String formatted = pricingType.replaceAll("_", " ");

    formatted = formatted[0].toUpperCase() + formatted.substring(1);

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: serviceDetailKey,
      drawer: SideMenu(),
      body: Stack(
        children: [
          isLoading
              ? Center(child: Loader())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  TitleBar(
                    title:
                        servicedetailsmodel?.data?.title
                            .toString()
                            .capitalizeFirst ??
                        "",
                    drawerCallback: () {
                      serviceDetailKey.currentState?.openDrawer();
                    },
                    back: () {
                      Get.back();
                    },
                  ),
                  SizedBox(height: 2.h),
                  isLoading
                      ? Loader().paddingOnly(top: 30.h)
                      : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container(
                              //   height: 25.h,
                              //   width: double.infinity,
                              //   decoration: const BoxDecoration(
                              //     color: AppColors.white,
                              //   ),
                              //   child: servicedetailsmodel?.data?.galleryImages == null ||
                              //       servicedetailsmodel!.data!.galleryImages==0
                              //       ? const Center(
                              //       child: Text("No images available"))
                              //       : CarouselSlider(
                              //     carouselController: _controller,
                              //     options: CarouselOptions(
                              //       height: 25.h,
                              //       autoPlay: true,
                              //       enlargeCenterPage: true,
                              //       viewportFraction: 1.0,
                              //       onPageChanged: (index, reason) {
                              //         setState(() {
                              //           _currentIndex = index;
                              //         });
                              //       },
                              //     ),
                              //     items: servicedetailsmodel!.data!.galleryImages!
                              //         .map((imageUrl) {
                              //       return Builder(
                              //         builder: (BuildContext context) {
                              //           return Stack(
                              //             children: [
                              //               ClipRRect(
                              //                 borderRadius:
                              //                 BorderRadius.circular(10),
                              //                 child: CachedNetworkImage(
                              //                   imageUrl: imageUrl,
                              //                   fit: BoxFit.cover,
                              //                   width: double.infinity,
                              //                   placeholder:
                              //                       (context, url) =>
                              //                   const Center(
                              //                     child:
                              //                     CircularProgressIndicator(
                              //                       color:
                              //                       AppColors.maincolor,
                              //                     ),
                              //                   ),
                              //                   errorWidget: (context, url,
                              //                       error) =>
                              //                   const Center(
                              //                       child: Icon(
                              //                           Icons.error)),
                              //                 ),
                              //               ),
                              //             ],
                              //           );
                              //         },
                              //       );
                              //     }).toList(),
                              //   ),
                              // ),
                              Container(
                                height: 25.h,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                ),
                                child:
                                    (servicedetailsmodel?.data?.galleryImages ==
                                                null ||
                                            servicedetailsmodel!
                                                .data!
                                                .galleryImages!
                                                .isEmpty)
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                servicedetailsmodel
                                                    ?.data
                                                    ?.images ??
                                                "",
                                            // fallback to empty string if image is null
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            placeholder:
                                                (context, url) => const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            AppColors.maincolor,
                                                      ),
                                                ),
                                            errorWidget:
                                                (context, url, error) => Center(
                                                  child: Image(
                                                    image: AssetImage(image),
                                                  ),
                                                ),
                                          ),
                                        )
                                        : CarouselSlider(
                                          carouselController: _controller,
                                          options: CarouselOptions(
                                            height: 25.h,
                                            autoPlay: true,
                                            enlargeCenterPage: true,
                                            viewportFraction: 1.0,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            },
                                          ),
                                          items:
                                              servicedetailsmodel!.data!.galleryImages!.map((
                                                imageUrl,
                                              ) {
                                                return Builder(
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: CachedNetworkImage(
                                                            imageUrl: imageUrl,
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => const Center(
                                                                  child: CircularProgressIndicator(
                                                                    color:
                                                                        AppColors
                                                                            .maincolor,
                                                                  ),
                                                                ),
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  error,
                                                                ) => const Center(
                                                                  child: Image(
                                                                    image: AssetImage(
                                                                      'assets/images/waveeLogoShort.png',
                                                                    ),
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                        ),
                              ),

                              SizedBox(height: 1.h),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children:  servicedetailsmodel!.data!.galleryImages!
                              //       .asMap()
                              //       .entries
                              //       .map((entry) {
                              //     return GestureDetector(
                              //       onTap: () =>
                              //           _controller.animateToPage(entry.key),
                              //       child: Container(
                              //         width: _currentIndex == entry.key ? 10 : 8,
                              //         height: _currentIndex == entry.key ? 10 : 8,
                              //         margin: const EdgeInsets.symmetric(
                              //             horizontal: 4),
                              //         decoration: BoxDecoration(
                              //           shape: BoxShape.circle,
                              //           color: _currentIndex == entry.key
                              //               ? AppColors.maincolor
                              //               : Colors.grey,
                              //         ),
                              //       ),
                              //     );
                              //   }).toList(),
                              // ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    (servicedetailsmodel?.data?.galleryImages !=
                                                    null &&
                                                servicedetailsmodel!
                                                    .data!
                                                    .galleryImages!
                                                    .isNotEmpty
                                            ? servicedetailsmodel!
                                                .data!
                                                .galleryImages!
                                            : [
                                              servicedetailsmodel
                                                      ?.data
                                                      ?.images ??
                                                  "",
                                            ])
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          return GestureDetector(
                                            onTap:
                                                () => _controller.animateToPage(
                                                  entry.key,
                                                ),
                                            child: Container(
                                              width:
                                                  _currentIndex == entry.key
                                                      ? 10
                                                      : 8,
                                              height:
                                                  _currentIndex == entry.key
                                                      ? 10
                                                      : 8,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    _currentIndex == entry.key
                                                        ? AppColors.maincolor
                                                        : Colors.grey,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                              ),

                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  const Icon(Icons.business),
                                  SizedBox(width: 2.w),
                                  Text(
                                    servicedetailsmodel?.data?.businessName ??
                                        "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              Row(
                                children: [
                                  // Container(
                                  //   padding: EdgeInsets.symmetric(
                                  //       horizontal: 3.w, vertical: 1.h),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.white,
                                  //     borderRadius:
                                  //         BorderRadius.circular(12),
                                  //   ),
                                  //   child: Row(
                                  //     children: [
                                  //       Icon(Icons.star,
                                  //           size: 18.sp,
                                  //           color: Colors.orange),
                                  //       SizedBox(width: 2.w),
                                  //       Text(
                                  //         "${servicedetailsmodel?.data?.productRating ?? "0.0"} Rating",
                                  //         style: TextStyle(
                                  //           fontSize: 15.sp,
                                  //           fontWeight: FontWeight.bold,
                                  //           color: Colors.black,
                                  //           fontFamily:
                                  //               AppConstants.manrope,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 18.sp,
                                          color: AppColors.maincolor,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          "${servicedetailsmodel?.data?.duration ?? ""} min",
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 0.5.h),
                              SingleChildScrollView(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 1.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_filled,
                                            size: 18.sp,
                                            color: AppColors.maincolor,
                                          ),
                                          SizedBox(width: 2.w),
                                          SizedBox(
                                            width: 80.w,
                                            child: Text(
                                              "Availability :${servicedetailsmodel?.data?.availability ?? "N/A"} ",
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                  ],
                                ),
                              ),

                              SizedBox(height: 1.5.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.category_rounded,
                                          size: 18.sp,
                                          color: AppColors.maincolor,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          "Category : ${servicedetailsmodel?.data?.categoryName ?? "N/A"} ",
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                ],
                              ),

                              SizedBox(height: 1.5.h),
                              Text(
                                "${servicedetailsmodel?.data?.title.toString().capitalizeFirst ?? ""}",
                                style: TextStyle(
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "£ ${servicedetailsmodel?.data?.price ?? "0.00"}",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Container(
                                width: 92.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ReadMoreText(
                                  servicedetailsmodel?.data?.description ?? "",
                                  trimLines: 4,
                                  trimLength: 145,
                                  colorClickableText: Colors.blue,
                                  trimMode: TrimMode.Length,
                                  trimCollapsedText: ' Show more',
                                  trimExpandedText: ' Show less',
                                  moreStyle: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppConstants.manrope,
                                    letterSpacing: 1,
                                    color: AppColors.maincolor,
                                  ),
                                  lessStyle: TextStyle(
                                    fontSize: 15.sp,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: AppColors.maincolor,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              if (featuresList.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Features",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                        color: AppColors.maincolor,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    ...featuresList.map((feature) {
                                      // return Container(
                                      //   margin: EdgeInsets.only(top: 0.5.h),
                                      //   padding: EdgeInsets.all(8),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.white,
                                      //     borderRadius:
                                      //         BorderRadius.circular(10),
                                      //   ),
                                      //   child: Row(
                                      //     children: [
                                      //       SizedBox(width: 10),
                                      //       Icon(Icons.check_circle_outline,
                                      //           color: AppColors.maincolor),
                                      //       SizedBox(width: 10),
                                      //       Expanded(
                                      //         child: Text(
                                      //           ,
                                      //           style: TextStyle(
                                      //             fontSize: 14.sp,
                                      //             fontFamily:
                                      //                 AppConstants.manrope,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // );
                                      return CustomFeatureCard(
                                        icon: Icons.check_circle_outline,
                                        title: feature,
                                      );
                                    }).toList(),
                                  ],
                                ),

                              if (benefitsList.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 1.5.h),
                                    Text(
                                      "Benefits",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                        color: AppColors.maincolor,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    ...benefitsList.map((benefit) {
                                      // return Container(
                                      //   margin: EdgeInsets.only(top: 0.5.h),
                                      //   padding: EdgeInsets.all(8),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.white,
                                      //     borderRadius:
                                      //         BorderRadius.circular(10),
                                      //   ),
                                      //   child: Row(
                                      //     children: [
                                      //       SizedBox(width: 10),
                                      //       Icon(Icons.stars_rounded,
                                      //           color: AppColors.maincolor),
                                      //       SizedBox(width: 10),
                                      //       Expanded(
                                      //         child: Text(
                                      //           benefit,
                                      //           style: TextStyle(
                                      //             fontSize: 14.sp,
                                      //             fontFamily:
                                      //                 AppConstants.manrope,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // );
                                      return CustomFeatureCard(
                                        icon: Icons.check_circle_outline,
                                        title: benefit,
                                      );
                                    }).toList(),
                                  ],
                                ),

                              SizedBox(height: 10.h),
                              // Space for bottom buttons
                            ],
                          ),
                        ),
                      ),
                ],
              ).paddingOnly(left: 2.w, right: 2.w),
          if (isAddReviewLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
      floatingActionButtonLocation:
          isLoading ? null : FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          isLoading
              ? null
              : Container(
                height: 7.5.h,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(12),
                        child: batan(
                          title: "Add to Cart",
                          // route: () {
                          //   AddCartServiceApi();
                          //   // Get.to(() => BookServicePage(serviceId: widget.serviceID));
                          // },
                          //   route: () {
                          //     if (cartDetailsModel?.data != null &&
                          //         cartDetailsModel!.data!.isNotEmpty &&
                          //         cartDetailsModel!.data![0].type == "product") {
                          //       Get.snackbar(
                          //         "Service item already in cart",
                          //         "Please remove service items before adding a service.",
                          //         backgroundColor: AppColors.redColor,
                          //         colorText: Colors.white,
                          //         margin: EdgeInsets.all(10),
                          //         snackPosition: SnackPosition.TOP,
                          //       );
                          //     } else if(cartDetailsModel?.data?[0].itemDetails?.businessId==widget.businessID){
                          //       log('dasddadsda');
                          //     }
                          //
                          //
                          //     else {
                          //       AddCartServiceApi();
                          //     }
                          //   },
                          route: () {
                            // Cart ma koi item che ke nahi check karo
                            if (cartDetailsModel?.data != null &&
                                cartDetailsModel!.data!.isNotEmpty) {
                              // Pachhi check karo ke cart ma je item che te product chhe ke service
                              if (cartDetailsModel!.data![0].type ==
                                  "product") {
                                Get.snackbar(
                                  "Service item already in cart",
                                  "Please remove service items before adding a service.",
                                  backgroundColor: AppColors.redColor,
                                  colorText: Colors.white,
                                  margin: EdgeInsets.all(10),
                                  snackPosition: SnackPosition.TOP,
                                );
                              }
                              // BusinessId same chhe ke nahi
                              else if (cartDetailsModel!
                                      .data![0]
                                      .itemDetails
                                      ?.businessId ==
                                  servicedetailsmodel?.data?.businessId) {
                                // BusinessId same hoy to add karva do
                                AddCartServiceApi();
                              } else {
                                // BusinessId alag hoy to alert karo
                                Get.snackbar(
                                  "Business mismatch",
                                  "You can only add items from the same business to the cart.",
                                  backgroundColor: AppColors.redColor,
                                  colorText: Colors.white,
                                  margin: EdgeInsets.all(10),
                                  snackPosition: SnackPosition.TOP,
                                );
                              }
                            } else {
                              // Cart empty hoy to direct add karva do
                              AddCartServiceApi();
                            }
                          },

                          color: AppColors.maincolor,
                          fontcolor: AppColors.white,
                          height: 5.h,
                          fontsize: 15.sp,
                          iconData: Icons.calendar_today,
                          radius: 12.0,
                          width: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // Expanded(
                    //   child: Material(
                    //     elevation: 1,
                    //     borderRadius: BorderRadius.circular(12),
                    //     child: batan(
                    //       title: "Book Now",
                    //       // route: () {
                    //       //   BuyNow();
                    //       // },
                    //       route: () {
                    //         if (cartDetailsModel?.data != null &&
                    //             cartDetailsModel!.data!.isNotEmpty &&
                    //             cartDetailsModel!.data![0].type == "product") {
                    //           Get.snackbar(
                    //             "Product item already in cart",
                    //             "Please remove service items before adding a service.",
                    //             backgroundColor: AppColors.redColor,
                    //             colorText: Colors.white,
                    //             margin: EdgeInsets.all(10),
                    //             snackPosition: SnackPosition.TOP,
                    //           );
                    //         } else {
                    //           BuyNow();
                    //         }
                    //       },
                    //       color: AppColors.maincolor,
                    //       fontcolor: AppColors.white,
                    //       height: 5.h,
                    //       // width: 50.w,
                    //       fontsize: 15.sp,
                    //       iconData: Icons.shopping_bag,
                    //       radius: 12.0,
                    //       width: 0,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
    );
  }

  void GetCartDetailApi() {
    checkInternet().then((internet) async {
      if (internet) {
        CartProvider()
            .GetCartDetailsApi(loginModel?.data?.user?.id.toString() ?? "")
            .then((response) async {
              cartDetailsModel = CartDetailsModel.fromJson(
                jsonDecode(response.body),
              );
              if (response.statusCode == 200) {
                print("adfdsfsdf${response.body}");
                print(
                  "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}",
                );

                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
                log("Error");
              }
            });
      } else {
        setState(() {
          isLoading = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  ServiceDetail() async {
    setState(() {
      isLoading = true;
    });

    bool internet = await checkInternet();

    if (!internet) {
      setState(() {
        isLoading = false;
      });
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await ServiceProvider().ServiceDetailApi(
        loginModel?.data?.user?.id.toString() ?? "",
        widget.serviceID.toString(),
        "service", // Type parameter
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        setState(() {
          servicedetailsmodel = ServiceDetailsModel.fromJson(jsonData);
          isLoading = false;

          // Process images
          // if (servicedetailsmodel?.data?.images != null &&
          //     servicedetailsmodel!.data!.images!.isNotEmpty) {
          //   imageList = servicedetailsmodel!.data!.images!.split(',');
          // }

          // Process features
          if (servicedetailsmodel?.data?.features != null) {
            featuresList = List<String>.from(
              servicedetailsmodel!.data!.features!,
            );
          }

          // Process benefits
          if (servicedetailsmodel?.data?.benefits != null) {
            benefitsList = List<String>.from(
              servicedetailsmodel!.data!.benefits!,
            );
          }
        });

        print("✅ Service loaded: ${response.body}");
      } else {
        print("❌ API Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(
          context,
          'Error',
          "Something went wrong. Please try again.",
        );
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() {
        isLoading = false;
      });
      buildErrorDialog(context, 'Error', "Server error occurred.");
    }
  }

  AddCartServiceApi() {
    setState(() {
      isAddReviewLoading = true;
    });
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "id": widget.serviceID.toString(),
      "type": "service",
    };
    log("data jay che che ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().AddToCart(data).then((response) async {
          // productViewModel =
          //     ProductViewModel.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200) {
            print("Service data response ave che ${response.body}");

            setState(() {
              isAddReviewLoading = false;
            });
            Get.to(() => AddToCartView(type: 'service'));
          } else {
            setState(() {
              isAddReviewLoading = false;
            });
            log("Error");
          }
        });
      } else {
        setState(() {
          isAddReviewLoading = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  BuyNow() {
    setState(() {
      isAddReviewLoading = true;
    });
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "id": widget.serviceID.toString(),
      "type": "service",
    };
    log("data jay che che ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().AddToCart(data).then((response) async {
          // productViewModel =
          //     ProductViewModel.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200) {
            print("adfdsfsdf${response.body}");

            setState(() {
              isAddReviewLoading = false;
            });
            Get.to(() => BuyProductView(type: "service"));
          } else {
            setState(() {
              isAddReviewLoading = false;
            });
            log("Error");
          }
        });
      } else {
        setState(() {
          isAddReviewLoading = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
