import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Buy%20Product/view/buy_product_view.dart';
import 'package:wavee/Screen/HomeNewPage/View/homenewpage.dart';
import 'package:wavee/comman/Custom_AppBar.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/bottom_bar.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/custom_batan.dart';
import '../../../comman/error_dialog.dart';
import '../../Community Screen/Community Screen/view/community_screen.dart';
import '../../Oredrscreen/View/order_screen_view.dart';
import '../../Product Detail Page/provider/product_provider.dart';
import '../model/add_to_cart_model.dart';
import '../provider/add_to_cart_provider.dart';

class AddToCartView extends StatefulWidget {
  String? type;
  int? selected;
  final bool fromBottomBar;

  AddToCartView({
    super.key,
    this.type,
    this.selected,
    this.fromBottomBar = false,
  });

  @override
  State<AddToCartView> createState() => _AddToCartViewState();
}

class _AddToCartViewState extends State<AddToCartView> {
  final GlobalKey<ScaffoldState> addtocartkey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isUpdateQuantity = false;

  double otherFees = 0.0;
  double deliveryFees = 0.0;
  bool hasShownFancySheet = false;
  bool isAddtoCart = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    GetCartDetailApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: addtocartkey,
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: TitleBar(
                back: () {
                  if (widget.fromBottomBar) {
                    Get.offAll(HomePage(userName: ""));
                  } else {
                    if ((cartDetailsModel?.data?.length ?? 0) == 0) {
                      Get.back();
                    } else {
                      Get.back();
                    }
                  }
                },
                title: "Your Basket",
                drawerCallback: () {
                  addtocartkey.currentState?.openDrawer();
                },
              ),
            ),
            SizedBox(height: 5.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              height: 90.h,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffdedfe5), width: 1),
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        isLoading
                            ? Expanded(child: Center(child: Loader()))
                            : cartDetailsModel?.data?.length == null ||
                                cartDetailsModel?.data?.length == 0
                            ? Expanded(
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 25.w,
                                        height: 25.w,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF0F0F0),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.shopping_basket_outlined,
                                          size: 12.w,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        "Your basket is empty",
                                        style: TextStyle(
                                          fontFamily: AppConstants.manrope,
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2E3333),
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        "Add items to get started",
                                        style: TextStyle(
                                          fontFamily: AppConstants.manrope,
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          batan(
                                            title: "Explore Community",
                                            route: () {
                                              Get.to(() => CommunityScreen());
                                            },
                                            color: AppColors.maincolor,
                                            fontcolor: Colors.white,
                                            height: 5.h,
                                            fontsize: 16.sp,
                                            radius: 12.0,
                                            width: 43.5.w,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          SizedBox(width: 4.w),
                                          batan(
                                            title: "View Orders",
                                            route: () {
                                              Get.to(() => Order_Screen());
                                            },
                                            color: AppColors.maincolor,
                                            fontcolor: Colors.white,
                                            height: 5.h,
                                            fontsize: 16.sp,
                                            radius: 12.0,
                                            width: 40.w,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.h),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            : Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "My Cart",
                                                style: TextStyle(
                                                  fontSize: 22.sp,
                                                  color: Colors.black,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          Row(
                                            children: [
                                              Container(
                                                width: 12.w,
                                                height: 1.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Row(
                                            children: [
                                              Text(
                                                "Items (${cartDetailsModel?.data?.length})",
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  color: Color(0xFF969696),
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 1.h),
                                          ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount:
                                                cartDetailsModel
                                                    ?.data
                                                    ?.length ??
                                                0,
                                            separatorBuilder:
                                                (context, index) => Container(
                                                  height: 1,
                                                  color: Color(0xFFF5F5F5),
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 4.w,
                                                  ),
                                                ),
                                            itemBuilder: (context, index) {
                                              final item =
                                                  cartDetailsModel!
                                                      .data![index];
                                              if (item.itemDetails == null) {
                                                return const SizedBox();
                                              }
                                              final product = item.itemDetails!;

                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                  vertical: 0.5.h,
                                                ),
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 2.w,
                                                  vertical: 1.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Color(0xFF969696),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Container(
                                                        width: 18.w,
                                                        height: 18.w,
                                                        decoration: BoxDecoration(
                                                          color: Color(
                                                            0xFFF8F8F8,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              (product.image !=
                                                                          null &&
                                                                      product
                                                                          .image!
                                                                          .isNotEmpty)
                                                                  ? product
                                                                      .image!
                                                                  : (product.images !=
                                                                          null &&
                                                                      product
                                                                          .images!
                                                                          .isNotEmpty)
                                                                  ? product
                                                                      .images!
                                                                      .first
                                                                  : "",
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Container(
                                                                child: Center(
                                                                  child: CircularProgressIndicator(
                                                                    color:
                                                                        AppColors
                                                                            .maincolor,
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                                ),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => Container(
                                                                child: Icon(
                                                                  Icons
                                                                      .image_outlined,
                                                                  color:
                                                                      Colors
                                                                          .grey[400],
                                                                  size: 8.w,
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 3.w),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  product.name ??
                                                                      "",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                    color: Color(
                                                                      0xFF2E3333,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  RemoveFromCartApi(
                                                                    item.productId ??
                                                                        0,
                                                                    item.type ??
                                                                        "product",
                                                                  );
                                                                },
                                                                child: Container(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        1.w,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Color(
                                                                      0xFFF5F5F5,
                                                                    ),
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                    size: 18.sp,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "£${product.offerPrice ?? product.price}",
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      17.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                  color:
                                                                      AppColors
                                                                          .maincolor,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          2.w,
                                                                      vertical:
                                                                          0.5.h,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  border: Border.all(
                                                                    color: Color(
                                                                      0xff969696,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      onTap: () {
                                                                        if (item.quantity! >
                                                                            1) {
                                                                          setState(() {
                                                                            item.quantity =
                                                                                item.quantity! -
                                                                                1;
                                                                          });
                                                                          updateQuantityApi(
                                                                            item.productId!,
                                                                            item.quantity!,
                                                                            item.type ??
                                                                                "",
                                                                          );
                                                                        } else if (item.quantity ==
                                                                            1) {
                                                                          RemoveFromCartApi(
                                                                            item.productId ??
                                                                                0,
                                                                            item.type ??
                                                                                "product",
                                                                          );
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                        "-",
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              17.sp,
                                                                          color:
                                                                              Colors.black,
                                                                          fontFamily:
                                                                              AppConstants.manrope,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          2.w,
                                                                    ),
                                                                    Text(
                                                                      "${item.quantity}",
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            17.sp,
                                                                        color:
                                                                            Colors.black,
                                                                        fontFamily:
                                                                            AppConstants.manrope,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          2.w,
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () {
                                                                        if (item.quantity! <
                                                                            10) {
                                                                          setState(() {
                                                                            item.quantity =
                                                                                item.quantity! +
                                                                                1;
                                                                          });
                                                                          updateQuantityApi(
                                                                            item.productId!,
                                                                            item.quantity!,
                                                                            item.type ??
                                                                                "",
                                                                          );
                                                                        }
                                                                      },
                                                                      child: Icon(
                                                                        Icons
                                                                            .add,
                                                                        color:
                                                                            Colors.black,
                                                                        size:
                                                                            16.sp,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    cartDetailsModel?.data?[0].type == "product"
                                        ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                              child: Text(
                                                "People also added",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            _buildSuggestedList(),
                                          ],
                                        )
                                        : SizedBox.shrink(),
                                    SizedBox(height: 50.h),
                                  ],
                                ),
                              ),
                            ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                  isLoading
                      ? Container()
                      : (cartDetailsModel?.data?.isEmpty ?? true)
                      ? Container()
                      : Positioned(
                        top: 10.h,
                        left: 0,
                        right: 0,
                        bottom: 0.h,
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.65,
                          minChildSize: 0.60,
                          builder: (context, scrollController) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(45),
                                  topLeft: Radius.circular(45),
                                ),
                                border: Border.all(
                                  color: Color(0xffc7c7c7),
                                  width: 1,
                                ),
                                color: Color(0xfff2f2f2),
                              ),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    cartDetailsModel?.data?.length == "" ||
                                            cartDetailsModel?.data?.length ==
                                                null
                                        ? Container()
                                        : _buildSectionCard(
                                          title: "Order Summary",
                                          icon: Icons.receipt,
                                          child: Column(
                                            children: [
                                              cartDetailsModel?.data?.length ==
                                                          "" ||
                                                      cartDetailsModel
                                                              ?.data
                                                              ?.length ==
                                                          null
                                                  ? Container()
                                                  : cartDetailsModel
                                                          ?.data?[0]
                                                          .type ==
                                                      "product"
                                                  ? _buildSummaryRow(
                                                    "Subtotal",
                                                    getSubtotal(),
                                                  )
                                                  : _buildSummaryRow(
                                                    "Subtotal",
                                                    getSubtotal1(),
                                                  ),
                                              cartDetailsModel?.data?[0].type ==
                                                          "product" &&
                                                      cartDetailsModel
                                                              ?.data?[0]
                                                              .loyaltyDetails
                                                              ?.willGetLoyaltyDiscountOnCurrentOrder ==
                                                          true
                                                  ? _buildSummaryRow(
                                                    "Loyalty Discount (-${getLoyaltyDiscountPercentage().toStringAsFixed(0)}%)",
                                                    getLoyaltyDiscountAmount(),
                                                    isDiscount: true,
                                                  )
                                                  : SizedBox(),
                                              Divider(
                                                height: 3.h,
                                                thickness: 1,
                                              ),
                                              cartDetailsModel?.data?[0].type ==
                                                      "product"
                                                  ? _buildSummaryRow(
                                                    "Total",
                                                    getFinalTotal(),
                                                    isTotal: true,
                                                  )
                                                  : _buildSummaryRow(
                                                    "Total",
                                                    getSubtotal1(),
                                                    isTotal: true,
                                                  ),
                                            ],
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  if (isUpdateQuantity)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(child: Loader()),
                    ),
                  isLoading
                      ? Container()
                      : cartDetailsModel?.data?.length == 0 ||
                          cartDetailsModel?.data?.length == null
                      ? Container()
                      : Positioned(
                        top: 60.h,
                        left: 35.w,
                        child: InkWell(
                          onTap: _handleCheckoutTap,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              border: Border.all(color: Color(0xffd9d9d9)),
                            ),
                            child: Text(
                              "Checkout",
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.black,
                                fontFamily: AppConstants.manrope,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Bottom_bar(selected: 4),
    );
  }

  AddCartProductApi(String productID) {
    setState(() {
      isUpdateQuantity = true;
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
            await GetCartDetailApi();
            setState(() {
              isUpdateQuantity = false;
              isAddtoCart = false;
            });
            Get.to(() => AddToCartView(type: "product"));
          } else {
            setState(() {
              isUpdateQuantity = false;
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            height: 1.h,
            width: 20.w,
            decoration: BoxDecoration(
              color: Color(0xf0D9D9D9),
              borderRadius: BorderRadius.circular(10),
            ),
          ).paddingOnly(top: 2.h, bottom: 2.h),
        ),
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: AppConstants.manrope,
                fontWeight: FontWeight.w600,
                color: Color(0xff969696),
              ),
            ),
          ],
        ),
        Divider(height: 3.h, thickness: 1),
        Padding(padding: EdgeInsets.all(4.w), child: child),
      ],
    );
  }

  Widget summaryTile(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 17.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontFamily: AppConstants.manrope,
            ),
          ),
          Text(
            "£${amount}",
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 17.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 16.5.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
              color:
                  isDiscount
                      ? Colors.green[700]
                      : (isTotal ? Colors.black : Colors.grey[800]),
            ),
          ),
          Text(
            isDiscount
                ? "-£${amount.toStringAsFixed(2)}"
                : "£${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 16.5.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
              color:
                  isDiscount
                      ? Colors.green[700]
                      : (isTotal ? AppColors.maincolor : Colors.black),
            ),
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

  double getSubtotal1() {
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

  GetCartDetailApi() {
    checkInternet().then((internet) {
      if (internet) {
        CartProvider()
            .cartDetailApi(loginModel?.data?.user?.id.toString() ?? "")
            .then((response) {
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

  updateQuantityApi(int productId, int quantity, type) {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "product_id": productId.toString(),
      "quantity": quantity.toString(),
      "type": type.toString(),
    };
    setState(() {
      isUpdateQuantity = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        CartProvider().updateCartQuantityApi(data).then((response) async {
          if (response.statusCode == 200) {
            setState(() {
              isUpdateQuantity = false;
            });
          } else {
            setState(() {
              isUpdateQuantity = false;
            });
          }
        });
      } else {
        setState(() {
          isUpdateQuantity = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  RemoveFromCartApi(int productId, String type) {
    setState(() {
      isUpdateQuantity = true;
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
              isUpdateQuantity = false;
            });
            GetCartDetailApi();
          } else {
            setState(() {
              isUpdateQuantity = false;
            });
          }
        });
      } else {
        setState(() {
          isUpdateQuantity = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  double getLoyaltyDiscountPercentage() {
    final loyaltyDetails = cartDetailsModel?.data?[0].loyaltyDetails;
    if (loyaltyDetails?.willGetLoyaltyDiscountOnCurrentOrder != true) {
      return 0.0;
    }
    String discountStr =
        checkoutTotal?.data?.first.loyaltyDetails?.loyaltyDiscountPercentage ??
        "0";
    return double.tryParse(discountStr) ?? 0.0;
  }

  double getLoyaltyDiscountAmount() {
    final loyaltyDetails = cartDetailsModel?.data?[0].loyaltyDetails;
    if (loyaltyDetails?.willGetLoyaltyDiscountOnCurrentOrder != true) {
      return 0.0;
    }

    double subtotal = getSubtotal();
    double discountPercent = getLoyaltyDiscountPercentage();

    return subtotal * (discountPercent / 100);
  }

  double getFinalTotal() {
    double subtotal = getSubtotal();
    double loyaltyDiscount = getLoyaltyDiscountAmount();
    return subtotal - loyaltyDiscount;
  }

  Widget _buildSuggestedList() {
    final List<BusinessProducts> allProducts =
        (cartDetailsModel?.data?.expand(
                  (item) => item.itemDetails?.businessProducts ?? [],
                ) ??
                [])
            .whereType<BusinessProducts>()
            .toList();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      height: 10.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allProducts.length,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final product = allProducts[index];

          return Container(
            margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              border: Border.all(color: Color(0xFF969696), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl:
                            (product.image != null && product.image!.isNotEmpty)
                                ? product.image!
                                : (product.images != null &&
                                    product.images!.isNotEmpty)
                                ? product.images!.first
                                : "",
                        fit: BoxFit.cover,
                        width: 14.w,
                        height: 14.w,
                        placeholder:
                            (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: AppColors.maincolor,
                                strokeWidth: 2,
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.image_outlined,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        (product?.offerPrice != null &&
                                product!.offerPrice != "0.00" &&
                                product.offerPrice != product.price)
                            ? Row(
                              children: [
                                Text(
                                  "£${product.price}",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: AppConstants.manrope,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.maincolor,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "£${product.offerPrice}",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppConstants.manrope,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                InkWell(
                                  onTap: () {
                                    AddCartProductApi(
                                      product?.id.toString() ?? "",
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: Colors.black,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 17.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              children: [
                                Text(
                                  "£${product?.price ?? ""}",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: AppConstants.manrope,
                                    color: Colors.black,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    AddCartProductApi(
                                      product?.id.toString() ?? "",
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 17.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFancyAnythingElseSheet() {
    final List<BusinessProducts> suggestedProducts =
        (cartDetailsModel?.data?.expand(
                  (item) => item.itemDetails?.businessProducts ?? [],
                ) ??
                [])
            .whereType<BusinessProducts>()
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (_, controller) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // com.wavee.comunity
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 10.h,
                          left: 4.w,
                          right: 4.w,
                        ),
                        child: ListView(
                          controller: controller,
                          physics: BouncingScrollPhysics(),
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 1.h, bottom: 2.h),
                                width: 10.w,
                                height: 0.5.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Fancy anything else?",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppConstants.manrope,
                                    color: Color(0xFF2E3333),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Icon(
                                    Icons.close,
                                    size: 24.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your regulars",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppConstants.manrope,
                                    color: Color(0xFF2E3333),
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  "Forgotten anything from your regular items?",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.grey[600],
                                    fontFamily: AppConstants.manrope,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            if (suggestedProducts.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Text(
                                    "No suggested items available",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: suggestedProducts.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 0.48,
                                      crossAxisSpacing: 3.w,
                                      mainAxisSpacing: 2.h,
                                    ),
                                itemBuilder: (context, index) {
                                  final product = suggestedProducts[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Color(0xFFE5E5E5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(12),
                                                  ),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    (product.image != null &&
                                                            product
                                                                .image!
                                                                .isNotEmpty)
                                                        ? product.image!
                                                        : (product.images !=
                                                                null &&
                                                            product
                                                                .images!
                                                                .isNotEmpty)
                                                        ? product.images!.first
                                                        : "",
                                                fit: BoxFit.cover,
                                                height: 14.h,
                                                width: double.infinity,
                                                placeholder:
                                                    (context, url) => Container(
                                                      color: Color(0xFFF8F8F8),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  AppColors
                                                                      .maincolor,
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => Container(
                                                      color: Color(0xFFF8F8F8),
                                                      height: 14.h,
                                                      child: Icon(
                                                        Icons.image_outlined,
                                                        color: Colors.grey[400],
                                                        size: 6.w,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: -12,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  AddCartProductApi(
                                                    product.id.toString(),
                                                  );
                                                  Get.back();
                                                },
                                                child: Container(
                                                  width: 11.w,
                                                  height: 11.w,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.15),
                                                        blurRadius: 6,
                                                        spreadRadius: 2,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 22.sp,
                                                    color: AppColors.maincolor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(4.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name ?? "",
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    color: Color(0xFF2E3333),
                                                  ),
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 0.w,
                                                  ),
                                                  child:
                                                      (product?.offerPrice !=
                                                                  null &&
                                                              product!.offerPrice !=
                                                                  "0.00" &&
                                                              product.offerPrice !=
                                                                  product.price)
                                                          ? FittedBox(
                                                            fit:
                                                                BoxFit
                                                                    .scaleDown,
                                                            alignment:
                                                                Alignment
                                                                    .centerLeft,
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  "£${product.price}",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        13.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    decorationColor:
                                                                        AppColors
                                                                            .maincolor,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  "£${product.offerPrice}",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        14.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                          : Text(
                                                            "£${product?.price ?? ""}",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, -2),
                              ),
                            ],
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              (cartDetailsModel?.data?[0].type == "product" &&
                                      cartDetailsModel
                                              ?.data?[0]
                                              .loyaltyDetails
                                              ?.loyaltyOrderThreshold !=
                                          null &&
                                      cartDetailsModel
                                              ?.data?[0]
                                              .loyaltyDetails
                                              ?.loyaltyDiscountPercentage !=
                                          null)
                                  ? Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.8.h,
                                    ),
                                    margin: EdgeInsets.only(bottom: 2.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.maincolor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "You're getting closer to an exclusive reward! Complete ${cartDetailsModel?.data?[0].loyaltyDetails?.loyaltyOrderThreshold} more orders to unlock a ${cartDetailsModel?.data?[0].loyaltyDetails?.loyaltyDiscountPercentage?.replaceAll(RegExp(r'\\.0+\$'), '')}% discount on your next purchase.",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Color(0xFF3C1361),
                                              fontFamily: AppConstants.manrope,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: AppColors.maincolor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.card_giftcard,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox(),
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                  _navigateToCheckout();
                                },
                                child: Container(
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.maincolor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_checkout,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        "Checkout",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: Colors.white,
                                          fontFamily: AppConstants.manrope,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _handleCheckoutTap() {
    if (cartDetailsModel?.data?[0].type == "product") {
      if (!hasShownFancySheet) {
        setState(() {
          hasShownFancySheet = true;
        });
        _showFancyAnythingElseSheet();
      } else {
        _navigateToCheckout();
      }
    } else {
      _navigateToCheckout();
    }
  }

  void _navigateToCheckout() {
    Get.to(
      BuyProductView(
        bunessid: cartDetailsModel?.data?[0].itemDetails?.businessId.toString(),
        type: cartDetailsModel?.data?.first.type,
      ),
    );
  }
}
