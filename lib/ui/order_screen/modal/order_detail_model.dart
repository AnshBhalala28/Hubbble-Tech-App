// class OrderDetailModel {
//   int? status;
//   String? message;
//   Data? data;
//
//   OrderDetailModel({this.status, this.message, this.data});
//
//   OrderDetailModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   Order? order;
//   Products? products;
//   Business? business;
//
//   Data({this.order, this.products, this.business});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     order = json['order'] != null ? new Order.fromJson(json['order']) : null;
//     products =
//         json['products'] != null
//             ? new Products.fromJson(json['products'])
//             : null;
//     business =
//         json['business'] != null
//             ? new Business.fromJson(json['business'])
//             : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.order != null) {
//       data['order'] = this.order!.toJson();
//     }
//     if (this.products != null) {
//       data['products'] = this.products!.toJson();
//     }
//     if (this.business != null) {
//       data['business'] = this.business!.toJson();
//     }
//     return data;
//   }
// }
//
// class Order {
//   int? id;
//   int? userId;
//   String? orderNo;
//   String? tokenNo;
//   int? loyaltyDiscountApplied;
//   String? discountApplied;
//   String? totalAmount;
//   String? pickupTime;
//   String? paymentIntentId;
//   String? paymentGateway;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//
//   Order({
//     this.id,
//     this.userId,
//     this.orderNo,
//     this.tokenNo,
//     this.loyaltyDiscountApplied,
//     this.discountApplied,
//     this.totalAmount,
//     this.pickupTime,
//     this.paymentIntentId,
//     this.paymentGateway,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   Order.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     orderNo = json['order_no'];
//     tokenNo = json['token_no'];
//     loyaltyDiscountApplied = json['loyalty_discount_applied'];
//     discountApplied = json['discount_applied'];
//     totalAmount = json['total_amount'];
//     pickupTime = json['pickup_time'];
//     paymentIntentId = json['payment_intent_id'];
//     paymentGateway = json['payment_gateway'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['order_no'] = this.orderNo;
//     data['token_no'] = this.tokenNo;
//     data['loyalty_discount_applied'] = this.loyaltyDiscountApplied;
//     data['discount_applied'] = this.discountApplied;
//     data['total_amount'] = this.totalAmount;
//     data['pickup_time'] = this.pickupTime;
//     data['payment_intent_id'] = this.paymentIntentId;
//     data['payment_gateway'] = this.paymentGateway;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class Products {
//   int? id;
//   int? orderId;
//   int? userId;
//   String? type;
//   int? productId;
//   var quantity;
//   String? price;
//   String? totalPrice;
//   int? isWithdrawn;
//   var isBooked;
//   String? createdAt;
//   String? updatedAt;
//   Product? product;
//
//   Products({
//     this.id,
//     this.orderId,
//     this.userId,
//     this.type,
//     this.productId,
//     this.quantity,
//     this.price,
//     this.totalPrice,
//     this.isWithdrawn,
//     this.isBooked,
//     this.createdAt,
//     this.updatedAt,
//     this.product,
//   });
//
//   Products.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     orderId = json['order_id'];
//     userId = json['user_id'];
//     type = json['type'];
//     productId = json['product_id'];
//     quantity = json['quantity'];
//     price = json['price'];
//     totalPrice = json['total_price'];
//     isWithdrawn = json['is_withdrawn'];
//     isBooked = json['is_booked'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     product =
//         json['product'] != null ? new Product.fromJson(json['product']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['order_id'] = this.orderId;
//     data['user_id'] = this.userId;
//     data['type'] = this.type;
//     data['product_id'] = this.productId;
//     data['quantity'] = this.quantity;
//     data['price'] = this.price;
//     data['total_price'] = this.totalPrice;
//     data['is_withdrawn'] = this.isWithdrawn;
//     data['is_booked'] = this.isBooked;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.product != null) {
//       data['product'] = this.product!.toJson();
//     }
//     return data;
//   }
// }
//
// class Product {
//   int? id;
//   int? userId;
//   int? productCategoryId;
//   String? name;
//   String? price;
//   String? offerPrice;
//   var quantity;
//   String? description;
//   String? features;
//   String? status;
//   bool? isFeatured;
//   String? image;
//   List<String>? images;
//   String? createdAt;
//   String? updatedAt;
//
//   Product({
//     this.id,
//     this.userId,
//     this.productCategoryId,
//     this.name,
//     this.price,
//     this.offerPrice,
//     this.quantity,
//     this.description,
//     this.features,
//     this.status,
//     this.isFeatured,
//     this.image,
//     this.images,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   Product.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     productCategoryId = json['product_category_id'];
//     name = json['name'];
//     price = json['price'];
//     offerPrice = json['offer_price'];
//     quantity = json['quantity'];
//     description = json['description'];
//     features = json['features'];
//     status = json['status'];
//     isFeatured = json['is_featured'];
//     image = json['image'];
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
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['product_category_id'] = this.productCategoryId;
//     data['name'] = this.name;
//     data['price'] = this.price;
//     data['offer_price'] = this.offerPrice;
//     data['quantity'] = this.quantity;
//     data['description'] = this.description;
//     data['features'] = this.features;
//     data['status'] = this.status;
//     data['is_featured'] = this.isFeatured;
//     data['image'] = this.image;
//     data['images'] = this.images;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
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
class OrderDetailModel {
  int? status;
  String? message;
  Data? data;

