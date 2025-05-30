import 'dart:convert';
import 'dart:developer';

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
import 'package:wavee/comman/Custom_AppBar.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/check_inernet_connecty.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/custom_button.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/error_dialog.dart';
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
      return discount.toStringAsFixed(0); // Round to 0 decimal
    } catch (e) {
      return "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    // log("Product ID Ave che che${widget.productID}");
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
                  SizedBox(height: 4.h),
                  TitleBar(
                    title:
                        productViewModel?.data?.name
                            .toString()
                            .capitalizeFirst ??
                        "",
                    drawerCallback: () {
                      productDetailKey.currentState?.openDrawer();
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
                              Container(
                                height: 25.h,
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
                                            10,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                productViewModel?.data?.image ??
                                                "", // fallback to empty string if image is null
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
                                                    image: AssetImage(
                                                      'assets/images/waveeLogoShort.png',
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
                                                                  child: Icon(
                                                                    Icons.error,
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
                                  const Icon(Icons.storefront),
                                  SizedBox(width: 2.w),
                                  Text(
                                    productViewModel?.data?.businessName ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.sp,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Container(
                                        width: 40.w,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                          vertical: 1.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              (productViewModel
                                                              ?.data
                                                              ?.quantity !=
                                                          null &&
                                                      productViewModel!
                                                              .data!
                                                              .quantity! >
                                                          0)
                                                  ? Icons.check_circle
                                                  : Icons.block,
                                              size: 18.sp,
                                              color:
                                                  (productViewModel
                                                                  ?.data
                                                                  ?.quantity !=
                                                              null &&
                                                          productViewModel!
                                                                  .data!
                                                                  .quantity! >
                                                              0)
                                                      ? AppColors.maincolor
                                                      : Colors.red,
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              (productViewModel
                                                              ?.data
                                                              ?.quantity !=
                                                          null &&
                                                      productViewModel!
                                                              .data!
                                                              .quantity! >
                                                          0)
                                                  ? "In Stock"
                                                  : "Out of Stock",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16.sp,
                                                fontFamily:
                                                    AppConstants.manrope,
                                                color:
                                                    (productViewModel
                                                                    ?.data
                                                                    ?.quantity !=
                                                                null &&
                                                            productViewModel!
                                                                    .data!
                                                                    .quantity! >
                                                                0)
                                                        ? Colors.black
                                                        : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              Row(
                                children: [
                                  Container(
                                    // width: 50.w,
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
                                          Icons.star,
                                          size: 18.sp,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          "${productViewModel?.data?.latestReviews?.length ?? 0} Ratings & Reviews",
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
                                          Icons.inventory,
                                          size: 18.sp,
                                          color: AppColors.maincolor,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          "Stock: ${productViewModel?.data?.quantity.toString() ?? ""}",
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
                              SizedBox(height: 1.5.h),
                              Text(
                                "${productViewModel?.data?.name.toString().capitalizeFirst ?? ""}",
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
                                  if (productViewModel?.data?.offerPrice !=
                                          null &&
                                      productViewModel!
                                          .data!
                                          .offerPrice!
                                          .isNotEmpty)
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          // Discount Percent (optional: can calculate dynamically)
                                          TextSpan(
                                            text:
                                                "-${_calculateDiscountPercentage(productViewModel!.data!.price, productViewModel!.data!.offerPrice)}%  ",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.red,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),

                                          TextSpan(
                                            text:
                                                "£ ${productViewModel!.data!.offerPrice}",
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Text(
                                      "£ ${productViewModel?.data?.price ?? "0.00"}",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  if (productViewModel?.data?.offerPrice !=
                                          null &&
                                      productViewModel!
                                          .data!
                                          .offerPrice!
                                          .isNotEmpty)
                                    // Show original price as MRP with line-through
                                    Text(
                                      "M.R.P.: £${productViewModel?.data?.price ?? "0.00"}",
                                      style: TextStyle(
                                        fontFamily: AppConstants.manrope,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.normal,
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
                              SizedBox(height: 1.5.h),
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
                                    SizedBox(height: 1.h),
                                    ...featuresList.map((feature) {
                                      // return Container(
                                      //   margin: EdgeInsets.only(top: 0.5.h),
                                      //   padding: EdgeInsets.all(8),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.white,
                                      //     borderRadius: BorderRadius.circular(10),
                                      //   ),
                                      //   child: Row(
                                      //     children: [
                                      //       SizedBox(width: 10),
                                      //       Icon(Icons.check_circle_outline, color: AppColors.maincolor),
                                      //       SizedBox(width: 10),
                                      //       Expanded(
                                      //         child: Text(
                                      //           feature,
                                      //           style: TextStyle(
                                      //             fontSize: 14.sp,
                                      //             fontFamily: AppConstants.manrope,
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
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Text(
                                    "Review & Ratings",
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,
                                      color: AppColors.maincolor,
                                    ),
                                  ),
                                  Spacer(),
                                  batan(
                                    title: "Add Review",
                                    route: () {
                                      showReviewDialog(context);
                                    },
                                    color: AppColors.maincolor,
                                    fontcolor: Colors.white,
                                    height: 5.h,
                                    fontsize: 17.sp,
                                    width: 35.w,
                                    radius: 12.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              SizedBox(
                                child:
                                    productViewModel
                                                ?.data
                                                ?.latestReviews
                                                ?.length ==
                                            0
                                        ? Center(
                                          child: Text(
                                            "No Reviews Avaiable",
                                            style: TextStyle(
                                              fontFamily: AppConstants.manrope,
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w100,
                                            ),
                                          ),
                                        )
                                        : ListView.builder(
                                          itemCount:
                                              productViewModel
                                                  ?.data
                                                  ?.latestReviews
                                                  ?.length ??
                                              0,
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final review =
                                                productViewModel
                                                    ?.data
                                                    ?.latestReviews?[index];

                                            return ReviewTile(
                                              name: review?.userName ?? "",
                                              rating:
                                                  review?.rating?.toDouble() ??
                                                  0.0,
                                              image: review?.userProfile ?? '',
                                              review: review?.review ?? "",
                                            ).marginOnly(bottom: 1.h);
                                          },
                                        ),
                              ),
                              SizedBox(height: 0.5.h),
                              productViewModel?.data?.latestReviews?.length == 0
                                  ? SizedBox()
                                  : Row(
                                    children: [
                                      Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          ShowAllReviewApi(
                                            widget.productID ?? "",
                                          );
                                        },
                                        child: const Text(
                                          "View All Reviews",
                                          style: TextStyle(
                                            color: Colors.orange,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              SizedBox(height: 10.h),
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
                child:
                    (productViewModel?.data?.quantity != null &&
                            productViewModel!.data!.quantity! > 0)
                        ? Row(
                          children: [
                            /// 🛒 Add to Cart Button
                            Expanded(
                              child: Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(12),
                                child: batan(
                                  title: "Add to Cart",
                                  // route: () {
                                  //   if (cartDetailsModel?.data != null &&
                                  //       cartDetailsModel!.data!.isNotEmpty &&
                                  //       cartDetailsModel!.data![0].type == "service") {
                                  //     Get.snackbar(
                                  //       "Service item already in cart",
                                  //       "Please remove service items before adding a product.",
                                  //       backgroundColor: AppColors.redColor,
                                  //       colorText: Colors.white,
                                  //       margin: EdgeInsets.all(10),
                                  //       snackPosition: SnackPosition.TOP,
                                  //     );
                                  //   } else {
                                  //     AddCartProductApi();
                                  //   }
                                  // },
                                  route: () {
                                    if (cartDetailsModel?.data != null &&
                                        cartDetailsModel!.data!.isNotEmpty) {
                                      if (cartDetailsModel!.data![0].type ==
                                          "service") {
                                        Get.snackbar(
                                          "Product item already in cart",
                                          "Please remove service items before adding a product.",
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
                                          productViewModel?.data?.businessId) {
                                        // BusinessId same hoy to add karva do
                                        AddCartProductApi();
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
                                      AddCartProductApi();
                                    }
                                  },

                                  color: AppColors.maincolor,
                                  fontcolor: AppColors.white,
                                  height: 5.h,
                                  fontsize: 15.sp,
                                  iconData: Icons.add_shopping_cart_outlined,
                                  radius: 12.0,
                                ),
                              ),
                            ),

                            SizedBox(width: 4.w),

                            // 🛍️ Buy Now Button
                            // Expanded(
                            //   child: Material(
                            //     elevation: 1,
                            //     borderRadius: BorderRadius.circular(12),
                            //     child: batan(
                            //       title: "Buy Now",
                            //       route: () {
                            //         // if (cartDetailsModel?.data != null &&
                            //         //     cartDetailsModel!.data!.isNotEmpty &&
                            //         //     cartDetailsModel!.data![0].type == "service") {
                            //         //   Get.snackbar(
                            //         //     "Service item already in cart",
                            //         //     "Please remove service items before adding a product.",
                            //         //     backgroundColor: AppColors.redColor,
                            //         //     colorText: Colors.white,
                            //         //     margin: EdgeInsets.all(10),
                            //         //     snackPosition: SnackPosition.TOP,
                            //         //   );
                            //         // } else {
                            //         //   BuyNow();
                            //         // }
                            //         if (cartDetailsModel?.data != null && cartDetailsModel!.data!.isNotEmpty) {
                            //           if (cartDetailsModel!.data![0].type == "service") {
                            //             Get.snackbar(
                            //               "Product item already in cart",
                            //               "Please remove service items before adding a product.",
                            //               backgroundColor: AppColors.redColor,
                            //               colorText: Colors.white,
                            //               margin: EdgeInsets.all(10),
                            //               snackPosition: SnackPosition.TOP,
                            //             );
                            //           }
                            //           // BusinessId same chhe ke nahi
                            //           else if (cartDetailsModel!.data![0].itemDetails?.businessId ==productViewModel?.data?.businessId) {
                            //             // BusinessId same hoy to add karva do
                            //             AddCartProductApi();
                            //           } else {
                            //             // BusinessId alag hoy to alert karo
                            //             Get.snackbar(
                            //               "Business mismatch",
                            //               "You can only add items from the same business to the cart.",
                            //               backgroundColor: AppColors.redColor,
                            //               colorText: Colors.white,
                            //               margin: EdgeInsets.all(10),
                            //               snackPosition: SnackPosition.TOP,
                            //             );
                            //           }
                            //         } else {
                            //           // Cart empty hoy to direct add karva do
                            //           AddCartProductApi();
                            //         }
                            //       },
                            //       color: AppColors.maincolor,
                            //       fontcolor: AppColors.white,
                            //       height: 5.h,
                            //       fontsize: 15.sp,
                            //       iconData: Icons.shopping_bag,
                            //       radius: 12.0,
                            //     ),
                            //   ),
                            // ),
                          ],
                        )
                        : Row(
                          children: [
                            /// ❌ Out of Stock Button
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

      // Container(
      //         height: 7.5.h,
      //         width: double.infinity,
      //         padding: EdgeInsets.symmetric(horizontal: 4.w),
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           boxShadow: [
      //             BoxShadow(
      //               color: Colors.black12,
      //               blurRadius: 10,
      //               offset: Offset(0, -2),
      //             )
      //           ],
      //           borderRadius:
      //               const BorderRadius.vertical(top: Radius.circular(20)),
      //         ),
      //         child: (productViewModel?.data?.quantity != null &&
      //                 productViewModel!.data!.quantity! > 0)
      //             ? Row(
      //                 children: [
      //                   /// 🛒 Add to Cart Button
      //                   Expanded(
      //                     child: Material(
      //                       elevation: 1,
      //                       borderRadius: BorderRadius.circular(12),
      //                       child: batan(
      //                         title: "Add to Cart",
      //                         route: () {
      //                           // Get.to(() => AddToCartView());
      //                           AddCartProductApi();
      //                         },
      //                         color: AppColors.maincolor,
      //                         fontcolor: AppColors.white,
      //                         height: 5.h,
      //                         // width: 50.w,
      //                         fontsize: 15.sp,
      //                         iconData: Icons.add_shopping_cart_outlined,
      //                         radius: 12.0,
      //                       ),
      //                     ),
      //                   ),
      //
      //                   SizedBox(width: 4.w),
      //                   Expanded(
      //                     child: Material(
      //                       elevation: 1,
      //                       borderRadius: BorderRadius.circular(12),
      //                       child: batan(
      //                         title: "Buy Now",
      //                         route: () {
      //                           BuyNow();
      //                         },
      //                         color: AppColors.maincolor,
      //                         fontcolor: AppColors.white,
      //                         height: 5.h,
      //                         // width: 50.w,
      //                         fontsize: 15.sp,
      //                         iconData: Icons.shopping_bag,
      //                         radius: 12.0,
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               )
      //             : Row(
      //                 children: [
      //                   /// 🛒 Add to Cart Button
      //                   Expanded(
      //                     child: Material(
      //                       elevation: 1,
      //                       borderRadius: BorderRadius.circular(12),
      //                       child: batan(
      //                         title: "Out of Stock",
      //                         route: () {},
      //                         color: Colors.grey.shade200,
      //                         fontcolor: AppColors.redColor,
      //                         height: 5.h,
      //                         // width: 50.w,
      //                         fontsize: 15.sp,
      //                         iconData: Icons.block,
      //                         radius: 12.0,
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //       ),
    );
  }

  List<String> parseFeatures(String raw) {
    return List<String>.from(jsonDecode(raw));
  }

  // void ProductDetail() {
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       ProductProvider()
  //           .ProductDetailApi(
  //               loginModel?.data?.user?.id.toString() ?? "", widget.productID)
  //           .then((response) async {
  //         productViewModel =
  //             ProductViewModel.fromJson(jsonDecode(response.body));
  //         if (response.statusCode == 200 && profileModel?.status == 200) {
  //           print("adfdsfsdf${response.body}");
  //           print(
  //               "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}");
  //
  //           setState(() {
  //             isLoading = false;
  //           });
  //         } else {
  //           setState(() {
  //             isLoading = false;
  //           });
  //           log("Error");
  //         }
  //       });
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }
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
      final response = await ProductProvider().ProductDetailApi(
        loginModel?.data?.user?.id.toString() ?? "",
        widget.productID.toString(),
        widget.type.toString(),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        setState(() {
          productViewModel = ProductViewModel.fromJson(jsonData);
          isLoading = false;
        });

        print("✅ Product loaded: ${response.body}");
        if (productViewModel?.data?.features != null) {
          featuresList = List<String>.from(productViewModel!.data!.features!);
        }

        /// Optional: Check if feature string is valid and parse it
        // String? featureRaw = productViewModel?.data?.features;
        // if (featureRaw != null && featureRaw.isNotEmpty) {
        //   try {
        //     featuresList = List<String>.from(jsonDecode(featureRaw));
        //   } catch (e) {
        //     print("⚠️ Error parsing features: $e");
        //     featuresList = [];
        //   }
        // }
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

  // void ProductDetail() async {
  //   // Show loader
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   bool internet = await checkInternet();
  //
  //   if (!internet) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     buildErrorDialog(context, 'Error', "Internet Required");
  //     return;
  //   }
  //
  //   try {
  //     final response = await ProductProvider().ProductDetailApi(
  //       loginModel?.data?.user?.id.toString() ?? "",
  //       widget.productID,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final jsonData = jsonDecode(response.body);
  //
  //       setState(() {
  //         productViewModel = ProductViewModel.fromJson(jsonData);
  //         isLoading = false;
  //       });
  //
  //       print("✅ Product loaded: ${response.body}");
  //
  //       /// Optional: Check if feature string is valid and parse it
  //       String? featureRaw = productViewModel?.data?.features;
  //       if (featureRaw != null && featureRaw.isNotEmpty) {
  //         try {
  //           featuresList = List<String>.from(jsonDecode(featureRaw));
  //         } catch (e) {
  //           print("⚠️ Error parsing features: $e");
  //           featuresList = [];
  //         }
  //       }
  //     } else {
  //       print("❌ API Error: ${response.statusCode}");
  //       setState(() {
  //         isLoading = false;
  //       });
  //       buildErrorDialog(
  //           context, 'Error', "Something went wrong. Please try again.");
  //     }
  //   } catch (e) {
  //     print("❌ Exception: $e");
  //     setState(() {
  //       isLoading = false;
  //     });
  //     buildErrorDialog(context, 'Error', "Server error occurred.");
  //   }
  // }

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
    log("data jay che che ${data}");
    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().AddReviewApi(data).then((response) async {
          // productViewModel =
          //     ProductViewModel.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200) {
            print("adfdsfsdf${response.body}");

            setState(() {
              isAddReviewLoading = false;
              reviewController.clear();
            });
            ProductDetail();
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

  void ShowAllReviewApi(productID) {
    setState(() {
      isAddReviewLoading = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().ShowAllReviewApi(productID).then((response) async {
          showAllReviewModel = ShowAllReviewModel.fromJson(
            jsonDecode(response.body),
          );
          if (response.statusCode == 200) {
            print("Data ave che all review no ${response.body}");

            setState(() {
              isAddReviewLoading = false;
            });
            showReviewsBottomSheet(context);
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
          /// 🧑 Name + Rating
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

          /// 📝 Review Text
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
            Get.to(() => AddToCartView(type: "product"));
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

  void BuyNow() {
    setState(() {
      isAddReviewLoading = true;
    });
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "id": widget.productID.toString(),
      "type": "product",
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
            Get.to(() => BuyProductView());
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
          // Half of the screen
          minChildSize: 0.4,
          // Minimum height when dragged down
          maxChildSize: 0.9,
          // Allow it to expand if needed
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
                backgroundImage: null, // keep null because we use child
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: image,
                    // ✅ replace with your image URL
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

          /// 📝 Review Text
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

  // final String? subtitle;

  const CustomFeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    // this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 6,
        //     offset: Offset(0, 2),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.maincolor),
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
                // Text(
                //   subtitle.toString(),
                //   style: TextStyle(
                //     fontSize: 14.sp,
                //     color: Colors.grey.shade600,
                //     fontFamily: AppConstants.manrope,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
