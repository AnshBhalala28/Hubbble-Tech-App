class ChatStoryModal {
  int? status;
  String? message;
  List<Data>? data;

  ChatStoryModal({this.status, this.message, this.data});

  ChatStoryModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
  int? role;
  String? name;
  String? email;
  String? dPassword;
  var mobileNo;
  String? address;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? userId;
  int? subId;
  String? logo;
  String? businessName;
  String? description;
  String? openingHours;
  String? website;
  int? categoryId;
  int? subCategoryId;
  String? experience;
  String? businessAddress;
  String? subStartDate;
  String? subEndDate;
  String? subStatus;
  String? latitude;
  String? longitude;
  String? creditBalance;
  String? stripeAccountId;
  int? isStripeConnected;
  String? onboardedAt;
  int? loyaltyOrderThreshold;
  String? loyaltyDiscountPercentage;
  int? serviceStatus;
  int? productStatus;
  int? chatStatus;
  double? distance;
  List<Posts>? posts;

  Data({
    this.id,
    this.role,
    this.name,
    this.email,
    this.dPassword,
    this.mobileNo,
    this.address,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.subId,
    this.logo,
    this.businessName,
    this.description,
    this.openingHours,
    this.website,
    this.categoryId,
    this.subCategoryId,
    this.experience,
    this.businessAddress,
    this.subStartDate,
    this.subEndDate,
    this.subStatus,
    this.latitude,
    this.longitude,
    this.creditBalance,
    this.stripeAccountId,
    this.isStripeConnected,
    this.onboardedAt,
    this.loyaltyOrderThreshold,
    this.loyaltyDiscountPercentage,
    this.serviceStatus,
    this.productStatus,
    this.chatStatus,
    this.distance,
    this.posts,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    address = json['address'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    subId = json['sub_id'];
    logo = json['logo'];
    businessName = json['business_name'];
    description = json['description'];
    openingHours = json['opening_hours'];
    website = json['website'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    experience = json['experience'];
    businessAddress = json['business_address'];
    subStartDate = json['sub_start_date'];
    subEndDate = json['sub_end_date'];
    subStatus = json['sub_status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    creditBalance = json['credit_balance'];
    stripeAccountId = json['stripe_account_id'];
    isStripeConnected = json['is_stripe_connected'];
    onboardedAt = json['onboarded_at'];
    loyaltyOrderThreshold = json['loyalty_order_threshold'];
    loyaltyDiscountPercentage = json['loyalty_discount_percentage'];
    serviceStatus = json['service_status'];
    productStatus = json['product_status'];
    chatStatus = json['chat_status'];
    distance = json['distance'];
    if (json['posts'] != null) {
      posts = <Posts>[];
      json['posts'].forEach((v) {
        posts!.add(Posts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['role'] = this.role;
    data['name'] = this.name;
    data['email'] = this.email;
    data['d_password'] = this.dPassword;
    data['mobile_no'] = this.mobileNo;
    data['address'] = this.address;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_id'] = this.userId;
    data['sub_id'] = this.subId;
    data['logo'] = this.logo;
    data['business_name'] = this.businessName;
    data['description'] = this.description;
    data['opening_hours'] = this.openingHours;
    data['website'] = this.website;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    data['experience'] = this.experience;
    data['business_address'] = this.businessAddress;
    data['sub_start_date'] = this.subStartDate;
    data['sub_end_date'] = this.subEndDate;
    data['sub_status'] = this.subStatus;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['credit_balance'] = this.creditBalance;
    data['stripe_account_id'] = this.stripeAccountId;
    data['is_stripe_connected'] = this.isStripeConnected;
    data['onboarded_at'] = this.onboardedAt;
    data['loyalty_order_threshold'] = this.loyaltyOrderThreshold;
    data['loyalty_discount_percentage'] = this.loyaltyDiscountPercentage;
    data['service_status'] = this.serviceStatus;
    data['product_status'] = this.productStatus;
    data['chat_status'] = this.chatStatus;
    data['distance'] = this.distance;
    if (this.posts != null) {
      data['posts'] = this.posts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Posts {
  int? id;
  int? userId;
  String? type;
  String? file;
  String? status;
  int? isFeatured;
  int? order;
  String? createdAt;
  String? updatedAt;
  int? viewCount;
  int? likeCount;
  UserName? userName;

  Posts({
    this.id,
    this.userId,
    this.type,
    this.file,
    this.status,
    this.isFeatured,
    this.order,
    this.createdAt,
    this.updatedAt,
    this.viewCount,
    this.likeCount,
    this.userName,
  });

  Posts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    type = json['type'];
    file = json['file'];
    status = json['status'];
    isFeatured = json['is_featured'];
    order = json['order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    viewCount = json['view_count'];
    likeCount = json['like_count'];
    userName =
        json['user_name'] != null ? UserName.fromJson(json['user_name']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['type'] = this.type;
    data['file'] = this.file;
    data['status'] = this.status;
    data['is_featured'] = this.isFeatured;
    data['order'] = this.order;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['view_count'] = this.viewCount;
    data['like_count'] = this.likeCount;
    if (this.userName != null) {
      data['user_name'] = this.userName!.toJson();
    }
    return data;
  }
}

class UserName {
  int? id;
  int? userId;
  int? subId;
  String? logo;
  String? businessName;
  String? description;
  String? openingHours;
  String? website;
  int? categoryId;
  int? subCategoryId;
  String? experience;
  String? businessAddress;
  String? subStartDate;
  String? subEndDate;
  String? subStatus;
  String? latitude;
  String? longitude;
  String? creditBalance;
  String? stripeAccountId;
  int? isStripeConnected;
  String? onboardedAt;
  int? loyaltyOrderThreshold;
  String? loyaltyDiscountPercentage;
  int? serviceStatus;
  int? productStatus;
  int? chatStatus;
  String? createdAt;
  String? updatedAt;

  UserName({
    this.id,
    this.userId,
    this.subId,
    this.logo,
    this.businessName,
    this.description,
    this.openingHours,
    this.website,
    this.categoryId,
    this.subCategoryId,
    this.experience,
    this.businessAddress,
    this.subStartDate,
    this.subEndDate,
    this.subStatus,
    this.latitude,
    this.longitude,
    this.creditBalance,
    this.stripeAccountId,
    this.isStripeConnected,
    this.onboardedAt,
    this.loyaltyOrderThreshold,
    this.loyaltyDiscountPercentage,
    this.serviceStatus,
    this.productStatus,
    this.chatStatus,
    this.createdAt,
    this.updatedAt,
  });

  UserName.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    subId = json['sub_id'];
    logo = json['logo'];
    businessName = json['business_name'];
    description = json['description'];
    openingHours = json['opening_hours'];
    website = json['website'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    experience = json['experience'];
    businessAddress = json['business_address'];
    subStartDate = json['sub_start_date'];
    subEndDate = json['sub_end_date'];
    subStatus = json['sub_status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    creditBalance = json['credit_balance'];
    stripeAccountId = json['stripe_account_id'];
    isStripeConnected = json['is_stripe_connected'];
    onboardedAt = json['onboarded_at'];
    loyaltyOrderThreshold = json['loyalty_order_threshold'];
    loyaltyDiscountPercentage = json['loyalty_discount_percentage'];
    serviceStatus = json['service_status'];
    productStatus = json['product_status'];
    chatStatus = json['chat_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['sub_id'] = this.subId;
    data['logo'] = this.logo;
    data['business_name'] = this.businessName;
    data['description'] = this.description;
    data['opening_hours'] = this.openingHours;
    data['website'] = this.website;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    data['experience'] = this.experience;
    data['business_address'] = this.businessAddress;
    data['sub_start_date'] = this.subStartDate;
    data['sub_end_date'] = this.subEndDate;
    data['sub_status'] = this.subStatus;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['credit_balance'] = this.creditBalance;
    data['stripe_account_id'] = this.stripeAccountId;
    data['is_stripe_connected'] = this.isStripeConnected;
    data['onboarded_at'] = this.onboardedAt;
    data['loyalty_order_threshold'] = this.loyaltyOrderThreshold;
    data['loyalty_discount_percentage'] = this.loyaltyDiscountPercentage;
    data['service_status'] = this.serviceStatus;
    data['product_status'] = this.productStatus;
    data['chat_status'] = this.chatStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
