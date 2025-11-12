// class AmendOrderModal {
//   int? status;
//   String? message;
//   AmendOrderData? amendOrderData;
//
//   AmendOrderModal({this.status, this.message, this.amendOrderData});
//
//   AmendOrderModal.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     amendOrderData =
//         json['data'] != null ? new AmendOrderData.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.amendOrderData != null) {
//       data['data'] = this.amendOrderData!.toJson();
//     }
//     return data;
//   }
// }
//
// class AmendOrderData {
//   int? id;
//   int? userId;
//   String? orderNo;
//   String? tokenNo;
//   String? totalAmount;
//   String? pickupTime;
//   String? paymentGateway;
//   String? paymentIntentId;
//   String? status;
//   String? discountApplied;
//   int? loyaltyDiscountApplied;
//   String? createdAt;
//   String? updatedAt;
//   List<Products>? products;
//
//   AmendOrderData({
//     this.id,
//     this.userId,
//     this.orderNo,
//     this.tokenNo,
//     this.totalAmount,
//     this.pickupTime,
//     this.paymentGateway,
//     this.paymentIntentId,
//     this.status,
//     this.discountApplied,
//     this.loyaltyDiscountApplied,
//     this.createdAt,
//     this.updatedAt,
//     this.products,
//   });
//
//   AmendOrderData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     orderNo = json['order_no'];
//     tokenNo = json['token_no'];
//     totalAmount = json['total_amount'];
//     pickupTime = json['pickup_time'];
//     paymentGateway = json['payment_gateway'];
//     paymentIntentId = json['payment_intent_id'];
//     status = json['status'];
//     discountApplied = json['discount_applied'];
//     loyaltyDiscountApplied = json['loyalty_discount_applied'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     if (json['products'] != null) {
//       products = <Products>[];
//       json['products'].forEach((v) {
//         products!.add(new Products.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['order_no'] = this.orderNo;
//     data['token_no'] = this.tokenNo;
//     data['total_amount'] = this.totalAmount;
//     data['pickup_time'] = this.pickupTime;
//     data['payment_gateway'] = this.paymentGateway;
//     data['payment_intent_id'] = this.paymentIntentId;
//     data['status'] = this.status;
//     data['discount_applied'] = this.discountApplied;
//     data['loyalty_discount_applied'] = this.loyaltyDiscountApplied;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.products != null) {
//       data['products'] = this.products!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Products {
//   int? id;
//   int? orderId;
//   int? userId;
//   int? productId;
//   String? type;
//   int? quantity;
//   String? price;
//   String? totalPrice;
//   String? createdAt;
//   String? updatedAt;
//   ItemDetails? itemDetails;
//   Business? business;
//
//   Products({
//     this.id,
//     this.orderId,
//     this.userId,
//     this.productId,
//     this.type,
//     this.quantity,
//     this.price,
//     this.totalPrice,
//     this.createdAt,
//     this.updatedAt,
//     this.itemDetails,
//     this.business,
//   });
//
//   Products.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     orderId = json['order_id'];
//     userId = json['user_id'];
//     productId = json['product_id'];
//     type = json['type'];
//     quantity = json['quantity'];
//     price = json['price'];
//     totalPrice = json['total_price'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     itemDetails =
//         json['item_details'] != null
//             ? new ItemDetails.fromJson(json['item_details'])
//             : null;
//     business =
//         json['business'] != null
//             ? new Business.fromJson(json['business'])
//             : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['order_id'] = this.orderId;
//     data['user_id'] = this.userId;
//     data['product_id'] = this.productId;
//     data['type'] = this.type;
//     data['quantity'] = this.quantity;
//     data['price'] = this.price;
//     data['total_price'] = this.totalPrice;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.itemDetails != null) {
//       data['item_details'] = this.itemDetails!.toJson();
//     }
//     if (this.business != null) {
//       data['business'] = this.business!.toJson();
//     }
//     return data;
//   }
// }
//
// class ItemDetails {
//   int? id;
//   String? name;
//   String? price;
//   var offerPrice;
//   int? quantity;
//   String? description;
//   List<String>? features;
//   var images;
//   String? image;
//   String? type;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//   int? businessId;
//   String? businessName;
//   List<Business>? businessProducts;
//
//   ItemDetails({
//     this.id,
//     this.name,
//     this.price,
//     this.offerPrice,
//     this.quantity,
//     this.description,
//     this.features,
//     this.images,
//     this.image,
//     this.type,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.businessId,
//     this.businessName,
//     this.businessProducts,
//   });
//
//   ItemDetails.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     price = json['price'];
//     offerPrice = json['offer_price'];
//     quantity = json['quantity'];
//     description = json['description'];
//
//     if (json['features'] != null) {
//       if (json['features'] is List) {
//         features = List<String>.from(json['features']);
//       } else if (json['features'] is String) {
//         features =
//             (json['features'] as String)
//                 .split(',')
//                 .map((e) => e.trim())
//                 .toList();
//       } else {
//         features = [];
//       }
//     } else {
//       features = [];
//     }
//
//     if (json['images'] != null) {
//       if (json['images'] is List) {
//         images = List<String>.from(json['images']);
//       } else if (json['images'] is String) {
//         images =
//             (json['images'] as String).split(',').map((e) => e.trim()).toList();
//       } else {
//         images = [];
//       }
//     } else {
//       images = [];
//     }
//
//     image = json['image'];
//     type = json['type'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     businessId = json['business_id'];
//     businessName = json['business_name'];
//
//     if (json['business_products'] != null) {
//       businessProducts = <Business>[];
//       json['business_products'].forEach((v) {
//         businessProducts!.add(Business.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['price'] = this.price;
//     data['offer_price'] = this.offerPrice;
//     data['quantity'] = this.quantity;
//     data['description'] = this.description;
//     data['features'] = this.features;
//     data['images'] = this.images;
//     data['image'] = this.image;
//     data['type'] = this.type;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['business_id'] = this.businessId;
//     data['business_name'] = this.businessName;
//     if (this.businessProducts != null) {
//       data['business_products'] =
//           this.businessProducts!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Business {
//   int? id;
//   String? businessName;
//   String? profile;
//
//   Business({this.id, this.businessName, this.profile});
//
//   Business.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     businessName = json['business_name'];
//     profile = json['profile'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['business_name'] = this.businessName;
//     data['profile'] = this.profile;
//     return data;
//   }
// }
