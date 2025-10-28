
class ServiceViewModel {
  int? status;
  String? message;
  Data? data;

  ServiceViewModel({this.status, this.message, this.data});

  ServiceViewModel.fromJson(Map<String, dynamic> json) {
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
  int? currentPage;
  int? perPage;
  int? total;
  int? lastPage;
  List<Data1>? data;

  Data({this.currentPage, this.perPage, this.total, this.lastPage, this.data});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    perPage = json['per_page'];
    total = json['total'];
    lastPage = json['last_page'];
    if (json['data'] != null) {
      data = <Data1>[];
      json['data'].forEach((v) {
        data!.add(Data1.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = this.currentPage;
    data['per_page'] = this.perPage;
    data['total'] = this.total;
    data['last_page'] = this.lastPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data1 {
  int? id;
  int? userId;
  String? orderNo;
  String? tokenNo;
  String? totalAmount;
  var pickupTime;
  String? paymentIntentId;
  String? paymentGateway;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<OrderProducts>? orderProducts;
  var randomProductImage;

  Data1({
    this.id,
    this.userId,
    this.orderNo,
    this.tokenNo,
    this.totalAmount,
    this.pickupTime,
    this.paymentIntentId,
    this.paymentGateway,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.orderProducts,
    this.randomProductImage,
  });

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderNo = json['order_no'];
    tokenNo = json['token_no'];
    totalAmount = json['total_amount'];
    pickupTime = json['pickup_time'];
    paymentIntentId = json['payment_intent_id'];
    paymentGateway = json['payment_gateway'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['orderProducts'] != null) {
      orderProducts = <OrderProducts>[];
      json['orderProducts'].forEach((v) {
        orderProducts!.add(OrderProducts.fromJson(v));
      });
    }
    randomProductImage = json['random_product_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['order_no'] = this.orderNo;
    data['token_no'] = this.tokenNo;
    data['total_amount'] = this.totalAmount;
    data['pickup_time'] = this.pickupTime;
    data['payment_intent_id'] = this.paymentIntentId;
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
  var isBooked;
  String? createdAt;
  String? updatedAt;
  Service? service;

  OrderProducts({
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
    this.service,
  });

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
    isBooked = json['is_booked'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    service =
        json['service'] != null ? Service.fromJson(json['service']) : null;
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
    if (this.service != null) {
      data['service'] = this.service!.toJson();
    }
    return data;
  }
}

class Service {
  int? id;
  int? userId;
  int? categoryId;
  String? title;
  var slug;
  String? description;
  String? price;
  String? offerPrice;
  String? pricingType;
  String? duration;
  var images;
  List<String>? galleryImages;
  List<String>? features;
  List<String>? benefits;
  String? availability;
  var typeOfService;
  var serviceProvider;
  var contactEmail;
  var contactPhone;
  var location;
  String? status;
  int? isDeleted;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Service({
    this.id,
    this.userId,
    this.categoryId,
    this.title,
    this.slug,
    this.description,
    this.price,
    this.offerPrice,
    this.pricingType,
    this.duration,
    this.images,
    this.galleryImages,
    this.features,
    this.benefits,
    this.availability,
    this.typeOfService,
    this.serviceProvider,
    this.contactEmail,
    this.contactPhone,
    this.location,
    this.status,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    price = json['price'];
    offerPrice = json['offer_price'];
    pricingType = json['pricing_type'];
    duration = json['duration'];
    images = json['images'];
    galleryImages = json['gallery_images'] != null
        ? List<String>.from(json['gallery_images'])
        : [];
    features = json['features'] != null
        ? List<String>.from(json['features'])
        : [];
    benefits = json['benefits'] != null
        ? List<String>.from(json['benefits'])
        : [];
    availability = json['availability'];
    typeOfService = json['type_of_service'];
    serviceProvider = json['service_provider'];
    contactEmail = json['contact_email'];
    contactPhone = json['contact_phone'];
    location = json['location'];
    status = json['status'];
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['description'] = this.description;
    data['price'] = this.price;
    data['offer_price'] = this.offerPrice;
    data['pricing_type'] = this.pricingType;
    data['duration'] = this.duration;
    data['images'] = this.images;
    data['gallery_images'] = this.galleryImages;
    data['features'] = this.features;
    data['benefits'] = this.benefits;
    data['availability'] = this.availability;
    data['type_of_service'] = this.typeOfService;
    data['service_provider'] = this.serviceProvider;
    data['contact_email'] = this.contactEmail;
    data['contact_phone'] = this.contactPhone;
    data['location'] = this.location;
    data['status'] = this.status;
    data['is_deleted'] = this.isDeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
