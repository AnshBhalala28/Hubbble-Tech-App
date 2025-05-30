import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Buy%20Product/view/buy_product_view.dart';
import 'package:wavee/comman/Custom_AppBar.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/error_dialog.dart';
import '../model/add_to_cart_model.dart';
import '../provider/add_to_cart_provider.dart';

class AddToCartView extends StatefulWidget {
  String? type;
  AddToCartView({super.key, this.type});

  @override
  State<AddToCartView> createState() => _AddToCartViewState();
}

class _AddToCartViewState extends State<AddToCartView> {
  final GlobalKey<ScaffoldState> addtocartkey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isUpdateQuantity = false;

  double otherFees = 0.0;
  double deliveryFees = 0.0;
  @override
  void initState() {
    // TODO: implement initState
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
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 4.h),
              TitleBar(
                title: "My Cart",
                drawerCallback: () {
                  addtocartkey.currentState?.openDrawer();
                },
              ),
              SizedBox(height: 2.h),
              isLoading
                  ? Loader().paddingOnly(top: 30.h)
                  : cartDetailsModel?.data?.length == null ||
                      cartDetailsModel?.data?.length == 0
                  ? Center(
                    child: Text(
                      "Cart is Empty!",
                      style: TextStyle(
                        fontFamily: AppConstants.manrope,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).paddingOnly(top: 35.h)
                  : Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      itemCount: cartDetailsModel?.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = cartDetailsModel!.data![index];
                        // અહીં Null check કરવું જરૂરી છે
                        if (item.itemDetails == null) {
                          return const SizedBox(); // જો null હોય તો ખાલી widget બતાવ
                        }
                        final product = item.itemDetails!;
                        print("Type ave che ${item.type}");
                        print("Type ave che ${item.type}");
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 15.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        // ClipRRect(
                                        //   borderRadius:
                                        //       BorderRadius.circular(8),
                                        //   child: CachedNetworkImage(
                                        //     imageUrl: product.image ?? "",
                                        //     height: 15.h,
                                        //     width: 25.w,
                                        //     fit: BoxFit.cover,
                                        //     placeholder: (context, url) =>
                                        //         const Center(
                                        //             child:
                                        //                 CircularProgressIndicator(
                                        //       color: AppColors.maincolor,
                                        //     )),
                                        //     errorWidget:
                                        //         (context, url, error) =>
                                        //             Icon(Icons.error),
                                        //   ),
                                        // ),
                                        // ClipRRect(
                                        //   borderRadius:
                                        //       BorderRadius.circular(8),
                                        //   child: (product.image != null &&
                                        //           product
                                        //               .image!.isNotEmpty)
                                        //       ? CachedNetworkImage(
                                        //           imageUrl:
                                        //               product.image!,
                                        //           height: 15.h,
                                        //           width: 25.w,
                                        //           fit: BoxFit.cover,
                                        //           placeholder:
                                        //               (context, url) =>
                                        //                   const Center(
                                        //             child:
                                        //                 CircularProgressIndicator(
                                        //               color: AppColors
                                        //                   .maincolor,
                                        //             ),
                                        //           ),
                                        //           errorWidget: (context,
                                        //                   url, error) =>
                                        //               Image.asset(
                                        //             "assets/images/Wavee Applogo.png",
                                        //             height: 15.h,
                                        //             width: 25.w,
                                        //             fit: BoxFit.cover,
                                        //           ),
                                        //         )
                                        //       : Image.asset(
                                        //           "assets/images/Wavee Applogo.png",
                                        //           height: 15.h,
                                        //           width: 25.w,
                                        //           fit: BoxFit.cover,
                                        //         ),
                                        // ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                (product.image != null &&
                                                        product
                                                            .image!
                                                            .isNotEmpty)
                                                    ? product.image!
                                                    : (product.images != null &&
                                                        product
                                                            .images!
                                                            .isNotEmpty)
                                                    ? product.images!.first
                                                    : "", // fallback to empty string if no image available
                                            height: 15.h,
                                            width: 25.w,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            AppColors.maincolor,
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
                                                  width: 25.w,
                                                  fit: BoxFit.cover,
                                                ),
                                          ),
                                        ),

                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 1.h),
                                              Text(
                                                product.name ?? "",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                              SizedBox(height: 0.7.h),
                                              Text(
                                                product.description ?? "",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Text(
                                                "£${product.offerPrice ?? product.price}",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                            ],
                                          ).paddingOnly(top: 0.5.h),
                                        ),
                                        //
                                        // item.type/ item.type == == 'product'
                                        //     ?
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                size: 22.sp,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                if (item.quantity! > 1) {
                                                  setState(() {
                                                    item.quantity =
                                                        item.quantity! - 1;
                                                  });
                                                  updateQuantityApi(
                                                    item.productId!,
                                                    item.quantity!,
                                                    item.type,
                                                  );
                                                }
                                              },
                                            ),
                                            Text(
                                              "${item.quantity}",
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: AppColors.maincolor,
                                                size: 22.sp,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  item.quantity =
                                                      item.quantity! + 1;
                                                });
                                                updateQuantityApi(
                                                  item.productId!,
                                                  item.quantity!,
                                                  item.type,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        // : SizedBox(),
                                        // service માટે ખાલી જગ્યા

                                        // Row(
                                        //   children: [
                                        //     IconButton(
                                        //       icon: Icon(
                                        //         Icons
                                        //             .remove_circle_outline,
                                        //         size: 22.sp,
                                        //         color: Colors.grey,
                                        //       ),
                                        //       onPressed: () {
                                        //         if (item.quantity! > 1) {
                                        //           setState(() {
                                        //             item.quantity =
                                        //                 item.quantity! -
                                        //                     1;
                                        //           });
                                        //           updateQuantityApi(
                                        //             item.productId!,
                                        //             item.quantity!,
                                        //           );
                                        //         }
                                        //       },
                                        //     ),
                                        //     Text(
                                        //       "${item.quantity}",
                                        //       style: TextStyle(
                                        //         fontSize: 15.sp,
                                        //         fontFamily:
                                        //             AppConstants.manrope,
                                        //       ),
                                        //     ),
                                        //     IconButton(
                                        //       icon: Icon(
                                        //         Icons.add_circle_outline,
                                        //         color:
                                        //             AppColors.maincolor,
                                        //         size: 22.sp,
                                        //       ),
                                        //       onPressed: () {
                                        //         setState(() {
                                        //           item.quantity =
                                        //               item.quantity! + 1;
                                        //         });
                                        //         updateQuantityApi(
                                        //           item.productId!,
                                        //           item.quantity!,
                                        //         );
                                        //       },
                                        //     ),
                                        //   ],
                                        // )
                                      ],
                                    ),
                                    Positioned(
                                      right: 1.w,
                                      top: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          // RemoveFromCartApi(
                                          //     product?.id ?? 0);
                                          RemoveFromCartApi(
                                            item.productId ?? 0,
                                            item.type ?? "product",
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(
                                              0.15,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.all(0.8.h),
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: AppColors.redColor,
                                            size: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).marginOnly(bottom: 2.h),
                            if (index ==
                                (cartDetailsModel!.data!.length - 1)) ...[
                              // TextButton.icon(
                              //   onPressed: () {},
                              //   icon: Icon(Icons.add, color: AppColors.maincolor),
                              //   label: Text("Add Items",
                              //       style: TextStyle(color: AppColors.maincolor)),
                              // ),
                              Divider(height: 4.h),
                              Text(
                                "Cart summary",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              summaryTile(
                                "Subtotal",
                                getSubtotal().toStringAsFixed(2),
                              ),

                              Divider(height: 3.h),
                              summaryTile(
                                "Total cost",
                                (getSubtotal() + otherFees + deliveryFees)
                                    .toStringAsFixed(2),
                                isTotal: true,
                              ),
                              SizedBox(height: 4.h),
                              // batan(
                              //   title: "Checkout",
                              //   route: () {
                              //     Get.to(BuyProductView());
                              //   },
                              //   color: AppColors.maincolor,
                              //   fontcolor: Colors.white,
                              //   height: 5.5.h,
                              //   fontsize: 17.sp,
                              //   width: double.infinity,
                              //   radius: 12.0,
                              //   iconData1: Icons.add_shopping_cart_outlined,
                              // ),
                              GestureDetector(
                                onTap: () {
                                  // submitBooking();
                                  Get.to(BuyProductView(type: item.type));
                                },
                                child: Container(
                                  height: 5.5.h,
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.maincolor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Checkout",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: AppColors.white,
                                          fontFamily: AppConstants.manrope,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Container(
                                        height: 5.h,
                                        width: 4.h,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.white,
                                          ),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Transform.translate(
                                              offset: Offset(
                                                -4,
                                                0,
                                              ), // Left shifted
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 14.sp,
                                              ),
                                            ),
                                            Transform.translate(
                                              offset: Offset(
                                                4,
                                                0,
                                              ), // Right shifted
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 14.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
            ],
          ).paddingOnly(left: 2.w, right: 2.w),
          if (isUpdateQuantity)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: Loader()),
            ),
        ],
      ),
    );
  }

  Widget summaryTile(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
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

  void updateQuantityApi(int productId, int quantity, type) {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "product_id": productId.toString(),
      "quantity": quantity.toString(),
      "type": type.toString(),
    };
    setState(() {
      isUpdateQuantity = true;
    });
    log("Sending quantity update: $data");

    checkInternet().then((internet) async {
      if (internet) {
        CartProvider().UpdateCartQuantity(data).then((response) async {
          if (response.statusCode == 200) {
            log("Quantity updated successfully: ${response.body}");
            setState(() {
              isUpdateQuantity = false;
            });
            // GetCartDetailApi();
          } else {
            setState(() {
              isUpdateQuantity = false;
            });
            log("Error updating quantity");
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

  // void RemoveFromCartApi(int productId,) {
  //   setState(() {
  //     isUpdateQuantity = true;
  //   });
  //
  //   final Map<String, String> data = {
  //     "user_id": loginModel?.data?.user?.id.toString() ?? "",
  //     "product_id": productId.toString(),
  //   };
  //
  //   log("Sending quantity update: $data");
  //
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       CartProvider().RemoveFromCartApi(data).then((response) async {
  //         if (response.statusCode == 200) {
  //           log("Quantity updated successfully: ${response.body}");
  //           setState(() {
  //             isUpdateQuantity = false;
  //           });
  //           GetCartDetailApi();
  //         } else {
  //           setState(() {
  //             isUpdateQuantity = false;
  //           });
  //           log("Error updating quantity");
  //         }
  //       });
  //     } else {
  //       setState(() {
  //         isUpdateQuantity = false;
  //       });
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }

  void RemoveFromCartApi(int productId, String type) {
    setState(() {
      isUpdateQuantity = true;
    });

    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "product_id": productId.toString(),
      "type": type,
    };

    log("Sending remove request: $data");

    checkInternet().then((internet) async {
      if (internet) {
        CartProvider().RemoveFromCartApi(data).then((response) async {
          if (response.statusCode == 200) {
            log("Item removed successfully: ${response.body}");
            setState(() {
              isUpdateQuantity = false;
            });
            GetCartDetailApi(); // refresh cart
          } else {
            setState(() {
              isUpdateQuantity = false;
            });
            log("Error removing item from cart");
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
}
