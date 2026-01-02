import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Ui/CartScreen/model/amendOrderModal.dart';
import 'package:wavee/Ui/CartScreen/model/amendPaymentModal.dart';
import 'package:wavee/Ui/CartScreen/model/cartDetailsModal.dart'
    hide ItemDetails;
import 'package:wavee/Utils/customSnackBars.dart';
import 'package:wavee/Utils/stripeWebView.dart';
import 'package:wavee/Utils/themeButton.dart';

import '../../../Utils/bottomBar.dart';
import '../../../Utils/chatCounter.dart';
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customBatan.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../../BuyProduct/view/buyProductView.dart';
import '../../CommunityScreen/Provider/communityProvider.dart';
import '../../CommunityScreen/view/communityScreen.dart';
import '../../HomeScreen/View/homePage.dart';
import '../../OrderScreen/Provider/orderProvider.dart';
import '../../orderScreen/View/orderScreenView.dart';
import '../../productDetailPage/provider/productProvider.dart';
import '../provider/addToCartProvider.dart';

class AddToCartView extends StatefulWidget {
  String? type;
  String? businessID;
  String? orderID;
  int? selected;
  final bool fromBottomBar;
  bool? isAmend;

  AddToCartView({
    super.key,
    this.type,
    this.selected,
    this.businessID,
    this.orderID,
    this.fromBottomBar = false,
    this.isAmend = false,
  });

  @override
  State<AddToCartView> createState() => _AddToCartViewState();
}

class SelectedItem {
  BusinessProducts product;
  int qty;

  SelectedItem({required this.product, this.qty = 1});
}

class _AddToCartViewState extends State<AddToCartView> {
  bool isLoading = false;
  bool isUpdateQuantity = false;
  double otherFees = 0.0;
  double deliveryFees = 0.0;
  bool hasShownFancySheet = false;
  bool isAddtoCart = false;
  final GlobalCountsController countsController = Get.find();
  AmendOrderModal? amendOrderModal;

  bool showAddMoreSection = false;
  List<BusinessProducts> availableProducts = [];
  bool isLoadingProducts = false;

  // List<BusinessProducts> selectedProducts = [];

  // Use SelectedItem instead of storing qty in product.id
  List<SelectedItem> selectedProducts = [];

  // bool isDark = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    log("dfsddfsshijhsddjhisdfhisdfjhdfhjdfbjh${widget.orderID}");
    if (widget.isAmend == true) {
      amendOrderApi();
    } else {
      GetCartDetailApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => HomePage(selected: 1, userName: ''));
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.isDark ? Color(0xf01A1A1A) : Color(0xFFF0F2F5),

        body: Column(
          children: [
            SizedBox(height: 6.h),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAmend == true ? "Amend Order" : "My Cart",
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: isDark ? Colors.white : Colors.black,
                        fontFamily: AppConstants.manropeBold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: 12.w,
                      height: 1.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isDark ? Color(0xffbdab82) : Colors.black,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                ThemeToggleButton().paddingOnly(bottom: 2.5.h),
              ],
            ),
            SizedBox(height: 5.h),

