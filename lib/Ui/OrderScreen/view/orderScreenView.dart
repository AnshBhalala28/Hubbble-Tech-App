import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/customAppBar.dart';
import '../../../Utils/errorDialog.dart';
import '../../../Utils/loader.dart';
import '../Provider/orderProvider.dart';
import '../modal/order_screen_model.dart';
import '../modal/service_view_model.dart';
import 'orderDetailsScreen.dart';

class Order_Screen extends StatefulWidget {
  int? selected;

  Order_Screen({super.key, this.selected});

  @override
  State<Order_Screen> createState() => _Order_ScreenState();
}

class _Order_ScreenState extends State<Order_Screen> {
  final GlobalKey<ScaffoldState> _scaffoldKeyorder = GlobalKey<ScaffoldState>();

  // --- Pagination State Variables ---
  final ScrollController _scrollController = ScrollController();

  // Common loading flag for initial (page 1) loads
  bool isLoading = false;

  // State for Product Pagination
  MyOrderModel? myOrderModel;
  int productPage = 1;
  bool productHasNextPage = true;
  bool isLoadMoreProducts = false;

  // State for Service Pagination
  ServiceViewModel? serviceViewModel;
  int servicePage = 1;
  bool serviceHasNextPage = true;
  bool isLoadMoreServices = false;

  // --- End Pagination State Variables ---

  int selectedCategory = 0;
  List<String> categories = [
    'All',
    'Pending Approval',
    'Packing Your Bag',
    'Ready for Collection',
    'Collected',
    'Declined',
    'Cancelled',
  ];
  List<String> serviceCategories = [
    'All',
    'Pending Approval',
    "Booking Confirmed",
  ];

