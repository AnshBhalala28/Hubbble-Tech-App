class ServiceDetailsModel {
  int? status;
  String? message;
  Data? data;

  ServiceDetailsModel({this.status, this.message, this.data});

  ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
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
  List<String>? features;
  List<String>? benefits;
  String? availability;
  var typeOfService;
  var serviceProvider;
  var contactEmail;
  var contactPhone;
  var location;
  String? status;
  String? createdAt;
  String? updatedAt;
  Category? category;
  int? businessId;
  String? businessName;
  var productRating;

  String? categoryName;

  Data({
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
    this.category,
    this.businessId,
    this.businessName,
    this.productRating,
    this.categoryName,
  });

  Data.fromJson(Map<String, dynamic> json) {
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

    galleryImages =
        json['gallery_images'] != null
            ? List<String>.from(json['gallery_images'])
            : [];

    features =
        json['features'] != null ? List<String>.from(json['features']) : [];

    benefits =
        json['benefits'] != null ? List<String>.from(json['benefits']) : [];

    availability = json['availability'];
    typeOfService = json['type_of_service'];
    serviceProvider = json['service_provider'];
    contactEmail = json['contact_email'];
    contactPhone = json['contact_phone'];
    location = json['location'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    businessId = json['business_id'];
    businessName = json['business_name'];
    productRating = json['product_rating'];
    categoryName = json['category_name'];
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
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['business_id'] = this.businessId;
    data['business_name'] = this.businessName;
    data['product_rating'] = this.productRating;

    data['category_name'] = this.categoryName;
    return data;
  }
}

class Category {
  int? id;
  int? subCategoryId;
  String? name;
  String? createdAt;
  String? updatedAt;

  Category({
    this.id,
    this.subCategoryId,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subCategoryId = json['sub_category_id'];
    name = json['name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['sub_category_id'] = this.subCategoryId;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
