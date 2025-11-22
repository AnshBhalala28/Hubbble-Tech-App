import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/bottomBar.dart';
import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../../../Utils/productDisable.dart';
import '../../CartScreen/provider/addToCartProvider.dart';
import '../../CartScreen/view/cartViewScreen.dart';
import '../../Category/view/categoryScreen.dart';
import '../../CommunityScreen/Provider/communityProvider.dart';
import '../../CommunityScreen/modal/BusnessViewModal.dart';
import '../../CommunityScreen/modal/businesslikemodel.dart';
import '../../messageScreen/View/messageScreen.dart';
import '../../productDetailPage/provider/productProvider.dart';
import '../../productDetailPage/view/productDetailPage.dart';
import '../Provider/communityDetailProvider.dart';
import '../modal/category_modal.dart';
import 'productSearchScreen.dart';

class BusinessDetailPage extends StatefulWidget {
  String? userID;
  String? businessID;
  String? lat;
  String? long;

  BusinessDetailPage({
    super.key,
    this.businessID,
    this.userID,
    this.lat,
    this.long,
  });

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  bool isLoading = false;
  bool isSending = false;
  bool isAddtoCart = false;

  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  List<String> options = [];

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    super.initState();
    BussinessViewProfile();

    CategoryAPI();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.offset > 200 && !_showTitle) {
          setState(() {
            _showTitle = true;
          });
        } else if (_scrollController.offset <= 200 && _showTitle) {
          setState(() {
            _showTitle = false;
          });
        }
      }
    });
  }

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String getTodayKey() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String? selectedOption;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final todayKey = getTodayKey();

    final openingHours =
        busnessviewmodal?.data?.business?.openingHours?.toJson();
    final todayHours = openingHours?[todayKey];

    final isClosedToday = todayHours?['closed'] ?? true;
    final closeTime = !isClosedToday ? (todayHours?['close'] ?? '') : '';
    final business = busnessviewmodal?.data?.business;
    return Scaffold(
      backgroundColor: AppColors.white,
      body:
          isLoading
              ? Loader()
              : Column(
                children: [
                  SizedBox(height: 10.h),
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
                          SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: [
                                // Header Section
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => Get.back(),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Container(
                                              height: 28,
                                              width: 28,
                                              decoration: const BoxDecoration(),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.arrow_back,
                                                color: AppColors.maincolor,
                                                size: 20.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 2.w),
                                          SizedBox(
                                            width: 70.w,
                                            child: Text(
                                              business?.businessName ?? "",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20.sp,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      _iconCircle(
                                        icon: Icons.share,
                                        color: AppColors.maincolor,
                                        onTap: () async {
                                          String businessName =
                                              busnessviewmodal
                                                  ?.data
                                                  ?.business
                                                  ?.businessName ??
                                              "Our Business";
                                          String imageUrl =
                                              busnessviewmodal
                                                  ?.data
                                                  ?.business
                                                  ?.logo ??
                                              "";
                                          String userId = widget.userID ?? "";
                                          String businessId =
                                              widget.businessID ?? "";
                                          String longitude =
                                              widget.long?.toString() ?? "0.0";
                                          String latitude =
                                              widget.lat?.toString() ?? "0.0";

                                          String businessUrl =
                                              "https://portal.wavee.ai/api/businessProfile/$userId/$businessId?longitude=$longitude&latitude=$latitude";
                                          String shareText =
                                              "Check out $businessName on our app!\n$businessUrl";

                                          try {
                                            if (imageUrl.isEmpty) {
                                              throw Exception(
                                                "Image URL is empty",
                                              );
                                            }

                                            final response = await http.get(
                                              Uri.parse(imageUrl),
                                            );
                                            if (response.statusCode != 200) {
                                              throw Exception(
                                                "Image download failed",
                                              );
                                            }

                                            final bytes = response.bodyBytes;

                                            final tempDir =
                                                await getTemporaryDirectory();
                                            final file =
                                                await File(
                                                  '${tempDir.path}/shared_business.jpg',
                                                ).create();
                                            await file.writeAsBytes(bytes);

                                            await Share.shareXFiles(
                                              [XFile(file.path)],
                                              text: shareText,
                                              subject: "Share Business",
                                            );
                                          } catch (e) {
                                            Get.snackbar(
                                              "Error",
                                              "Could not share business details.",
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),

                                // Divider line
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20.w,
                                        height: 0.5.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),

                                // Search Bar
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                  ),
                                  height: 5.h,
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xffc7c7c7),
                                    ),
                                  ),
                                  child: TextField(
                                    onTap: () {
                                      Get.to(
                                        SearchScreen(
                                          businessID: widget.businessID,
                                          addStatus:
                                              busnessviewmodal
                                                  ?.data
                                                  ?.business
                                                  ?.productStatus,
                                        ),
                                      );
                                    },
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      hintText: "Search Products or services",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      suffixIcon:
                                          searchController.text.isNotEmpty
                                              ? IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Colors.grey[600],
                                                  size: 18,
                                                ),
                                                onPressed: () {
                                                  searchController.clear();
                                                  setState(() {});
                                                },
                                              )
                                              : null,
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                SizedBox(height: 1.h),

                                // All Products Title
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "All Products",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19.sp,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: AppConstants.manropeBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),

                                // Category Dropdown
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 5.h,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButton<String>(
                                          dropdownColor: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          hint: Text(
                                            "Select option",
                                            style: TextStyle(
                                              fontFamily: AppConstants.manrope,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          underline: Container(),
                                          value: selectedOption,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                          ),
                                          items:
                                              categoryOptions
                                                  .map(
                                                    (item) => DropdownMenuItem(
                                                      value: item['name'],
                                                      child: Text(
                                                        item['name'] ?? "",
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedOption = value;
                                              selectedCategoryId =
                                                  categoryOptions.firstWhere(
                                                    (item) =>
                                                        item['name'] == value,
                                                  )['id'];
                                              Get.to(
                                                CategoryScreen(
                                                  categoryID:
                                                      selectedCategoryId,
                                                  businessID: widget.businessID,
                                                  CategoryName: selectedOption,
                                                ),
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),

                                // Products Grid
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  child: GridView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount:
                                        busnessviewmodal
                                            ?.data
                                            ?.products
                                            ?.length ??
                                        0,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 0.70,
                                          crossAxisSpacing: 3.w,
                                          mainAxisSpacing: 2.h,
                                        ),
                                    itemBuilder: (context, index) {
                                      final product =
                                          busnessviewmodal!
                                              .data!
                                              .products![index];
                                      return GestureDetector(
                                        onTap: () {
                                          Get.to(
                                            ProductDetailPage(
                                              type: "product",
                                              productID:
                                                  product.id.toString() ?? "",
                                            ),
                                          );
                                        },
                                        child: Material(
                                          elevation: 2,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Container(
                                            height: 25.h,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xffc7c7c7),
                                                width: 1,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(12),
                                                      ),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        product.image
                                                            ?.toString() ??
                                                        "",
                                                    height: 28.h,
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
                                                          fit: BoxFit.contain,
                                                        ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0.h,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 2.w,
                                                          vertical: 1.h,
                                                        ),
                                                    width: 29.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        width: 1,
                                                        color: const Color(
                                                          0xffc7c7c7,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                  10,
                                                                ),
                                                            topLeft:
                                                                Radius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
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
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manropeBold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          product.productCategoryName ??
                                                              "Product Category",
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                            color: const Color(
                                                              0xffa1a1a1,
                                                            ),
                                                          ),
                                                        ),
                                                        (product.offerPrice !=
                                                                    null &&
                                                                product.offerPrice !=
                                                                    "0.00" &&
                                                                product.offerPrice !=
                                                                    product
                                                                        .price)
                                                            ? Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
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
                                                            )
                                                            : Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  "£${product.price ?? ""}",
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
                                                        product.quantity == 0 ||
                                                                product.quantity ==
                                                                    null
                                                            ? Text(
                                                              "Out of Stock",
                                                              style: TextStyle(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    AppConstants
                                                                        .manrope,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            )
                                                            : const SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0.5.h,
                                                  right: 2,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      bool isBlocked =
                                                          product.quantity ==
                                                              0 ||
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
                                                                final itemtype =
                                                                    cartDetailsModel!
                                                                        .data![i]
                                                                        .itemDetails
                                                                        ?.type;
                                                                if (itemId !=
                                                                    null) {
                                                                  await RemoveFromCartApi(
                                                                    itemId,
                                                                    itemtype
                                                                        .toString(),
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
                                                          product.id
                                                                  .toString() ??
                                                              "",
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 7.w,
                                                      height: 7.w,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                        shape:
                                                            BoxShape.rectangle,
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black26,
                                                            blurRadius: 4,
                                                            offset: Offset(
                                                              0,
                                                              2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        product.quantity == "0"
                                                            ? Icons.block
                                                            : Icons.add,
                                                        size: 17.sp,
                                                        color:
                                                            product.quantity ==
                                                                    "0"
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
                                  ),
                                ),
                                SizedBox(height: 50.h),
                              ],
                            ),
                          ),

                          // Draggable Bottom Sheet
                          Positioned(
                            top: 11.h,
                            left: 0,
                            right: 0,
                            bottom: 0.h,
                            child: DraggableScrollableSheet(
                              initialChildSize: 0.50,
                              minChildSize: 0.50,
                              builder: (context, scrollController) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(45),
                                      topLeft: Radius.circular(45),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xffc7c7c7),
                                      width: 1,
                                    ),
                                    color: const Color(0xfff2f2f2),
                                  ),
                                  child: SingleChildScrollView(
                                    controller: scrollController,
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            height: 1.h,
                                            width: 20.w,
                                            decoration: BoxDecoration(
                                              color: const Color(0xf0D9D9D9),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ).paddingOnly(top: 2.h, bottom: 2.h),
                                        ),
                                        Text(
                                          "About ${business?.businessName ?? ""}",
                                          style: TextStyle(
                                            fontSize: 19.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontFamily: AppConstants.manropeBold,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Container(
                                          width: 20.w,
                                          height: 0.5.h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Material(
                                                  elevation: 1,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 3.w,
                                                          vertical: 1.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_history,
                                                          size: 18.sp,
                                                          color:
                                                              AppColors
                                                                  .maincolor,
                                                        ),
                                                        SizedBox(width: 2.w),
                                                        Text(
                                                          "${(busnessviewmodal?.data?.distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                Material(
                                                  elevation: 1,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 3.w,
                                                          vertical: 1.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.timer,
                                                          size: 18.sp,
                                                          color:
                                                              AppColors
                                                                  .maincolor,
                                                        ),
                                                        SizedBox(width: 2.w),
                                                        Text(
                                                          closeTime.isNotEmpty
                                                              ? "Closes at $closeTime"
                                                              : "Closed today",
                                                          style: TextStyle(
                                                            fontSize: 14.6.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                AppConstants
                                                                    .manrope,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              width: 92.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ReadMoreText(
                                                "${busnessviewmodal?.data?.business?.description == null || busnessviewmodal?.data?.business?.description == "" ? "N/A" : busnessviewmodal?.data?.business?.description}",
                                                trimLines: 4,
                                                trimLength: 145,
                                                colorClickableText:
                                                    AppColors.maincolor,
                                                trimMode: TrimMode.Length,
                                                trimCollapsedText: ' Show more',
                                                trimExpandedText: ' Show less',
                                                moreStyle: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  letterSpacing: 1,
                                                  color: AppColors.maincolor,
                                                ),
                                                lessStyle: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                  color: AppColors.maincolor,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(
                                                      MessageScreen(
                                                        type: "business",
                                                        chatName:
                                                            busnessviewmodal
                                                                ?.data
                                                                ?.business
                                                                ?.businessName ??
                                                            "N/A",
                                                        conciergeID:
                                                            (busnessviewmodal
                                                                    ?.data
                                                                    ?.business
                                                                    ?.user
                                                                    ?.id)
                                                                .toString(),
                                                        image:
                                                            busnessviewmodal
                                                                ?.data
                                                                ?.business
                                                                ?.logo ??
                                                            "",
                                                        chatStatus:
                                                            busnessviewmodal
                                                                ?.data
                                                                ?.business
                                                                ?.chatStatus,
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 2.w,
                                                          vertical: 0.5.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xffc0c0c0,
                                                        ),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Live Chat",
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.id !=
                                                        null) {
                                                      await handleLikeTap();
                                                    } else {}
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 2.w,
                                                          vertical: 0.4.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xffc0c0c0,
                                                        ),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      busnessviewmodal
                                                                  ?.data
                                                                  ?.isLiked ==
                                                              true
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_outline,
                                                      color:
                                                          busnessviewmodal
                                                                      ?.data
                                                                      ?.isLiked ==
                                                                  true
                                                              ? Colors.red
                                                              : Colors.black,
                                                      size: 18.sp,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isSending)
                            Container(child: Center(child: Loader())),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: const BottomBar(selected: 0),
    );
  }

  // Rest of your methods remain the same...
  handleLikeTap() {
    bool isCurrentlyLiked = busnessviewmodal?.data?.isLiked ?? false;
    String newLikeStatus = isCurrentlyLiked ? "0" : "1";
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (busnessviewmodal?.data?.business?.id).toString(),
      'is_like': newLikeStatus,
    };

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .businessLikeApi(data)
            .then((response) async {
              if (response.statusCode == 200) {
                bussinesslikemodel = BussinessLikeModel.fromJson(response.data);

                setState(() {
                  isSending = false;
                });
                await Future.delayed(const Duration(milliseconds: 100));
                BussinessViewProfile();
              } else if (response.statusCode == 429) {
                setState(() {
                  isSending = false;
                });
              } else {}
            })
            .catchError((error, stackTrace) {});
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Widget _iconCircle({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 10.w,
        width: 10.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  BussinessViewProfile() {
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .businessProfileViewApi(
              widget.businessID.toString(),
              widget.lat,
              widget.long,
            )
            .then((response) async {
              busnessviewmodal = BusnessViewModal.fromJson(response.data);
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

  List<Map<String, String>> categoryOptions = [];

  String? selectedCategoryId;

  CategoryAPI() {
    checkInternet().then((internet) async {
      if (internet) {
        CommunityDetailProvider()
            .categoryViewApi(widget.businessID.toString())
            .then((response) async {
              categoryModal = CategoryModal.fromJson(response.data);
              if (response.statusCode == 200) {
                if (categoryModal?.data != null) {
                  for (int i = 0; i < categoryModal!.data!.length; i++) {
                    final name = categoryModal?.data![i].name;
                    final id = categoryModal?.data![i].id?.toString() ?? "";

                    if (name != null && name.isNotEmpty) {
                      categoryOptions.add({'name': name, 'id': id});
                    }
                  }
                }
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

  BusinessLikeApi() {
    bool isCurrentlyLiked = busnessviewmodal?.data?.isLiked ?? false;
    String newLikeStatus = isCurrentlyLiked ? "0" : "1";
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': widget.businessID ?? "",
      'is_like': newLikeStatus,
    };
    setState(() {
      isAddtoCart = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().businessLikeApi(data).then((response) async {
          bussinesslikemodel = BussinessLikeModel.fromJson(response.data);
          if (response.statusCode == 200) {
            setState(() {
              isAddtoCart = false;
            });
            // BussinessViewProfile();
          } else if (response.statusCode == 422) {
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