            // if (widget.isAmend == true &&
            //     amendOrderModal?.amendOrderData != null)
            //   _buildAmendOrderBanner(),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  // border: Border.all(color: const Color(0xff373737), width: 1),
                  color: isDark ? Color(0xff242424) : AppColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: Stack(
                  children: [
                    if (isLoading)
                      Center(child: Loader())
                    else if ((widget.isAmend == true &&
                            (amendOrderModal
                                    ?.amendOrderData
                                    ?.products
                                    ?.isEmpty ??
                                true)) ||
                        (widget.isAmend != true &&
                            (cartDetailsModel?.data == null ||
                                (cartDetailsModel?.data?.length ?? 0) == 0)))
                      _buildEmptyBasketView()
                    else
                      ListView(
                        padding: const EdgeInsets.all(8.0),
                        children: [
                          Container(
                            margin: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff272727) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isDark
                                        ? Color(0xff373737)
                                        : Color(0xffbdab82),
                                width: 0.2.w,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  SizedBox(height: 0.5.h),
                                  Text(
                                    widget.isAmend == true
                                        ? "Items (${amendOrderModal?.amendOrderData?.products?.length ?? 0})"
                                        : "Items (${cartDetailsModel?.data?.length ?? 0})",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: const Color(0xFF969696),
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                ],
                              ),
                            ),
                          ),

                          if (widget.isAmend == true)
                            ..._buildAmendOrderItems()
                          else
                            ..._buildRegularCartItems(),

                          if (widget.isAmend == true && !showAddMoreSection)
                            _buildAddMoreButton(),

                          if (widget.isAmend == true && showAddMoreSection)
                            _buildAddMoreItemsSection(),

                          if (widget.isAmend != true &&
                              cartDetailsModel?.data?[0].type == "product") ...[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "People also added",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppConstants.manropeBold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            _buildSuggestedList(),
                          ],
                          if (!isLoading && _hasItems())
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  color:
                                      isDark
                                          ? Color(0xff383838)
                                          : Colors.grey.shade200,
                                  width: 0.3.w,
                                ),
                                color:
                                    isDark
                                        ? Color(0xff2b2b2b)
                                        : Color(0xfff2f2f2),
                              ),

                              child: Column(
                                // controller: scrollController,
                                children: [
                                  _buildSectionCard(
                                    title: "Order Summary",
                                    icon: Icons.receipt,
                                    child: Column(
                                      children: [
                                        if (widget.isAmend == true)
                                          _buildAmendOrderSummary()
                                        else if (cartDetailsModel
                                                ?.data?[0]
                                                .type ==
                                            "product")
                                          _buildRegularOrderSummary()
                                        else
                                          _buildServiceOrderSummary(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!isLoading && _hasItems()) SizedBox(height: 2.h),
                          InkWell(
                            onTap: _handleCheckoutTap,
                            child: Container(
                              height: 5.h,
                              alignment: Alignment.center,
                              // padding: EdgeInsets.symmetric(
                              //   horizontal: 7.w,
                              //   vertical: 1.h,
                              // ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color:
                                    isDark ? Color(0xffbdab82) : Colors.white,
                                border: Border.all(
                                  color: const Color(0xffd9d9d9),
                                ),
                              ),
                              child: Text(
                                widget.isAmend == true
                                    ? "Amend Order"
                                    : "Checkout",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.black,
                                  fontFamily:
                                      widget.isAmend == true
                                          ? AppConstants.manropeBold
                                          : AppConstants.manrope,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 50.h),
                        ],
                      ),

                    if (isUpdateQuantity)
                      Container(
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Color(0xff2B2B2B)
                                  : Colors.black.withValues(alpha: .2),

                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45),
                          ),
                        ),
                        child: Center(child: Loader()),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 3.w),
        bottomNavigationBar: Obx(
          () => BottomBar(
            selected: 4,
            chatCount: countsController.chatCount.value,
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: GestureDetector(
        onTap: () {
          setState(() {
            showAddMoreSection = true;
          });
          _loadAvailableProducts();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xff969696), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppColors.maincolor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 3.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add More Items",
                    style: TextStyle(
                      fontSize: 18.sp,
                      // fontWeight: FontWeight.bold,
                      color: AppColors.maincolor,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                  Text(
                    "Add additional items to your order",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.maincolor,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreItemsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add More Items",
                style: TextStyle(
                  fontSize: 20.sp,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: AppConstants.manropeBold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAddMoreSection = false;
                    selectedProducts.clear();
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.black, size: 18.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            "Select items to add to your order",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontFamily: AppConstants.manrope,
            ),
          ),
          SizedBox(height: 2.h),

          if (isLoadingProducts)
            Center(child: Loader())
          else if (availableProducts.isEmpty)
            _buildNoProductsAvailable()
          else
            _buildAvailableProductsList(),

          SizedBox(height: 2.h),

          if (selectedProducts.isNotEmpty) _buildAddSelectedButton(),
        ],
      ),
    );
  }

  Widget _buildNoProductsAvailable() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 40.sp, color: Colors.grey[400]),
          SizedBox(height: 2.h),
          Text(
            "No additional products available",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "All available products are already in your order",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableProductsList() {
    return Column(
      children:
          availableProducts.map((product) {
            final bool isAlreadyInOrder = _isProductInOrder(product);

            // Check if product is selected and get the SelectedItem (or a temp one)
            final bool isSelected = selectedProducts.any(
              (s) => s.product.id == product.id,
            );
            final SelectedItem selectedItem = selectedProducts.firstWhere(
              (s) => s.product.id == product.id,
              orElse: () => SelectedItem(product: product, qty: 1),
            );
            final int quantity = selectedItem.qty;

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.maincolor.withValues(alpha: 0.05)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected
                          ? AppColors.maincolor
                          : const Color(0xFFE5E5E5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      color: const Color(0xFFF8F8F8),
                      child: CachedNetworkImage(
                        imageUrl: _getProductImage(product),
                        fit: BoxFit.cover,
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
                              size: 6.w,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name ?? "",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E3333),
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        if (product.offerPrice != null &&
                            product.offerPrice != "0.00" &&
                            product.offerPrice != product.price)
                          Row(
                            children: [
                              Text(
                                "£${product.price}",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "£${product.offerPrice}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.maincolor,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            "£${product.price ?? ""}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.maincolor,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (isAlreadyInOrder)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        "Already in Order",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isSelected)
                    // show quantity control for selected item
                    _buildAddMoreQuantityControl(product, quantity)
                  else
                    GestureDetector(
                      onTap: () {
                        _addProductToSelection(product);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.maincolor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Add",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAddMoreQuantityControl(BusinessProducts product, int quantity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.maincolor),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (quantity > 1) {
                _updateSelectedProductQuantity(product, quantity - 1);
              } else {
                _removeProductFromSelection(product);
              }
            },
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: Icon(
                Icons.remove,
                size: 16.sp,
                color: AppColors.maincolor,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            "$quantity",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: AppConstants.manrope,
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () {
              if (quantity < 10) {
                _updateSelectedProductQuantity(product, quantity + 1);
              }
            },
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: Icon(Icons.add, size: 16.sp, color: AppColors.maincolor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSelectedButton() {
    final double totalAmount = _calculateSelectedItemsTotal();

    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Divider(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total to add:",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "£${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maincolor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: () {
              if (selectedProducts.isEmpty) return;

              // Build product list (id + qty) from selectedProducts (SelectedItem)
              final List<Map<String, dynamic>> selectedItemsPayload =
                  selectedProducts.map((sel) {
                    final productId = sel.product.id?.toString() ?? "";
                    final qty = sel.qty ?? 1;
                    return {"product_id": productId, "qty": qty};
                  }).toList();

              // Call prepaidAddProduct that accepts a list of items
              prepaidAddProduct(selectedItemsPayload);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: AppColors.maincolor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.maincolor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    "Add ${selectedProducts.length} Items to Order",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadAvailableProducts() {
    setState(() {
      isLoadingProducts = true;
    });

    checkInternet().then((internet) {
      if (internet) {
        CommunityProvider()
            .businessProfileViewApi(widget.businessID.toString(), '', '')
            .then((response) {
              setState(() {
                isLoadingProducts = false;
                if (response.statusCode == 200) {
                  dynamic productsData;

                  if (response.data['data'] != null &&
                      response.data['data']['products'] != null) {
                    productsData = response.data['data']['products'];
                  } else if (response.data['products'] != null) {
                    productsData = response.data['products'];
                  } else if (response.data['data'] != null &&
                      response.data['data'] is List) {
                    productsData = response.data['data'];
                  } else {
                    productsData = response.data;
                  }

                  final List<BusinessProducts> allProducts = [];

                  if (productsData is List) {
                    allProducts.addAll(
                      productsData.map<BusinessProducts>((item) {
                        if (item is Map<dynamic, dynamic>) {
                          final Map<String, dynamic> stringMap =
                              item.cast<String, dynamic>();
                          return BusinessProducts.fromJson(stringMap);
                        } else if (item is Map<String, dynamic>) {
                          return BusinessProducts.fromJson(item);
                        } else {
                          return BusinessProducts.fromJson({});
                        }
                      }).toList(),
                    );
                  } else if (productsData is Map) {
                    if (productsData is Map<dynamic, dynamic>) {
                      final Map<String, dynamic> stringMap =
                          productsData.cast<String, dynamic>();
                      allProducts.add(BusinessProducts.fromJson(stringMap));
                    } else if (productsData is Map<String, dynamic>) {
                      allProducts.add(BusinessProducts.fromJson(productsData));
                    }
                  }

                  availableProducts =
                      allProducts
                          .where((product) => !_isProductInOrder(product))
                          .toList();

                  print(
                    "Loaded ${availableProducts.length} available products",
                  );
                } else {
                  buildErrorDialog(context, 'Error', "Failed to load products");
                }
              });
            })
            .catchError((error) {
              setState(() {
                isLoadingProducts = false;
              });
              print("Error loading products: $error");
              buildErrorDialog(context, 'Error', "Failed to load products");
            });
      } else {
        setState(() {
          isLoadingProducts = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  String _getProductImage(BusinessProducts product) {
    if (product.image != null && product.image!.isNotEmpty) {
      return product.image!;
    } else if (product.images != null && product.images!.isNotEmpty) {
      return product.images!.first;
    }
    return "";
  }

  bool _isProductInOrder(BusinessProducts product) {
    return amendOrderModal?.amendOrderData?.products?.any(
          (orderProduct) => orderProduct.productId == product.id,
        ) ??
        false;
  }

  void _addProductToSelection(BusinessProducts product) {
    setState(() {
      // add with default qty 1
      selectedProducts.add(SelectedItem(product: product, qty: 1));
    });
  }

  void _removeProductFromSelection(BusinessProducts product) {
    setState(() {
      selectedProducts.removeWhere((s) => s.product.id == product.id);
    });
  }

  void _updateSelectedProductQuantity(
    BusinessProducts product,
    int newQuantity,
  ) {
    setState(() {
      final sel = selectedProducts.firstWhere(
        (s) => s.product.id == product.id,
        orElse: () => SelectedItem(product: product, qty: 1),
      );
      sel.qty = newQuantity;
    });
  }

  double _calculateSelectedItemsTotal() {
    double total = 0.0;
    for (var sel in selectedProducts) {
      final product = sel.product;
      final int qty = sel.qty;
      double price =
          double.tryParse(product.offerPrice ?? product.price ?? '0') ?? 0;
      total += price * qty;
    }
    return total;
  }

  void removeFromAmendOrderApi(int productId, String type) {
    setState(() {
      isUpdateQuantity = true;
    });

    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID ?? "",
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

            amendOrderApi();
          } else {
            setState(() {
              isUpdateQuantity = false;
            });
            buildErrorDialog(context, 'Error', "Failed to remove item");
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

  void _handleCheckoutTap() {
    if (widget.isAmend == true) {
      _navigateToAmendCheckout();
    } else {
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
  }

  void _navigateToAmendCheckout() {
    CheckOutAPI();
  }

  Widget _buildEmptyBasketView() {
    final theme = Provider.of<ThemeController>(context, listen: false);
    final isDark = theme.isDark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Column(
          children: [
            Container(
              width: 25.w,
              height: 25.w,
              decoration:  BoxDecoration(
                color:isDark?Color(0xf035332E): Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 12.w,
                color:isDark?Color(0xf0CBB88C): Colors.grey[400],
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Your cart is empty",
              style: TextStyle(
                fontFamily: AppConstants.manrope,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Color(0xFF2E3333),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                batan(
                  title: "Explore Community",
                  route: () {
                    Get.to(() => CommunityScreen());
                  },
                  color: isDark ? Color(0xffbdab82) : AppColors.maincolor,
                  fontcolor: isDark ? Colors.black : Colors.white,
                  height: 5.h,
                  fontsize: 16.sp,
                  radius: 12.0,
                  width: 43.5.w,
                  fontFamily: AppConstants.manropeBold,

                  fontWeight: FontWeight.bold,
                ),
                SizedBox(width: 4.w),
                batan(
                  title: "View Orders",
                  route: () {
                    Get.to(() => Order_Screen());
                  },
                  color: isDark ? Color(0xffbdab82) : AppColors.maincolor,
                  fontcolor: isDark ? Colors.black : Colors.white,
                  height: 5.h,
                  fontsize: 16.5.sp,
                  radius: 12.0,
                  width: 40.w,
                  fontFamily: AppConstants.manropeBold,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(dynamic item) {
    final product = item.itemDetails;
    if (product == null) return const SizedBox();
    final theme = Provider.of<ThemeController>(context, listen: false);
    final isDark = theme.isDark;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Color(0xff272727) : Colors.white,
        border: Border.all(
          color: isDark ? Color(0xff373737) : Color(0xFF969696),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 18.w,
              height: 18.w,
              color: const Color(0xFFF8F8F8),
              child: CachedNetworkImage(
                imageUrl:
                    (product.image != null &&
                            (product.image as String).isNotEmpty)
                        ? product.image
                        : (product.images != null &&
                            (product.images as List).isNotEmpty)
                        ? product.images.first
                        : "",
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: Loader()),
                errorWidget:
                    (context, url, error) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color(0xFFF8F8F8)),
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/Applogo_remove_background.png",
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name ?? "",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manropeBold,
                          color: isDark ? Colors.white : Color(0xFF2E3333),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        RemoveFromCartApi(
                          item.productId ?? 0,
                          item.type ?? "product",
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xff3b3935) : Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete,
                          color: isDark ? Colors.white : Colors.black,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),

                Row(
                  children: [
                    Text(
                      "£${(product.offerPrice ?? product.price)?.toString() ?? '0'}",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppConstants.manrope,
                        color: isDark ? Color(0xffbdab82) : AppColors.maincolor,
                      ),
                    ),
                    const Spacer(),
                    _buildQuantityControl(item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(dynamic item) {
    final theme = Provider.of<ThemeController>(context, listen: false);
    final isDark = theme.isDark;
    int qty = item.quantity ?? 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        // ram
        color: isDark ? Color(0xff3A3934) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        // ram
        // border: Border.all(color: const Color(0xffE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ➖ Minus Button
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              if (qty > 1) {
                setState(() {
                  item.quantity = qty - 1;
                });

                updateQuantityApi(
                  item.productId ?? 0,
                  item.quantity ?? 1,
                  item.type ?? "",
                );
              } else {
                RemoveFromCartApi(item.productId ?? 0, item.type ?? "product");
              }
            },
            child: Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Color(0xff2F2F2F) : Colors.white,
              ),
              child: Center(
                child: Text(
                  "-",
                  style: TextStyle(
                    color: isDark ? AppColors.white : Colors.black,
                    fontSize: 18,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            qty.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              fontFamily: AppConstants.manrope,
              // ram
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const SizedBox(width: 12),

          /// ➕ Plus Button
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              final int currentQty = item.quantity ?? 1;
              final dynamic maxQ = item.maxQuantity;

              bool canIncrease = false;

              if (maxQ == "unlimited") {
                canIncrease = true;
              } else {
                final int maxQty = int.tryParse(maxQ.toString()) ?? 0;
                canIncrease = currentQty < maxQty;
              }

              if (canIncrease) {
                setState(() {
                  item.quantity = currentQty + 1;
                });

                updateQuantityApi(
                  item.productId ?? 0,
                  item.quantity ?? 1,
                  item.type ?? "",
                );
              } else {
                showSnackBar(
                  context: context,
                  title: 'Stock Unavailable',
                  message: 'Requested quantity exceeds available stock.',
                  backgoundColor: Colors.red,
                );
              }
            },
            child: Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Color(0xff2F2F2F) : Colors.white,
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Provider.of<ThemeController>(context, listen: false);
    final isDark = theme.isDark;
    return Card(
      elevation: 0,
      color: isDark ? Color(0xff2B2B2B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isDark ? Colors.white : Colors.black),
                SizedBox(width: 2.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppConstants.manrope,

                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            child,
          ],
        ),
      ),
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
            "£$amount",
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
    final theme = Provider.of<ThemeController>(context, listen: false);
    final isDark = theme.isDark;
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
                      : (isTotal
                          ? isDark
                              ? Colors.white
                              : Colors.black
                          : isDark
                          ? Colors.white
                          : Colors.grey[800]),
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
                      : (isTotal
                          ? isDark
                              ? Colors.white
                              : AppColors.maincolor
                          : isDark
                          ? Colors.white
                          : Colors.black),
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

  ///hiren
  // Widget _buildSuggestedList() {
  //   final List<BusinessProducts> allProducts =
  //       (cartDetailsModel?.data?.expand(
  //                 (item) => item.itemDetails?.businessProducts ?? [],
  //               ) ??
  //               [])
  //           .whereType<BusinessProducts>()
  //           .toList();
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     height: 10.h,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: allProducts.length,
  //       padding: const EdgeInsets.symmetric(horizontal: 12),
  //       itemBuilder: (context, index) {
  //         final product = allProducts[index];
  //
  //         return Container(
  //           margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
  //           alignment: Alignment.center,
  //           padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(20),
  //             color: Colors.white,
  //             border: Border.all(color: const Color(0xFF969696), width: 1),
  //           ),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.circular(10),
  //                     child: CachedNetworkImage(
  //                       imageUrl:
  //                           (product.image != null && product.image!.isNotEmpty)
  //                               ? product.image!
  //                               : (product.images != null &&
  //                                   product.images!.isNotEmpty)
  //                               ? product.images!.first
  //                               : "",
  //                       fit: BoxFit.cover,
  //                       width: 14.w,
  //                       height: 14.w,
  //                       placeholder:
  //                           (context, url) => const Center(
  //                             child: CircularProgressIndicator(
  //                               color: AppColors.maincolor,
  //                               strokeWidth: 2,
  //                             ),
  //                           ),
  //                       errorWidget:
  //                           (context, url, error) => Icon(
  //                             Icons.image_outlined,
  //                             color: Colors.grey[400],
  //                             size: 30,
  //                           ),
  //                     ),
  //                   ),
  //                   SizedBox(width: 2.w),
  //                   Column(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         product.name ?? "",
  //                         maxLines: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: const TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                       (product.offerPrice != null &&
  //                               product.offerPrice != "0.00" &&
  //                               product.offerPrice != product.price)
  //                           ? Row(
  //                             children: [
  //                               Text(
  //                                 "£${product.price}",
  //                                 style: TextStyle(
  //                                   fontSize: 14.sp,
  //                                   fontWeight: FontWeight.normal,
  //                                   fontFamily: AppConstants.manrope,
  //                                   color: Colors.grey,
  //                                   decoration: TextDecoration.lineThrough,
  //                                   decorationColor: AppColors.maincolor,
  //                                 ),
  //                               ),
  //                               const SizedBox(width: 5),
  //                               Text(
  //                                 "£${product.offerPrice}",
  //                                 style: TextStyle(
  //                                   fontSize: 15.sp,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontFamily: AppConstants.manrope,
  //                                   color: Colors.black,
  //                                 ),
  //                               ),
  //                               SizedBox(width: 4.w),
  //                               InkWell(
  //                                 onTap: () {
  //                                   AddCartProductApi(
  //                                     product.id.toString() ?? "",
  //                                   );
  //                                 },
  //                                 child: Container(
  //                                   decoration: BoxDecoration(
  //                                     borderRadius: BorderRadius.circular(3),
  //                                     color: Colors.black,
  //                                   ),
  //                                   child: Icon(
  //                                     Icons.add,
  //                                     size: 17.sp,
  //                                     color: AppColors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           )
  //                           : Row(
  //                             children: [
  //                               Text(
  //                                 "£${product.price ?? ""}",
  //                                 style: TextStyle(
  //                                   fontSize: 15.sp,
  //                                   fontWeight: FontWeight.bold,
  //                                   fontFamily: AppConstants.manrope,
  //                                   color: Colors.black,
  //                                 ),
  //                               ),
  //                               InkWell(
  //                                 onTap: () {
  //                                   AddCartProductApi(
  //                                     product.id.toString() ?? "",
  //                                   );
  //                                 },
  //                                 child: Container(
  //                                   decoration: BoxDecoration(
  //                                     borderRadius: BorderRadius.circular(10),
  //                                     color: Colors.black,
  //                                   ),
  //                                   child: Icon(
  //                                     Icons.add,
  //                                     size: 17.sp,
  //                                     color: AppColors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  Widget _buildSuggestedList() {
    final List<BusinessProducts> allProducts =
        (cartDetailsModel?.data?.expand(
                  (item) => item.itemDetails?.businessProducts ?? [],
                ) ??
                [])
            .whereType<BusinessProducts>()
            .toList();
    final theme = Provider.of<ThemeController>(context, listen: false);
    final isDark = theme.isDark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allProducts.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final product = allProducts[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Color(0xff1F1F1F) : Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Color(0xff383838) : Color(0xffE6E7ED),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 🖼 Product Image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl:
                          (product.image != null && product.image!.isNotEmpty)
                              ? product.image!
                              : (product.images != null &&
                                  product.images!.isNotEmpty)
                              ? product.images!.first
                              : "",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 🏷 Product Name (CENTER)
                Text(
                  product.name ?? "",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                /// 💰 Price (CENTER)
                Text(
                  "£${product.offerPrice != null && product.offerPrice != "0.00" ? product.offerPrice : product.price}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // ram
                    color: isDark ? Color(0xffbdab82) : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                /// ➕ Add Button
                InkWell(
                  onTap: () {
                    AddCartProductApi(product.id.toString());
                  },
                  child: Container(
                    height: 32,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // ram
                      border: Border.all(
                        color: isDark ? Color(0xffbdab82) : Color(0xff7380A4),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: isDark ? Color(0xffbdab82) : Color(0xff7380A4),
                        size: 18,
                      ),
                    ),
                  ),
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
    final theme = Provider.of<ThemeController>(context, listen: false);
    final isDark = theme.isDark;
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
                    color: isDark ? Color(0xff2B2B2B) : Colors.white,

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
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 1.h, bottom: 2.h),
                                width: 10.w,
                                height: 0.5.h,
                                decoration: BoxDecoration(
                                  color:
                                      isDark ? Colors.white : Colors.grey[300],
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
                                    color:
                                        isDark
                                            ? Colors.white
                                            : Color(0xFF2E3333),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.back(),
                                  child: Icon(
                                    Icons.close,
                                    size: 24.sp,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : Colors.grey[600],
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
                                    color:
                                        isDark
                                            ? Colors.white
                                            : Color(0xFF2E3333),
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
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.grey[500],
                                    ),
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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
                                      color:
                                          isDark
                                              ? Color(0xff242424)
                                              : Colors.white,
                                      border: Border.all(
                                        color:
                                            isDark
                                                ? Color(0xff383838)
                                                : Color(0xFFE5E5E5),
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
                                                  const BorderRadius.vertical(
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
                                                      color: const Color(
                                                        0xFFF8F8F8,
                                                      ),
                                                      child: const Center(
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
                                                      color: const Color(
                                                        0xFFF8F8F8,
                                                      ),
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
                                                    color:
                                                        isDark
                                                            ? Color(0xff242424)
                                                            : Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.15,
                                                            ),
                                                        blurRadius: 6,
                                                        spreadRadius: 2,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 22.sp,
                                                    color:
                                                        isDark
                                                            ? Colors.white
                                                            : AppColors
                                                                .maincolor,
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
                                                        AppConstants
                                                            .manropeBold,
                                                    color:
                                                        isDark
                                                            ? Colors.white
                                                            : Color(0xFF2E3333),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 0.w,
                                                  ),
                                                  child:
                                                      (product.offerPrice !=
                                                                  null &&
                                                              product.offerPrice !=
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
                                                                        isDark
                                                                            ? Color(
                                                                              0xffbdab82,
                                                                            )
                                                                            : Colors.grey,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    decorationColor:
                                                                        isDark
                                                                            ? Color(
                                                                              0xffbdab82,
                                                                            )
                                                                            : AppColors.maincolor,
                                                                  ),
                                                                ),
                                                                const SizedBox(
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
                                                                        isDark
                                                                            ? Colors.white
                                                                            : Colors.black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                          : Text(
                                                            "£${product.price ?? ""}",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              color:
                                                                  isDark
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
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
                            color: isDark ? Color(0xff2b2b2b) : Colors.white,
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
                                      color: AppColors.maincolor.withValues(
                                        alpha: 0.1,
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
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Color(0xFF3C1361),
                                              fontFamily: AppConstants.manrope,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : AppColors.maincolor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.card_giftcard,
                                            size: 16,
                                            color:
                                                isDark
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : const SizedBox(),
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                  _navigateToCheckout();
                                },
                                child: Container(
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Color(0xffbdab82)
                                            : AppColors.maincolor,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_checkout,
                                        color:
                                            isDark
                                                ? Colors.black
                                                : Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        "Checkout",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color:
                                              isDark
                                                  ? Colors.black
                                                  : Colors.white,
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

  void _navigateToCheckout() {
    Get.to(
      BuyProductView(
        bunessid: cartDetailsModel?.data?[0].itemDetails?.businessId.toString(),
        type: cartDetailsModel?.data?.first.type,
      ),
    );
  }

  // 1) Updated amendOrderApi() - now async and returns after model is set
  Future<void> amendOrderApi() async {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID ?? "",
    };

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
      final response = await CartProvider().amendOrderDetailapi(data);

      if (response.statusCode == 200) {
        // parse into model
        amendOrderModal = AmendOrderModal.fromJson(response.data);

        // optional: log the relevant server data for debugging
        try {} catch (_) {}
      } else {
        // try to parse even on non-200 (defensive)
        try {
          amendOrderModal = AmendOrderModal.fromJson(response.data);
        } catch (e) {
          log("amendOrderApi failed to parse response: $e");
        }
      }
    } catch (e) {
      log("amendOrderApi exception: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildAmendOrderSummary() {
    double subtotal = _getAmendSubtotal();

    // parse discountApplied raw string
    String rawDiscount =
        amendOrderModal?.amendOrderData?.discountApplied ?? '0';
    double discountParsed =
        double.tryParse(rawDiscount.replaceAll('%', '')) ?? 0;

    // Determine whether discountParsed is likely a percent or absolute amount.
    // Heuristic:
    // - if raw string contains '%' -> treat as percent
    // - else if discountParsed > 0 && discountParsed <= 100 && discountParsed <= subtotal * 0.5
    //     -> could be percent (<=100) OR absolute small amount; prefer absolute if <= subtotal/2
    // - else if discountParsed > subtotal -> treat as percent if <= 100, otherwise absolute.
    double discountAmount = 0.0;
    bool discountIsPercent = rawDiscount.contains('%');

    if (!discountIsPercent) {
      // heuristic fallback
      if (discountParsed > 0 && discountParsed <= 100) {
        // could be percent or small absolute; decide:
        // if parsed value is <= subtotal * 0.5 assume absolute; else treat as percentage.
        if (discountParsed <= subtotal * 0.5) {
          // ambiguous: if discountParsed is small relative to subtotal treat as absolute
          discountAmount = discountParsed;
        } else {
          // treat as percentage
          discountIsPercent = true;
        }
      } else if (discountParsed > 100) {
        // probably absolute amount
        discountAmount = discountParsed;
      } else {
        discountAmount = 0.0;
      }
    }

    if (discountIsPercent && discountAmount == 0.0) {
      // calculate percentage amount
      discountAmount = subtotal * (discountParsed / 100.0);
    }

    // loyalty discount (server already provides loyaltyDiscountApplied as a number)
    double loyaltyDiscount =
        (amendOrderModal?.amendOrderData?.loyaltyDiscountApplied ?? 0)
            .toDouble();

    // computed final total on client
    double calculatedTotal = subtotal - discountAmount - loyaltyDiscount;

    // server reported total (fallback)
    double serverTotal =
        double.tryParse(amendOrderModal?.amendOrderData?.totalAmount ?? '') ??
        calculatedTotal;

    // Decide which to show: prefer serverTotal if it's within a small tolerance of calculatedTotal,
    // otherwise show calculatedTotal and keep server total as note (helps debug)
    const double tolerance = 0.5; // 50p tolerance
    final bool preferServer =
        (serverTotal - calculatedTotal).abs() <= tolerance;

    final double totalToShow = preferServer ? serverTotal : calculatedTotal;

    return Column(
      children: [
        _buildSummaryRow("Subtotal", subtotal),
        if (discountAmount > 0)
          _buildSummaryRow("Discount", discountAmount, isDiscount: true),
        if (loyaltyDiscount > 0)
          _buildSummaryRow(
            "Loyalty Discount",
            loyaltyDiscount,
            isDiscount: true,
          ),
        Divider(height: 3.h, thickness: 1),
        _buildSummaryRow("Total", totalToShow, isTotal: true),
        SizedBox(height: 1.5.h),
        Text(
          "Note: Price differences will be adjusted in the final payment",
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildAmendOrderItems() {
    return List.generate(
      amendOrderModal?.amendOrderData?.products?.length ?? 0,
      (index) {
        final product = amendOrderModal?.amendOrderData?.products?[index];
        if (product == null) return const SizedBox();

        return Column(
          children: [
            _buildAmendCartItem(product),
            if (index !=
                (amendOrderModal?.amendOrderData?.products?.length ?? 0) - 1)
              Divider(
                height: 1,
                color: const Color(0xFFF5F5F5),
                indent: 4.w,
                endIndent: 4.w,
              ),
          ],
        );
      },
    );
  }

  Widget _buildAmendCartItem(Products product) {
    final itemDetails = product.itemDetails;
    if (itemDetails == null) return const SizedBox();

    bool isExisting = product.id != null; // existing product
    bool isNewItem = product.id == null; // new amend item

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: const Color(0xFF969696), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 18.w,
              height: 18.w,
              color: const Color(0xFFF8F8F8),
              child: CachedNetworkImage(
                imageUrl: _getAmendItemImage(itemDetails),
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: Loader()),
                errorWidget:
                    (context, url, error) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Color(0xFFF8F8F8)),
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/Applogo_remove_background.png",
                          ),
                        ),
                      ),
                    ),
              ),
            ),
          ),
          SizedBox(width: 3.w),

          // 🧾 Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        itemDetails.name ?? "",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manropeBold,
                          color: const Color(0xFF2E3333),
                        ),
                      ),
                    ),

                    // 🗑 Delete Icon
                    if (isNewItem)
                      GestureDetector(
                        onTap: () {
                          showCancelConfirmationDialog(
                            context: context,
                            onConfirm: () {
                              CancleOrder(product.amendMeta?.amendCartId);
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.black,
                            size: 18.sp,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 1.h),
                Text(
                  "Original Price: £${product.price ?? '0'}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 0.5.h),

                Row(
                  children: [
                    Text(
                      "£${_getAmendItemPrice(itemDetails)}",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppConstants.manrope,
                        color: AppColors.maincolor,
                      ),
                    ),
                    const Spacer(),

                    // 👉 If product has valid id → show editable quantity control
                    if (isExisting)
                      _buildAmendQuantityControl(product, isNewItem),

                    // 👉 If id is null → show warning icon instead of quantity control
                    if (isNewItem)
                      GestureDetector(
                        onTap: () => _showEditWarning(context),
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 16.sp,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                "Can't edit",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                if (product.totalPrice != null)
                  Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: Text(
                      "Total: £${product.totalPrice}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmendQuantityControl(Products product, bool isNewItem) {
    int qty = product.quantity ?? 1;
    int orderProductID = product.id ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff969696)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button (-)
          InkWell(
            onTap: () {
              if (qty > 1) {
                // Decrement by 1
                prepaidCartQuantity(
                  orderProductID.toString(),
                  qty - 1,
                  'decrement',
                );
              } else {
                showSnackBar(
                  context: context,
                  title: 'Sorry !!',
                  message: 'The minimum quantity allowed is 1.',
                  backgoundColor: Colors.red,
                );
              }
            },
            child: Text(
              "-",
              style: TextStyle(
                fontSize: 17.sp,
                color: Colors.black,
                fontFamily: AppConstants.manrope,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            "$qty",
            style: TextStyle(
              fontSize: 17.sp,
              color: Colors.black,
              fontFamily: AppConstants.manrope,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 2.w),
          // Increment button (+)
          InkWell(
            onTap: () {
              if (qty < 10) {
                // Increment by 1
                prepaidCartQuantity(
                  orderProductID.toString(),
                  qty + 1,
                  'increment',
                );
              }
            },
            child: Icon(Icons.add, color: Colors.black, size: 16.sp),
          ),
        ],
      ),
    );
  }

  // Updated prepaidCartQuantity method with operation type
  prepaidCartQuantity(
    String orderProductID,
    int newQty,
    String operation,
  ) async {
    setState(() {
      isUpdateQuantity = true;
    });

    // Determine the amendment type based on operation
    String amendmentType =
        operation == 'increment' ? "increment_qty" : "decrement_qty";

    List<Map<String, dynamic>> amendments = [
      {
        "type": amendmentType,
        "order_product_id": orderProductID,
        if (operation == 'increment') "qty_to_add": 1,
        if (operation != 'increment') "qty_to_subtract": 1,
      },
    ];

    final Map<String, dynamic> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID.toString(),
      "amendments": jsonEncode(amendments),
    };

    log("Amend Order Data: $data");

    bool internet = await checkInternet();
    if (!internet) {
      setState(() => isUpdateQuantity = false);
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await CartProvider().amendOrderApi(data);

      if (response.statusCode == 200) {
        setState(() => isUpdateQuantity = false);

        // Update local UI immediately for better UX
        if (amendOrderModal?.amendOrderData?.products != null) {
          for (var product in amendOrderModal!.amendOrderData!.products!) {
            if (product.id.toString() == orderProductID) {
              product.quantity = newQty;
              break;
            }
          }
        }

        // Then refresh from server
        amendOrderApi();
      } else {
        setState(() => isUpdateQuantity = false);
        buildErrorDialog(context, 'Error', "Failed to update quantity");
      }
    } catch (e) {
      setState(() => isUpdateQuantity = false);
      buildErrorDialog(context, 'Error', e.toString());
    }
  }

  void _showEditWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "You can't edit this product because it's newly added.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orangeAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Widget> _buildRegularCartItems() {
    return List.generate(cartDetailsModel!.data!.length, (index) {
      final item = cartDetailsModel!.data![index];
      return Column(
        children: [
          _buildCartItem(item),
          if (index != cartDetailsModel!.data!.length - 1)
            Divider(
              height: 1,
              color: const Color(0xFFF5F5F5),
              indent: 4.w,
              endIndent: 4.w,
            ),
        ],
      );
    });
  }

  Widget _buildRegularOrderSummary() {
    return Column(
      children: [
        _buildSummaryRow("Subtotal", getSubtotal()),
        if (cartDetailsModel
                ?.data?[0]
                .loyaltyDetails
                ?.willGetLoyaltyDiscountOnCurrentOrder ??
            false)
          _buildSummaryRow(
            "Loyalty Discount (-${getLoyaltyDiscountPercentage().toStringAsFixed(0)}%)",
            getLoyaltyDiscountAmount(),
            isDiscount: true,
          ),
        Divider(height: 3.h, thickness: 1),
        _buildSummaryRow("Total", getFinalTotal(), isTotal: true),
      ],
    );
  }

  bool _hasItems() {
    if (widget.isAmend == true) {
      return amendOrderModal?.amendOrderData?.products?.isNotEmpty ?? false;
    } else {
      return cartDetailsModel?.data?.isNotEmpty ?? false;
    }
  }

  String _getAmendItemImage(ItemDetails itemDetails) {
    if (itemDetails.image != null && itemDetails.image!.isNotEmpty) {
      return itemDetails.image!;
    } else if (itemDetails.images != null &&
        itemDetails.images is List &&
        (itemDetails.images as List).isNotEmpty) {
      return (itemDetails.images as List).first;
    }
    return "";
  }

  Widget _buildServiceOrderSummary() {
    return Column(
      children: [
        _buildSummaryRow("Subtotal", getSubtotal1()),
        Divider(height: 3.h, thickness: 1),
        _buildSummaryRow("Total", getSubtotal1(), isTotal: true),
      ],
    );
  }

  String _getAmendItemPrice(ItemDetails itemDetails) {
    if (itemDetails.offerPrice != null &&
        itemDetails.offerPrice != "0.00" &&
        itemDetails.offerPrice != itemDetails.price) {
      return itemDetails.offerPrice.toString();
    }
    return itemDetails.price ?? '0';
  }

  double _getAmendSubtotal() {
    double total = 0.0;
    amendOrderModal?.amendOrderData?.products?.forEach((product) {
      final itemDetails = product.itemDetails;
      if (itemDetails != null) {
        double price = double.tryParse(_getAmendItemPrice(itemDetails)) ?? 0;
        total += price * (product.quantity ?? 1);
      }
    });
    return total;
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
                  "Do you really want to remove this order?\nThis action cannot be undone.",
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
                          width: 50.w,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(12.0),
                        child: batan(
                          title: "Yes, Remove",
                          route: () {
                            onConfirm();
                            Get.back();
                          },
                          width: 50.w,

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

  CancleOrder(id) async {
    setState(() {
      isUpdateQuantity = true;
    });
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID.toString(),
      "amend_cart_id": id.toString(),
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await OrderProvider().cancleOrderApi(data);

          if (response.statusCode == 200) {
            setState(() {
              isUpdateQuantity = false;
            });
            amendOrderApi();
          } else {
            setState(() {
              isUpdateQuantity = false;
            });
          }
        } catch (e) {
          setState(() {
            isUpdateQuantity = false;
          });
        }
      } else {
        setState(() {
          isUpdateQuantity = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
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
                          Get.to(HomePage(userName: ""));
                        },
                        color: AppColors.maincolor,
                        fontcolor: Colors.white,
                        height: 5.h,
                        fontsize: 16.sp,
                        radius: 12.0,
                        width: double.infinity,
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

  Future<void> prepaidAddProduct(
    List<Map<String, dynamic>> selectedItems,
  ) async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No items selected to add.")),
      );
      return;
    }

    setState(() {
      isUpdateQuantity = true;
    });

    // Build amendments array dynamically
    List<Map<String, dynamic>> amendments =
        selectedItems.map((item) {
          return {
            "type": "add_item",
            "product_id": item["product_id"]?.toString() ?? "",
            "qty": item["qty"] ?? 1,
          };
        }).toList();

    final Map<String, dynamic> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID?.toString() ?? "",
      "amendments": jsonEncode(amendments),
    };

    log("Add Product Payload => $data");

    bool internet = await checkInternet();
    if (!internet) {
      if (mounted) setState(() => isUpdateQuantity = false);
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }

    try {
      final response = await CartProvider().amendOrderApi(data);

      if (response.statusCode == 200) {
        // refresh data depending on flow and wait for it to finish
        try {
          if (widget.isAmend == true) {
            // amendOrderApi is now async so we await fresh server state
            await amendOrderApi();
          } else {
            // GetCartDetailApi() in your code is not async; call it to reload
            GetCartDetailApi();
          }

          // success: clear selection and close add-more section
          if (mounted) {
            setState(() {
              isUpdateQuantity = false;
              selectedProducts.clear();
              showAddMoreSection = false;
            });
          }

          // user feedback
          final addedCount = selectedItems.length;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "$addedCount item${addedCount > 1 ? 's' : ''} added to your order",
              ),
            ),
          );
        } catch (e) {
          // Failed while refreshing -- keep the UI consistent and show error
          log("Error while refreshing order after add: $e");
          if (mounted) setState(() => isUpdateQuantity = false);
          buildErrorDialog(
            context,
            'Error',
            "Failed to refresh order after adding items",
          );
        }
      } else {
        if (mounted) setState(() => isUpdateQuantity = false);
        buildErrorDialog(context, 'Error', "Failed to add items");
      }
    } catch (e) {
      if (mounted) setState(() => isUpdateQuantity = false);
      buildErrorDialog(context, 'Error', e.toString());
      log("Exception in prepaidAddProduct: $e");
    }
  }

  bool isCheckout = false;

  CheckOutAPI() {
    setState(() {
      isCheckout = true;
    });
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID ?? "",
    };

    checkInternet().then((internet) async {
      if (internet) {
        CartProvider().amendPaymentApi(data).then((response) async {
          amendPaymentModal = AmendPaymentModal.fromJson(response.data);

          if (response.statusCode == 200) {
            setState(() {
              isCheckout = false;
            });

            _openPaymentPage(
              amendPaymentModal?.data?.paymentUrl.toString() ?? "",
            );
          } else {
            setState(() {
              isCheckout = false;
            });
          }
        });
      } else {
        setState(() {
          isCheckout = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  _openPaymentPage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                StripeWebView(title: 'Pay Online', link: url, isAmend: true),
      ),
    );
  }
}
