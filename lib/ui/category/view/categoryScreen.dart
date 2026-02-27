import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/ui/category/modal/categoryDetailModal.dart';
import 'package:wavee/ui/cart_screen/model/cartDetailsModal.dart';

import '../../../utils/checkInternetConnection.dart';
import '../../../utils/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/customAppBar.dart';
import '../../../utils/customBatan.dart';
import '../../../utils/errorDialog.dart';
import '../../../utils/loader.dart';
import '../../../utils/productDisable.dart';
import '../../cart_screen/provider/addToCartProvider.dart';
import '../../cart_screen/view/cartViewScreen.dart';
import '../../community_details_page/provider/communityDetailProvider.dart';
import '../../product_detail_page/provider/productProvider.dart';
import '../../product_detail_page/view/productDetailPage.dart';

class CategoryScreen extends StatefulWidget {
  String? categoryID;
  String? businessID;
  String? CategoryName;

  CategoryScreen({
    super.key,
    this.categoryID,
    this.businessID,
    this.CategoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool isLoading = false;
  bool isAddtoCart = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    CategoryDetailAPI();
    GetCartDetailApi();
  }

  final GlobalKey<ScaffoldState> categoryScreen = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body:
          isLoading
              ? const Loader()
              : Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      TitleBar(title: "Category", drawerCallback: () {}),
                      SizedBox(height: 3.h),
                      Text(
                        "Products for '${widget.CategoryName}'",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        child: GridView.builder(
                          itemCount: categoryDetailModal?.data?.length ?? 0,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.50,
                                crossAxisSpacing: 3.w,
                                mainAxisSpacing: 2.h,
                              ),
                          itemBuilder: (context, index) {
                            final product = categoryDetailModal?.data?[index];
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  ProductDetailPage(
                                    type: "product",
                                    productID: product?.id.toString() ?? "",
                                  ),
                                );
                              },
                              child:
                                  product == null
                                      ? Center(
                                        child: Text(
                                          "No Product Available",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: AppConstants.manrope,
                                          ),
                                        ),
                                      )
                                      : Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          product.image
                                                              ?.toString() ??
                                                          "",
                                                      height: 15.h,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
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
                                                          ) => Image.asset(
                                                            "assets/images/waveeLogoShort.png",
                                                            height: 15.h,
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 1.5.h),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 2.w,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            product.name ??
                                                                "Product Name",
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      0.5.w,
                                                                ),
                                                            child:
                                                                (product.offerPrice !=
                                                                            null &&
                                                                        product.offerPrice !=
                                                                            "0.00" &&
                                                                        product.offerPrice !=
                                                                            product.price)
                                                                    ? Row(
                                                                      children: [
                                                                        Text(
                                                                          "£${product.price}",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                13.sp,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            fontFamily:
                                                                                AppConstants.manrope,
                                                                            color:
                                                                                Colors.grey,
                                                                            decoration:
                                                                                TextDecoration.lineThrough,
                                                                            decorationColor:
                                                                                AppColors.maincolor,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          "£${product.offerPrice}",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                14.sp,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                AppConstants.manrope,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                    : Text(
                                                                      "£${product.price ?? ""}",
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            14.sp,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            AppConstants.manrope,
                                                                        color:
                                                                            Colors.black,
                                                                      ),
                                                                    ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      0.5.w,
                                                                ),
                                                            child:
                                                                product.quantity ==
                                                                            0 ||
                                                                        product.quantity ==
                                                                            null
                                                                    ? Text(
                                                                      "Out of Stock",
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            14.sp,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontFamily:
                                                                            AppConstants.manrope,
                                                                        color:
                                                                            Colors.red,
                                                                      ),
                                                                    )
                                                                    : const SizedBox(),
                                                          ),
                                                          SizedBox(height: 3.h),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                top: 12.h,
                                                right: 2,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    bool isBlocked =
                                                        product.quantity == 0 ||
                                                        product.quantity ==
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
                                                        const SnackBar(
                                                          content: Text(
                                                            'Product is out of stock.',
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    if (cartDetailsModel
                                                                ?.data !=
                                                            null &&
                                                        cartDetailsModel!
                                                            .data!
                                                            .isNotEmpty) {
                                                      if (cartDetailsModel!
                                                              .data![0]
                                                              .type ==
                                                          "service") {
                                                        ShowAddCart(
                                                          context: context,
                                                          businessName:
                                                              busnessviewmodal
                                                                  ?.data
                                                                  ?.business
                                                                  ?.businessName ??
                                                              "",
                                                          isProduct: false,
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
                                                              if (itemId !=
                                                                  null) {
                                                                await RemoveFromCartApi(
                                                                  itemId,
                                                                  "service",
                                                                );
                                                              }
                                                            }
                                                            AddCartProductApi(
                                                              product.id
                                                                      .toString() ??
                                                                  "",
                                                            );
                                                          },
                                                        );
                                                      } else if (cartDetailsModel!
                                                              .data![0]
                                                              .itemDetails
                                                              ?.businessId ==
                                                          productViewModel
                                                              ?.data
                                                              ?.businessId) {
                                                        AddCartProductApi(
                                                          product.id
                                                                  .toString() ??
                                                              "",
                                                        );
                                                      } else {
                                                        ShowAddCart(
                                                          context: context,
                                                          businessName:
                                                              busnessviewmodal
                                                                  ?.data
                                                                  ?.business
                                                                  ?.businessName ??
                                                              "",
                                                          isProduct: false,
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

                                                              if (itemId !=
                                                                  null) {
                                                                await RemoveFromCartApi(
                                                                  itemId,
                                                                  type.toString(),
                                                                );
                                                              }
                                                            }
                                                            AddCartProductApi(
                                                              product.id
                                                                      .toString() ??
                                                                  "",
                                                            );
                                                          },
                                                        );
                                                      }
                                                    } else {
                                                      AddCartProductApi(
                                                        product.id.toString() ??
                                                            "",
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 10.w,
                                                    height: 10.w,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors
                                                                      .black26,
                                                              blurRadius: 4,
                                                              offset: Offset(
                                                                0,
                                                                2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                    child: Icon(
                                                      product.quantity == 0 ||
                                                              product.quantity ==
                                                                  null
                                                          ? Icons.block
                                                          : Icons.add,
                                                      size: 22.sp,
                                                      color:
                                                          product.quantity ==
                                                                      0 ||
                                                                  product.quantity ==
                                                                      null
                                                              ? AppColors
                                                                  .redColor
                                                              : AppColors
                                                                  .maincolor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                            );
                          },
                        ).paddingOnly(left: 2.w, right: 2.w),
                      ),
                    ],
                  ).paddingOnly(left: 4.w, right: 4.w),
                  Positioned(
                    bottom: 10,
                    left: 16,
                    right: 16,
                    child: SizedBox(
                      width: double.infinity,
                      height: 5.h,
                      child: batan(
                        title: "View Basket",
                        route: () {
                          Get.to(
                            AddToCartView(
                              type: 'product',
                              fromBottomBar: false,
                              isAmend: false,
                            ),
                          );
                        },
                        color: AppColors.maincolor,
                        fontcolor: AppColors.white,
                        height: 5.h,
                        width: double.infinity,
                        fontsize: 18.sp,
                        radius: 12.0,
                        iconData: Icons.shopping_cart_checkout,
                      ),
                    ),
                  ),
                  if (isAddtoCart)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(child: Loader()),
                    ),
                ],
              ),
    );
  }

  double getSubtotal() {
    double total = 0.0;
    cartDetailsModel?.data?.forEach((item) {
      double price =
          double.tryParse(
            item.itemDetails?.offerPrice ?? item.itemDetails?.price ?? '0',
          ) ??
          0;
      total += price * (item.quantity ?? 1);
    });
    return total;
  }

  CategoryDetailAPI() {
    checkInternet().then((internet) async {
      if (internet) {
        CommunityDetailProvider()
            .categoryDetailApi(
              widget.businessID.toString(),
              widget.categoryID.toString(),
            )
            .then((response) async {
              categoryDetailModal = CategoryDetailModal.fromJson(response.data);
              if (response.statusCode == 200) {
                setState(() {
                  isLoading = false;
                });
              } else if (response.statusCode == 422) {
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

  AddCartProductApi(String productID) {
    setState(() {
      isAddtoCart = true;
    });
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "id": productID.toString(),
      "type": "product",
    };

    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider().AddToCart(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isAddtoCart = false;
            });
            Get.to(
              () => AddToCartView(
                type: "product",
                fromBottomBar: false,
                isAmend: false,
              ),
            );
          } else {
            setState(() {
              isAddtoCart = false;
            });
          }
        });
      } else {
        setState(() {
          isAddtoCart = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  GetCartDetailApi() {
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
      isAddtoCart = true;
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
              isAddtoCart = false;
            });
          } else {
            setState(() {
              isAddtoCart = false;
            });
          }
        });
      } else {
        setState(() {
          isAddtoCart = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
