import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Add%20to%20Cart/view/add_to_cart_view.dart';
import 'package:wavee/Screen/Buy%20Product/view/buy_product_view.dart';
import 'package:wavee/Screen/Product%20Detail%20Page/model/product_model.dart';
import 'package:wavee/Screen/Product%20Detail%20Page/provider/product_provider.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/check_inernet_connecty.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/custom_button.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/bottom_bar.dart';
import '../../../comman/error_dialog.dart';
import '../../../comman/product_disable.dart';
import '../../Add to Cart/model/add_to_cart_model.dart';
import '../../Add to Cart/provider/add_to_cart_provider.dart';
import '../model/all_review_model.dart';

class ProductDetailPage extends StatefulWidget {
  final String? productID;
  final String? type;

  const ProductDetailPage({super.key, this.productID, this.type});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final GlobalKey<ScaffoldState> productDetailKey = GlobalKey<ScaffoldState>();
  final CarouselSliderController _controller = CarouselSliderController();
  bool isLoading = false;
  bool isAddReviewLoading = false;
  int _currentIndex = 0;
  final TextEditingController reviewController = TextEditingController();
  double tempRating = 4.0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    ProductDetail();
  }

  String _calculateDiscountPercentage(String? original, String? offer) {
    try {
      double o = double.parse(original ?? "0");
      double p = double.parse(offer ?? "0");
      double discount = ((o - p) / o) * 100;
      return discount.toStringAsFixed(0);
    } catch (e) {
      return "0";
    }
  }

  int count = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: productDetailKey,
      drawer: SideMenu(),
      body: Stack(
        children: [
          isLoading
              ? Center(child: Loader())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  productViewModel?.data?.businessName ?? "",
                                  style: TextStyle(
                                    fontFamily: AppConstants.manrope,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Container(
                                  height: 20.h,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                  ),
                                  child:
                                      (productViewModel?.data?.images == null ||
                                              productViewModel!
                                                  .data!
                                                  .images!
                                                  .isEmpty)
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  productViewModel
                                                      ?.data
                                                      ?.image ??
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
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Center(
                                                    child: Image.asset(
                                                      'assets/images/waveeLogoShort.png',
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
                                                productViewModel!.data!.images!.map((
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
                                                                  20,
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
                                                                    child: Icon(
                                                                      Icons
                                                                          .error,
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
                                      (productViewModel?.data?.images != null &&
                                                  productViewModel!
                                                      .data!
                                                      .images!
                                                      .isNotEmpty
                                              ? productViewModel!.data!.images!
                                              : [
                                                productViewModel?.data?.image ??
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
                                    Expanded(
                                      child: Text(
                                        "${productViewModel?.data?.name.toString().capitalizeFirst ?? ""}",
                                        style: TextStyle(
                                          fontFamily: AppConstants.manrope,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                            (productViewModel
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
                                      "£ ${productViewModel?.data?.price ?? "0.00"}",
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
                                    productViewModel?.data?.description ?? "",
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
                                      SizedBox(height: 1.h),
                                      ...featuresList.map((feature) {
                                        return CustomFeatureCard(
                                          icon: Icons.check_circle_rounded,
                                          icnSize: 18.sp,
                                          title: feature,
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                productViewModel?.data?.quantity != '0'
                                    ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 18,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () {
                                                  if (count > 1) {
                                                    setState(() => count--);
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                '$count',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              count == 10
                                                  ? Container()
                                                  : IconButton(
                                                    icon: const Icon(
                                                      Icons.add,
                                                      size: 18,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                    onPressed: () {
                                                      setState(() => count++);
                                                    },
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                    : Container(),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ).paddingOnly(left: 1.w, right: 1.w),
          if (isAddReviewLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
      bottomNavigationBar: Bottom_bar(selected: 0),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child:
                    productViewModel?.data?.quantity != '0'
                        ? Row(
                          children: [
                            Expanded(
                              child: Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(12),
                                child: batan(
                                  title: "Add ${count} to Cart",
                                  route: () {
                                    bool isBlocked =
                                        productViewModel?.data?.quantity == 0 ||
                                        productViewModel?.data?.quantity ==
                                            null;
                                    int? productStatus =
                                        busnessviewmodal
                                            ?.data
                                            ?.business
                                            ?.productStatus;

                                    if (productStatus == 0) {
                                      showOnlineOrderDisabledDialog(
                                        context: context,
                                        businessName:
                                            busnessviewmodal
                                                ?.data
                                                ?.business
                                                ?.businessName ??
                                            "",
                                        isProduct: true,
                                      );
                                      return;
                                    }

                                    if (isBlocked) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Product is out of stock.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    if (cartDetailsModel?.data != null &&
                                        cartDetailsModel!.data!.isNotEmpty) {
                                      if (cartDetailsModel!.data![0].type ==
                                          "service") {
                                        ShowAddCart(
                                          context: context,
                                          businessName:
                                              productViewModel
                                                  ?.data
                                                  ?.businessName ??
                                              "",
                                          isProduct: true,
                                          onContinue: () async {
                                            for (
                                              int i = 0;
                                              i <
                                                  cartDetailsModel!
                                                      .data!
                                                      .length;
                                              i++
                                            ) {
                                              final itemId =
                                                  cartDetailsModel!
                                                      .data![i]
                                                      .itemDetails
                                                      ?.id;
                                              final type =
                                                  cartDetailsModel!
                                                      .data![i]
                                                      .itemDetails
                                                      ?.type;
                                              if (itemId != null) {
                                                await RemoveFromCartApi(
                                                  itemId,
                                                  type.toString(),
                                                );
                                              }
                                            }
                                            AddCartProductApi();
                                          },
                                        );
                                      } else if (cartDetailsModel!
                                              .data![0]
                                              .itemDetails
                                              ?.businessId ==
                                          productViewModel?.data?.businessId) {
                                        AddCartProductApi();
                                      } else {
                                        ShowAddCart(
                                          context: context,
                                          businessName:
                                              productViewModel
                                                  ?.data
                                                  ?.businessName ??
                                              "",
                                          isProduct: true,
                                          onContinue: () async {
                                            for (
                                              int i = 0;
                                              i <
                                                  cartDetailsModel!
                                                      .data!
                                                      .length;
                                              i++
                                            ) {
                                              final itemId =
                                                  cartDetailsModel!
                                                      .data![i]
                                                      .itemDetails
                                                      ?.id;
                                              final type =
                                                  cartDetailsModel!
                                                      .data![i]
                                                      .itemDetails
                                                      ?.type;
                                              if (itemId != null) {
                                                await RemoveFromCartApi(
                                                  itemId,
                                                  type.toString(),
                                                );
                                              }
                                            }
                                            AddCartProductApi();
                                          },
                                        );
                                      }
                                    } else {
                                      AddCartProductApi();
                                    }
                                  },
                                  shadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  color: AppColors.white,
                                  fontcolor: AppColors.maincolor,
                                  height: 5.h,
                                  fontsize: 15.sp,
                                  iconData: Icons.add_shopping_cart_outlined,
                                  radius: 12.0,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                          ],
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(12),
                                child: batan(
                                  title: "Out of Stock",
                                  route: () {},
                                  color: Colors.grey.shade200,
                                  fontcolor: AppColors.redColor,
                                  height: 5.h,
                                  fontsize: 15.sp,
                                  iconData: Icons.block,
                                  radius: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
    );
  }

  List<String> parseFeatures(String raw) {
    return List<String>.from(jsonDecode(raw));
  }

  List<String> featuresList = [];

  void ProductDetail() async {
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
      final response = await ProductProvider().productDetailApi(
        loginModel?.data?.user?.id.toString() ?? "",
        widget.productID.toString(),
        widget.type.toString(),
      );

      if (response.statusCode == 200) {
        setState(() {
          productViewModel = ProductViewModel.fromJson(response.data);
          isLoading = false;
        });

        if (productViewModel?.data?.features != null) {
          featuresList = List<String>.from(productViewModel!.data!.features!);
        }
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
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      buildErrorDialog(context, 'Error', "Server error occurred.");
    }
  }

  void AddReview() {
    setState(() {
      isAddReviewLoading = true;
    });
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "product_id": widget.productID.toString(),
      "rating": tempRating.toInt().toString(),
      "review": reviewController.text.trim(),
    };

    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().addReviewApi(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isAddReviewLoading = false;
              reviewController.clear();
            });
            ProductDetail();
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

  void ShowAllReviewApi(productID) {
    setState(() {
      isAddReviewLoading = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().showAllReviewApi(productID).then((response) async {
          showAllReviewModel = ShowAllReviewModel.fromJson(response.data);

          if (response.statusCode == 200) {
            setState(() {
              isAddReviewLoading = false;
            });
            showReviewsBottomSheet(context);
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

  Widget ReviewDetail({
    required String name,
    required int rating,
    required String comment,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_rounded,
                size: 22.sp,
                color: AppColors.maincolor,
              ),
              SizedBox(width: 2.w),
              Text(
                name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  SizedBox(width: 1.w),
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  void AddCartProductApi() {
    setState(() {
      isAddReviewLoading = true;
    });
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "id": widget.productID.toString(),
      "type": "product",
      "qty": count.toString(),
    };

    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().AddToCart(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isAddReviewLoading = false;
            });
            Get.to(() => AddToCartView(type: "product", fromBottomBar: false));
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

  void BuyNow() {
    setState(() {
      isAddReviewLoading = true;
    });
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "id": widget.productID.toString(),
      "type": "product",
    };

    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().AddToCart(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isAddReviewLoading = false;
            });
            Get.to(() => BuyProductView());
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

  void showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Add Your Review",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                        color: AppColors.maincolor,
                      ),
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  SizedBox(height: 2.h),
                  Text(
                    "Your Rating",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConstants.manrope,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Center(
                    child: RatingBar.builder(
                      initialRating: tempRating,
                      minRating: 1,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30.sp,
                      itemBuilder:
                          (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        tempRating = rating;
                      },
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "Write your experience",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppConstants.manrope,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Write your experience...',
                      filled: true,
                      fillColor: AppColors.maincolor.withOpacity(0.1),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 1.2.h,
                        horizontal: 4.w,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppConstants.manrope,
                        color: Colors.black45,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.maincolor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manrope,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(12),
                          child: batan(
                            title: "Cancel",
                            route: () {
                              Get.back();
                            },
                            color: Colors.grey.shade200,
                            fontcolor: Colors.black,
                            height: 5.h,
                            fontsize: 16.sp,
                            radius: 12.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(12),
                          child: batan(
                            title: "Submit",
                            route: () {
                              String reviewText = reviewController.text.trim();

                              if (reviewText.isNotEmpty) {
                                Navigator.pop(context);
                                AddReview();
                              } else {
                                Get.snackbar(
                                  "Oops!",
                                  "Please write something before submitting.",
                                  backgroundColor: Colors.red.shade100,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
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
          ),
        );
      },
    );
  }

  void showReviewsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "All Reviews",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: showAllReviewModel?.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final review = showAllReviewModel?.data?[index];
                        return ReviewTile(
                          name: review?.userName ?? "",
                          image: review?.userProfile ?? "",
                          rating: review?.rating?.toDouble() ?? 0.0,
                          review: review?.review ?? "",
                        ).marginOnly(bottom: 12);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
}

class ReviewTile extends StatelessWidget {
  final String name;
  final double rating;
  final String review;
  final String image;

  const ReviewTile({
    Key? key,
    required this.name,
    required this.rating,
    required this.review,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: null,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    placeholder:
                        (context, url) => CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.maincolor,
                        ),
                    errorWidget:
                        (context, url, error) => Image(
                          image: AssetImage("assets/images/waveeLogoShort.png"),
                          height: 20,
                          width: 20,
                        ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  SizedBox(width: 1.w),
                  Text(
                    rating.toString(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            review,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey.shade800,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double? icnSize;

  const CustomFeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    this.icnSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: icnSize == null ? 24.sp : icnSize,
            color: AppColors.maincolor,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 92.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ReadMoreText(
                    title,
                    trimLines: 1,
                    trimLength: 50,
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
                SizedBox(height: 0.5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
