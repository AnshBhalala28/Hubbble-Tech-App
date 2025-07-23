class BusinessProfileModel {
  int? status;
  String? message;
  List<Data1>? data;

  BusinessProfileModel({this.status, this.message, this.data});

  BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data1>[];
      json['data'].forEach((v) {
        data!.add(new Data1.fromJson(v));
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

class Data1 {
  int? id;
  int? role;
  String? name;
  String? email;
  var emailVerifiedAt;
  var dPassword;
  int? mobileNo;
  String? gender;
  String? dateOfBirth;
  String? address;
  var fcmToken;
  var forgetPassKey;
  String? moduleLock;
  String? status;
  String? profile;
  String? createdAt;
  String? updatedAt;
  int? userId;
  int? subId;
  int? stripeSubscriptionId;
  String? logo;
  String? businessName;
  String? about;
  String? description;
  String? industry;
  int? categoryId;
  int? subCategoryId;
  List<Tags>? tags;
  String? businessServices;
  String? experience;
  String? businessAddress;
  String? subStartDate;
  String? subEndDate;
  String? subStatus;
  String? latitude;
  String? longitude;
  var media;
  String? creditBalance;
  double? distance;
  Category? category;
  SubCategory? subCategory;
  List<FeaturedPosts>? featuredPosts;
  var business;

  Data1({
    this.id,
    this.role,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.dPassword,
    this.mobileNo,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.fcmToken,
    this.forgetPassKey,
    this.moduleLock,
    this.status,
    this.profile,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.subId,
    this.stripeSubscriptionId,
    this.logo,
    this.businessName,
    this.about,
    this.description,
    this.industry,
    this.categoryId,
    this.subCategoryId,
    this.tags,
    this.businessServices,
    this.experience,
    this.businessAddress,
    this.subStartDate,
    this.subEndDate,
    this.subStatus,
    this.latitude,
    this.longitude,
    this.media,
    this.creditBalance,
    this.distance,
    this.category,
    this.subCategory,
    this.featuredPosts,
    this.business,
  });

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    address = json['address'];
    fcmToken = json['fcm_token'];
    forgetPassKey = json['forget_pass_key'];
    moduleLock = json['module_lock'];
    status = json['status'];
    profile = json['profile'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    subId = json['sub_id'];
    stripeSubscriptionId = json['stripe_subscription_id'];
    logo = json['logo'];
    businessName = json['business_name'];
    about = json['about'];
    description = json['description'];
    industry = json['industry'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(new Tags.fromJson(v));
      });
    }
    businessServices = json['business_services'];
    experience = json['experience'];
    businessAddress = json['business_address'];
    subStartDate = json['sub_start_date'];
    subEndDate = json['sub_end_date'];
    subStatus = json['sub_status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    media = json['media'];
    creditBalance = json['credit_balance'];
    distance = json['distance'];
    category =
        json['category'] != null
            ? new Category.fromJson(json['category'])
            : null;
    subCategory =
        json['sub_category'] != null
            ? new SubCategory.fromJson(json['sub_category'])
            : null;
    if (json['featured_posts'] != null) {
      featuredPosts = <FeaturedPosts>[];
      json['featured_posts'].forEach((v) {
        featuredPosts!.add(new FeaturedPosts.fromJson(v));
      });
    }
    business = json['business'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['d_password'] = this.dPassword;
    data['mobile_no'] = this.mobileNo;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    data['address'] = this.address;
    data['fcm_token'] = this.fcmToken;
    data['forget_pass_key'] = this.forgetPassKey;
    data['module_lock'] = this.moduleLock;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_id'] = this.userId;
    data['sub_id'] = this.subId;
    data['stripe_subscription_id'] = this.stripeSubscriptionId;
    data['logo'] = this.logo;
    data['business_name'] = this.businessName;
    data['about'] = this.about;
    data['description'] = this.description;
    data['industry'] = this.industry;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    data['business_services'] = this.businessServices;
    data['experience'] = this.experience;
    data['business_address'] = this.businessAddress;
    data['sub_start_date'] = this.subStartDate;
    data['sub_end_date'] = this.subEndDate;
    data['sub_status'] = this.subStatus;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['media'] = this.media;
    data['credit_balance'] = this.creditBalance;
    data['distance'] = this.distance;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.subCategory != null) {
      data['sub_category'] = this.subCategory!.toJson();
    }
    if (this.featuredPosts != null) {
      data['featured_posts'] =
          this.featuredPosts!.map((v) => v.toJson()).toList();
    }
    data['business'] = this.business;
    return data;
  }
}

class Tags {
  String? name;
  String? img;

  Tags({this.name, this.img});

  Tags.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['img'] = this.img;
    return data;
  }
}

class Category {
  int? categoryId;
  String? categoryName;

  Category({this.categoryId, this.categoryName});

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    return data;
  }
}

class SubCategory {
  int? subCategoryId;
  String? subCategoryName;

  SubCategory({this.subCategoryId, this.subCategoryName});

  SubCategory.fromJson(Map<String, dynamic> json) {
    subCategoryId = json['sub_category_id'];
    subCategoryName = json['sub_category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sub_category_id'] = this.subCategoryId;
    data['sub_category_name'] = this.subCategoryName;
    return data;
  }
}

class FeaturedPosts {
  int? id;
  String? type;
  String? file;
  String? status;

  FeaturedPosts({this.id, this.type, this.file, this.status});

  FeaturedPosts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    file = json['file'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['file'] = this.file;
    data['status'] = this.status;
    return data;
  }
}
