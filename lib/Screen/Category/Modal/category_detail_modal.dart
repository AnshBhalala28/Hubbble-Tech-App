class CategoryDetailModal {
  int? status;
  String? message;
  List<Data>? data;

  CategoryDetailModal({this.status, this.message, this.data});

  CategoryDetailModal.fromJson(Map<String, dynamic> json) {
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
  int? productCategoryId;
  String? name;
  String? price;
  String? offerPrice;
  var quantity;
  String? description;
  String? features;
  String? status;
  bool? isFeatured;
  String? image;
  List<String>? images;
  String? createdAt;
  String? updatedAt;
  String? categoryName;

  Data({
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
    this.createdAt,
    this.updatedAt,
    this.categoryName,
  });

  Data.fromJson(Map<String, dynamic> json) {
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
    images = json['images'].cast<String>();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['category_name'] = this.categoryName;
    return data;
  }
}
