// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:wavee/Ui/CartScreen/model/amendOrderModal.dart';
// import 'package:wavee/Ui/CartScreen/model/cartDetailsModal.dart'
//     hide ItemDetails;
//
// import '../../../Utils/bottomBar.dart';
// import '../../../Utils/chatCounter.dart';
// import '../../../Utils/checkInternetConnection.dart';
// import '../../../Utils/colors.dart';
// import '../../../Utils/const.dart';
// import '../../../Utils/customAppBar.dart';
// import '../../../Utils/customBatan.dart';
// import '../../../Utils/errorDialog.dart';
// import '../../../Utils/loader.dart';
// import '../../BuyProduct/view/buyProductView.dart';
// import '../../CommunityScreen/Provider/communityProvider.dart';
// import '../../CommunityScreen/view/communityScreen.dart';
// import '../../HomeScreen/View/homePage.dart';
// import '../../OrderScreen/Provider/orderProvider.dart';
// import '../../orderScreen/View/orderScreenView.dart';
// import '../../productDetailPage/provider/productProvider.dart';
// import '../provider/addToCartProvider.dart';
//
// class AddToCartView extends StatefulWidget {
//   String? type;
//   String? businessID;
//   String? orderID;
//   int? selected;
//   final bool fromBottomBar;
//   bool? isAmend;
//
//   AddToCartView({
//     super.key,
//     this.type,
//     this.selected,
//     this.businessID,
//     this.orderID,
//     this.fromBottomBar = false,
//     this.isAmend = false,
//   });
//
//   @override
//   State<AddToCartView> createState() => _AddToCartViewState();
// }
//
// class _AddToCartViewState extends State<AddToCartView> {
//   bool isLoading = false;
//   bool isUpdateQuantity = false;
//   double otherFees = 0.0;
//   double deliveryFees = 0.0;
//   bool hasShownFancySheet = false;
//   bool isAddtoCart = false;
//   final GlobalCountsController countsController = Get.find();
//   AmendOrderModal? amendOrderModal;
//
//   bool showAddMoreSection = false;
//   List<BusinessProducts> availableProducts = [];
//   bool isLoadingProducts = false;
//   List<BusinessProducts> selectedProducts = [];
//
//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       isLoading = true;
//     });
//     log("dfsddfsshijhsddjhisdfhisdfjhdfhjdfbjh${widget.orderID}");
//     if (widget.isAmend == true) {
//       amendOrderApi();
//     } else {
//       GetCartDetailApi();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Get.offAll(() => HomePage(selected: 1, userName: ''));
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         body: Column(
//           children: [
//             SizedBox(height: 6.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 2.w),
//               child: TitleBar(
//                 back: () {
//                   if (widget.fromBottomBar) {
//                     Get.offAll(HomePage(userName: ""));
//                   } else {
//                     Get.back();
//                   }
//                 },
//                 title: widget.isAmend == true ? "Amend Order" : "Your Cart",
//                 drawerCallback: () {},
//               ),
//             ),
//             SizedBox(height: 5.h),
//
//             // if (widget.isAmend == true &&
//             //     amendOrderModal?.amendOrderData != null)
//             //   _buildAmendOrderBanner(),
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 2.h),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: const Color(0xffdedfe5), width: 1),
//                   color: AppColors.white,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(45),
//                     topRight: Radius.circular(45),
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     if (isLoading)
//                       Center(child: Loader())
//                     else if ((widget.isAmend == true &&
//                             (amendOrderModal
//                                     ?.amendOrderData
//                                     ?.products
//                                     ?.isEmpty ??
//                                 true)) ||
//                         (widget.isAmend != true &&
//                             (cartDetailsModel?.data == null ||
//                                 (cartDetailsModel?.data?.length ?? 0) == 0)))
//                       _buildEmptyBasketView()
//                     else
//                       ListView(
//                         padding: const EdgeInsets.all(8.0),
//                         children: [
//                           Container(
//                             margin: EdgeInsets.all(2.w),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(3.w),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     widget.isAmend == true
//                                         ? "Amend Order"
//                                         : "My Cart",
//                                     style: TextStyle(
//                                       fontSize: 22.sp,
//                                       color: Colors.black,
//                                       fontFamily: AppConstants.manropeBold,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(height: 1.h),
//                                   Container(
//                                     width: 12.w,
//                                     height: 1.h,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   SizedBox(height: 0.5.h),
//                                   Text(
//                                     widget.isAmend == true
//                                         ? "Items (${amendOrderModal?.amendOrderData?.products?.length ?? 0})"
//                                         : "Items (${cartDetailsModel?.data?.length ?? 0})",
//                                     style: TextStyle(
//                                       fontSize: 18.sp,
//                                       color: const Color(0xFF969696),
//                                       fontFamily: AppConstants.manrope,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   SizedBox(height: 1.h),
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                           if (widget.isAmend == true)
//                             ..._buildAmendOrderItems()
//                           else
//                             ..._buildRegularCartItems(),
//
//                           if (widget.isAmend == true && !showAddMoreSection)
//                             _buildAddMoreButton(),
//
//                           if (widget.isAmend == true && showAddMoreSection)
//                             _buildAddMoreItemsSection(),
//
//                           if (widget.isAmend != true &&
//                               cartDetailsModel?.data?[0].type == "product") ...[
//                             const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 12),
//                               child: Text(
//                                 "People also added",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                             _buildSuggestedList(),
//                           ],
//
//                           SizedBox(height: 50.h),
//                         ],
//                       ),
//
//                     if (!isLoading && _hasItems())
//                       Positioned(
//                         top: widget.isAmend == true ? 15.h : 10.h,
//                         left: 0,
//                         right: 0,
//                         bottom: 0,
//                         child: DraggableScrollableSheet(
//                           initialChildSize: 0.65,
//                           minChildSize: 0.60,
//                           builder: (context, scrollController) {
//                             return Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 3.w,
//                                 vertical: 1.h,
//                               ),
//                               decoration: const BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//                                   topRight: Radius.circular(45),
//                                   topLeft: Radius.circular(45),
//                                 ),
//                                 border: Border(
//                                   top: BorderSide(
//                                     color: Color(0xffc7c7c7),
//                                     width: 1,
//                                   ),
//                                   left: BorderSide(
//                                     color: Color(0xffc7c7c7),
//                                     width: 1,
//                                   ),
//                                   right: BorderSide(
//                                     color: Color(0xffc7c7c7),
//                                     width: 1,
//                                   ),
//                                   // bottom: BorderSide.none, // ← default none, optional
//                                 ),
//                                 color: Color(0xfff2f2f2),
//                               ),
//
//                               child: ListView(
//                                 controller: scrollController,
//                                 children: [
//                                   _buildSectionCard(
//                                     title: "Order Summary",
//                                     icon: Icons.receipt,
//                                     child: Column(
//                                       children: [
//                                         if (widget.isAmend == true)
//                                           _buildAmendOrderSummary()
//                                         else if (cartDetailsModel
//                                                 ?.data?[0]
//                                                 .type ==
//                                             "product")
//                                           _buildRegularOrderSummary()
//                                         else
//                                           _buildServiceOrderSummary(),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//
//                     if (!isLoading && _hasItems())
//                       Positioned(
//                         top: widget.isAmend == true ? 62.h : 60.h,
//                         left: 30.w,
//                         child: InkWell(
//                           onTap: _handleCheckoutTap,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 7.w,
//                               vertical: 1.h,
//                             ),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(15),
//                               color: Colors.white,
//                               border: Border.all(
//                                 color: const Color(0xffd9d9d9),
//                               ),
//                             ),
//                             child: Text(
//                               widget.isAmend == true
//                                   ? "Amend Order"
//                                   : "Checkout",
//                               style: TextStyle(
//                                 fontSize: 18.sp,
//                                 color: Colors.black,
//                                 fontFamily:
//                                     widget.isAmend == true
//                                         ? AppConstants.manropeBold
//                                         : AppConstants.manrope,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                     if (isUpdateQuantity)
//                       Container(
//                         color: Colors.white,
//                         child: Center(child: Loader()),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: Obx(
//           () => BottomBar(
//             selected: 4,
//             chatCount: countsController.chatCount.value,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddMoreButton() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             showAddMoreSection = true;
//           });
//           _loadAvailableProducts();
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xff969696), width: 1),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 10.w,
//                 height: 10.w,
//                 decoration: BoxDecoration(
//                   color: AppColors.maincolor,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.add, color: Colors.white, size: 18.sp),
//               ),
//               SizedBox(width: 3.w),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Add More Items",
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       // fontWeight: FontWeight.bold,
//                       color: AppColors.maincolor,
//                       fontFamily: AppConstants.manrope,
//                     ),
//                   ),
//                   Text(
//                     "Add additional items to your order",
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       color: Colors.grey[600],
//                       fontFamily: AppConstants.manrope,
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: AppColors.maincolor,
//                 size: 18.sp,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddMoreItemsSection() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
//       padding: EdgeInsets.all(3.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE5E5E5)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Add More Items",
//                 style: TextStyle(
//                   fontSize: 20.sp,
//                   // fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                   fontFamily: AppConstants.manropeBold,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     showAddMoreSection = false;
//                     selectedProducts.clear();
//                   });
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(1.w),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.close, color: Colors.black, size: 18.sp),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 1.h),
//           Text(
//             "Select items to add to your order",
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.grey[600],
//               fontFamily: AppConstants.manrope,
//             ),
//           ),
//           SizedBox(height: 2.h),
//
//           if (isLoadingProducts)
//             Center(child: Loader())
//           else if (availableProducts.isEmpty)
//             _buildNoProductsAvailable()
//           else
//             _buildAvailableProductsList(),
//
//           SizedBox(height: 2.h),
//
//           if (selectedProducts.isNotEmpty) _buildAddSelectedButton(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoProductsAvailable() {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Column(
//         children: [
//           Icon(Icons.search_off, size: 40.sp, color: Colors.grey[400]),
//           SizedBox(height: 2.h),
//           Text(
//             "No additional products available",
//             style: TextStyle(
//               fontSize: 16.sp,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 1.h),
//           Text(
//             "All available products are already in your order",
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAvailableProductsList() {
//     return Column(
//       children:
//           availableProducts.map((product) {
//             final bool isAlreadyInOrder = _isProductInOrder(product);
//             final bool isSelected = selectedProducts.contains(product);
//             final selectedProduct = selectedProducts.firstWhere(
//               (p) => p.id == product.id,
//               orElse: () => BusinessProducts(),
//             );
//             final int quantity = selectedProduct.id ?? 1;
//
//             return Container(
//               margin: EdgeInsets.only(bottom: 2.h),
//               padding: EdgeInsets.all(2.w),
//               decoration: BoxDecoration(
//                 color:
//                     isSelected
//                         ? AppColors.maincolor.withOpacity(0.05)
//                         : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color:
//                       isSelected
//                           ? AppColors.maincolor
//                           : const Color(0xFFE5E5E5),
//                   width: isSelected ? 2 : 1,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Container(
//                       width: 16.w,
//                       height: 16.w,
//                       color: const Color(0xFFF8F8F8),
//                       child: CachedNetworkImage(
//                         imageUrl: _getProductImage(product),
//                         fit: BoxFit.cover,
//                         placeholder:
//                             (context, url) => Center(
//                               child: CircularProgressIndicator(
//                                 color: AppColors.maincolor,
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                         errorWidget:
//                             (context, url, error) => Icon(
//                               Icons.image_outlined,
//                               color: Colors.grey[400],
//                               size: 6.w,
//                             ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 3.w),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           product.name ?? "",
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w600,
//                             color: const Color(0xFF2E3333),
//                             fontFamily: AppConstants.manrope,
//                           ),
//                         ),
//                         SizedBox(height: 0.5.h),
//                         if (product.offerPrice != null &&
//                             product.offerPrice != "0.00" &&
//                             product.offerPrice != product.price)
//                           Row(
//                             children: [
//                               Text(
//                                 "£${product.price}",
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   color: Colors.grey,
//                                   decoration: TextDecoration.lineThrough,
//                                 ),
//                               ),
//                               SizedBox(width: 2.w),
//                               Text(
//                                 "£${product.offerPrice}",
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: AppColors.maincolor,
//                                   fontFamily: AppConstants.manrope,
//                                 ),
//                               ),
//                             ],
//                           )
//                         else
//                           Text(
//                             "£${product.price ?? ""}",
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.maincolor,
//                               fontFamily: AppConstants.manrope,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//
//                   if (isAlreadyInOrder)
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 3.w,
//                         vertical: 0.5.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(color: Colors.orange),
//                       ),
//                       child: Text(
//                         "Already in Order",
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.orange,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     )
//                   else if (isSelected)
//                     _buildAddMoreQuantityControl(product, quantity)
//                   else
//                     GestureDetector(
//                       onTap: () {
//                         _addProductToSelection(product);
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 3.w,
//                           vertical: 1.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.maincolor,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           "Add",
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: AppConstants.manrope,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           }).toList(),
//     );
//   }
//
//   Widget _buildAddMoreQuantityControl(BusinessProducts product, int quantity) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.maincolor),
//         color: Colors.white,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           GestureDetector(
//             onTap: () {
//               if (quantity > 1) {
//                 _updateSelectedProductQuantity(product, quantity - 1);
//               } else {
//                 _removeProductFromSelection(product);
//               }
//             },
//             child: Container(
//               padding: EdgeInsets.all(1.w),
//               child: Icon(
//                 Icons.remove,
//                 size: 16.sp,
//                 color: AppColors.maincolor,
//               ),
//             ),
//           ),
//           SizedBox(width: 2.w),
//           Text(
//             "$quantity",
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//               fontFamily: AppConstants.manrope,
//             ),
//           ),
//           SizedBox(width: 2.w),
//           GestureDetector(
//             onTap: () {
//               if (quantity < 10) {
//                 _updateSelectedProductQuantity(product, quantity + 1);
//               }
//             },
//             child: Container(
//               padding: EdgeInsets.all(1.w),
//               child: Icon(Icons.add, size: 16.sp, color: AppColors.maincolor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAddSelectedButton() {
//     final double totalAmount = _calculateSelectedItemsTotal();
//
//     return Container(
//       width: double.infinity,
//       child: Column(
//         children: [
//           Divider(height: 2.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Total to add:",
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               Text(
//                 "£${totalAmount.toStringAsFixed(2)}",
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.maincolor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 2.h),
//           GestureDetector(
//             onTap: () {
//               _addSelectedItemsToOrder();
//             },
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(vertical: 1.5.h),
//               decoration: BoxDecoration(
//                 color: AppColors.maincolor,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.maincolor.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.add_shopping_cart,
//                     color: Colors.white,
//                     size: 20.sp,
//                   ),
//                   SizedBox(width: 2.w),
//                   Text(
//                     "Add ${selectedProducts.length} Items to Order",
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: AppConstants.manropeBold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _loadAvailableProducts() {
//     setState(() {
//       isLoadingProducts = true;
//     });
//
//     checkInternet().then((internet) {
//       if (internet) {
//         CommunityProvider()
//             .businessProfileViewApi(widget.businessID.toString(), '', '')
//             .then((response) {
//               setState(() {
//                 isLoadingProducts = false;
//                 if (response.statusCode == 200) {
//                   print("Business Profile Response: ${response.data}");
//
//                   dynamic productsData;
//
//                   if (response.data['data'] != null &&
//                       response.data['data']['products'] != null) {
//                     productsData = response.data['data']['products'];
//                   } else if (response.data['products'] != null) {
//                     productsData = response.data['products'];
//                   } else if (response.data['data'] != null &&
//                       response.data['data'] is List) {
//                     productsData = response.data['data'];
//                   } else {
//                     productsData = response.data;
//                   }
//
//                   final List<BusinessProducts> allProducts = [];
//
//                   if (productsData is List) {
//                     allProducts.addAll(
//                       productsData.map<BusinessProducts>((item) {
//                         if (item is Map<dynamic, dynamic>) {
//                           final Map<String, dynamic> stringMap =
//                               item.cast<String, dynamic>();
//                           return BusinessProducts.fromJson(stringMap);
//                         } else if (item is Map<String, dynamic>) {
//                           return BusinessProducts.fromJson(item);
//                         } else {
//                           return BusinessProducts.fromJson({});
//                         }
//                       }).toList(),
//                     );
//                   } else if (productsData is Map) {
//                     if (productsData is Map<dynamic, dynamic>) {
//                       final Map<String, dynamic> stringMap =
//                           productsData.cast<String, dynamic>();
//                       allProducts.add(BusinessProducts.fromJson(stringMap));
//                     } else if (productsData is Map<String, dynamic>) {
//                       allProducts.add(BusinessProducts.fromJson(productsData));
//                     }
//                   }
//
//                   availableProducts =
//                       allProducts
//                           .where((product) => !_isProductInOrder(product))
//                           .toList();
//
//                   print(
//                     "Loaded ${availableProducts.length} available products",
//                   );
//                 } else {
//                   buildErrorDialog(context, 'Error', "Failed to load products");
//                 }
//               });
//             })
//             .catchError((error) {
//               setState(() {
//                 isLoadingProducts = false;
//               });
//               print("Error loading products: $error");
//               buildErrorDialog(context, 'Error', "Failed to load products");
//             });
//       } else {
//         setState(() {
//           isLoadingProducts = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   String _getProductImage(BusinessProducts product) {
//     if (product.image != null && product.image!.isNotEmpty) {
//       return product.image!;
//     } else if (product.images != null && product.images!.isNotEmpty) {
//       return product.images!.first;
//     }
//     return "";
//   }
//
//   bool _isProductInOrder(BusinessProducts product) {
//     return amendOrderModal?.amendOrderData?.products?.any(
//           (orderProduct) => orderProduct.productId == product.id,
//         ) ??
//         false;
//   }
//
//   void _addProductToSelection(BusinessProducts product) {
//     setState(() {
//       product.id = 1;
//       selectedProducts.add(product);
//     });
//   }
//
//   void _removeProductFromSelection(BusinessProducts product) {
//     setState(() {
//       selectedProducts.remove(product);
//     });
//   }
//
//   void _updateSelectedProductQuantity(
//     BusinessProducts product,
//     int newQuantity,
//   ) {
//     setState(() {
//       final selectedProduct = selectedProducts.firstWhere(
//         (p) => p.id == product.id,
//       );
//       selectedProduct.id = newQuantity;
//     });
//   }
//
//   double _calculateSelectedItemsTotal() {
//     double total = 0.0;
//     for (var product in selectedProducts) {
//       double price =
//           double.tryParse(product.offerPrice ?? product.price ?? '0') ?? 0;
//       total += price * (product.id ?? 1);
//     }
//     return total;
//   }
//
//   void _addSelectedItemsToOrder() {
//     setState(() {
//       isUpdateQuantity = true;
//     });
//   }
//
//   void removeFromAmendOrderApi(int productId, String type) {
//     setState(() {
//       isUpdateQuantity = true;
//     });
//
//     final Map<String, String> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? "",
//       "order_id": widget.orderID ?? "",
//       "product_id": productId.toString(),
//       "type": type,
//     };
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         CartProvider().removeCartApi(data).then((response) async {
//           if (response.statusCode == 200) {
//             setState(() {
//               isUpdateQuantity = false;
//             });
//
//             amendOrderApi();
//           } else {
//             setState(() {
//               isUpdateQuantity = false;
//             });
//             buildErrorDialog(context, 'Error', "Failed to remove item");
//           }
//         });
//       } else {
//         setState(() {
//           isUpdateQuantity = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   void _handleCheckoutTap() {
//     if (widget.isAmend == true) {
//       _navigateToAmendCheckout();
//     } else {
//       if (cartDetailsModel?.data?[0].type == "product") {
//         if (!hasShownFancySheet) {
//           setState(() {
//             hasShownFancySheet = true;
//           });
//           _showFancyAnythingElseSheet();
//         } else {
//           _navigateToCheckout();
//         }
//       } else {
//         _navigateToCheckout();
//       }
//     }
//   }
//
//   void _navigateToAmendCheckout() {
//     Get.to(
//       BuyProductView(
//         bunessid:
//             amendOrderModal
//                 ?.amendOrderData
//                 ?.products
//                 ?.first
//                 .itemDetails
//                 ?.businessId
//                 .toString(),
//         type: "product",
//       ),
//     );
//   }
//
//   Widget _buildEmptyBasketView() {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Padding(
//         padding: EdgeInsets.only(top: 20.h),
//         child: Column(
//           children: [
//             Container(
//               width: 25.w,
//               height: 25.w,
//               decoration: const BoxDecoration(
//                 color: Color(0xFFF0F0F0),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.shopping_basket_outlined,
//                 size: 12.w,
//                 color: Colors.grey[400],
//               ),
//             ),
//             SizedBox(height: 3.h),
//             Text(
//               "Your cart is empty",
//               style: TextStyle(
//                 fontFamily: AppConstants.manrope,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF2E3333),
//               ),
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               "Add items to get started",
//               style: TextStyle(
//                 fontFamily: AppConstants.manrope,
//                 fontSize: 14.sp,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 batan(
//                   title: "Explore Community",
//                   route: () {
//                     Get.to(() => CommunityScreen());
//                   },
//                   color: AppColors.maincolor,
//                   fontcolor: Colors.white,
//                   height: 5.h,
//                   fontsize: 16.sp,
//                   radius: 12.0,
//                   width: 43.5.w,
//                   fontFamily: AppConstants.manropeBold,
//
//                   fontWeight: FontWeight.bold,
//                 ),
//                 SizedBox(width: 4.w),
//                 batan(
//                   title: "View Orders",
//                   route: () {
//                     Get.to(() => Order_Screen());
//                   },
//                   color: AppColors.maincolor,
//                   fontcolor: Colors.white,
//                   height: 5.h,
//                   fontsize: 16.5.sp,
//                   radius: 12.0,
//                   width: 40.w,
//                   fontFamily: AppConstants.manropeBold,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ],
//             ),
//             SizedBox(height: 5.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCartItem(dynamic item) {
//     final product = item.itemDetails;
//     if (product == null) return const SizedBox();
//
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
//       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//         border: Border.all(color: const Color(0xFF969696), width: 1),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               width: 18.w,
//               height: 18.w,
//               color: const Color(0xFFF8F8F8),
//               child: CachedNetworkImage(
//                 imageUrl:
//                     (product.image != null &&
//                             (product.image as String).isNotEmpty)
//                         ? product.image
//                         : (product.images != null &&
//                             (product.images as List).isNotEmpty)
//                         ? product.images.first
//                         : "",
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Center(child: Loader()),
//                 errorWidget:
//                     (context, url, error) => Icon(
//                       Icons.image_outlined,
//                       color: Colors.grey[400],
//                       size: 8.w,
//                     ),
//               ),
//             ),
//           ),
//           SizedBox(width: 3.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         product.name ?? "",
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: AppConstants.manropeBold,
//                           color: const Color(0xFF2E3333),
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         RemoveFromCartApi(
//                           item.productId ?? 0,
//                           item.type ?? "product",
//                         );
//                       },
//                       child: Container(
//                         padding: EdgeInsets.all(1.w),
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFF5F5F5),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.delete,
//                           color: Colors.black,
//                           size: 18.sp,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 1.h),
//
//                 Row(
//                   children: [
//                     Text(
//                       "£${(product.offerPrice ?? product.price)?.toString() ?? '0'}",
//                       style: TextStyle(
//                         fontSize: 17.sp,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: AppConstants.manrope,
//                         color: AppColors.maincolor,
//                       ),
//                     ),
//                     const Spacer(),
//                     _buildQuantityControl(item),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuantityControl(dynamic item) {
//     int qty = (item.quantity ?? 1) as int;
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xff969696)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           InkWell(
//             onTap: () {
//               if (qty > 1) {
//                 setState(() {
//                   item.quantity = qty - 1;
//                 });
//                 updateQuantityApi(
//                   item.productId ?? 0,
//                   item.quantity ?? 1,
//                   item.type ?? "",
//                 );
//               } else {
//                 RemoveFromCartApi(item.productId ?? 0, item.type ?? "product");
//               }
//             },
//             child: Text(
//               "-",
//               style: TextStyle(
//                 fontSize: 17.sp,
//                 color: Colors.black,
//                 fontFamily: AppConstants.manrope,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 2.w),
//           Text(
//             "${item.quantity ?? 1}",
//             style: TextStyle(
//               fontSize: 17.sp,
//               color: Colors.black,
//               fontFamily: AppConstants.manrope,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(width: 2.w),
//           InkWell(
//             onTap: () {
//               if ((item.quantity ?? 1) < 10) {
//                 setState(() {
//                   item.quantity = (item.quantity ?? 1) + 1;
//                 });
//                 updateQuantityApi(
//                   item.productId ?? 0,
//                   item.quantity ?? 1,
//                   item.type ?? "",
//                 );
//               }
//             },
//             child: Icon(Icons.add, color: Colors.black, size: 16.sp),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionCard({
//     required String title,
//     required IconData icon,
//     required Widget child,
//   }) {
//     return Card(
//       elevation: 0,
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(3.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon),
//                 SizedBox(width: 2.w),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 2.h),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
//
//   AddCartProductApi(String productID) {
//     setState(() {
//       isUpdateQuantity = true;
//       isAddtoCart = true;
//     });
//     final Map<String, String> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? "",
//       "id": productID.toString(),
//       "type": "product",
//     };
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         ProductProvider().AddToCart(data).then((response) async {
//           if (response.statusCode == 200) {
//             await GetCartDetailApi();
//             setState(() {
//               isUpdateQuantity = false;
//               isAddtoCart = false;
//             });
//             Get.to(() => AddToCartView(type: "product"));
//           } else {
//             setState(() {
//               isUpdateQuantity = false;
//               isAddtoCart = false;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isAddtoCart = false;
//         });
//
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   Widget summaryTile(String title, String amount, {bool isTotal = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 0.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: isTotal ? 18.sp : 17.sp,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               fontFamily: AppConstants.manrope,
//             ),
//           ),
//           Text(
//             "£$amount",
//             style: TextStyle(
//               fontSize: isTotal ? 18.sp : 17.sp,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               fontFamily: AppConstants.manrope,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(
//     String title,
//     double amount, {
//     bool isTotal = false,
//     bool isDiscount = false,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 0.5.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: isTotal ? 18.sp : 16.5.sp,
//               fontWeight: FontWeight.bold,
//               fontFamily: AppConstants.manrope,
//               color:
//                   isDiscount
//                       ? Colors.green[700]
//                       : (isTotal ? Colors.black : Colors.grey[800]),
//             ),
//           ),
//           Text(
//             isDiscount
//                 ? "-£${amount.toStringAsFixed(2)}"
//                 : "£${amount.toStringAsFixed(2)}",
//             style: TextStyle(
//               fontSize: isTotal ? 18.sp : 16.5.sp,
//               fontWeight: FontWeight.bold,
//               fontFamily: AppConstants.manrope,
//               color:
//                   isDiscount
//                       ? Colors.green[700]
//                       : (isTotal ? AppColors.maincolor : Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   double getSubtotal() {
//     double total = 0.0;
//     cartDetailsModel?.data?.forEach((item) {
//       double price =
//           double.tryParse(
//             item.itemDetails?.offerPrice ?? item.itemDetails?.price ?? '0',
//           ) ??
//           0;
//       total += price * (item.quantity ?? 1);
//     });
//     return total;
//   }
//
//   double getSubtotal1() {
//     double total = 0.0;
//     cartDetailsModel?.data?.forEach((item) {
//       double price =
//           double.tryParse(
//             item.itemDetails?.offerPrice ?? item.itemDetails?.price ?? '0',
//           ) ??
//           0;
//       total += price * (item.quantity ?? 1);
//     });
//     return total;
//   }
//
//   GetCartDetailApi() {
//     checkInternet().then((internet) {
//       if (internet) {
//         CartProvider()
//             .cartDetailApi(loginModel?.data?.user?.id.toString() ?? "")
//             .then((response) {
//               cartDetailsModel = CartDetailsModel.fromJson(response.data);
//               if (response.statusCode == 200) {
//                 setState(() {
//                   isLoading = false;
//                 });
//               } else {
//                 setState(() {
//                   isLoading = false;
//                 });
//               }
//             });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   updateQuantityApi(int productId, int quantity, type) {
//     final Map<String, String> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? "",
//       "product_id": productId.toString(),
//       "quantity": quantity.toString(),
//       "type": type.toString(),
//     };
//     setState(() {
//       isUpdateQuantity = true;
//     });
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         CartProvider().updateCartQuantityApi(data).then((response) async {
//           if (response.statusCode == 200) {
//             setState(() {
//               isUpdateQuantity = false;
//             });
//           } else {
//             setState(() {
//               isUpdateQuantity = false;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isUpdateQuantity = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   RemoveFromCartApi(int productId, String type) {
//     setState(() {
//       isUpdateQuantity = true;
//     });
//
//     final Map<String, String> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? "",
//       "product_id": productId.toString(),
//       "type": type,
//     };
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         CartProvider().removeCartApi(data).then((response) async {
//           if (response.statusCode == 200) {
//             setState(() {
//               isUpdateQuantity = false;
//             });
//             GetCartDetailApi();
//           } else {
//             setState(() {
//               isUpdateQuantity = false;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isUpdateQuantity = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   double getLoyaltyDiscountPercentage() {
//     final loyaltyDetails = cartDetailsModel?.data?[0].loyaltyDetails;
//     if (loyaltyDetails?.willGetLoyaltyDiscountOnCurrentOrder != true) {
//       return 0.0;
//     }
//     String discountStr =
//         checkoutTotal?.data?.first.loyaltyDetails?.loyaltyDiscountPercentage ??
//         "0";
//     return double.tryParse(discountStr) ?? 0.0;
//   }
//
//   double getLoyaltyDiscountAmount() {
//     final loyaltyDetails = cartDetailsModel?.data?[0].loyaltyDetails;
//     if (loyaltyDetails?.willGetLoyaltyDiscountOnCurrentOrder != true) {
//       return 0.0;
//     }
//
//     double subtotal = getSubtotal();
//     double discountPercent = getLoyaltyDiscountPercentage();
//
//     return subtotal * (discountPercent / 100);
//   }
//
//   double getFinalTotal() {
//     double subtotal = getSubtotal();
//     double loyaltyDiscount = getLoyaltyDiscountAmount();
//     return subtotal - loyaltyDiscount;
//   }
//
//   Widget _buildSuggestedList() {
//     final List<BusinessProducts> allProducts =
//         (cartDetailsModel?.data?.expand(
//                   (item) => item.itemDetails?.businessProducts ?? [],
//                 ) ??
//                 [])
//             .whereType<BusinessProducts>()
//             .toList();
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       height: 10.h,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: allProducts.length,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemBuilder: (context, index) {
//           final product = allProducts[index];
//
//           return Container(
//             margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
//             alignment: Alignment.center,
//             padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//               border: Border.all(color: const Color(0xFF969696), width: 1),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: CachedNetworkImage(
//                         imageUrl:
//                             (product.image != null && product.image!.isNotEmpty)
//                                 ? product.image!
//                                 : (product.images != null &&
//                                     product.images!.isNotEmpty)
//                                 ? product.images!.first
//                                 : "",
//                         fit: BoxFit.cover,
//                         width: 14.w,
//                         height: 14.w,
//                         placeholder:
//                             (context, url) => const Center(
//                               child: CircularProgressIndicator(
//                                 color: AppColors.maincolor,
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                         errorWidget:
//                             (context, url, error) => Icon(
//                               Icons.image_outlined,
//                               color: Colors.grey[400],
//                               size: 30,
//                             ),
//                       ),
//                     ),
//                     SizedBox(width: 2.w),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           product.name ?? "",
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         (product.offerPrice != null &&
//                                 product.offerPrice != "0.00" &&
//                                 product.offerPrice != product.price)
//                             ? Row(
//                               children: [
//                                 Text(
//                                   "£${product.price}",
//                                   style: TextStyle(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.normal,
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.grey,
//                                     decoration: TextDecoration.lineThrough,
//                                     decorationColor: AppColors.maincolor,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Text(
//                                   "£${product.offerPrice}",
//                                   style: TextStyle(
//                                     fontSize: 15.sp,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 InkWell(
//                                   onTap: () {
//                                     AddCartProductApi(
//                                       product.id.toString() ?? "",
//                                     );
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(3),
//                                       color: Colors.black,
//                                     ),
//                                     child: Icon(
//                                       Icons.add,
//                                       size: 17.sp,
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             )
//                             : Row(
//                               children: [
//                                 Text(
//                                   "£${product.price ?? ""}",
//                                   style: TextStyle(
//                                     fontSize: 15.sp,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: AppConstants.manrope,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 InkWell(
//                                   onTap: () {
//                                     AddCartProductApi(
//                                       product.id.toString() ?? "",
//                                     );
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       color: Colors.black,
//                                     ),
//                                     child: Icon(
//                                       Icons.add,
//                                       size: 17.sp,
//                                       color: AppColors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _showFancyAnythingElseSheet() {
//     final List<BusinessProducts> suggestedProducts =
//         (cartDetailsModel?.data?.expand(
//                   (item) => item.itemDetails?.businessProducts ?? [],
//                 ) ??
//                 [])
//             .whereType<BusinessProducts>()
//             .toList();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder:
//           (context) => DraggableScrollableSheet(
//             initialChildSize: 0.85,
//             minChildSize: 0.4,
//             maxChildSize: 0.95,
//             expand: false,
//             builder:
//                 (_, controller) => Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(20),
//                     ),
//                   ),
//                   child: Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(
//                           bottom: 10.h,
//                           left: 4.w,
//                           right: 4.w,
//                         ),
//                         child: ListView(
//                           controller: controller,
//                           physics: const BouncingScrollPhysics(),
//                           children: [
//                             Center(
//                               child: Container(
//                                 margin: EdgeInsets.only(top: 1.h, bottom: 2.h),
//                                 width: 10.w,
//                                 height: 0.5.h,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[300],
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Fancy anything else?",
//                                   style: TextStyle(
//                                     fontSize: 20.sp,
//                                     fontWeight: FontWeight.w700,
//                                     fontFamily: AppConstants.manrope,
//                                     color: const Color(0xFF2E3333),
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () => Navigator.pop(context),
//                                   child: Icon(
//                                     Icons.close,
//                                     size: 24.sp,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 2.h),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Your regulars",
//                                   style: TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w600,
//                                     fontFamily: AppConstants.manrope,
//                                     color: const Color(0xFF2E3333),
//                                   ),
//                                 ),
//                                 SizedBox(height: 0.5.h),
//                                 Text(
//                                   "Forgotten anything from your regular items?",
//                                   style: TextStyle(
//                                     fontSize: 15.sp,
//                                     color: Colors.grey[600],
//                                     fontFamily: AppConstants.manrope,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 2.h),
//                             if (suggestedProducts.isEmpty)
//                               Center(
//                                 child: Padding(
//                                   padding: EdgeInsets.symmetric(vertical: 4.h),
//                                   child: Text(
//                                     "No suggested items available",
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       color: Colors.grey[500],
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             else
//                               GridView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: suggestedProducts.length,
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 3,
//                                       childAspectRatio: 0.48,
//                                       crossAxisSpacing: 3.w,
//                                       mainAxisSpacing: 2.h,
//                                     ),
//                                 itemBuilder: (context, index) {
//                                   final product = suggestedProducts[index];
//                                   return Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       border: Border.all(
//                                         color: const Color(0xFFE5E5E5),
//                                         width: 1,
//                                       ),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Stack(
//                                           clipBehavior: Clip.none,
//                                           children: [
//                                             ClipRRect(
//                                               borderRadius:
//                                                   const BorderRadius.vertical(
//                                                     top: Radius.circular(12),
//                                                   ),
//                                               child: CachedNetworkImage(
//                                                 imageUrl:
//                                                     (product.image != null &&
//                                                             product
//                                                                 .image!
//                                                                 .isNotEmpty)
//                                                         ? product.image!
//                                                         : (product.images !=
//                                                                 null &&
//                                                             product
//                                                                 .images!
//                                                                 .isNotEmpty)
//                                                         ? product.images!.first
//                                                         : "",
//                                                 fit: BoxFit.cover,
//                                                 height: 14.h,
//                                                 width: double.infinity,
//                                                 placeholder:
//                                                     (context, url) => Container(
//                                                       color: const Color(
//                                                         0xFFF8F8F8,
//                                                       ),
//                                                       child: const Center(
//                                                         child:
//                                                             CircularProgressIndicator(
//                                                               color:
//                                                                   AppColors
//                                                                       .maincolor,
//                                                               strokeWidth: 2,
//                                                             ),
//                                                       ),
//                                                     ),
//                                                 errorWidget:
//                                                     (
//                                                       context,
//                                                       url,
//                                                       error,
//                                                     ) => Container(
//                                                       color: const Color(
//                                                         0xFFF8F8F8,
//                                                       ),
//                                                       height: 14.h,
//                                                       child: Icon(
//                                                         Icons.image_outlined,
//                                                         color: Colors.grey[400],
//                                                         size: 6.w,
//                                                       ),
//                                                     ),
//                                               ),
//                                             ),
//                                             Positioned(
//                                               bottom: -12,
//                                               right: 4,
//                                               child: GestureDetector(
//                                                 onTap: () {
//                                                   AddCartProductApi(
//                                                     product.id.toString(),
//                                                   );
//                                                   Get.back();
//                                                 },
//                                                 child: Container(
//                                                   width: 11.w,
//                                                   height: 11.w,
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.white,
//                                                     shape: BoxShape.circle,
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: Colors.black
//                                                             .withOpacity(0.15),
//                                                         blurRadius: 6,
//                                                         spreadRadius: 2,
//                                                         offset: const Offset(
//                                                           0,
//                                                           2,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   child: Icon(
//                                                     Icons.add,
//                                                     size: 22.sp,
//                                                     color: AppColors.maincolor,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Expanded(
//                                           child: Padding(
//                                             padding: EdgeInsets.all(4.w),
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   product.name ?? "",
//                                                   maxLines: 3,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: TextStyle(
//                                                     fontSize: 15.sp,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontFamily:
//                                                         AppConstants
//                                                             .manropeBold,
//                                                     color: const Color(
//                                                       0xFF2E3333,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 const Spacer(),
//                                                 Padding(
//                                                   padding: EdgeInsets.symmetric(
//                                                     horizontal: 0.w,
//                                                   ),
//                                                   child:
//                                                       (product.offerPrice !=
//                                                                   null &&
//                                                               product.offerPrice !=
//                                                                   "0.00" &&
//                                                               product.offerPrice !=
//                                                                   product.price)
//                                                           ? FittedBox(
//                                                             fit:
//                                                                 BoxFit
//                                                                     .scaleDown,
//                                                             alignment:
//                                                                 Alignment
//                                                                     .centerLeft,
//                                                             child: Row(
//                                                               children: [
//                                                                 Text(
//                                                                   "£${product.price}",
//                                                                   style: TextStyle(
//                                                                     fontSize:
//                                                                         13.sp,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .normal,
//                                                                     fontFamily:
//                                                                         AppConstants
//                                                                             .manrope,
//                                                                     color:
//                                                                         Colors
//                                                                             .grey,
//                                                                     decoration:
//                                                                         TextDecoration
//                                                                             .lineThrough,
//                                                                     decorationColor:
//                                                                         AppColors
//                                                                             .maincolor,
//                                                                   ),
//                                                                 ),
//                                                                 const SizedBox(
//                                                                   width: 5,
//                                                                 ),
//                                                                 Text(
//                                                                   "£${product.offerPrice}",
//                                                                   style: TextStyle(
//                                                                     fontSize:
//                                                                         14.sp,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold,
//                                                                     fontFamily:
//                                                                         AppConstants
//                                                                             .manrope,
//                                                                     color:
//                                                                         Colors
//                                                                             .black,
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           )
//                                                           : Text(
//                                                             "£${product.price ?? ""}",
//                                                             style: TextStyle(
//                                                               fontSize: 14.sp,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold,
//                                                               fontFamily:
//                                                                   AppConstants
//                                                                       .manrope,
//                                                               color:
//                                                                   Colors.black,
//                                                             ),
//                                                           ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                             SizedBox(height: 20.h),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         left: 0,
//                         right: 0,
//                         child: Container(
//                           padding: EdgeInsets.all(4.w),
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 10,
//                                 offset: Offset(0, -2),
//                               ),
//                             ],
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(20),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               (cartDetailsModel?.data?[0].type == "product" &&
//                                       cartDetailsModel
//                                               ?.data?[0]
//                                               .loyaltyDetails
//                                               ?.loyaltyOrderThreshold !=
//                                           null &&
//                                       cartDetailsModel
//                                               ?.data?[0]
//                                               .loyaltyDetails
//                                               ?.loyaltyDiscountPercentage !=
//                                           null)
//                                   ? Container(
//                                     width: double.infinity,
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 4.w,
//                                       vertical: 1.8.h,
//                                     ),
//                                     margin: EdgeInsets.only(bottom: 2.h),
//                                     decoration: BoxDecoration(
//                                       color: AppColors.maincolor.withOpacity(
//                                         0.1,
//                                       ),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             "You're getting closer to an exclusive reward! Complete ${cartDetailsModel?.data?[0].loyaltyDetails?.loyaltyOrderThreshold} more orders to unlock a ${cartDetailsModel?.data?[0].loyaltyDetails?.loyaltyDiscountPercentage?.replaceAll(RegExp(r'\\.0+\$'), '')}% discount on your next purchase.",
//                                             style: TextStyle(
//                                               fontSize: 14.sp,
//                                               color: const Color(0xFF3C1361),
//                                               fontFamily: AppConstants.manrope,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ),
//                                         Container(
//                                           width: 28,
//                                           height: 28,
//                                           decoration: const BoxDecoration(
//                                             color: AppColors.maincolor,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: const Icon(
//                                             Icons.card_giftcard,
//                                             size: 16,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                   : const SizedBox(),
//                               GestureDetector(
//                                 onTap: () {
//                                   Get.back();
//                                   _navigateToCheckout();
//                                 },
//                                 child: Container(
//                                   height: 6.h,
//                                   decoration: BoxDecoration(
//                                     color: AppColors.maincolor,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.shopping_cart_checkout,
//                                         color: Colors.white,
//                                         size: 20.sp,
//                                       ),
//                                       SizedBox(width: 3.w),
//                                       Text(
//                                         "Checkout",
//                                         style: TextStyle(
//                                           fontSize: 18.sp,
//                                           color: Colors.white,
//                                           fontFamily: AppConstants.manrope,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                       SizedBox(width: 2.w),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//           ),
//     );
//   }
//
//   void _navigateToCheckout() {
//     Get.to(
//       BuyProductView(
//         bunessid: cartDetailsModel?.data?[0].itemDetails?.businessId.toString(),
//         type: cartDetailsModel?.data?.first.type,
//       ),
//     );
//   }
//
//   amendOrderApi() {
//     final Map<String, String> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? "",
//       "order_id": widget.orderID ?? "",
//     };
//     print("dadsadadadasdadsaseqwe$data");
//     checkInternet().then((internet) {
//       if (internet) {
//         CartProvider().amendOrderDetailapi(data).then((response) {
//           amendOrderModal = AmendOrderModal.fromJson(response.data);
//           if (response.statusCode == 200) {
//             log("Data ave che che ${response.data}");
//             setState(() {
//               isLoading = false;
//             });
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   Widget _buildAmendOrderBanner() {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//       decoration: BoxDecoration(
//         color: AppColors.maincolor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.maincolor.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.edit_note, color: AppColors.maincolor, size: 20.sp),
//               SizedBox(width: 2.w),
//               Text(
//                 "Amending Order #${amendOrderModal?.amendOrderData?.orderNo ?? ''}",
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.maincolor,
//                   fontFamily: AppConstants.manropeBold,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 1.h),
//           Text(
//             "You can modify items, quantities, or add new items to your existing order.",
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.grey[700],
//               fontFamily: AppConstants.manrope,
//             ),
//           ),
//           if (amendOrderModal?.amendOrderData?.pickupTime != null)
//             Padding(
//               padding: EdgeInsets.only(top: 1.h),
//               child: Text(
//                 "Pickup Time: ${amendOrderModal?.amendOrderData?.pickupTime ?? ''}",
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                   fontFamily: AppConstants.manrope,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildAmendOrderItems() {
//     return List.generate(
//       amendOrderModal?.amendOrderData?.products?.length ?? 0,
//       (index) {
//         final product = amendOrderModal?.amendOrderData?.products?[index];
//         if (product == null) return const SizedBox();
//
//         return Column(
//           children: [
//             _buildAmendCartItem(product),
//             if (index !=
//                 (amendOrderModal?.amendOrderData?.products?.length ?? 0) - 1)
//               Divider(
//                 height: 1,
//                 color: const Color(0xFFF5F5F5),
//                 indent: 4.w,
//                 endIndent: 4.w,
//               ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildAmendCartItem(Products product) {
//     final itemDetails = product.itemDetails;
//     if (itemDetails == null) return const SizedBox();
//
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
//       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//         border: Border.all(color: const Color(0xFF969696), width: 1),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               width: 18.w,
//               height: 18.w,
//               color: const Color(0xFFF8F8F8),
//               child: CachedNetworkImage(
//                 imageUrl: _getAmendItemImage(itemDetails),
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Center(child: Loader()),
//                 errorWidget:
//                     (context, url, error) => Icon(
//                       Icons.image_outlined,
//                       color: Colors.grey[400],
//                       size: 8.w,
//                     ),
//               ),
//             ),
//           ),
//           SizedBox(width: 3.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         itemDetails.name ?? "",
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: AppConstants.manropeBold,
//                           color: const Color(0xFF2E3333),
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         showCancelConfirmationDialog(
//                           context: context,
//                           onConfirm: CancleOrder,
//                         );
//                       },
//                       child: Container(
//                         padding: EdgeInsets.all(1.w),
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFF5F5F5),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.delete,
//                           color: Colors.black,
//                           size: 18.sp,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 1.h),
//                 Text(
//                   "Original Price: £${product.price ?? '0'}",
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Colors.grey[600],
//                     fontFamily: AppConstants.manrope,
//                   ),
//                 ),
//                 SizedBox(height: 0.5.h),
//                 Row(
//                   children: [
//                     Text(
//                       "£${_getAmendItemPrice(itemDetails)}",
//                       style: TextStyle(
//                         fontSize: 17.sp,
//                         fontWeight: FontWeight.w700,
//                         fontFamily: AppConstants.manrope,
//                         color: AppColors.maincolor,
//                       ),
//                     ),
//                     const Spacer(),
//                     _buildAmendQuantityControl(product),
//                   ],
//                 ),
//                 if (product.totalPrice != null)
//                   Padding(
//                     padding: EdgeInsets.only(top: 0.5.h),
//                     child: Text(
//                       "Total: £${product.totalPrice}",
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                         fontFamily: AppConstants.manrope,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAmendQuantityControl(Products product) {
//     int qty = product.quantity ?? 1;
//     int orderProductID = product.id ?? 1;
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xff969696)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           InkWell(
//             onTap: () {
//               if (qty > 1) {
//                 // _updateAmendQuantity(product, qty - 1);
//                 log("QTY MINUS $qty");
//
//                 prepateCartQuantity(orderProductID.toString(), qty);
//               } else {
//                 showCancelConfirmationDialog(
//                   context: context,
//                   onConfirm: CancleOrder,
//                 );
//               }
//             },
//             child: Text(
//               "-",
//               style: TextStyle(
//                 fontSize: 17.sp,
//                 color: Colors.black,
//                 fontFamily: AppConstants.manrope,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 2.w),
//           Text(
//             "$qty",
//             style: TextStyle(
//               fontSize: 17.sp,
//               color: Colors.black,
//               fontFamily: AppConstants.manrope,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(width: 2.w),
//           InkWell(
//             onTap: () {
//               if (qty < 10) {
//                 log("QTY PLUS $qty");
//                 prepateCartQuantity(orderProductID.toString(), qty);
//               }
//             },
//             child: Icon(Icons.add, color: Colors.black, size: 16.sp),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildRegularCartItems() {
//     return List.generate(cartDetailsModel!.data!.length, (index) {
//       final item = cartDetailsModel!.data![index];
//       return Column(
//         children: [
//           _buildCartItem(item),
//           if (index != cartDetailsModel!.data!.length - 1)
//             Divider(
//               height: 1,
//               color: const Color(0xFFF5F5F5),
//               indent: 4.w,
//               endIndent: 4.w,
//             ),
//         ],
//       );
//     });
//   }
//
//   Widget _buildRegularOrderSummary() {
//     return Column(
//       children: [
//         _buildSummaryRow("Subtotal", getSubtotal()),
//         if (cartDetailsModel
//                 ?.data?[0]
//                 .loyaltyDetails
//                 ?.willGetLoyaltyDiscountOnCurrentOrder ??
//             false)
//           _buildSummaryRow(
//             "Loyalty Discount (-${getLoyaltyDiscountPercentage().toStringAsFixed(0)}%)",
//             getLoyaltyDiscountAmount(),
//             isDiscount: true,
//           ),
//         Divider(height: 3.h, thickness: 1),
//         _buildSummaryRow("Total", getFinalTotal(), isTotal: true),
//       ],
//     );
//   }
//
//   bool _hasItems() {
//     if (widget.isAmend == true) {
//       return amendOrderModal?.amendOrderData?.products?.isNotEmpty ?? false;
//     } else {
//       return cartDetailsModel?.data?.isNotEmpty ?? false;
//     }
//   }
//
//   String _getAmendItemImage(ItemDetails itemDetails) {
//     if (itemDetails.image != null && itemDetails.image!.isNotEmpty) {
//       return itemDetails.image!;
//     } else if (itemDetails.images != null &&
//         itemDetails.images is List &&
//         (itemDetails.images as List).isNotEmpty) {
//       return (itemDetails.images as List).first;
//     }
//     return "";
//   }
//
//   Widget _buildAmendOrderSummary() {
//     double subtotal = _getAmendSubtotal();
//     double discount =
//         double.tryParse(
//           amendOrderModal?.amendOrderData?.discountApplied ?? '0',
//         ) ??
//         0.0;
//     double loyaltyDiscount =
//         (amendOrderModal?.amendOrderData?.loyaltyDiscountApplied ?? 0)
//             .toDouble();
//     double total =
//         double.tryParse(amendOrderModal?.amendOrderData?.totalAmount ?? '0') ??
//         0.0;
//
//     return Column(
//       children: [
//         _buildSummaryRow("Subtotal", subtotal),
//         if (discount > 0)
//           _buildSummaryRow("Discount", discount, isDiscount: true),
//         if (loyaltyDiscount > 0)
//           _buildSummaryRow(
//             "Loyalty Discount",
//             loyaltyDiscount,
//             isDiscount: true,
//           ),
//         Divider(height: 3.h, thickness: 1),
//         _buildSummaryRow("Total", total, isTotal: true),
//         SizedBox(height: 2.h),
//         Text(
//           "Note: Price differences will be adjusted in the final payment",
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.grey[600],
//             fontStyle: FontStyle.italic,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildServiceOrderSummary() {
//     return Column(
//       children: [
//         _buildSummaryRow("Subtotal", getSubtotal1()),
//         Divider(height: 3.h, thickness: 1),
//         _buildSummaryRow("Total", getSubtotal1(), isTotal: true),
//       ],
//     );
//   }
//
//   String _getAmendItemPrice(ItemDetails itemDetails) {
//     if (itemDetails.offerPrice != null &&
//         itemDetails.offerPrice != "0.00" &&
//         itemDetails.offerPrice != itemDetails.price) {
//       return itemDetails.offerPrice.toString();
//     }
//     return itemDetails.price ?? '0';
//   }
//
//   double _getAmendSubtotal() {
//     double total = 0.0;
//     amendOrderModal?.amendOrderData?.products?.forEach((product) {
//       final itemDetails = product.itemDetails;
//       if (itemDetails != null) {
//         double price = double.tryParse(_getAmendItemPrice(itemDetails)) ?? 0;
//         total += price * (product.quantity ?? 1);
//       }
//     });
//     return total;
//   }
//
//   Future<void> showCancelConfirmationDialog({
//     required BuildContext context,
//     required VoidCallback onConfirm,
//   }) async {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 16,
//           backgroundColor: Colors.white,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 15),
//                 Text(
//                   "Are you sure?",
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Do you really want to cancel this order?\nThis action cannot be undone.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     color: Colors.black54,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Material(
//                         elevation: 1,
//                         borderRadius: BorderRadius.circular(12.0),
//                         child: batan(
//                           title: "No, Keep It",
//                           route: () {
//                             Get.back();
//                           },
//                           color: AppColors.white,
//                           fontcolor: Colors.black,
//                           height: 5.h,
//                           fontsize: 16.sp,
//                           radius: 12.0,
//                           width: 50.w,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Material(
//                         elevation: 1,
//                         borderRadius: BorderRadius.circular(12.0),
//                         child: batan(
//                           title: "Yes, Cancel",
//                           route: () {
//                             onConfirm();
//                             Get.back();
//                           },
//                           width: 50.w,
//
//                           color: AppColors.maincolor,
//                           fontcolor: Colors.white,
//                           height: 5.h,
//                           fontsize: 16.sp,
//                           radius: 12.0,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   CancleOrder() async {
//     setState(() {
//       isUpdateQuantity = true;
//     });
//     Map<String, String> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? "",
//       "order_id": widget.orderID.toString(),
//     };
//
//     checkInternet().then((internet) async {
//       if (internet) {
//         try {
//           var response = await OrderProvider().cancleOrderApi(data);
//
//           if (response.statusCode == 200) {
//             setState(() {
//               isUpdateQuantity = false;
//             });
//             confirmShowDialog(context: context);
//           } else {
//             setState(() {
//               isUpdateQuantity = false;
//             });
//           }
//         } catch (e) {
//           setState(() {
//             isUpdateQuantity = false;
//           });
//         }
//       } else {
//         setState(() {
//           isUpdateQuantity = false;
//         });
//         buildErrorDialog(context, 'Error', "Internet Required");
//       }
//     });
//   }
//
//   Future<void> confirmShowDialog({required BuildContext context}) async {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 16,
//           backgroundColor: Colors.white,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 15),
//                 Text(
//                   "Your Order has Cancelled!",
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                     fontFamily: AppConstants.manropeBold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Your booking has been cancelled.\n You will receive your refund within 48 hours.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     color: Colors.black54,
//                     fontFamily: AppConstants.manrope,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: batan(
//                         title: "Yes",
//                         route: () {
//                           Get.to(HomePage(userName: ""));
//                         },
//                         color: AppColors.maincolor,
//                         fontcolor: Colors.white,
//                         height: 5.h,
//                         fontsize: 16.sp,
//                         radius: 12.0,
//                         width: double.infinity,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   prepateCartQuantity(String orderProductID, qty) async {
//     setState(() {
//       isUpdateQuantity = true;
//     });
//
//     // Example amendments list
//     List<Map<String, dynamic>> amendments = [
//       {
//         "type": "increment_qty",
//         "order_product_id": orderProductID,
//         "qty_to_add": qty,
//       },
//     ];
//
//     final Map<String, dynamic> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? "",
//       "order_id": widget.orderID.toString(),
//       "amendments": jsonEncode(amendments),
//     };
//     log("data chat gpt $data");
//     bool internet = await checkInternet();
//     if (!internet) {
//       setState(() => isUpdateQuantity = false);
//       buildErrorDialog(context, 'Error', "Internet Required");
//       return;
//     }
//
//     try {
//       final response = await CartProvider().amendOrderApi(data);
//
//       if (response.statusCode == 200) {
//         setState(() => isUpdateQuantity = false);
//         GetCartDetailApi();
//         log("sdadsad${response.data}");
//       } else {
//         log("sdadsad${response.data}");
//
//         setState(() => isUpdateQuantity = false);
//       }
//     } catch (e) {
//       setState(() => isUpdateQuantity = false);
//       buildErrorDialog(context, 'Error', e.toString());
//     }
//   }
//
//   prepareAddProduct(String orderProductID, qty) async {
//     setState(() {
//       isUpdateQuantity = true;
//     });
//
//     // Example amendments list
//     List<Map<String, dynamic>> amendments = [
//       {
//         "type": "add_item",
//         "product_id": orderProductID,
//         "qty": qty,
//       },
//     ];
//
//     final Map<String, dynamic> data = {
//       "user_id": loginModel?.data?.user?.id.toString() ?? "",
//       "order_id": widget.orderID.toString(),
//       "amendments": jsonEncode(amendments),
//     };
//     log("data chat gpt $data");
//     bool internet = await checkInternet();
//     if (!internet) {
//       setState(() => isUpdateQuantity = false);
//       buildErrorDialog(context, 'Error', "Internet Required");
//       return;
//     }
//
//     try {
//       final response = await CartProvider().amendOrderApi(data);
//
//       if (response.statusCode == 200) {
//         setState(() => isUpdateQuantity = false);
//         GetCartDetailApi();
//         log("sdadsad${response.data}");
//       } else {
//         log("sdadsad${response.data}");
//
//         setState(() => isUpdateQuantity = false);
//       }
//     } catch (e) {
//       setState(() => isUpdateQuantity = false);
//       buildErrorDialog(context, 'Error', e.toString());
//     }
//   }
// }

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Ui/CartScreen/model/amendOrderModal.dart';
import 'package:wavee/Ui/CartScreen/model/amendPaymentModal.dart';
import 'package:wavee/Ui/CartScreen/model/cartDetailsModal.dart';
import 'package:wavee/Utils/stripeWebView.dart';

import '../../../Utils/bottomBar.dart';
import '../../../Utils/chatCounter.dart';
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
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

class _AddToCartViewState extends State<AddToCartView> {
  bool isLoading = false;
  bool isUpdateQuantity = false;
  double otherFees = 0.0;
  double deliveryFees = 0.0;
  bool hasShownFancySheet = false;
  bool isAddtoCart = false;
  final GlobalCountsController countsController = Get.find();
  AmendOrderModal? amendOrderModal;
  AmendCartPreparedModal? amendCartPreparedModal;

  bool showAddMoreSection = false;
  List<BusinessProducts> availableProducts = [];
  bool isLoadingProducts = false;
  List<BusinessProducts> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    print(widget.orderID);
    if (widget.isAmend == true) {
      amendOrderApi();
    } else {
      GetCartDetailApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => HomePage(selected: 1, userName: ''));
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 6.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: TitleBar(
                    back: () {
                      if (widget.fromBottomBar) {
                        Get.offAll(HomePage(userName: ""));
                      } else {
                        Get.back();
                      }
                    },
                    title: widget.isAmend == true ? "Amend Order" : "Your Cart",
                    drawerCallback: () {},
                  ),
                ),
                SizedBox(height: 5.h),

                if (widget.isAmend == true && _hasAmendData())
                  _buildAmendOrderBanner(),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xffdedfe5),
                        width: 1,
                      ),
                      color: AppColors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45),
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (isLoading)
                          Center(child: Loader())
                        else if ((widget.isAmend == true && !_hasItems()) ||
                            (widget.isAmend != true &&
                                (cartDetailsModel?.data == null ||
                                    (cartDetailsModel?.data?.length ?? 0) ==
                                        0)))
                          _buildEmptyBasketView()
                        else
                          ListView(
                            padding: const EdgeInsets.all(8.0),
                            children: [
                              Container(
                                margin: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isAmend == true
                                            ? "Amend Order"
                                            : "My Cart",
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          color: Colors.black,
                                          fontFamily: AppConstants.manropeBold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Container(
                                        width: 12.w,
                                        height: 1.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      _buildItemCount(),
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
                                  cartDetailsModel?.data?[0].type ==
                                      "product") ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
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

                              SizedBox(height: 50.h),
                            ],
                          ),

                        if (!isLoading && _hasItems())
                          Positioned(
                            top: widget.isAmend == true ? 15.h : 10.h,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: DraggableScrollableSheet(
                              initialChildSize: 0.65,
                              minChildSize: 0.60,
                              builder: (context, scrollController) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(45),
                                      topLeft: Radius.circular(45),
                                    ),
                                    border: Border(
                                      top: BorderSide(
                                        color: Color(0xffc7c7c7),
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: Color(0xffc7c7c7),
                                        width: 1,
                                      ),
                                      right: BorderSide(
                                        color: Color(0xffc7c7c7),
                                        width: 1,
                                      ),
                                    ),
                                    color: Color(0xfff2f2f2),
                                  ),

                                  child: ListView(
                                    controller: scrollController,
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
                                );
                              },
                            ),
                          ),

                        if (!isLoading && _hasItems())
                          Positioned(
                            top: widget.isAmend == true ? 62.h : 60.h,
                            left: 30.w,
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
                          ),

                        if (!isLoading && _hasItems() && widget.isAmend == true)
                          Positioned(
                            bottom: 2.h,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: _handleCheckoutTap,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.maincolor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.maincolor.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        "Amend Order",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: Colors.white,
                                          fontFamily: AppConstants.manropeBold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (isUpdateQuantity)
                          Container(
                            color: Colors.white,
                            child: Center(child: Loader()),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isCheckout)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.2),
                ),
                child: Loader(),
              ),
          ],
        ),
        bottomNavigationBar: Obx(
          () => BottomBar(
            selected: 4,
            chatCount: countsController.chatCount.value,
          ),
        ),
      ),
    );
  }

  // Helper methods for amend order data
  bool _hasAmendData() {
    return (amendOrderModal?.amendOrderData != null) ||
        (amendCartPreparedModal?.data != null);
  }

  bool _hasItems() {
    if (widget.isAmend == true) {
      return (amendOrderModal?.amendOrderData?.products?.isNotEmpty ?? false) ||
          (amendCartPreparedModal?.data?.items?.isNotEmpty ?? false);
    } else {
      return cartDetailsModel?.data?.isNotEmpty ?? false;
    }
  }

  Widget _buildItemCount() {
    if (widget.isAmend == true) {
      if (amendCartPreparedModal?.data != null) {
        return Text(
          "Items (${amendCartPreparedModal?.data?.itemCount ?? 0})",
          style: TextStyle(
            fontSize: 18.sp,
            color: const Color(0xFF969696),
            fontFamily: AppConstants.manrope,
            fontWeight: FontWeight.w600,
          ),
        );
      } else {
        return Text(
          "Items (${amendOrderModal?.amendOrderData?.products?.length ?? 0})",
          style: TextStyle(
            fontSize: 18.sp,
            color: const Color(0xFF969696),
            fontFamily: AppConstants.manrope,
            fontWeight: FontWeight.w600,
          ),
        );
      }
    } else {
      return Text(
        "Items (${cartDetailsModel?.data?.length ?? 0})",
        style: TextStyle(
          fontSize: 18.sp,
          color: const Color(0xFF969696),
          fontFamily: AppConstants.manrope,
          fontWeight: FontWeight.w600,
        ),
      );
    }
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
            final bool isSelected = selectedProducts.contains(product);
            final selectedProduct = selectedProducts.firstWhere(
              (p) => p.id == product.id,
              orElse: () => BusinessProducts(),
            );
            final int quantity = selectedProduct.id ?? 1;

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.maincolor.withOpacity(0.05)
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
                        color: Colors.orange.withOpacity(0.1),
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
              _addSelectedItemsToOrder();
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: AppColors.maincolor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.maincolor.withOpacity(0.3),
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
                } else {
                  buildErrorDialog(context, 'Error', "Failed to load products");
                }
              });
            })
            .catchError((error) {
              setState(() {
                isLoadingProducts = false;
              });
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
    if (amendCartPreparedModal?.data?.items != null) {
      return amendCartPreparedModal!.data!.items!.any(
        (item) => item.productId == product.id,
      );
    }
    return amendOrderModal?.amendOrderData?.products?.any(
          (orderProduct) => orderProduct.productId == product.id,
        ) ??
        false;
  }

  void _addProductToSelection(BusinessProducts product) {
    setState(() {
      // Assuming 'id' in BusinessProducts is used for quantity here
      // This is a bit confusing, ideally it should be a separate field
      product.id = 1;
      selectedProducts.add(product);
    });
  }

  void _removeProductFromSelection(BusinessProducts product) {
    setState(() {
      selectedProducts.remove(product);
    });
  }

  void _updateSelectedProductQuantity(
    BusinessProducts product,
    int newQuantity,
  ) {
    setState(() {
      final selectedProduct = selectedProducts.firstWhere(
        (p) => p.id == product.id,
      );
      selectedProduct.id = newQuantity;
    });
  }

  double _calculateSelectedItemsTotal() {
    double total = 0.0;
    for (var product in selectedProducts) {
      double price =
          double.tryParse(product.offerPrice ?? product.price ?? '0') ?? 0;
      // Assuming 'id' is quantity
      total += price * (product.id ?? 1);
    }
    return total;
  }

  void _addSelectedItemsToOrder() {
    setState(() {
      isUpdateQuantity = true;
    });
    for (var product in selectedProducts) {
      // Assuming product.id is the PRODUCT ID, and the quantity is stored in product.id
      // This is very confusing logic from your original code.
      // If product.id is quantity:
      prepareAddProduct(product.id.toString(), product.id ?? 1);
      // If product.id is PRODUCT ID and quantity is ALSO product.id:
      // prepareAddProduct(product.id.toString(), product.id ?? 1);
    }
    setState(() {
      showAddMoreSection = false;
      selectedProducts.clear();
      isUpdateQuantity = false; // Stop loader after loop
    });
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
    log("Amend Order Payment");
    CheckOutAPI();
  }

  String? _getBusinessId() {
    if (amendCartPreparedModal?.data?.items?.isNotEmpty ?? false) {
      return amendCartPreparedModal!.data!.items!.first.itemDetails?.businessId
          ?.toString();
    } else if (amendOrderModal?.amendOrderData?.products?.isNotEmpty ?? false) {
      return amendOrderModal!
          .amendOrderData!
          .products!
          .first
          .itemDetails
          ?.businessId
          ?.toString();
    }
    return null;
  }

  Widget _buildEmptyBasketView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Column(
          children: [
            Container(
              width: 25.w,
              height: 25.w,
              decoration: const BoxDecoration(
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
              "Your cart is empty",
              style: TextStyle(
                fontFamily: AppConstants.manrope,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3333),
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
                  color: AppColors.maincolor,
                  fontcolor: Colors.white,
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
                  color: AppColors.maincolor,
                  fontcolor: Colors.white,
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
                    (context, url, error) => Icon(
                      Icons.image_outlined,
                      color: Colors.grey[400],
                      size: 8.w,
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
                          color: const Color(0xFF2E3333),
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

                Row(
                  children: [
                    Text(
                      "£${(product.offerPrice ?? product.price)?.toString() ?? '0'}",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppConstants.manrope,
                        color: AppColors.maincolor,
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
    int qty = (item.quantity ?? 1) as int;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff969696)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
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
            "${item.quantity ?? 1}",
            style: TextStyle(
              fontSize: 17.sp,
              color: Colors.black,
              fontFamily: AppConstants.manrope,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 2.w),
          InkWell(
            onTap: () {
              if ((item.quantity ?? 1) < 10) {
                setState(() {
                  item.quantity = (item.quantity ?? 1) + 1;
                });
                updateQuantityApi(
                  item.productId ?? 0,
                  item.quantity ?? 1,
                  item.type ?? "",
                );
              }
            },
            child: Icon(Icons.add, color: Colors.black, size: 16.sp),
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
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                SizedBox(width: 2.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 10.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allProducts.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final product = allProducts[index];

          return Container(
            margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              border: Border.all(color: const Color(0xFF969696), width: 1),
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
                            (context, url) => const Center(
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        (product.offerPrice != null &&
                                product.offerPrice != "0.00" &&
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
                                const SizedBox(width: 5),
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
                                      product.id.toString() ?? "",
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
                                  "£${product.price ?? ""}",
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
                                      product.id.toString() ?? "",
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
                                    color: const Color(0xFF2E3333),
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
                                    color: const Color(0xFF2E3333),
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
                                      color: Colors.white,
                                      border: Border.all(
                                        color: const Color(0xFFE5E5E5),
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
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.15),
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
                                                        AppConstants
                                                            .manropeBold,
                                                    color: const Color(
                                                      0xFF2E3333,
                                                    ),
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
                                                                        Colors
                                                                            .black,
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
                          decoration: const BoxDecoration(
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
                                              color: const Color(0xFF3C1361),
                                              fontFamily: AppConstants.manrope,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            color: AppColors.maincolor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.card_giftcard,
                                            size: 16,
                                            color: Colors.white,
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

  void _navigateToCheckout() {
    Get.to(
      BuyProductView(
        bunessid: cartDetailsModel?.data?[0].itemDetails?.businessId.toString(),
        type: cartDetailsModel?.data?.first.type,
      ),
    );
  }

  amendOrderApi() {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID ?? "",
    };

    checkInternet().then((internet) {
      if (internet) {
        CartProvider()
            .amendOrderDetailapi(data)
            .then((response) {
              if (response.statusCode == 200) {
                // Reset both modals first
                amendOrderModal = null;
                amendCartPreparedModal = null;

                // Check which type of response we have
                if (response.data['data'] != null) {
                  if (response.data['data']['items'] != null) {
                    // This is the AmendCartPreparedModal structure
                    try {
                      amendCartPreparedModal = AmendCartPreparedModal.fromJson(
                        response.data,
                      );
                      print(
                        "Loaded AmendCartPreparedModal with ${amendCartPreparedModal?.data?.items?.length} items",
                      );
                    } catch (e) {
                      print("Error parsing AmendCartPreparedModal: $e");
                      // Fall back to regular amend order modal
                      try {
                        amendOrderModal = AmendOrderModal.fromJson(
                          response.data,
                        );
                        print(
                          "Fallback: Loaded AmendOrderModal with ${amendOrderModal?.amendOrderData?.products?.length} products",
                        );
                      } catch (e2, stacktrace) {
                        print("Error parsing AmendOrderModal: $e2");
                        print("Error parsing AmendOrderModal: $stacktrace");
                      }
                    }
                  } else if (response.data['data']['products'] != null ||
                      response.data['data']['id'] != null) {
                    // This is the regular AmendOrderModal structure
                    try {
                      amendOrderModal = AmendOrderModal.fromJson(response.data);
                      print(
                        "Loaded AmendOrderModal with ${amendOrderModal?.amendOrderData?.products?.length} products",
                      );
                    } catch (e, stacktrace) {
                      print("Error parsing AmendOrderModal: $e");
                      print("Error parsing AmendOrderModal: $stacktrace");
                    }
                  }
                }

                setState(() {
                  isLoading = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                });
              }
            })
            .catchError((error) {
              setState(() {
                isLoading = false;
              });
              print("API Error: $error");
              buildErrorDialog(
                context,
                'Error',
                "Failed to load order details",
              );
            });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Widget _buildAmendOrderBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.maincolor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.maincolor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.maincolor, size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                "Amending Order #${_getOrderNumber()}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.maincolor,
                  fontFamily: AppConstants.manropeBold,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            "You can modify items, quantities, or add new items to your existing order.",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              fontFamily: AppConstants.manrope,
            ),
          ),
          if (_getPickupTime() != null)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                "Pickup Time: ${_getPickupTime()}",
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
    );
  }

  String _getOrderNumber() {
    if (amendOrderModal?.amendOrderData?.orderNo != null) {
      return amendOrderModal!.amendOrderData!.orderNo!;
    }
    return widget.orderID ?? '';
  }

  String? _getPickupTime() {
    return amendOrderModal?.amendOrderData?.pickupTime;
  }

  List<Widget> _buildAmendOrderItems() {
    if (amendCartPreparedModal?.data?.items != null) {
      return _buildAmendCartPreparedItems();
    } else {
      return _buildLegacyAmendOrderItems();
    }
  }

  List<Widget> _buildAmendCartPreparedItems() {
    return List.generate(amendCartPreparedModal?.data?.items?.length ?? 0, (
      index,
    ) {
      final item = amendCartPreparedModal?.data?.items?[index];
      if (item == null) return const SizedBox();

      return Column(
        children: [
          _buildAmendCartPreparedItem(item),
          if (index != (amendCartPreparedModal?.data?.items?.length ?? 0) - 1)
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

  Widget _buildAmendCartPreparedItem(AmendCartItem item) {
    final itemDetails = item.itemDetails;
    if (itemDetails == null) return const SizedBox();

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
                    (context, url, error) => Icon(
                      Icons.image_outlined,
                      color: Colors.grey[400],
                      size: 8.w,
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
                        itemDetails.name ?? "",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manropeBold,
                          color: const Color(0xFF2E3333),
                        ),
                      ),
                    ),
                    if (item.orderProductId != null)
                      GestureDetector(
                        onTap: () {
                          showCancelConfirmationDialog(
                            context: context,
                            onConfirm:
                                () => removeFromAmendOrderApi(
                                  item.productId ?? 0,
                                  item.type ?? "product",
                                ),
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
                Row(
                  children: [
                    Text(
                      "£${item.totalPrice ?? '0'}",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppConstants.manrope,
                        color: AppColors.maincolor,
                      ),
                    ),
                    const Spacer(),
                    _buildAmendCartPreparedQuantityControl(item),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Quantity: ${item.quantity ?? 1} × £${itemDetails.price ?? '0'}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
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

  Widget _buildAmendCartPreparedQuantityControl(AmendCartItem item) {
    int qty = item.quantity ?? 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff969696)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (qty > 1) {
                // *** FIX: Send -1 for decrement ***
                prepareCartQuantity(item.orderProductId.toString(), -1);
              } else {
                showCancelConfirmationDialog(
                  context: context,
                  onConfirm:
                      () => removeFromAmendOrderApi(
                        item.productId ?? 0,
                        item.type ?? "product",
                      ),
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
          InkWell(
            onTap: () {
              if (qty < 10) {
                if (item.orderProductId != null) {
                  // *** FIX: Send 1 for increment ***
                  prepareCartQuantity(item.orderProductId.toString(), 1);
                } else {
                  // updateAmendCartQuantity(item.id.toString(), qty + 1);
                }
              }
            },
            child: Icon(Icons.add, color: Colors.black, size: 16.sp),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLegacyAmendOrderItems() {
    return List.generate(
      amendOrderModal?.amendOrderData?.products?.length ?? 0,
      (index) {
        final product = amendOrderModal?.amendOrderData?.products?[index];
        if (product == null) return const SizedBox();

        return Column(
          children: [
            _buildLegacyAmendCartItem(product),
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

  Widget _buildLegacyAmendCartItem(Products product) {
    final itemDetails = product.itemDetails;
    if (itemDetails == null) return const SizedBox();

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
                    (context, url, error) => Icon(
                      Icons.image_outlined,
                      color: Colors.grey[400],
                      size: 8.w,
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
                        itemDetails.name ?? "",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.manropeBold,
                          color: const Color(0xFF2E3333),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showCancelConfirmationDialog(
                          context: context,
                          onConfirm:
                              CancleOrder, // This should probably remove the item, not cancel the whole order
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
                  "Original Price: £${product.getPriceAsDouble().toStringAsFixed(2)}",
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
                    _buildLegacyAmendQuantityControl(product),
                  ],
                ),
                if (product.totalPrice != null)
                  Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: Text(
                      "Total: £${product.getTotalPriceAsDouble().toStringAsFixed(2)}",
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

  Widget _buildLegacyAmendQuantityControl(Products product) {
    int qty = product.quantity ?? 1;
    int orderProductID = product.id ?? 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff969696)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              if (qty > 1) {
                // *** FIX: Send -1 for decrement ***
                prepareCartQuantity(orderProductID.toString(), -1);
              } else {
                showCancelConfirmationDialog(
                  context: context,
                  onConfirm: CancleOrder, // This should probably remove item
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
          InkWell(
            onTap: () {
              if (qty < 10) {
                // *** FIX: Send 1 for increment ***
                prepareCartQuantity(orderProductID.toString(), 1);
              }
            },
            child: Icon(Icons.add, color: Colors.black, size: 16.sp),
          ),
        ],
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

  Widget _buildAmendOrderSummary() {
    if (amendCartPreparedModal?.data != null) {
      return _buildAmendCartPreparedSummary();
    } else {
      return _buildLegacyAmendOrderSummary();
    }
  }

  Widget _buildAmendCartPreparedSummary() {
    double subtotal =
        double.tryParse(
          amendCartPreparedModal?.data?.subtotal?.replaceAll(',', '') ?? '0',
        ) ??
        0.0;
    double tax =
        double.tryParse(
          amendCartPreparedModal?.data?.tax?.replaceAll(',', '') ?? '0',
        ) ??
        0.0;

    // *** FIX: Calculate total manually ***
    double total = subtotal + tax;

    return Column(
      children: [
        _buildSummaryRow("Subtotal", subtotal),
        if (tax > 0) _buildSummaryRow("Tax", tax),
        Divider(height: 3.h, thickness: 1),
        _buildSummaryRow("Total", total, isTotal: true),
        // <-- Shows calculated total
        SizedBox(height: 2.h),
        Text(
          "Note: Price differences will be adjusted in the final payment",
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLegacyAmendOrderSummary() {
    double subtotal = _getAmendSubtotal();
    double discount =
        double.tryParse(
          amendOrderModal?.amendOrderData?.discountApplied ?? '0',
        ) ??
        0.0;
    double loyaltyDiscount =
        (amendOrderModal?.amendOrderData?.loyaltyDiscountApplied ?? 0)
            .toDouble();

    // *** FIX: Calculate total manually ***
    double total = subtotal - discount - loyaltyDiscount;
    if (total < 0) {
      total = 0.0; // Ensure total isn't negative
    }

    return Column(
      children: [
        _buildSummaryRow("Subtotal", subtotal),
        if (discount > 0)
          _buildSummaryRow("Discount", discount, isDiscount: true),
        if (loyaltyDiscount > 0)
          _buildSummaryRow(
            "Loyalty Discount",
            loyaltyDiscount,
            isDiscount: true,
          ),
        Divider(height: 3.h, thickness: 1),
        _buildSummaryRow("Total", total, isTotal: true),
        // <-- Shows calculated total
        SizedBox(height: 2.h),
        Text(
          "Note: Price differences will be adjusted in the final payment",
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
      // *** FIX: Use the helper method from your model to get the total price ***
      total += product.getTotalPriceAsDouble();
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
                          title: "Yes, Cancel",
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

  CancleOrder() async {
    setState(() {
      isUpdateQuantity = true;
    });
    Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID.toString(),
    };

    checkInternet().then((internet) async {
      if (internet) {
        try {
          var response = await OrderProvider().cancleOrderApi(data);

          if (response.statusCode == 200) {
            setState(() {
              isUpdateQuantity = false;
            });
            confirmShowDialog(context: context);
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

  // *** FIX: Renamed function and changed logic to accept quantityChange (1 or -1) ***
  prepareCartQuantity(String orderProductID, int quantityChange) async {
    setState(() {
      isUpdateQuantity = true;
    });

    List<Map<String, dynamic>> amendments = [
      {
        "type": "increment_qty",
        "order_product_id": orderProductID,
        "qty_to_add": quantityChange, // <-- FIX: Use quantityChange
      },
    ];

    final Map<String, dynamic> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID.toString(),
      "amendments": jsonEncode(amendments),
    };
    log("amendmentsamendmentsamendmentsamendments$data");
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
        amendOrderApi(); // Refresh the cart
      } else {
        setState(() => isUpdateQuantity = false);
        buildErrorDialog(context, 'Error', "Failed to update quantity");
      }
    } catch (e) {
      setState(() => isUpdateQuantity = false);
      buildErrorDialog(context, 'Error', e.toString());
    }
  }

  updateAmendCartQuantity(String cartItemId, int newQuantity) async {
    setState(() {
      isUpdateQuantity = true;
    });

    List<Map<String, dynamic>> amendments = [
      {
        "type": "increment_qty",
        "cart_item_id": cartItemId,
        "new_qty": newQuantity,
      },
    ];

    final Map<String, dynamic> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID.toString(),
      "amendments": jsonEncode(amendments),
    };
    log("sadadsaadd#$data");
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

  prepareAddProduct(String productID, int quantity) async {
    setState(() {
      isUpdateQuantity = true;
    });

    List<Map<String, dynamic>> amendments = [
      {"type": "add_item", "product_id": productID, "qty": quantity},
    ];

    final Map<String, dynamic> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "order_id": widget.orderID.toString(),
      "amendments": jsonEncode(amendments),
    };

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
        amendOrderApi();
      } else {
        setState(() => isUpdateQuantity = false);
        buildErrorDialog(context, 'Error', "Failed to add product");
      }
    } catch (e) {
      setState(() => isUpdateQuantity = false);
      buildErrorDialog(context, 'Error', e.toString());
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
        builder: (context) => StripeWebView(title: 'Pay Online', link: url),
      ),
    );
  }
}

class AmendOrderModal {
  var status;
  String? message;
  AmendOrderData? amendOrderData;

  AmendOrderModal({this.status, this.message, this.amendOrderData});

  AmendOrderModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    amendOrderData =
        json['data'] != null ? AmendOrderData.fromJson(json['data']) : null;
  }
}

class AmendOrderData {
  int? id;
  int? userId;
  String? orderNo;
  String? tokenNo;
  String? totalAmount;
  String? pickupTime;
  String? paymentGateway;
  String? paymentIntentId;
  String? status;
  String? discountApplied;
  int? loyaltyDiscountApplied;
  String? createdAt;
  String? updatedAt;
  List<Products>? products;

  AmendOrderData({
    this.id,
    this.userId,
    this.orderNo,
    this.tokenNo,
    this.totalAmount,
    this.pickupTime,
    this.paymentGateway,
    this.paymentIntentId,
    this.status,
    this.discountApplied,
    this.loyaltyDiscountApplied,
    this.createdAt,
    this.updatedAt,
    this.products,
  });

  AmendOrderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderNo = json['order_no'];
    tokenNo = json['token_no'];
    totalAmount = json['total_amount'];
    pickupTime = json['pickup_time'];
    paymentGateway = json['payment_gateway'];
    paymentIntentId = json['payment_intent_id'];
    status = json['status'];
    discountApplied = json['discount_applied'];
    loyaltyDiscountApplied = json['loyalty_discount_applied'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }
}

class Products {
  int? id;
  int? orderId;
  int? userId;
  int? productId;
  String? type;
  int? quantity;
  dynamic price; // Can be String or int
  dynamic totalPrice; // Can be String or int
  String? createdAt;
  String? updatedAt;
  ItemDetails? itemDetails;
  Business? business;
  AmendMeta? amendMeta;

  Products({
    this.id,
    this.orderId,
    this.userId,
    this.productId,
    this.type,
    this.quantity,
    this.price,
    this.totalPrice,
    this.createdAt,
    this.updatedAt,
    this.itemDetails,
    this.business,
    this.amendMeta,
  });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    userId =
        json['user_id'] is String
            ? int.tryParse(json['user_id'])
            : json['user_id'];
    productId = json['product_id'];
    type = json['type'];
    quantity =
        json['quantity'] is String
            ? int.tryParse(json['quantity'])
            : json['quantity'];
    price = json['price'];
    totalPrice = json['total_price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemDetails =
        json['item_details'] != null
            ? ItemDetails.fromJson(json['item_details'])
            : null;
    business =
        json['business'] != null ? Business.fromJson(json['business']) : null;
    amendMeta =
        json['amend_meta'] != null
            ? AmendMeta.fromJson(json['amend_meta'])
            : null;
  }

  // Helper method to get price as double
  double getPriceAsDouble() {
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    } else if (price is int) {
      return price.toDouble();
    } else if (price is double) {
      return price;
    }
    return 0.0;
  }

  // Helper method to get total price as double
  double getTotalPriceAsDouble() {
    if (totalPrice is String) {
      return double.tryParse(totalPrice) ?? 0.0;
    } else if (totalPrice is int) {
      return totalPrice.toDouble();
    } else if (totalPrice is double) {
      return totalPrice;
    }
    return 0.0;
  }
}

class Business {
  int? id;
  String? businessName;
  String? profile;

  Business({this.id, this.businessName, this.profile});

  Business.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessName = json['business_name'];
    profile = json['profile'];
  }
}

class AmendMeta {
  String? source;
  String? actionType;
  int? amendCartId;
  String? displayLabel;

  AmendMeta({
    this.source,
    this.actionType,
    this.amendCartId,
    this.displayLabel,
  });

  AmendMeta.fromJson(Map<String, dynamic> json) {
    source = json['source'];
    actionType = json['action_type'];
    amendCartId = json['amend_cart_id'];
    displayLabel = json['display_label'];
  }
}

class AmendCartPreparedModal {
  bool? status;
  String? message;
  AmendCartPreparedData? data;

  AmendCartPreparedModal({this.status, this.message, this.data});

  AmendCartPreparedModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null
            ? AmendCartPreparedData.fromJson(json['data'])
            : null;
  }
}

class AmendCartPreparedData {
  List<AmendCartItem>? items;
  String? subtotal;
  String? total;
  String? tax;
  int? itemCount;

  AmendCartPreparedData({
    this.items,
    this.subtotal,
    this.total,
    this.tax,
    this.itemCount,
  });

  AmendCartPreparedData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <AmendCartItem>[];
      json['items'].forEach((v) {
        items!.add(AmendCartItem.fromJson(v));
      });
    }
    subtotal = json['subtotal'];
    total = json['total'];
    tax = json['tax'];
    itemCount = json['item_count'];
  }
}

class AmendCartItem {
  int? id;
  String? type;
  int? userId;
  int? productId;
  int? orderProductId;
  int? quantity;
  String? totalPrice;
  String? createdAt;
  String? updatedAt;
  ItemDetails? itemDetails;

  AmendCartItem({
    this.id,
    this.type,
    this.userId,
    this.productId,
    this.orderProductId,
    this.quantity,
    this.totalPrice,
    this.createdAt,
    this.updatedAt,
    this.itemDetails,
  });

  AmendCartItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    userId = json['user_id'];
    productId = json['product_id'];
    orderProductId = json['order_product_id'];
    quantity = json['quantity'];
    totalPrice = json['total_price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemDetails =
        json['item_details'] != null
            ? ItemDetails.fromJson(json['item_details'])
            : null;
  }
}