  OrderDetailModel({this.status, this.message, this.data});

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Order? order;
  Products? products;
  Business? business;

  Data({this.order, this.products, this.business});

  Data.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    products =
        json['products'] != null ? Products.fromJson(json['products']) : null;
    business =
        json['business'] != null ? Business.fromJson(json['business']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    if (this.products != null) {
      data['products'] = this.products!.toJson();
    }
    if (this.business != null) {
      data['business'] = this.business!.toJson();
    }
    return data;
  }
}

class Order {
  int? id;
  int? userId;
  String? orderNo;
  String? tokenNo;
  int? loyaltyDiscountApplied;
  String? discountApplied;
  String? totalAmount;
  var pickupTime;
  String? paymentIntentId;
  String? paymentGateway;
  String? status;
  var note;
  String? createdAt;
  String? updatedAt;

  Order({
    this.id,
    this.userId,
    this.orderNo,
    this.tokenNo,
    this.loyaltyDiscountApplied,
    this.discountApplied,
    this.totalAmount,
    this.pickupTime,
    this.paymentIntentId,
    this.paymentGateway,
    this.status,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderNo = json['order_no'];
    tokenNo = json['token_no'];
    loyaltyDiscountApplied = json['loyalty_discount_applied'];
    discountApplied = json['discount_applied'];
    totalAmount = json['total_amount'];
    pickupTime = json['pickup_time'];
    paymentIntentId = json['payment_intent_id'];
    paymentGateway = json['payment_gateway'];
    status = json['status'];
    note = json['note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['order_no'] = this.orderNo;
    data['token_no'] = this.tokenNo;
    data['loyalty_discount_applied'] = this.loyaltyDiscountApplied;
    data['discount_applied'] = this.discountApplied;
    data['total_amount'] = this.totalAmount;
    data['pickup_time'] = this.pickupTime;
    data['payment_intent_id'] = this.paymentIntentId;
    data['payment_gateway'] = this.paymentGateway;
    data['status'] = this.status;
    data['note'] = this.note;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Products {
  int? id;
  int? orderId;
  int? userId;
  String? type;
  int? productId;
  int? quantity;
  String? price;
  String? totalPrice;
  int? isWithdrawn;
  var isBooked;
  String? createdAt;
  String? updatedAt;
  Product? product;

  Products({
    this.id,
    this.orderId,
    this.userId,
    this.type,
    this.productId,
    this.quantity,
    this.price,
    this.totalPrice,
    this.isWithdrawn,
    this.isBooked,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    userId = json['user_id'];
    type = json['type'];
    productId = json['product_id'];
    quantity = json['quantity'];
    price = json['price'];
    totalPrice = json['total_price'];
    isWithdrawn = json['is_withdrawn'];
    isBooked = json['is_booked'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product =
        json['product'] != null ? Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['user_id'] = this.userId;
    data['type'] = this.type;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['total_price'] = this.totalPrice;
    data['is_withdrawn'] = this.isWithdrawn;
    data['is_booked'] = this.isBooked;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    return data;
  }
}

class Product {
  int? id;
  int? userId;
  int? productCategoryId;
  String? name;
  String? price;
  String? offerPrice;
  String? quantity;
  String? description;
  String? features;
  String? status;
  bool? isFeatured;
  String? image;
  List<String>? images;
  int? isDeleted;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Product({
    this.id,
    this.userId,
    this.productCategoryId,
    this.name,
    this.price,
    this.offerPrice,
    this.quantity,
    this.description,
    this.features,
    this.status,
    this.isFeatured,
    this.image,
    this.images,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productCategoryId = json['product_category_id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    quantity = json['quantity'];
    description = json['description'];
    features = json['features'];
    status = json['status'];
    isFeatured = json['is_featured'];
    image = json['image'];
    if (json['images'] != null) {
      if (json['images'] is List) {
        images = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        images = [json['images']];
      } else {
        images = [];
      }
    } else {
      images = [];
    }
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['product_category_id'] = this.productCategoryId;
    data['name'] = this.name;
    data['price'] = this.price;
    data['offer_price'] = this.offerPrice;
    data['quantity'] = this.quantity;
    data['description'] = this.description;
    data['features'] = this.features;
    data['status'] = this.status;
    data['is_featured'] = this.isFeatured;
    data['image'] = this.image;
    data['images'] = this.images;

    data['is_deleted'] = this.isDeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['business_name'] = this.businessName;
    data['profile'] = this.profile;
    return data;
  }
}
