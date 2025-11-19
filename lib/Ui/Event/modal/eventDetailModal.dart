class EventDetailModal {
  int? status;
  String? message;
  Data? data;

  EventDetailModal({this.status, this.message, this.data});

  EventDetailModal.fromJson(Map<String, dynamic> json) {
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
  int? creatorId;
  String? title;
  var description;
  var apartmentNumber;
  String? attachment;
  String? eventDate;
  String? location;
  var latitude;
  var longitude;
  String? status;
  int? isDeleted;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? bio;
  String? eventTime;
  String? startTime;
  String? endTime;
  Creator? creator;
  List<Business>? business;

  Data({
    this.id,
    this.creatorId,
    this.title,
    this.description,
    this.apartmentNumber,
    this.attachment,
    this.eventDate,
    this.location,
    this.latitude,
    this.longitude,
    this.status,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.bio,
    this.eventTime,
    this.startTime,
    this.endTime,
    this.creator,
    this.business,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    creatorId = json['creator_id'];
    title = json['title'];
    description = json['description'];
    apartmentNumber = json['apartment_number'];
    attachment = json['attachment'];
    eventDate = json['event_date'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    bio = json['bio'];
    eventTime = json['event_time'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    if (json['business'] != null) {
      business = <Business>[];
      json['business'].forEach((v) {
        business!.add(Business.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['creator_id'] = this.creatorId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['apartment_number'] = this.apartmentNumber;
    data['attachment'] = this.attachment;
    data['event_date'] = this.eventDate;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['status'] = this.status;
    data['is_deleted'] = this.isDeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['bio'] = this.bio;
    data['event_time'] = this.eventTime;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    if (this.creator != null) {
      data['creator'] = this.creator!.toJson();
    }
    if (this.business != null) {
      data['business'] = this.business!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Creator {
  int? id;
  int? role;
  String? name;
  String? email;
  var emailVerifiedAt;
  var dPassword;
  var mobileNo;
  var gender;
  var dateOfBirth;
  String? address;
  var psLatitude;
  var psLongitude;
  var fcmToken;
  var forgetPassKey;
  var moduleLock;
  String? isOnline;
  String? lastOnlineAt;
  String? status;
  var profile;
  int? isDeleted;
  var deletedAt;
  String? createdAt;
  String? updatedAt;

  Creator({
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
    this.psLatitude,
    this.psLongitude,
    this.fcmToken,
    this.forgetPassKey,
    this.moduleLock,
    this.isOnline,
    this.lastOnlineAt,
    this.status,
    this.profile,
    this.isDeleted,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  Creator.fromJson(Map<String, dynamic> json) {
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
    psLatitude = json['ps_latitude'];
    psLongitude = json['ps_longitude'];
    fcmToken = json['fcm_token'];
    forgetPassKey = json['forget_pass_key'];
    moduleLock = json['module_lock'];
    isOnline = json['is_online'];
    lastOnlineAt = json['last_online_at'];
    status = json['status'];
    profile = json['profile'];
    isDeleted = json['is_deleted'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    data['ps_latitude'] = this.psLatitude;
    data['ps_longitude'] = this.psLongitude;
    data['fcm_token'] = this.fcmToken;
    data['forget_pass_key'] = this.forgetPassKey;
    data['module_lock'] = this.moduleLock;
    data['is_online'] = this.isOnline;
    data['last_online_at'] = this.lastOnlineAt;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['is_deleted'] = this.isDeleted;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Business {
  int? id;
  int? userId;
  int? subId;
  var stripeSubscriptionId;
  var logo;
  String? businessName;
  String? about;
  String? description;
  var industry;
  String? openingHours;
  var website;
  int? categoryId;
  int? subCategoryId;
  String? tags;
  var businessServices;
  String? experience;
  String? businessAddress;
  String? subStartDate;
  String? subEndDate;
  String? subStatus;
  String? latitude;
  String? longitude;
  var media;
  String? creditBalance;
  String? stripeAccountId;
  String? stripePrimaryAccountId;
  int? isStripeConnected;
  String? stripeAccessToken;
  String? onboardedAt;
  int? loyaltyOrderThreshold;
  String? loyaltyDiscountPercentage;
  int? serviceStatus;
  int? productStatus;
  int? chatStatus;
  int? isDeleted;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? loyaltyOnServiceId;
  var loyaltyOnServiceCatId;
  var loyaltyOnProductId;
  var loyaltyOnProductCatId;
  var cardNo;
  var cardExp;

  Business({
    this.id,
    this.userId,
    this.subId,
    this.stripeSubscriptionId,
    this.logo,
    this.businessName,
    this.about,
    this.description,
    this.industry,
    this.openingHours,
    this.website,
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
    this.stripeAccountId,
    this.stripePrimaryAccountId,
    this.isStripeConnected,
    this.stripeAccessToken,
    this.onboardedAt,
    this.loyaltyOrderThreshold,
    this.loyaltyDiscountPercentage,
    this.serviceStatus,
    this.productStatus,
    this.chatStatus,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.loyaltyOnServiceId,
    this.loyaltyOnServiceCatId,
    this.loyaltyOnProductId,
    this.loyaltyOnProductCatId,
    this.cardNo,
    this.cardExp,
  });

  Business.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    subId = json['sub_id'];
    stripeSubscriptionId = json['stripe_subscription_id'];
    logo = json['logo'];
    businessName = json['business_name'];
    about = json['about'];
    description = json['description'];
    industry = json['industry'];
    openingHours = json['opening_hours'];
    website = json['website'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    tags = json['tags'];
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
    stripeAccountId = json['stripe_account_id'];
    stripePrimaryAccountId = json['stripe_primary_account_id'];
    isStripeConnected = json['is_stripe_connected'];
    stripeAccessToken = json['stripe_access_token'];
    onboardedAt = json['onboarded_at'];
    loyaltyOrderThreshold = json['loyalty_order_threshold'];
    loyaltyDiscountPercentage = json['loyalty_discount_percentage'];
    serviceStatus = json['service_status'];
    productStatus = json['product_status'];
    chatStatus = json['chat_status'];
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    loyaltyOnServiceId = json['loyalty_on_service_id'];
    loyaltyOnServiceCatId = json['loyalty_on_service_cat_id'];
    loyaltyOnProductId = json['loyalty_on_product_id'];
    loyaltyOnProductCatId = json['loyalty_on_product_cat_id'];
    cardNo = json['card_no'];
    cardExp = json['card_exp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['sub_id'] = this.subId;
    data['stripe_subscription_id'] = this.stripeSubscriptionId;
    data['logo'] = this.logo;
    data['business_name'] = this.businessName;
    data['about'] = this.about;
    data['description'] = this.description;
    data['industry'] = this.industry;
    data['opening_hours'] = this.openingHours;
    data['website'] = this.website;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    data['tags'] = this.tags;
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
    data['stripe_account_id'] = this.stripeAccountId;
    data['stripe_primary_account_id'] = this.stripePrimaryAccountId;
    data['is_stripe_connected'] = this.isStripeConnected;
    data['stripe_access_token'] = this.stripeAccessToken;
    data['onboarded_at'] = this.onboardedAt;
    data['loyalty_order_threshold'] = this.loyaltyOrderThreshold;
    data['loyalty_discount_percentage'] = this.loyaltyDiscountPercentage;
    data['service_status'] = this.serviceStatus;
    data['product_status'] = this.productStatus;
    data['chat_status'] = this.chatStatus;
    data['is_deleted'] = this.isDeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['loyalty_on_service_id'] = this.loyaltyOnServiceId;
    data['loyalty_on_service_cat_id'] = this.loyaltyOnServiceCatId;
    data['loyalty_on_product_id'] = this.loyaltyOnProductId;
    data['loyalty_on_product_cat_id'] = this.loyaltyOnProductCatId;
    data['card_no'] = this.cardNo;
    data['card_exp'] = this.cardExp;
    return data;
  }
}
