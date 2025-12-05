import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Ui/CartScreen/view/cartViewScreen.dart';
import 'package:wavee/Ui/OrderScreen/modal/order_detail_model.dart';
import 'package:wavee/Ui/OrderScreen/modal/service_order_model.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/customButton.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../../MessageScreen/View/messageScreen.dart';
import '../../orderScreen/View/orderScreenView.dart';
import '../Provider/orderProvider.dart';

class Orderdetail_Screen extends StatefulWidget {
  String? orderid;
  String? orderProductID;

  Orderdetail_Screen({super.key, this.orderid, this.orderProductID});

  @override
  State<Orderdetail_Screen> createState() => _Orderdetail_ScreenState();
}

class _Orderdetail_ScreenState extends State<Orderdetail_Screen> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;
  bool _isWhereMyOrderExpanded = false;
  String selectedMethod = '';
  String selectedDate = '25-05-2025';
  bool isLoading = false;
  bool isCancleOrder = false;
  String? selectedGateway =
      orderDetailModel?.data?.order?.paymentGateway?.toLowerCase();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    OrderDetailAPI();
    OrderDetailAPI1();
    log(widget.orderid.toString());
    log(widget.orderProductID.toString());
  }

  @override
  Widget build(BuildContext context) {
    DateTime? bookingDateTime = DateTime.tryParse(
      serviceOrderDetail?.data?.products?.bookingDetails?.bookingDatetime ?? '',
    );

    bool shouldShowCancelButton = false;

    if (bookingDateTime != null) {
      final now = DateTime.now();
      final difference = bookingDateTime.difference(now);
      if (difference.inHours >= 48 && difference.inSeconds > 0) {
        shouldShowCancelButton = true;
      }
    }
    final service = serviceOrderDetail?.data?.products?.service;
    final List<String>? galleryImages = service?.galleryImages;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          orderDetailModel?.data?.products?.type == "service"
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.h),
                  TitleBar(
                    title:
                        serviceOrderDetail?.data?.products?.service?.title
                            .toString()
                            .capitalizeFirst ??
                        "",
                    drawerCallback: () {},
                    back: () {
                      Get.back();
                    },
                  ),
                  SizedBox(height: 2.h),
                  isLoading
                      ? Loader().paddingOnly(top: 0.h)
                      : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // serviceOrderDetail!
                              //         .data!
                              //         .products!
                              //         .service!
                              //         .galleryImages!
                              //         .isEmpty
                              //     ? Container(
                              //       height: 25.h,
                              //       width: double.infinity,
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(10),
                              //         color: Colors.grey[200],
                              //       ),
                              //       alignment: Alignment.center,
                              //       child: ClipRRect(
                              //         borderRadius: BorderRadius.circular(10),
                              //         child: CachedNetworkImage(
                              //           width: double.infinity,
                              //           imageUrl:
                              //               serviceOrderDetail!
                              //                   .data!
                              //                   .products!
                              //                   .service!
                              //                   .images ??
                              //               "",
                              //           fit: BoxFit.fill,
                              //           placeholder:
                              //               (context, url) => const Center(
                              //                 child: CircularProgressIndicator(
                              //                   color: AppColors.maincolor,
                              //                 ),
                              //               ),
                              //           errorWidget:
                              //               (
                              //                 context,
                              //                 url,
                              //                 error,
                              //               ) => const Image(
                              //                 image: AssetImage(
                              //                   'assets/images/Applogo_remove_background.png',
                              //                 ),
                              //               ),
                              //         ),
                              //       ),
                              //     )
                              //     : CarouselSlider(
                              //       carouselController: _controller,
                              //       options: CarouselOptions(
                              //         height: 25.h,
                              //         autoPlay: true,
                              //         enlargeCenterPage: true,
                              //         viewportFraction: 1.0,
                              //         onPageChanged: (index, reason) {
                              //           setState(() {
                              //             _currentIndex = index;
                              //           });
                              //         },
                              //       ),
                              //       items:
                              //           serviceOrderDetail!
                              //               .data!
                              //               .products!
                              //               .service!
                              //               .galleryImages!
                              //               .map((imageUrl) {
                              //                 return Builder(
                              //                   builder: (
                              //                     BuildContext context,
                              //                   ) {
                              //                     return Stack(
                              //                       children: [
                              //                         ClipRRect(
                              //                           borderRadius:
                              //                               BorderRadius.circular(
                              //                                 10,
                              //                               ),
                              //                           child: CachedNetworkImage(
                              //                             imageUrl: imageUrl,
                              //                             fit: BoxFit.cover,
                              //                             width:
                              //                                 double.infinity,
                              //                             placeholder:
                              //                                 (
                              //                                   context,
                              //                                   url,
                              //                                 ) => const Center(
                              //                                   child: CircularProgressIndicator(
                              //                                     color:
                              //                                         AppColors
                              //                                             .maincolor,
                              //                                   ),
                              //                                 ),
                              //                             errorWidget:
                              //                                 (
                              //                                   context,
                              //                                   url,
                              //                                   error,
                              //                                 ) => const Image(
                              //                                   image: AssetImage(
                              //                                     'assets/images/Applogo_remove_background.png',
                              //                                   ),
                              //                                 ),
                              //                           ),
                              //                         ),
                              //                       ],
                              //                     );
                              //                   },
                              //                 );
                              //               })
                              //               .toList(),
                              //     ),
                              (service == null ||
                                      galleryImages == null ||
                                      galleryImages.isEmpty)
                                  ? Container(
                                    height: 25.h,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[200],
                                    ),
                                    alignment: Alignment.center,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        width: double.infinity,
                                        imageUrl: service?.images ?? "",
                                        fit: BoxFit.fill,
                                        placeholder:
                                            (context, url) => const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.maincolor,
                                              ),
                                            ),
                                        errorWidget:
                                            (
                                              context,
                                              url,
                                              error,
                                            ) => const Image(
                                              image: AssetImage(
                                                'assets/images/Applogo_remove_background.png',
                                              ),
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
                                        galleryImages
                                            .where(
                                              (img) => img.isNotEmpty,
                                            ) // khali string hata hoy to filter
                                            .map((imageUrl) {
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
                                                              ) => const Image(
                                                                image: AssetImage(
                                                                  'assets/images/Applogo_remove_background.png',
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            })
                                            .toList(),
                                  ),
                              SizedBox(height: 1.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    serviceOrderDetail!
                                        .data!
                                        .products!
                                        .service!
                                        .galleryImages!
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
                              SizedBox(height: 1.h),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.local_mall, size: 18.sp),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Order Id: #ORDERNO${serviceOrderDetail?.data?.order?.orderNo}",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      Icon(Icons.inventory, size: 18.sp),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Collect Token: ${serviceOrderDetail?.data?.order?.tokenNo}",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  serviceOrderDetail
                                              ?.data
                                              ?.products
                                              ?.bookingDetails ==
                                          null
                                      ? const SizedBox()
                                      : SizedBox(height: 1.h),
                                  serviceOrderDetail
                                              ?.data
                                              ?.products
                                              ?.bookingDetails ==
                                          null
                                      ? const SizedBox()
                                      : Row(
                                        children: [
                                          Icon(Icons.date_range, size: 18.sp),
                                          SizedBox(width: 2.w),
                                          Text(
                                            "Booking Confirm: ${formatDateTime(serviceOrderDetail?.data?.products?.bookingDetails?.bookingDatetime ?? "")}",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontFamily:
                                                  AppConstants.manropeBold,
                                            ),
                                          ),
                                        ],
                                      ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      Icon(
                                        getStatusIconData(
                                          serviceOrderDetail
                                                  ?.data
                                                  ?.order
                                                  ?.status ??
                                              "",
                                        ),
                                        size: 18.sp,
                                        color: getStatusColor(
                                          serviceOrderDetail
                                                  ?.data
                                                  ?.order
                                                  ?.status
                                                  ?.toString()
                                                  .capitalizeFirst ??
                                              "",
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Status: ${serviceOrderDetail?.data?.order?.status?.toString().capitalizeFirst ?? "Status"}",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: getStatusColor(
                                            orderDetailModel
                                                    ?.data
                                                    ?.order
                                                    ?.status
                                                    ?.toString()
                                                    .capitalizeFirst ??
                                                "",
                                          ),
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              Text(
                                serviceOrderDetail
                                        ?.data
                                        ?.products
                                        ?.service
                                        ?.title
                                        .toString()
                                        .capitalizeFirst ??
                                    "",
                                style: TextStyle(
                                  fontFamily: AppConstants.manropeBold,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "£${serviceOrderDetail?.data?.order?.totalAmount ?? ""}",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Container(
                                width: 92.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ReadMoreText(
                                  serviceOrderDetail
                                          ?.data
                                          ?.products
                                          ?.service
                                          ?.description ??
                                      "",
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
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                "Payment Method",
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppConstants.manropeBold,
                                  color: AppColors.maincolor,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              serviceOrderDetail != null &&
                                      serviceOrderDetail
                                              ?.data
                                              ?.order
                                              ?.paymentGateway !=
                                          null
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 1.5.h),
                                      if (orderDetailModel!
                                              .data!
                                              .order
                                              ?.paymentGateway!
                                              .toLowerCase() ==
                                          'stripe')
                                        paymentOptionContainer(
                                          image:
                                              "assets/images/stripe_pay_image2.png",
                                          value: "Stripe",
                                        ),
                                      if (serviceOrderDetail!
                                              .data!
                                              .order
                                              ?.paymentGateway!
                                              .toLowerCase() ==
                                          'googlepay')
                                        paymentOptionContainer(
                                          image: "assets/images/google_pay.png",
                                          value: "Google Pay",
                                        ),
                                      if (serviceOrderDetail!
                                              .data!
                                              .order
                                              ?.paymentGateway!
                                              .toLowerCase() ==
                                          'applepay')
                                        paymentOptionContainer(
                                          image: "assets/images/apple_pay.png",
                                          value: "Apple Pay",
                                        ),
                                    ],
                                  )
                                  : const SizedBox(),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                ],
              ).paddingOnly(left: 3.w, right: 2.w)
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  TitleBar(
                    title:
                        orderDetailModel?.data?.products?.product?.name
                            .toString()
                            .capitalizeFirst ??
                        "",
                    drawerCallback: () {},
                    back: () {
                      Get.back();
                    },
                  ),
                  SizedBox(height: 2.h),
                  isLoading
                      ? Loader().paddingOnly(top: 0.h)
                      : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (orderDetailModel
                                              ?.data
                                              ?.products
                                              ?.product
                                              ?.images ==
                                          null ||
                                      (orderDetailModel
                                              ?.data
                                              ?.products
                                              ?.product
                                              ?.images)!
                                          .isEmpty)
                                  ? Container(
                                    height: 25.h,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[200],
                                    ),
                                    alignment: Alignment.center,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        width: double.infinity,
                                        imageUrl:
                                            (orderDetailModel
                                                    ?.data
                                                    ?.products
                                                    ?.product
                                                    ?.image)
                                                .toString(),
                                        fit: BoxFit.fill,
                                        placeholder:
                                            (context, url) => const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.maincolor,
                                              ),
                                            ),
                                        errorWidget:
                                            (
                                              context,
                                              url,
                                              error,
                                            ) => const Image(
                                              image: AssetImage(
                                                'assets/images/Applogo_remove_background.png',
                                              ),
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
                                        orderDetailModel!
                                            .data!
                                            .products!
                                            .product!
                                            .images!
                                            .map((imageUrl) {
                                              return Builder(
                                                builder: (
                                                  BuildContext context,
                                                ) {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
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
                                                            child: Icon(
                                                              Icons.error,
                                                              color:
                                                                  AppColors
                                                                      .maincolor,
                                                            ),
                                                          ),
                                                    ),
                                                  );
                                                },
                                              );
                                            })
                                            .toList(),
                                  ),

                              SizedBox(height: 1.h),
                              if (orderDetailModel
                                          ?.data
                                          ?.products
                                          ?.product
                                          ?.images !=
                                      null &&
                                  orderDetailModel!
                                      .data!
                                      .products!
                                      .product!
                                      .images!
                                      .isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      orderDetailModel!
                                          .data!
                                          .products!
                                          .product!
                                          .images!
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            return GestureDetector(
                                              onTap:
                                                  () => _controller
                                                      .animateToPage(entry.key),
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
                                )
                              else
                                const SizedBox.shrink(), // Or show a placeholder

                              SizedBox(height: 1.h),
                              SizedBox(height: 1.h),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.local_mall, size: 18.sp),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Order Id: #ORDERNO${orderDetailModel?.data?.order?.orderNo}",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      Icon(Icons.inventory, size: 18.sp),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Collect Code: ${orderDetailModel?.data?.order?.tokenNo}",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      Icon(
                                        getStatusIconData(
                                          orderDetailModel
                                                  ?.data
                                                  ?.order
                                                  ?.status ??
                                              "",
                                        ),
                                        size: 18.sp,
                                        color: getStatusColor(
                                          orderDetailModel?.data?.order?.status
                                                  ?.toString()
                                                  .capitalizeFirst ??
                                              "",
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Status: ${orderDetailModel?.data?.order?.status?.toString().capitalizeFirst ?? "Status"}",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: getStatusColor(
                                            orderDetailModel
                                                    ?.data
                                                    ?.order
                                                    ?.status
                                                    ?.toString()
                                                    .capitalizeFirst ??
                                                "",
                                          ),
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              Text(
                                orderDetailModel?.data?.products?.product?.name
                                        .toString()
                                        .capitalizeFirst ??
                                    "",
                                style: TextStyle(
                                  fontFamily: AppConstants.manrope,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "£${orderDetailModel?.data?.products?.totalPrice ?? ""}",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Container(
                                width: 92.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ReadMoreText(
                                  orderDetailModel
                                          ?.data
                                          ?.products
                                          ?.product
                                          ?.description ??
                                      "",
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
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                "Payment Method",
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppConstants.manropeBold,
                                  color: AppColors.maincolor,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              orderDetailModel != null &&
                                      orderDetailModel
                                              ?.data
                                              ?.order
                                              ?.paymentGateway !=
                                          null
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 1.5.h),
                                      if (orderDetailModel!
                                              .data!
                                              .order
                                              ?.paymentGateway!
                                              .toLowerCase() ==
                                          'stripe')
                                        paymentOptionContainer(
                                          image:
                                              "assets/images/stripe_pay_image2.png",
                                          value: "Stripe",
                                        ),
                                      if (orderDetailModel!
                                              .data!
                                              .order
                                              ?.paymentGateway!
                                              .toLowerCase() ==
                                          'googlepay')
                                        paymentOptionContainer(
                                          image: "assets/images/google_pay.png",
                                          value: "Google Pay",
                                        ),
                                      if (orderDetailModel!
                                              .data!
                                              .order
                                              ?.paymentGateway!
                                              .toLowerCase() ==
                                          'applepay')
                                        paymentOptionContainer(
                                          image: "assets/images/apple_pay.png",
                                          value: "Apple Pay",
                                        ),
                                    ],
                                  )
                                  : const SizedBox(),
                              SizedBox(height: 1.h),
                              orderDetailModel?.data?.order?.status ==
                                          "collected" ||
                                      orderDetailModel?.data?.order?.status ==
                                          "Collected" ||
                                      orderDetailModel?.data?.order?.status
                                              ?.toLowerCase() ==
                                          "declined" ||
                                      orderDetailModel?.data?.order?.status
                                              ?.toLowerCase() ==
                                          "cancelled"
                                  ? const SizedBox()
                                  : _buildOrderManagementSection(),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                ],
              ).paddingOnly(left: 2.w, right: 2.w),
          if (isCancleOrder)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          (isLoading ||
                  orderDetailModel?.data?.order?.status == "Collected" ||
                  orderDetailModel?.data?.order?.status == "cancelled")
              ? const SizedBox.shrink()
              : (orderDetailModel?.data?.order?.status?.toLowerCase() ==
                      "declined" ||
                  orderDetailModel?.data?.order?.status?.toLowerCase() ==
                      "packing your bag" ||
                  orderDetailModel?.data?.order?.status?.toLowerCase() ==
                      "ready for collection")
              ? Container(
                height: 7.5.h,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(12),
                        child: batan(
                          title: _getStatusMessage(
                            orderDetailModel?.data?.order?.status,
                          ),
                          fontFamily: AppConstants.manropeBold,
                          route: () {},
                          color: getStatusColor(
                            orderDetailModel?.data?.order?.status.toString() ??
                                "",
                          ),
                          fontcolor: Colors.white,
                          height: 5.h,
                          fontsize: 15.sp,
                          iconData: Icons.free_cancellation_outlined,
                          radius: 12.0,
                          width: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : (shouldShowCancelButton ||
                      (orderDetailModel?.data?.order?.status?.toLowerCase() ==
                          "pending approval")) &&
                  (orderDetailModel?.data?.products?.type == "service")
              ? Container(
                height: 7.5.h,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(12),
                        child: batan(
                          title: "Cancel Order",
                          route: () {
                            showCancelConfirmationDialog(
                              context: context,
                              onConfirm: CancleOrder,
                            );
                          },
                          fontFamily: AppConstants.manropeBold,
                          color: AppColors.maincolor,
                          fontcolor: AppColors.white,
                          height: 5.h,
                          fontsize: 15.sp,
                          iconData: Icons.free_cancellation_outlined,
                          radius: 12.0,
                          width: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }

  String _getStatusMessage(String? status) {
    switch (status?.toLowerCase()) {
      case "declined":
        return "Sorry, your order was declined.";
      case "packing your bag":
        return "Packing your bag";
      case "ready for collection":
        return "Ready for collection";
      default:
        return "";
    }
  }

  Future<void> showCancelConfirmationDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                Text(
                  "Are you sure?",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Do you really want to cancel this order?\nThis action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black54,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(12.0),
                        child: batan(
                          title: "No, Keep It",
                          route: () {
                            Get.back();
                          },
                          color: AppColors.white,
                          fontcolor: Colors.black,
                          height: 5.h,
                          fontsize: 16.sp,
                          radius: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(12.0),
                        child: batan(
                          title: "Yes, Cancel",
                          route: () {
                            onConfirm();
                            Get.back();
                          },
                          color: AppColors.maincolor,
                          fontcolor: Colors.white,
                          height: 5.h,
                          fontsize: 16.sp,
                          radius: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> confirmShowDialog({required BuildContext context}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                Text(
                  "Your Order has Cancelled!",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: AppConstants.manropeBold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your booking has been cancelled.\n You will receive your refund within 48 hours.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black54,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: batan(
                        title: "Yes",
                        route: () {
                          Navigator.of(context).pop();
                          Get.to(Order_Screen());
                        },
                        color: AppColors.maincolor,
                        fontcolor: Colors.white,
                        height: 5.h,
                        fontsize: 16.sp,
                        radius: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending approval":
        return Colors.orange;
      case "packing your bag":
        return Colors.green;
      case "collected" || "booking confirmed":
        return AppColors.maincolor;
      case "ready for collection":
        return AppColors.maincolor;
      case "declined" || "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIconData(String status) {
    switch (status.toLowerCase()) {
      case "pending approval":
        return Icons.pending_actions;
      case "packing your bag":
        return Icons.local_shipping;
      case "ready for collection":
        return Icons.outbox;
      case "collected" || "booking confirmed":
        return Icons.task_alt;
      case "declined" || "cancelled":
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  OrderDetailAPI1() {
    checkInternet().then((internet) async {
      if (internet) {
        OrderProvider()
            .orderDetailApi(
              loginModel?.data?.user?.id.toString() ?? "",
              widget.orderid,
              widget.orderProductID,
            )
            .then((response) async {
              serviceOrderDetail = ServiceOrderDetail.fromJson(response.data);
              if (response.statusCode == 200) {
                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
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

  OrderDetailAPI() {
    checkInternet().then((internet) async {
      if (internet) {
        OrderProvider()
            .orderDetailApi(
              loginModel?.data?.user?.id.toString() ?? "",
              widget.orderid,
              widget.orderProductID,
            )
            .then((response) async {
              orderDetailModel = OrderDetailModel.fromJson(response.data);
              if (response.statusCode == 200) {
                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
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

  CancleOrder() async {
    setState(() {
      isCancleOrder = true;
    });
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderid.toString(),
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await OrderProvider().cancleOrderApi1(data);

          if (response.statusCode == 200) {
            setState(() {
              isCancleOrder = false;
            });
            confirmShowDialog(context: context);
          } else {
            setState(() {
              isCancleOrder = false;
            });
          }
        } catch (e) {
          setState(() {
            isCancleOrder = false;
          });
        }
      } else {
        setState(() {
          isCancleOrder = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  String formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return "N/A";

    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('dd-MM-yyyy hh:mm a').format(parsedDate);
  }

  Widget paymentOptionContainer({
    required String image,
    required String value,
  }) {
    String? selectedGateway =
        orderDetailModel?.data?.order?.paymentGateway?.toLowerCase();
    bool isSelected = selectedGateway == value.toLowerCase();

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.maincolor.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.maincolor : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Image.asset(image, height: 5.h, width: 15.w, fit: BoxFit.contain),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: AppConstants.manrope,
            ),
          ),
          const Spacer(),
          if (isSelected)
            Icon(Icons.check_circle, color: AppColors.maincolor, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildOrderManagementSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Management",
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          _buildExpandableOrderTile(),
          _buildManagementTile(
            icon: Icons.edit,
            title: "Amend order",
            subtitle: "Check if your order can be modified",
            onTap: () => _showAmendOrderDialog(),
          ),
          _buildManagementTile(
            icon: Icons.cancel,
            title: "Cancel order",
            subtitle: "View cancellation policy",
            onTap: () => _showCancelOrderDialog(),
          ),
          _buildManagementTile(
            icon: Icons.chat,
            title: "Something Else",
            subtitle: "Live chat",
            onTap: () {
              Get.to(
                MessageScreen(
                  chatName: orderDetailModel?.data?.business?.businessName,
                  conciergeID:
                      (orderDetailModel?.data?.business?.id).toString(),
                  type: "order",
                  image: orderDetailModel?.data?.business?.profile,
                  orderproductID:
                      (orderDetailModel?.data?.products?.id).toString(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableOrderTile() {
    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isWhereMyOrderExpanded = !_isWhereMyOrderExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppColors.maincolor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.maincolor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Where's my order?",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.normal,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "Track your order status",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isWhereMyOrderExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isWhereMyOrderExpanded ? null : 0,
            child:
                _isWhereMyOrderExpanded
                    ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          OrderStepsWidget(
                            currentStatus:
                                orderDetailModel?.data?.order?.status ?? "",
                          ),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppColors.maincolor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.maincolor, size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.normal,
            fontFamily: AppConstants.manrope,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontFamily: AppConstants.manrope,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showAmendOrderDialog() {
    String currentStatus =
        orderDetailModel?.data?.order?.status?.toLowerCase() ?? "";
    bool isPendingApproval = currentStatus == "pending approval";
    bool isOrderPlaced = currentStatus == "order placed";

    bool canAmend = isPendingApproval || isOrderPlaced;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.maincolor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit,
                  color: AppColors.maincolor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                "Amend Order",
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: canAmend ? Colors.blue[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canAmend ? Colors.blue[200]! : Colors.orange[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      canAmend ? Icons.info_outline : Icons.warning_amber,
                      color: canAmend ? Colors.blue[600] : Colors.orange[600],
                      size: 20.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        canAmend
                            ? "Order Modification Available"
                            : "Order Modification Restricted",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              canAmend ? Colors.blue[700] : Colors.orange[700],
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              if (canAmend)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your order can be modified since it's still in the ${isPendingApproval ? 'pending approval' : 'order placed'} stage.",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[700],
                        fontFamily: AppConstants.manrope,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "You can:",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "• Change item quantities\n• Add or remove items\n",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[600],
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Unfortunately, orders cannot be modified once they have been confirmed by the store and are being prepared.",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[700],
                        fontFamily: AppConstants.manrope,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• Items cannot be added or removed",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey[600],
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                        Text(
                          "• Quantities cannot be changed",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey[600],
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                        Text(
                          "• Delivery address cannot be modified",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey[600],
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            batan(
              title: canAmend ? "Modify Order" : "Ok",
              route: () {
                Get.back();
                if (canAmend) {
                  // Add your amend order logic here
                  // For example: Get.to(AmendOrderScreen());
                  Get.to(
                    AddToCartView(
                      isAmend: true,
                      businessID:
                          orderDetailModel?.data?.business?.id.toString() ?? "",
                      orderID:
                          orderDetailModel?.data?.order?.id.toString() ?? "",
                    ),
                  );
                }
              },
              color: canAmend ? AppColors.maincolor : AppColors.maincolor,
              fontcolor: Colors.white,
              height: 5.h,
              width: double.infinity,
              fontsize: 18,
              radius: 12.0,
              fontFamily: AppConstants.manropeBold,
            ),
          ],
        );
      },
    );
  }

  void _showCancelOrderDialog() {
    String currentStatus =
        orderDetailModel?.data?.order?.status?.toLowerCase() ?? "";
    bool isPendingApproval = currentStatus == "pending approval";
    bool isOrderPlaced = currentStatus == "order placed";

    bool canCancel = isPendingApproval || isOrderPlaced;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.maincolor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cancel,
                  color: AppColors.maincolor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                "Cancel Order",
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manropeBold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: canCancel ? Colors.blue[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canCancel ? Colors.blue[200]! : Colors.red[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      canCancel ? Icons.info_outline : Icons.block,
                      color: canCancel ? Colors.blue[600] : Colors.red[600],
                      size: 20.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        canCancel
                            ? "Cancellation Available"
                            : "Cancellation Not Allowed",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: canCancel ? Colors.blue[700] : Colors.red[700],
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              if (canCancel)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your order can be cancelled since it's still in the ${isPendingApproval ? 'pending approval' : 'order placed'} stage.",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[700],
                        fontFamily: AppConstants.manrope,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "If you proceed with cancellation:",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "• You will receive a full refund\n• The cancellation will be immediate\n• You can place a new order anytime",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[600],
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sorry, this order cannot be cancelled as it has already been confirmed by the store and is being prepared.",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[700],
                        fontFamily: AppConstants.manrope,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "If you have any concerns about your order, please contact our support team through live chat.",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[600],
                        fontFamily: AppConstants.manrope,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            if (canCancel)
              Row(
                children: [
                  Expanded(
                    child: Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(12.0),

                      child: batan(
                        title: "No, Keep Order",
                        route: () {
                          Get.back();
                        },
                        color: Colors.white,
                        fontcolor: Colors.black,
                        height: 5.h,
                        fontsize: 16.sp,
                        radius: 12.0,
                        fontFamily: AppConstants.manropeBold,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(12.0),
                      child: batan(
                        title: "Yes, Cancel",
                        route: () {
                          Get.back();
                          showCancelConfirmationDialog(
                            context: context,
                            onConfirm: CancleOrder,
                          );
                        },
                        color: AppColors.maincolor,
                        fontcolor: Colors.white,
                        height: 5.h,
                        fontsize: 16.sp,
                        radius: 12.0,
                        fontFamily: AppConstants.manropeBold,
                      ),
                    ),
                  ),
                ],
              )
            else
              batan(
                title: "Ok",
                route: () {
                  Get.back();
                },
                color: AppColors.maincolor,
                fontcolor: Colors.white,
                height: 5.h,
                width: double.infinity,
                fontsize: 18,
                radius: 12.0,
              ),
          ],
        );
      },
    );
  }
}

class CustomFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const CustomFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.maincolor),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _StatusType { inProgress, completed, failed }

_StatusType _getStatusType(String status, int currentIndex, int totalSteps) {
  if (status == "declined" || status == "cancelled") {
    return _StatusType.failed;
  }
  if (currentIndex == totalSteps - 1) {
    return _StatusType.completed;
  }
  return _StatusType.inProgress;
}

class OrderStepsWidget extends StatelessWidget {
  final String currentStatus;

  const OrderStepsWidget({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    String lowerCaseStatus = currentStatus.toLowerCase();
    List<Map<String, dynamic>> steps;

    // 1. Status pramane steps ni list taiyar karo
    if (lowerCaseStatus == "declined") {
      steps = [
        {"title": "Order Placed", "status": "order placed"},
        {"title": "Pending Approval", "status": "pending approval"},
        {"title": "Declined", "status": "declined"},
      ];
    } else if (lowerCaseStatus == "cancelled") {
      steps = [
        {"title": "Order Placed", "status": "order placed"},
        {"title": "Cancelled", "status": "cancelled"},
      ];
    } else {
      // Normal "Happy Path"
      steps = [
        {"title": "Order Placed", "status": "order placed"},
        {"title": "Pending Approval", "status": "pending approval"},
        {"title": "Packing Your Bag", "status": "packing your bag"},
        {"title": "Ready for Collection", "status": "ready for collection"},
        {"title": "Collected", "status": "collected"},
      ];
    }

    int currentStatusIndex = steps.indexWhere(
      (step) => step['status'] == lowerCaseStatus,
    );

    return Column(
      children:
          steps.asMap().entries.map((entry) {
            int index = entry.key;
            var step = entry.value;
            bool isLast = index == steps.length - 1;
            bool isCompleted = index <= currentStatusIndex;
            bool isActive = index == currentStatusIndex;

            // 2. Status no prakar ane color nakki karo
            _StatusType statusType = _getStatusType(
              step['status']!,
              index,
              steps.length,
            );

            Color stepColor;
            if (statusType == _StatusType.failed) {
              stepColor = Colors.red;
            } else if (statusType == _StatusType.completed) {
              stepColor = Colors.green; // "Collected" mate Green
            } else {
              stepColor = AppColors.maincolor; // Normal In-Progress
            }

            // Active step mate color
            Color activeColor = isActive ? stepColor : AppColors.maincolor;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    isActive
                        ? LiveStatusIndicator(
                          // *** AA WIDGET HAVE NAVI "GLOWING ORB" EFFECT BATAVSHE ***
                          color: activeColor,
                          child: _buildStatusCircle(
                            step['status'],
                            isCompleted,
                            isActive,
                            activeColor,
                          ),
                        )
                        : _buildStatusCircle(
                          step['status'],
                          isCompleted,
                          isActive,
                          stepColor,
                        ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 30,
                        color:
                            index < currentStatusIndex
                                ? stepColor.withValues(alpha: 0.5)
                                : Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'],
                          style: TextStyle(
                            fontSize: isActive ? 17.5.sp : 16.5.sp,
                            fontWeight:
                                isActive
                                    ? FontWeight.bold
                                    : isCompleted
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                            color:
                                isActive
                                    ? activeColor
                                    : isCompleted
                                    ? Colors.black
                                    : Colors.grey[600],
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (statusType == _StatusType.failed)
                                  ? step['title'] // "Declined" or "Cancelled"
                                  : "Live Status",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: activeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildStatusCircle(
    String status,
    bool isCompleted,
    bool isActive,
    Color color,
  ) {
    IconData iconData = getStatusIconData(status);
    if (isCompleted && !isActive) {
      iconData = Icons.check;
    }
    if (status == 'collected') {
      iconData = Icons.check_circle_outline;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isActive
                ? color
                : isCompleted
                ? color.withValues(alpha: 0.7)
                : Colors.grey[300],
        border: isActive ? Border.all(color: color, width: 2) : null,
      ),
      child:
          isCompleted
              ? Icon(iconData, color: Colors.white, size: isActive ? 12 : 10)
              : const SizedBox.shrink(),
    );
  }

  IconData getStatusIconData(String status) {
    switch (status.toLowerCase()) {
      case 'order placed':
        return Icons.shopping_cart_checkout;
      case 'pending approval':
        return Icons.hourglass_empty;
      case 'packing your bag':
        return Icons.inventory_2_outlined;
      case 'ready for collection':
        return Icons.storefront_outlined;
      case 'collected':
        return Icons.check_circle_outline;
      case 'declined':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.do_not_disturb_alt_outlined;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}

class LiveStatusIndicator extends StatefulWidget {
  final Widget child;
  final Color color;

  const LiveStatusIndicator({
    super.key,
    required this.child,
    required this.color,
  });

  @override
  State<LiveStatusIndicator> createState() => _LiveStatusIndicatorState();
}

class _LiveStatusIndicatorState extends State<LiveStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // 1.5 second nu cycle
    )..repeat(reverse: true); // Forward ane reverse repeat thashe

    // Glow effect mate tween
    _glowAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Smooth transition
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Main dot ni paachhal soft glow add karo
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.6), // Glow no color
                blurRadius: _glowAnimation.value, // Animated blur
                spreadRadius: _glowAnimation.value / 4, // Animated spread
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child, // Original dot (inner content)
    );
  }
}
