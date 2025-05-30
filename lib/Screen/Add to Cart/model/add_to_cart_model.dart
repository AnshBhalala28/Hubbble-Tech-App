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

  Data(
      {this.id,
        this.type,
        this.userId,
        this.productId,
        this.quantity,
        this.totalPrice,
        this.createdAt,
        this.updatedAt,
        this.itemDetails});

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
  List<String>? images;
var image;
  String? type;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? duration;
  List<String>? benefits;
  int? businessId;
  String? businessName;

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
        this.duration,
        this.benefits,
        this.businessId,
        this.businessName});

  // ItemDetails.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  //   name = json['name'];
  //   price = json['price'];
  //   offerPrice = json['offer_price'];
  //   quantity = json['quantity'];
  //   description = json['description'];
  //   features = json['features'].cast<String>();
  //   images = json['images'].cast<String>();
  //   image = json['image'];
  //   type = json['type'];
  //   status = json['status'];
  //   createdAt = json['created_at'];
  //   updatedAt = json['updated_at'];
  //   duration = json['duration'];
  //   benefits = json['benefits'];
  //   businessId = json['business_id'];
  //   businessName = json['business_name'];
  // }
  ItemDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    quantity = json['quantity'];
    description = json['description'];

    features = json['features'] != null
        ? List<String>.from(json['features'])
        : [];

    images = json['images'] != null
        ? List<String>.from(json['images'])
        : [];

    image = json['image'];
    type = json['type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    duration = json['duration'];

    benefits = json['benefits'] != null
        ? List<String>.from(json['benefits'])
        : [];

    businessId = json['business_id'];
    businessName = json['business_name'];
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
    data['duration'] = this.duration;
    data['benefits'] = this.benefits;
    data['business_id'] = this.businessId;
    data['business_name'] = this.businessName;
    return data;
  }
}
