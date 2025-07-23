import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../comman/check_inernet_connecty.dart';
import '../../../comman/colors.dart';
import '../../../comman/const.dart';
import '../../../comman/error_dialog.dart';
import '../../Add to Cart/provider/add_to_cart_provider.dart';
import '../../Add to Cart/view/add_to_cart_view.dart';
import '../../Product Detail Page/provider/product_provider.dart';
import '../../Product Detail Page/view/product_detail_page.dart';
import '../Model/SearchProductModel.dart';
import '../Provider/community_detail_provider.dart';

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

  Map<int, int> productQuantities = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
            Expanded(
              child: Container(
                height: 38,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      businessSearchApi(value);
                    } else {
                      setState(() {
                        searchResults.clear();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
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
                                setState(() {
                                  searchResults.clear();
                                });
                              },
                            )
                            : null,
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.maincolor),
              )
              : searchResults.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 60, color: Colors.grey[300]),
                    SizedBox(height: 16),
                    Text(
                      "Search for products",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final product = searchResults[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
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
                          SizedBox(width: 12),
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
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (product.offerPrice != null &&
                                          product.offerPrice != product.price)
                                        Text(
                                          "£${product.price}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      if (product.offerPrice != null &&
                                          product.offerPrice != product.price)
                                        SizedBox(width: 8),
                                      Text(
                                        "£${product.offerPrice ?? product.price}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.maincolor,
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
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap:
                      () => Get.off(
                        AddToCartView(type: 'product', fromBottomBar: false),
                      ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.maincolor,
                          AppColors.maincolor.withOpacity(0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.maincolor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${getTotalItems()}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "View Basket",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "£${getTotalPrice().toStringAsFixed(2)}",
                          style: TextStyle(
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
          Get.snackbar(
            "Product item already in cart",
            "Please remove service items before adding a product.",
            backgroundColor: AppColors.redColor,
            colorText: Colors.white,
            margin: EdgeInsets.all(10),
            snackPosition: SnackPosition.TOP,
          );
        } else if (cartDetailsModel!.data![0].itemDetails?.businessId ==
            productViewModel?.data?.businessId) {
          updateQuantityApi(product.id!, newQuantity, "product");
        } else {
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
        } catch (e, stackTrace) {
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
    searchResults.forEach((product) {
      final quantity = getProductQuantity(product.id!);
      if (quantity > 0) {
        final price =
            double.tryParse(product.offerPrice ?? product.price ?? '0') ?? 0.0;
        total += price * quantity;
      }
    });
    return total;
  }
}
