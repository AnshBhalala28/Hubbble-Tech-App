class ProductViewModel {
  int? status;
  String? message;
  Data? data;

  ProductViewModel({this.status, this.message, this.data});

  ProductViewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? name;
  String? price;
  String? offerPrice;
  String? quantity;
  String? description;
  List<String>? features;
  String? status;
  bool? isFeatured;
  String? image;
  List<String>? images;
  String? createdAt;
  String? updatedAt;
  int? businessId;
  String? businessName;
  int? productRating;
  List<LatestReviews>? latestReviews;
  var galleryImages;
  var benefits;
  String? discount;

  Data(
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
      this.updatedAt,
      this.businessId,
      this.businessName,
      this.productRating,
      this.latestReviews,
      this.galleryImages,
      this.benefits,
      this.discount});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
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

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    businessId = json['business_id'];
    businessName = json['business_name'];
    productRating = json['product_rating'];

    if (json['latest_reviews'] != null) {
      latestReviews = <LatestReviews>[];
      json['latest_reviews'].forEach((v) {
        latestReviews!.add(LatestReviews.fromJson(v));
      });
    }

    galleryImages = json['gallery_images'];
    benefits = json['benefits'];
    discount = json['discount'];
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
    data['business_id'] = this.businessId;
    data['business_name'] = this.businessName;
    data['product_rating'] = this.productRating;
    if (this.latestReviews != null) {
      data['latest_reviews'] =
          this.latestReviews!.map((v) => v.toJson()).toList();
    }
    data['gallery_images'] = this.galleryImages;
    data['benefits'] = this.benefits;
    data['discount'] = this.discount;
    return data;
  }
}

class LatestReviews {
  int? id;
  int? userId;
  int? productId;
  int? rating;
  String? review;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? userProfile;

  LatestReviews(
      {this.id,
      this.userId,
      this.productId,
      this.rating,
      this.review,
      this.createdAt,
      this.updatedAt,
      this.userName,
      this.userProfile});

  LatestReviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    productId = json['product_id'];
    rating = json['rating'];
    review = json['review'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userName = json['user_name'];
    userProfile = json['user_profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['product_id'] = this.productId;
    data['rating'] = this.rating;
    data['review'] = this.review;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_name'] = this.userName;
    data['user_profile'] = this.userProfile;
    return data;
  }
}
