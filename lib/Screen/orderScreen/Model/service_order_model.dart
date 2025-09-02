class ServiceOrderDetail {
  int? status;
  String? message;
  Data? data;

  ServiceOrderDetail({this.status, this.message, this.data});

  ServiceOrderDetail.fromJson(Map<String, dynamic> json) {
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

  Data({this.order, this.products});

  Data.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    products =
        json['products'] != null ? Products.fromJson(json['products']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    if (this.products != null) {
      data['products'] = this.products!.toJson();
    }
    return data;
  }
}

class Order {
  int? id;
  int? userId;
  String? orderNo;
  String? tokenNo;
  String? totalAmount;
  String? pickupTime;
  String? paymentIntentId;
  String? paymentGateway;
  String? status;
  String? createdAt;
  String? updatedAt;

  Order({
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
  });

  Order.fromJson(Map<String, dynamic> json) {
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
  int? isBooked;
  String? createdAt;
  String? updatedAt;
  Service? service;
  BookingDetails? bookingDetails;

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
    this.service,
    this.bookingDetails,
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
    service =
        json['service'] != null ? Service.fromJson(json['service']) : null;
    bookingDetails =
        json['booking_details'] != null
            ? BookingDetails.fromJson(json['booking_details'])
            : null;
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
    if (this.bookingDetails != null) {
      data['booking_details'] = this.bookingDetails!.toJson();
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
  String? pricingType;
  String? duration;
  String? images;
  List<String>? galleryImages;
  var features;
  var benefits;
  String? availability;
  var typeOfService;
  var serviceProvider;
  var contactEmail;
  var contactPhone;
  var location;
  String? status;
  String? createdAt;
  String? updatedAt;

  Service({
    this.id,
    this.userId,
    this.categoryId,
    this.title,
    this.slug,
    this.description,
    this.price,
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
    this.createdAt,
    this.updatedAt,
  });

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    price = json['price'];
    pricingType = json['pricing_type'];
    duration = json['duration'];
    images = json['images'];
    galleryImages = json['gallery_images'].cast<String>();
    features = json['features'];
    benefits = json['benefits'];
    availability = json['availability'];
    typeOfService = json['type_of_service'];
    serviceProvider = json['service_provider'];
    contactEmail = json['contact_email'];
    contactPhone = json['contact_phone'];
    location = json['location'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class BookingDetails {
  int? id;
  int? serviceRequestId;
  String? bookingDatetime;
  String? status;
  String? createdAt;
  String? updatedAt;

  BookingDetails({
    this.id,
    this.serviceRequestId,
    this.bookingDatetime,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  BookingDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceRequestId = json['service_request_id'];
    bookingDatetime = json['booking_datetime'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['service_request_id'] = this.serviceRequestId;
    data['booking_datetime'] = this.bookingDatetime;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
