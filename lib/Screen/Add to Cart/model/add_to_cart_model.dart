class CartDetailsModel {
  int? status;
  String? message;
  List<Data>? data;

  CartDetailsModel({this.status, this.message, this.data});

  CartDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? type;
  int? userId;
  int? productId;
  int? quantity;
  String? totalPrice;
  String? createdAt;
  String? updatedAt;
  ItemDetails? itemDetails;
  LoyaltyDetails? loyaltyDetails;

  Data(
      {this.id,
      this.type,
      this.userId,
      this.productId,
      this.quantity,
      this.totalPrice,
      this.createdAt,
      this.updatedAt,
      this.itemDetails,
      this.loyaltyDetails});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    userId = json['user_id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    totalPrice = json['total_price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemDetails = json['item_details'] != null
        ? new ItemDetails.fromJson(json['item_details'])
        : null;
    loyaltyDetails = json['loyalty_details'] != null
        ? new LoyaltyDetails.fromJson(json['loyalty_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['user_id'] = this.userId;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    data['total_price'] = this.totalPrice;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.itemDetails != null) {
      data['item_details'] = this.itemDetails!.toJson();
    }
    if (this.loyaltyDetails != null) {
      data['loyalty_details'] = this.loyaltyDetails!.toJson();
    }
    return data;
  }
}

class ItemDetails {
  int? id;
  String? name;
  String? price;
  var offerPrice;
  int? quantity;
  String? description;
  List<String>? features;
  var images;
  String? image;
  String? type;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? businessId;
  String? businessName;
  List<BusinessProducts>? businessProducts;

  ItemDetails(
      {this.id,
      this.name,
      this.price,
      this.offerPrice,
      this.quantity,
      this.description,
      this.features,
      this.images,
      this.image,
      this.type,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.businessId,
      this.businessName,
      this.businessProducts});

  ItemDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    quantity = json['quantity'];
    description = json['description'];

    if (json['features'] != null) {
      if (json['features'] is List) {
        features = List<String>.from(json['features']);
      } else if (json['features'] is String) {
        features = (json['features'] as String)
            .split(',')
            .map((e) => e.trim())
            .toList();
      } else {
        features = [];
      }
    } else {
      features = [];
    }

    if (json['images'] != null) {
      if (json['images'] is List) {
        images = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        images =
            (json['images'] as String).split(',').map((e) => e.trim()).toList();
      } else {
        images = [];
      }
    } else {
      images = [];
    }

    image = json['image'];
    type = json['type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    businessId = json['business_id'];
    businessName = json['business_name'];

    if (json['business_products'] != null) {
      businessProducts = <BusinessProducts>[];
      json['business_products'].forEach((v) {
        businessProducts!.add(BusinessProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['offer_price'] = this.offerPrice;
    data['quantity'] = this.quantity;
    data['description'] = this.description;
    data['features'] = this.features;
    data['images'] = this.images;
    data['image'] = this.image;
    data['type'] = this.type;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['business_id'] = this.businessId;
    data['business_name'] = this.businessName;
    if (this.businessProducts != null) {
      data['business_products'] =
          this.businessProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BusinessProducts {
  int? id;
  String? name;
  String? price;
  String? offerPrice;
  String? description;
  List<String>? features;
  List<String>? images;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;

  BusinessProducts({
    this.id,
    this.name,
    this.price,
    this.offerPrice,
    this.description,
    this.features,
    this.images,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  BusinessProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    description = json['description'];

    if (json['features'] is List) {
      features = List<String>.from(json['features']);
    } else if (json['features'] is String) {
      features = [json['features']];
    } else {
      features = [];
    }

    if (json['images'] is List) {
      images = List<String>.from(json['images']);
    } else if (json['images'] is String) {
      images = [json['images']];
    } else {
      images = [];
    }

    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['offer_price'] = offerPrice;
    data['description'] = description;
    data['features'] = features;
    data['images'] = images;
    data['image'] = image;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class LoyaltyDetails {
  int? loyaltyOrderThreshold;
  String? loyaltyDiscountPercentage;
  int? ordersCompletedWithBusiness;
  bool? willGetLoyaltyDiscountOnNextOrder;
  bool? willGetLoyaltyDiscountOnCurrentOrder;

  LoyaltyDetails(
      {this.loyaltyOrderThreshold,
      this.loyaltyDiscountPercentage,
      this.ordersCompletedWithBusiness,
      this.willGetLoyaltyDiscountOnCurrentOrder,
      this.willGetLoyaltyDiscountOnNextOrder});

  LoyaltyDetails.fromJson(Map<String, dynamic> json) {
    loyaltyOrderThreshold = json['loyalty_order_threshold'];
    loyaltyDiscountPercentage = json['loyalty_discount_percentage'];
    ordersCompletedWithBusiness = json['orders_completed_with_business'];
    willGetLoyaltyDiscountOnNextOrder =
        json['will_get_loyalty_discount_on_next_order'];
    willGetLoyaltyDiscountOnCurrentOrder =
        json['will_get_loyalty_discount_on_current_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loyalty_order_threshold'] = this.loyaltyOrderThreshold;
    data['loyalty_discount_percentage'] = this.loyaltyDiscountPercentage;
    data['orders_completed_with_business'] = this.ordersCompletedWithBusiness;
    data['will_get_loyalty_discount_on_next_order'] =
        this.willGetLoyaltyDiscountOnNextOrder;
    data['will_get_loyalty_discount_on_current_order'] =
        this.willGetLoyaltyDiscountOnCurrentOrder;
    return data;
  }
}
