import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/productDetailPage/view/product_detail_page.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/loader.dart';
import '../../../comman/product_disable.dart';
import '../../Add to Cart/model/add_to_cart_model.dart';
import '../../Add to Cart/provider/add_to_cart_provider.dart';
import '../../Add to Cart/view/add_to_cart_view.dart';
import '../../Buy Product/view/buy_product_view.dart';
import '../../productDetailPage/provider/product_provider.dart';
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
      body: Stack(
        children: [
          isLoading
              ? Center(child: Loader())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  SizedBox(height: 10.h),
                  isLoading
                      ? Loader().paddingOnly(top: 30.h)
                      : Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 2.h,
                          horizontal: 3.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgcolor,
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey),
                            right: BorderSide(color: Colors.grey),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45),
                          ),
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  servicedetailsmodel?.data?.businessName ?? "",
                                  style: TextStyle(
                                    fontFamily: AppConstants.manrope,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Container(
                                  height: 25.h,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                  ),
                                  child:
                                      (servicedetailsmodel
                                                      ?.data
                                                      ?.galleryImages ==
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
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              placeholder:
                                                  (
                                                    context,
                                                    url,
                                                  ) => const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              AppColors
                                                                  .maincolor,
                                                        ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Center(
                                                        child: Image(
                                                          image: AssetImage(
                                                            image,
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
                                                              imageUrl:
                                                                  imageUrl,
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  double
                                                                      .infinity,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      (servicedetailsmodel
                                                          ?.data
                                                          ?.galleryImages !=
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
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      servicedetailsmodel?.data?.title ??
                                          "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20.sp,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 2.w),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: AppColors.maincolor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: AppColors.maincolor,
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text(
                                            (servicedetailsmodel
                                                        ?.data
                                                        ?.productRating ??
                                                    0)
                                                .toString(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 0.8.h),
                                Container(
                                  width: 24.w,
                                  height: 0.7.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(90),
                                  ),
                                ),
                                SizedBox(height: 0.8.h),
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
                                    servicedetailsmodel?.data?.description ??
                                        "",
                                    trimLines: 4,
                                    trimLength: 145,
                                    colorClickableText: Colors.blue,
                                    trimMode: TrimMode.Length,
                                    trimCollapsedText: ' Show more',
                                    trimExpandedText: ' Show less',
                                    moreStyle: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,
                                      letterSpacing: 1,
                                      color: AppColors.maincolor1,
                                    ),
                                    lessStyle: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,
                                      letterSpacing: 1,
                                      color: AppColors.maincolor1,
                                    ),
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: AppColors.maincolor,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                if (featuresList.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        return CustomFeatureCard(
                                          icon: Icons.check_circle_outline,
                                          title: feature,
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                if (benefitsList.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        return CustomFeatureCard(
                                          icon: Icons.check_circle_outline,
                                          title: benefit,
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                SizedBox(height: 10.h),
                              ],
                            ),
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
                width: double.infinity * 0.5,
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                margin: EdgeInsets.only(bottom: 2.h),
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
                          route: () {
                            int? serviceStatus =
                                busnessviewmodal?.data?.business?.serviceStatus;

                            if (serviceStatus == 0) {
                              showOnlineOrderDisabledDialog(
                                context: context,
                                businessName:
                                    busnessviewmodal
                                        ?.data
                                        ?.business
                                        ?.businessName ??
                                    "",
                                isProduct: false,
                              );
                              return;
                            }

                            if (cartDetailsModel?.data != null &&
                                cartDetailsModel!.data!.isNotEmpty) {
                              if (cartDetailsModel!.data![0].type ==
                                  "product") {
                                ShowAddCart(
                                  context: context,
                                  businessName:
                                      busnessviewmodal
                                          ?.data
                                          ?.business
                                          ?.businessName ??
                                      "",
                                  isProduct: true,
                                  onContinue: () async {
                                    for (
                                      int i = 0;
                                      i < cartDetailsModel!.data!.length;
                                      i++
                                    ) {
                                      final itemId =
                                          cartDetailsModel!
                                              .data![i]
                                              .itemDetails
                                              ?.id;
                                      if (itemId != null) {
                                        await RemoveFromCartApi(
                                          itemId,
                                          "product",
                                        );
                                      }
                                    }
                                    AddCartServiceApi();
                                  },
                                );
                              } else if (cartDetailsModel!
                                      .data![0]
                                      .itemDetails
                                      ?.businessId ==
                                  servicedetailsmodel?.data?.businessId) {
                                AddCartServiceApi();
                              } else {
                                ShowAddCart(
                                  context: context,
                                  businessName:
                                      busnessviewmodal
                                          ?.data
                                          ?.business
                                          ?.businessName ??
                                      "",
                                  isProduct: true,
                                  onContinue: () async {
                                    for (
                                      int i = 0;
                                      i < cartDetailsModel!.data!.length;
                                      i++
                                    ) {
                                      final itemId =
                                          cartDetailsModel!
                                              .data![i]
                                              .itemDetails
                                              ?.id;
                                      if (itemId != null) {
                                        await RemoveFromCartApi(
                                          itemId,
                                          "product",
                                        );
                                      }
                                    }
                                    AddCartServiceApi();
                                  },
                                );
                              }
                            } else {
                              AddCartServiceApi();
                            }
                          },
                          color: AppColors.white,
                          fontcolor: AppColors.maincolor,
                          height: 5.h,
                          fontsize: 15.sp,
                          iconData: Icons.add_shopping_cart_outlined,
                          radius: 12.0,
                          width: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                ),
              ),
    );
  }

  void GetCartDetailApi() {
    checkInternet().then((internet) async {
      if (internet) {
        CartProvider()
            .cartDetailApi(loginModel?.data?.user?.id.toString() ?? "")
            .then((response) async {
              cartDetailsModel = CartDetailsModel.fromJson(response.data);
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

  RemoveFromCartApi(int productId, String type) {
    setState(() {
      isAddReviewLoading = true;
    });

    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "product_id": productId.toString(),
      "type": type,
    };

    checkInternet().then((internet) async {
      if (internet) {
        CartProvider().removeCartApi(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isAddReviewLoading = false;
            });
          } else {
            setState(() {
              isAddReviewLoading = false;
            });
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
      final response = await ServiceProvider().serviceDetailApi(
        loginModel?.data?.user?.id.toString() ?? "",
        widget.serviceID.toString(),
        "service",
      );

      if (response.statusCode == 200) {
        setState(() {
          servicedetailsmodel = ServiceDetailsModel.fromJson(response.data);
          isLoading = false;

          if (servicedetailsmodel?.data?.features != null) {
            featuresList = List<String>.from(
              servicedetailsmodel!.data!.features!,
            );
          }

          if (servicedetailsmodel?.data?.benefits != null) {
            benefitsList = List<String>.from(
              servicedetailsmodel!.data!.benefits!,
            );
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(
          context,
          'Error',
          "Something went wrong. Please try again.",
        );
      }
    } catch (e,stackTrace) {
      print("error ic coming $e");
      print("error ic coming $stackTrace");
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

    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().AddToCart(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isAddReviewLoading = false;
            });
            Get.to(() => AddToCartView(type: 'service', fromBottomBar: false));
          } else {
            setState(() {
              isAddReviewLoading = false;
            });
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

    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().AddToCart(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isAddReviewLoading = false;
            });
            Get.to(() => BuyProductView(type: "service"));
          } else {
            setState(() {
              isAddReviewLoading = false;
            });
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
