import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Utils/customSnackBars.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/colors.dart';
import '../../../Utils/const.dart';
import '../../../Utils/errorDialog.dart';
import '../../CartScreen/provider/addToCartProvider.dart';
import '../../CartScreen/view/cartViewScreen.dart';
import '../../productDetailPage/provider/productProvider.dart';
import '../../productDetailPage/view/productDetailPage.dart';
import '../Provider/communityDetailProvider.dart';
import '../modal/SearchProductModel.dart';

class SearchScreen extends StatefulWidget {
  String? businessID;
  int? addStatus;

  SearchScreen({super.key, this.businessID, this.addStatus});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchProductModel? searchProductModel;
  List<Data> searchResults = [];
  bool isLoading = false;
  bool isUpdateQuantity = false;
  final TextEditingController searchController = TextEditingController();
  bool isAddtoCart = false;
  Timer? _debounce;

  Map<int, int> productQuantities = {};

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        businessSearchApi(query);
      } else {
        setState(() {
          searchResults.clear();
        });
      }
    });
  }

  // bool isDark = true;
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.black : Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Color(0xffbdab82) : Colors.black,
              ),
              onPressed: () => Get.back(),
            ),
            Expanded(
              child: Container(
                height: 38,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff272727) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Color(0xffbdab82) : Colors.grey[600],
                      size: 20,
                    ),
                    suffixIcon:
                        searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.close,
                                color:
                                    isDark
                                        ? Color(0xffbdab82)
                                        : Colors.grey[600],
                                size: 18,
                              ),
                              onPressed: () {
                                searchController.clear();
                                if (_debounce?.isActive ?? false) {
                                  _debounce!.cancel();
                                }
                                setState(() {
                                  searchResults.clear();
                                });
                              },
                            )
                            : null,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: isDark ? Color(0xffbdab82) : AppColors.maincolor,
                ),
              )
              : searchResults.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 60,
                      color: isDark ? Color(0xffbdab82) : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Search for products",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Color(0xffbdab82) : Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final product = searchResults[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xff272727) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Get.to(
                          () => ProductDetailPage(
                            productID: product.id.toString() ?? "",
                            type: "product",
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.image ?? '',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                  () => ProductDetailPage(
                                    productID: product.id.toString() ?? "",
                                    type: "product",
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? Color(0xffbdab82)
                                              : Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (product.offerPrice != null &&
                                          product.offerPrice != product.price)
                                        Text(
                                          "£${product.price}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.grey[500],
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      if (product.offerPrice != null &&
                                          product.offerPrice != product.price)
                                        const SizedBox(width: 8),
                                      Text(
                                        "£${product.offerPrice ?? product.price}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isDark
                                                  ? Color(0xffbdab82)
                                                  : AppColors.maincolor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar:
          searchResults.any((product) => getProductQuantity(product.id!) > 0)
              ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap:
                      () => Get.off(
                        AddToCartView(
                          type: 'product',
                          fromBottomBar: false,
                          isAmend: false,
                        ),
                      ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.maincolor,
                          AppColors.maincolor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.maincolor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${getTotalItems()}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "View Basket",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "£${getTotalPrice().toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : null,
    );
  }

  void updateQuantity(Data product, int newQuantity) {
    int currentQuantity = getProductQuantity(product.id!);

    if (newQuantity <= 0) {
      setState(() {
        productQuantities.remove(product.id!);
      });
    } else {
      setState(() {
        productQuantities[product.id!] = newQuantity;
      });

      if (cartDetailsModel?.data != null &&
          cartDetailsModel!.data!.isNotEmpty) {
        if (cartDetailsModel!.data![0].type == "service") {
          showSnackBar(
            context: context,
            title: 'Product item already in cart',
            message: 'Please remove service items before adding a product.',
            backgoundColor: AppColors.redColor,
            ColorText: Colors.white,
          );
        } else if (cartDetailsModel!.data![0].itemDetails?.businessId ==
            productViewModel?.data?.businessId) {
          updateQuantityApi(product.id!, newQuantity, "product");
        } else {
          showSnackBar(
            context: context,
            title: "Business mismatch",
            message:
                "You can only add items from the same business to the cart.",
            backgoundColor: AppColors.redColor,
            ColorText: Colors.white,
          );
        }
      } else {
        updateQuantityApi(product.id!, newQuantity, "product");
      }
    }
  }

  void AddCartProductApiAndUpdateQuantity(String productID, int quantity) {
    setState(() {
      isUpdateQuantity = true;
      isAddtoCart = true;
    });

    final Map<String, String> addToCartData = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "id": productID.toString(),
      "type": "product",
    };

    checkInternet().then((internet) async {
      if (internet) {
        ProductProvider()
            .AddToCart(addToCartData)
            .then((response) async {
              if (response.statusCode == 200) {
                updateQuantityApi(int.parse(productID), quantity, "product");
              } else {
                setState(() {
                  isUpdateQuantity = false;
                  isAddtoCart = false;
                });
              }
            })
            .catchError((error) {
              setState(() {
                isUpdateQuantity = false;
                isAddtoCart = false;
              });
            });
      } else {
        setState(() {
          isAddtoCart = false;
          isUpdateQuantity = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void updateQuantityApi(int productId, int quantity, String type) {
    final Map<String, String> data = {
      "user_id": loginModel?.data?.user?.id.toString() ?? "",
      "product_id": productId.toString(),
      "quantity": quantity.toString(),
      "type": type,
    };

    checkInternet().then((internet) async {
      if (internet) {
        CartProvider()
            .updateCartQuantityApi(data)
            .then((response) async {
              if (response.statusCode == 200) {
              } else {}
              setState(() {
                isUpdateQuantity = false;
                isAddtoCart = false;
              });
            })
            .catchError((error) {
              setState(() {
                isUpdateQuantity = false;
                isAddtoCart = false;
              });
            });
      } else {
        setState(() {
          isUpdateQuantity = false;
          isAddtoCart = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void businessSearchApi(String searchTerm) {
    if (searchTerm.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await CommunityDetailProvider().categorySearchApi(
            loginModel?.data?.user?.id.toString() ?? "",
            widget.businessID,
            searchTerm,
          );

          if (response.statusCode == 200) {
            searchProductModel = SearchProductModel.fromJson(response.data);
            setState(() {
              searchResults = searchProductModel?.data ?? [];
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              searchResults.clear();
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
            searchResults.clear();
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  int getProductQuantity(int productId) {
    return productQuantities[productId] ?? 0;
  }

  int getTotalItems() {
    return productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var product in searchResults) {
      final quantity = getProductQuantity(product.id!);
      if (quantity > 0) {
        final price =
            double.tryParse(product.offerPrice ?? product.price ?? '0') ?? 0.0;
        total += price * quantity;
      }
    }
    return total;
  }
}
