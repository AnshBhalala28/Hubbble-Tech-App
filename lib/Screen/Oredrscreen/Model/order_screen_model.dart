// class MyOrderModel {
//   int? status;
//   String? message;
//   List<Data>? data;
//
//   MyOrderModel({this.status, this.message, this.data});
//
//   MyOrderModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   int? id;
//   int? userId;
//   String? orderNo;
//   String? tokenNo;
//   String? totalAmount;
//   String? pickupTime;
//   String? paymentGateway;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//   List<OrderProducts>? orderProducts;
//
//   Data(
//       {this.id,
//       this.userId,
//       this.orderNo,
//       this.tokenNo,
//       this.totalAmount,
//       this.pickupTime,
//       this.paymentGateway,
//       this.status,
//       this.createdAt,
//       this.updatedAt,
//       this.orderProducts});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     orderNo = json['order_no'];
//     tokenNo = json['token_no'];
//     totalAmount = json['total_amount'];
//     pickupTime = json['pickup_time'];
//     paymentGateway = json['payment_gateway'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     if (json['order_products'] != null) {
//       orderProducts = <OrderProducts>[];
//       json['order_products'].forEach((v) {
//         orderProducts!.add(new OrderProducts.fromJson(v));
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
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.orderProducts != null) {
//       data['order_products'] =
//           this.orderProducts!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class OrderProducts {
//   int? id;
//   int? orderId;
//   int? userId;
//   int? productId;
//   int? quantity;
//   String? price;
//   String? totalPrice;
//   String? createdAt;
//   String? updatedAt;
//   Product? product;
//
//   OrderProducts(
//       {this.id,
//       this.orderId,
//       this.userId,
//       this.productId,
//       this.quantity,
//       this.price,
//       this.totalPrice,
//       this.createdAt,
//       this.updatedAt,
//       this.product});
//
//   OrderProducts.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     orderId = json['order_id'];
//     userId = json['user_id'];
//     productId = json['product_id'];
//     quantity = json['quantity'];
//     price = json['price'];
//     totalPrice = json['total_price'];
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
//     data['product_id'] = this.productId;
//     data['quantity'] = this.quantity;
//     data['price'] = this.price;
//     data['total_price'] = this.totalPrice;
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
//   String? name;
//   String? price;
//   String? offerPrice;
//   int? quantity;
//   String? description;
//   String? features;
//   String? status;
//   bool? isFeatured;
//   String? image;
//   List<String>? images;
//   String? createdAt;
//   String? updatedAt;
//
//   Product(
//       {this.id,
//       this.userId,
//       this.name,
//       this.price,
//       this.offerPrice,
//       this.quantity,
//       this.description,
//       this.features,
//       this.status,
//       this.isFeatured,
//       this.image,
//       this.images,
//       this.createdAt,
//       this.updatedAt});
//
//   Product.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     name = json['name'];
//     price = json['price'];
//     offerPrice = json['offer_price'];
//     quantity = json['quantity'];
//     description = json['description'];
//     features = json['features'];
//     status = json['status'];
//     isFeatured = json['is_featured'];
//     image = json['image'];
//     images = json['images'].cast<String>();
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
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
class MyOrderModel {
  int? status;
  String? message;
  List<Data>? data;

  MyOrderModel({this.status, this.message, this.data});

  MyOrderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? orderNo;
  String? tokenNo;
  String? totalAmount;
  String? pickupTime;
  String? paymentGateway;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<OrderProducts>? orderProducts;
  String? randomProductImage;


  Data(
      {this.id,
        this.userId,
        this.orderNo,
        this.tokenNo,
        this.totalAmount,
        this.pickupTime,
        this.paymentGateway,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.orderProducts,
        this.randomProductImage,
       });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderNo = json['order_no'];
    tokenNo = json['token_no'];
    totalAmount = json['total_amount'];
    pickupTime = json['pickup_time'];
    paymentGateway = json['payment_gateway'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['orderProducts'] != null) {
      orderProducts = <OrderProducts>[];
      json['orderProducts'].forEach((v) {
        orderProducts!.add(new OrderProducts.fromJson(v));
      });
    }
    randomProductImage = json['random_product_image'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['order_no'] = this.orderNo;
    data['token_no'] = this.tokenNo;
    data['total_amount'] = this.totalAmount;
    data['pickup_time'] = this.pickupTime;
    data['payment_gateway'] = this.paymentGateway;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.orderProducts != null) {
      data['orderProducts'] =
          this.orderProducts!.map((v) => v.toJson()).toList();
    }
    data['random_product_image'] = this.randomProductImage;

    return data;
  }
}

class OrderProducts {
  int? id;
  int? orderId;
  int? userId;
  String? type;
  int? productId;
  int? quantity;
  String? price;
  String? totalPrice;
  int? isWithdrawn;
  String? createdAt;
  String? updatedAt;
  Product? product;

  OrderProducts(
      {this.id,
        this.orderId,
        this.userId,
        this.type,
        this.productId,
        this.quantity,
        this.price,
        this.totalPrice,
        this.isWithdrawn,
        this.createdAt,
        this.updatedAt,
        this.product});

  OrderProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    userId = json['user_id'];
    type = json['type'];
    productId = json['product_id'];
    quantity = json['quantity'];
    price = json['price'];
    totalPrice = json['total_price'];
    isWithdrawn = json['is_withdrawn'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['user_id'] = this.userId;
    data['type'] = this.type;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['total_price'] = this.totalPrice;
    data['is_withdrawn'] = this.isWithdrawn;
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
  String? name;
  String? price;
  String? offerPrice;
  int? quantity;
  String? description;
  String? features;
  String? status;
  bool? isFeatured;
  String? image;
  List<String>? images;
  String? createdAt;
  String? updatedAt;

  Product(
      {this.id,
        this.userId,
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
        this.createdAt,
        this.updatedAt});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    quantity = json['quantity'];
    description = json['description'];
    features = json['features'];
    status = json['status'];
    isFeatured = json['is_featured'];
    image = json['image'];
    images = json['images'].cast<String>();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
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
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