  String selectedType = "products";

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });

    // Load initial data for the default type (products)
    OrderListViewApi(selectedType, productPage);

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // --- Scroll Listener for Pagination ---
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User has reached the end of the list
      if (selectedType == "products") {
        if (productHasNextPage && !isLoadMoreProducts) {
          setState(() {
            isLoadMoreProducts = true;
            productPage++;
          });
          OrderListViewApi(selectedType, productPage);
        }
      } else {
        // Services
        if (serviceHasNextPage && !isLoadMoreServices) {
          setState(() {
            isLoadMoreServices = true;
            servicePage++;
          });
          OrderListViewApi1(selectedType, servicePage);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Column(
              children: [
                SizedBox(height: 6.h),
                TitleBar(title: "My Order", drawerCallback: () {}),
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
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppConstants.manropeBold,
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
                    const Spacer(),
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
                            if (selectedType == value) return; // No change

                            setState(() {
                              selectedType = value;
                              selectedCategory = 0; // Reset tabs
                              isLoading = true; // Show main loader
                              myOrderModel = null; // Clear old data
                              serviceViewModel = null; // Clear old data
                            });

                            // Reset pagination and fetch page 1 for the new type
                            if (value == "products") {
                              productPage = 1;
                              productHasNextPage = true;
                              OrderListViewApi(value, productPage);
                            } else {
                              servicePage = 1;
                              serviceHasNextPage = true;
                              OrderListViewApi1(value, servicePage);
                            }
                          },
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          offset: const Offset(0, 45),
                          itemBuilder:
                              (BuildContext context) => [
                                PopupMenuItem(
                                  value: "products",
                                  child: Text(
                                    "Products",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
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
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ),
                              ],
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedType.toString().capitalizeFirst ?? "",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppConstants.manropeBold,
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
                          return GestureDetector(
                            onTap: () {
                              if (selectedCategory != index) {
                                setState(() {
                                  selectedCategory = index;
                                  isLoading = true; // Show main loader
                                  serviceViewModel = null; // Clear old data
                                });
                                // Reset pagination and fetch page 1
                                servicePage = 1;
                                serviceHasNextPage = true;
                                OrderListViewApi1(selectedType, servicePage);
                              }
                            },
                            child: Container(
                              height: 5.h,
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
                                  fontSize: 16.sp,
                                  color:
                                      selectedCategory == index
                                          ? Colors.white
                                          : Colors.black,
                                  fontFamily:
                                      selectedCategory == index
                                          ? AppConstants.manropeBold
                                          : AppConstants.manrope,
                                  fontWeight: FontWeight.w500,
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
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (selectedCategory != index) {
                                setState(() {
                                  selectedCategory = index;
                                  isLoading = true; // Show main loader
                                  myOrderModel = null; // Clear old data
                                });
                                // Reset pagination and fetch page 1
                                productPage = 1;
                                productHasNextPage = true;
                                OrderListViewApi(selectedType, productPage);
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
                                  fontSize: 16.sp,
                                  color:
                                      selectedCategory == index
                                          ? Colors.white
                                          : Colors.black,
                                  fontFamily:
                                      selectedCategory == index
                                          ? AppConstants.manropeBold
                                          : AppConstants.manrope,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                SizedBox(height: 2.h),
                // --- Updated Expanded Section ---
                Expanded(
                  child:
                      isLoading
                          ? Loader().paddingOnly(top: 30.h)
                          : selectedType == "services"
                          ? _buildServiceList()
                          : _buildProductList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builder for Product List ---
  Widget _buildProductList() {
    // Check for empty list (after initial load)
    if (myOrderModel?.data?.data?.isEmpty ?? true) {
      return Text(
        "No Orders Found",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17.sp,
          fontFamily: AppConstants.manrope,
        ),
      ).paddingOnly(top: 30.h);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
      // Add 1 to the item count for the loading indicator
      itemCount:
          (myOrderModel?.data?.data?.length ?? 0) +
          (isLoadMoreProducts ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        // If this is the last item, show the loader
        if (index == (myOrderModel?.data?.data?.length ?? 0)) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // --- Build the regular order item ---
        final order = myOrderModel?.data?.data?[index];
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
                  orderProductID: orderProduct.id?.toString() ?? "",
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade100, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.only(bottom: 7),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 15.h,
                            width: 30.w,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: orderProduct?.product?.image ?? "",
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) => const Image(
                                      image: AssetImage(
                                        "assets/images/waveeLogoShort.png",
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(width: 1.h),
                          SizedBox(
                            height: 15.h,
                            width: 55.w,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pending_rounded,
                                      color: statusColor,
                                      size: 18.sp,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      status.capitalize ?? "",
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: SizedBox(
                                    width: 60.w,
                                    child: Text(
                                      orderProduct
                                              ?.product
                                              ?.name
                                              ?.capitalizeFirst ??
                                          "",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '#ORDERNO${order?.orderNo ?? ""}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    Text(
                                      "£${orderProduct?.totalPrice ?? ""}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      formatDate(
                                        orderProduct?.createdAt ?? "",
                                      ), // Using your format function
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: AppConstants.manrope,
                                        fontWeight: FontWeight.bold,
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
    );
  }

  // --- Widget Builder for Service List ---
  Widget _buildServiceList() {
    // Check for empty list (after initial load)
    if (serviceViewModel?.data?.data?.isEmpty ?? true) {
      return Text(
        "No Service Orders",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17.sp,
          fontFamily: AppConstants.manrope,
        ),
      ).paddingOnly(top: 30.h);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
      // Add 1 to the item count for the loading indicator
      itemCount:
          (serviceViewModel?.data?.data?.length ?? 0) +
          (isLoadMoreServices ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        // If this is the last item, show the loader
        if (index == (serviceViewModel?.data?.data?.length ?? 0)) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // --- Build the regular service item ---
        final order = serviceViewModel?.data?.data?[index];
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
                  orderProductID: orderProduct.id?.toString() ?? "",
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade100, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.only(bottom: 7),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 15.h,
                            width: 30.w,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: orderProduct?.service?.images ?? "",
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) => const Image(
                                      image: AssetImage(
                                        "assets/images/waveeLogoShort.png",
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          SizedBox(width: 1.h),
                          SizedBox(
                            height: 15.h,
                            width: 55.w,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pending_rounded,
                                      color: getStatusColor(status),
                                      size: 18.sp,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      status.capitalize ?? "",
                                      style: TextStyle(
                                        color: getStatusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    orderProduct
                                            ?.service
                                            ?.title
                                            ?.capitalizeFirst ??
                                        "",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manropeBold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '#ORDERNO${order?.orderNo ?? ""}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    Text(
                                      "£${orderProduct?.totalPrice ?? ""}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      formatDate(
                                        orderProduct?.createdAt ?? "",
                                      ), // Using your format function
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: AppConstants.manrope,
                                        fontWeight: FontWeight.bold,
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
      case "declined" || "cancelled":
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
      case 6:
        return "Cancelled";
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

  // --- Updated API Call for Products ---
  OrderListViewApi(type, int page) {
    String status =
        selectedType == "services"
            ? getStatusFromServiceTab(selectedCategory)
            : getStatusFromTab(selectedCategory);

    // Only set isLoading1 if it's not a page 1 load
    if (page > 1) {
      setState(() {
        isLoadMoreProducts = true;
      });
    }

    checkInternet().then((internet) async {
      if (internet) {
        OrderProvider()
            .orderListApi(
              loginModel?.data?.user?.id.toString() ?? "",
              status,
              type,
              page.toString(), // Pass the page number
            )
            .then((response) async {
              final newOrderData = MyOrderModel.fromJson(response.data);
              if (response.statusCode == 200) {
                setState(() {
                  if (page == 1) {
                    myOrderModel = newOrderData; // Initialize list
                  } else {
                    // Append to existing list
                    myOrderModel?.data?.data?.addAll(
                      newOrderData.data?.data ?? [],
                    );
                  }

                  // Check if this was the last page
                  if (newOrderData.data?.data?.isEmpty ?? true) {
                    productHasNextPage = false;
                  }

                  isLoading = false;
                  isLoadMoreProducts = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                  isLoadMoreProducts = false;
                });
              }
            });
      } else {
        setState(() {
          isLoading = false;
          isLoadMoreProducts = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  // --- Updated API Call for Services ---
  OrderListViewApi1(type, int page) {
    String status =
        selectedType == "services"
            ? getStatusFromServiceTab(selectedCategory)
            : getStatusFromTab(selectedCategory);

    if (page > 1) {
      setState(() {
        isLoadMoreServices = true;
      });
    }

    checkInternet().then((internet) async {
      if (internet) {
        OrderProvider()
            .orderListApi(
              loginModel?.data?.user?.id.toString() ?? "",
              status,
              type,
              page.toString(), // Pass the page number
            )
            .then((response) async {
              final newServiceData = ServiceViewModel.fromJson(response.data);
              if (response.statusCode == 200) {
                setState(() {
                  if (page == 1) {
                    serviceViewModel = newServiceData; // Initialize list
                  } else {
                    // Append to existing list
                    serviceViewModel?.data?.data?.addAll(
                      newServiceData.data?.data ?? [],
                    );
                  }

                  // Check if this was the last page
                  if (newServiceData.data?.data?.isEmpty ?? true) {
                    serviceHasNextPage = false;
                  }

                  isLoading = false;
                  isLoadMoreServices = false;
                });
              } else {
                setState(() {
                  isLoading = false;
                  isLoadMoreServices = false;
                });
              }
            });
      } else {
        setState(() {
          isLoading = false;
          isLoadMoreServices = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
