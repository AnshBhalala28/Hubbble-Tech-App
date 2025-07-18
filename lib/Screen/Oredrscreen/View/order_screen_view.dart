import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/comman/loader.dart';

import '../../../comman/SideMenu.dart';
import '../../../comman/bottom_bar.dart';
import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../../ViewProfile/View/viewprofile.dart';
import '../Model/order_screen_model.dart';
import '../Model/service_view_model.dart';
import '../Provider/order_screen_provider.dart';
import 'orderdetailscreen.dart';

class Order_Screen extends StatefulWidget {
  int? selected;

  Order_Screen({super.key, this.selected});

  @override
  State<Order_Screen> createState() => _Order_ScreenState();
}

class _Order_ScreenState extends State<Order_Screen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyorder = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isLoading1 = false;
  int selectedCategory = 0;
  List<String> categories = [
    'All',
    'Pending Approval',
    'Packing Your Bag',
    'Ready for Collection',
    'Collected',
    'Declined',
  ];
  List<String> serviceCategories = [
    'All',
    'Pending Approval',
    "Booking Confirmed",
    "Cancelled",
  ];
  Offset _cartButtonPosition = Offset.zero;
  int cartCount = cartDetailsModel?.data?.length ?? 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    OrderListViewApi(selectedType);
  }

  String selectedType = "products";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(),
      key: _scaffoldKeyorder,
      backgroundColor: AppColors.bgcolor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                children: [
                  SizedBox(height: 4.h),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            _scaffoldKeyorder.currentState?.openDrawer();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 0.4.h,
                                  width: 6.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.maincolor,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 0.5.h),
                                  height: 0.4.h,
                                  width: 8.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.maincolor,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                Container(
                                  height: 0.4.h,
                                  width: 6.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.maincolor,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          "My Orders",
                          style: TextStyle(
                            fontFamily: AppConstants.manrope,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  ViewProfile(id: loginModel?.data?.user?.id),
                                );
                              },
                              child: Container(
                                height: 11.w,
                                width: 11.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 5.w,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage:
                                      (profileModel?.data?.user?.profile !=
                                                  null &&
                                              profileModel!
                                                  .data!
                                                  .user!
                                                  .profile!
                                                  .isNotEmpty)
                                          ? CachedNetworkImageProvider(
                                            profileModel!.data!.user!.profile!,
                                          )
                                          : AssetImage(
                                                "assets/images/waveeLogoShort.png",
                                              )
                                              as ImageProvider,
                                ),
                              ).paddingOnly(right: 2.w),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      SizedBox(width: 3.w),
                      Row(
                        children: [
                          Text(
                            "Filter Orders By",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 17.sp,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      SizedBox(width: 15.w),
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 4.5.h,
                          width: 32.w,
                          decoration: BoxDecoration(
                            color: AppColors.maincolor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: PopupMenuButton<String>(
                            onSelected: (value) {
                              setState(() {
                                selectedType = value;
                              });
                              print("Selected: $value");
                              OrderListViewApi(selectedType.camelCase);
                            },
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            offset: Offset(0, 45),
                            itemBuilder:
                                (BuildContext context) => [
                                  PopupMenuItem(
                                    value: "products",
                                    child: Text(
                                      "Products",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: "services",
                                    child: Text(
                                      "Services",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                ],
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    selectedType.toString().capitalizeFirst ??
                                        "",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Icon(
                                    CupertinoIcons.chevron_down,
                                    color: Colors.white,
                                    size: 15.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(bottom: 2.h),
                  selectedType == "services"
                      ? SizedBox(
                        height: 5.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: serviceCategories.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                if (selectedCategory != index) {
                                  setState(() {
                                    selectedCategory = index;
                                    isLoading = true;
                                  });
                                  OrderListViewApi(selectedType);
                                }
                              },
                              child: Container(
                                height: 6.h,
                                padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 7.w,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 0.5,
                                    color: Colors.grey,
                                  ),
                                  color:
                                      selectedCategory == index
                                          ? AppColors.maincolor
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                child: Text(
                                  serviceCategories[index],
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color:
                                        selectedCategory == index
                                            ? Colors.white
                                            : Colors.black,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : SizedBox(
                        height: 5.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                if (selectedCategory != index) {
                                  setState(() {
                                    selectedCategory = index;
                                    isLoading = true;
                                  });
                                  OrderListViewApi(selectedType);
                                }
                              },
                              child: Container(
                                height: 6.h,
                                padding: EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 7.w,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 0.5,
                                    color: Colors.grey,
                                  ),
                                  color:
                                      selectedCategory == index
                                          ? AppColors.maincolor
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 2.w),
                                child: Text(
                                  categories[index],
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color:
                                        selectedCategory == index
                                            ? Colors.white
                                            : Colors.black,
                                    fontFamily: AppConstants.manrope,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  SizedBox(height: 2.h),
                  isLoading
                      ? Loader().paddingOnly(top: 30.h)
                      : (myOrderModel?.data?.isNotEmpty != true ||
                          myOrderModel!.data![0].orderProducts?.isNotEmpty !=
                              true)
                      ? Text(
                        "No Orders Found",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          fontFamily: AppConstants.manrope,
                        ),
                      ).paddingOnly(top: 30.h)
                      : myOrderModel!.data![0].orderProducts![0].type ==
                          'service'
                      ? (serviceViewModel?.data == null ||
                              serviceViewModel!.data!.isEmpty)
                          ? Text(
                            "No Service Orders",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.sp,
                              fontFamily: AppConstants.manrope,
                            ),
                          ).paddingOnly(top: 30.h)
                          : isLoading1
                          ? Loader().paddingOnly(top: 30.h)
                          : Column(
                            children: [
                              Container(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  itemCount: myOrderModel?.data?.length ?? 0,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    final order =
                                        serviceViewModel?.data?[index];
                                    final orderProduct =
                                        order?.orderProducts?.isNotEmpty == true
                                            ? order!.orderProducts!.first
                                            : null;

                                    String status = order?.status ?? "";
                                    Color statusColor = getStatusColor(status);

                                    return GestureDetector(
                                      onTap: () {
                                        if (order != null &&
                                            orderProduct != null) {
                                          Get.to(
                                            Orderdetail_Screen(
                                              orderid:
                                                  order.id?.toString() ?? "",
                                              orderProductID:
                                                  orderProduct.id?.toString() ??
                                                  "",
                                            ),
                                          );
                                          log(
                                            'Order Product ID: ${orderProduct.id}',
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.shade100,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 7,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 15.h,
                                                        width: 30.w,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: CachedNetworkImage(
                                                            imageUrl:
                                                                orderProduct
                                                                    ?.service
                                                                    ?.images ??
                                                                "",
                                                            fit: BoxFit.cover,
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                            errorWidget:
                                                                (
                                                                  context,
                                                                  url,
                                                                  error,
                                                                ) => Image(
                                                                  image: AssetImage(
                                                                    "assets/images/waveeLogoShort.png",
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 1.h),
                                                      Container(
                                                        height: 15.h,
                                                        width: 55.w,
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .pending_rounded,
                                                                  color:
                                                                      getStatusColor(
                                                                        status,
                                                                      ),
                                                                  size: 18.sp,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  status.capitalize ??
                                                                      "",
                                                                  style: TextStyle(
                                                                    color:
                                                                        getStatusColor(
                                                                          status,
                                                                        ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                orderProduct
                                                                        ?.service
                                                                        ?.title
                                                                        ?.capitalizeFirst ??
                                                                    "",
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 0.5.h,
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                '#ORDERNO${order?.orderNo ?? ""}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 0.5.h,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "£${orderProduct?.totalPrice ?? ""}",
                                                                  style: const TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Text(
                                                                  formatDate(
                                                                    orderProduct
                                                                            ?.createdAt ??
                                                                        "",
                                                                  ),
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                      : isLoading1
                      ? Loader().paddingOnly(top: 30.h)
                      : Column(
                        children: [
                          Container(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 8.0),
                              itemCount: myOrderModel?.data?.length ?? 0,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                final order = myOrderModel?.data?[index];
                                final orderProduct =
                                    order?.orderProducts?.isNotEmpty == true
                                        ? order!.orderProducts!.first
                                        : null;

                                String status = order?.status ?? "";
                                Color statusColor = getStatusColor(status);

                                return GestureDetector(
                                  onTap: () {
                                    if (order != null && orderProduct != null) {
                                      Get.to(
                                        Orderdetail_Screen(
                                          orderid: order.id?.toString() ?? "",
                                          orderProductID:
                                              orderProduct.id?.toString() ?? "",
                                        ),
                                      );
                                      log(
                                        'OrderProduct ID: ${orderProduct.id}',
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey.shade100,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 7),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 15.h,
                                                    width: 30.w,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            orderProduct
                                                                ?.product
                                                                ?.image ??
                                                            "",
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => Image(
                                                              image: AssetImage(
                                                                "assets/images/waveeLogoShort.png",
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 1.h),
                                                  Container(
                                                    height: 15.h,
                                                    width: 55.w,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .pending_rounded,
                                                              color:
                                                                  statusColor,
                                                              size: 18.sp,
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                              status.capitalize ??
                                                                  "",
                                                              style: TextStyle(
                                                                color:
                                                                    statusColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    AppConstants
                                                                        .manrope,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: SizedBox(
                                                            width: 60.w,
                                                            child: Text(
                                                              orderProduct
                                                                      ?.product
                                                                      ?.name
                                                                      ?.capitalizeFirst ??
                                                                  "",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    AppConstants
                                                                        .manrope,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 0.5.h),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            '#ORDERNO${order?.orderNo ?? ""}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 0.5.h),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "£${orderProduct?.totalPrice ?? ""}",
                                                              style: const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    AppConstants
                                                                        .manrope,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              formatDate(
                                                                orderProduct
                                                                        ?.createdAt ??
                                                                    "",
                                                              ),
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontFamily:
                                                                    AppConstants
                                                                        .manrope,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Bottom_bar(selected: 5),
    );
  }

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "N/A";
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat("dd-MM-yyyy").format(parsedDate);
    } catch (e) {
      return "N/A";
    }
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
      case "declined":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusFromTab(int index) {
    switch (index) {
      case 1:
        return "Pending Approval";
      case 2:
        return "Packing Your Bag";
      case 3:
        return "Ready for Collection";
      case 4:
        return "Collected";
      case 5:
        return "Declined";
      default:
        return "";
    }
  }

  String getStatusFromServiceTab(int index) {
    switch (index) {
      case 1:
        return "Pending Approval";
      case 2:
        return "Booking Confirmed";
      case 3:
        return "Cancelled";
      default:
        return "";
    }
  }

  OrderListViewApi(type) {
    String status =
        selectedType == "services"
            ? getStatusFromServiceTab(selectedCategory)
            : getStatusFromTab(selectedCategory);
    log("TYPE$type");
    setState(() {
      isLoading1 = true;
    });
    checkInternet().then((internet) async {
      if (internet) {
        OrderProvider()
            .orderListApi(
              loginModel?.data?.user?.id.toString() ?? "",
              status,
              type,
            )
            .then((response) async {
              myOrderModel = MyOrderModel.fromJson(response.data);
              serviceViewModel = ServiceViewModel.fromJson(response.data);
              if (response.statusCode == 200) {
                setState(() {
                  isLoading = false;
                  isLoading1 = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                  isLoading1 = false;
                });
                log("Error");
              }
            });
      } else {
        setState(() {
          isLoading = false;
          isLoading1 = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
