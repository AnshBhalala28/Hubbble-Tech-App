class ChatModel {
  int? status;
  String? message;
  Data? data;

  ChatModel({this.status, this.message, this.data});

  ChatModel.fromJson(Map<String, dynamic> json) {
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
  List<BusinessUsers>? businessUsers;
  List<Concierges>? concierges;

  Data({this.businessUsers, this.concierges});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['business_users'] != null) {
      businessUsers = <BusinessUsers>[];
      json['business_users'].forEach((v) {
        businessUsers!.add(new BusinessUsers.fromJson(v));
      });
    }
    if (json['concierges'] != null) {
      concierges = <Concierges>[];
      json['concierges'].forEach((v) {
        concierges!.add(new Concierges.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.businessUsers != null) {
      data['business_users'] =
          this.businessUsers!.map((v) => v.toJson()).toList();
    }
    if (this.concierges != null) {
      data['concierges'] = this.concierges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BusinessUsers {
  int? id;
  int? role;
  String? name;
  String? email;
  var emailVerifiedAt;
  String? dPassword;
  int? mobileNo;
  var gender;
  var dateOfBirth;
  Address? address;
  var psLatitude;
  var psLongitude;
  String? isOnline;
  var fcmToken;
  var forgetPassKey;
  var moduleLock;
  String? status;
  var profile;
  String? createdAt;
  String? updatedAt;
  String? lastMessage;
  String? lastMessageTime;
  String? lastOnlineAt;
  int? unreadCount;
  Business? business;

  BusinessUsers({
    this.id,
    this.role,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.dPassword,
    this.mobileNo,
    this.gender,
    this.dateOfBirth,
    this.isOnline,
    this.address,
    this.psLatitude,
    this.psLongitude,
    this.fcmToken,
    this.forgetPassKey,
    this.moduleLock,
    this.status,
    this.profile,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
    this.lastOnlineAt,
    this.business,
  });

  BusinessUsers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];
    isOnline = json['is_online'];
    dateOfBirth = json['date_of_birth'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    psLatitude = json['ps_latitude'];
    psLongitude = json['ps_longitude'];
    fcmToken = json['fcm_token'];
    forgetPassKey = json['forget_pass_key'];
    moduleLock = json['module_lock'];
    status = json['status'];
    profile = json['profile'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    lastMessage = json['last_message'];
    lastMessageTime = json['last_message_time'];
    unreadCount = json['unread_count'];
    lastOnlineAt = json['last_online_at'];
    business =
        json['business'] != null
            ? new Business.fromJson(json['business'])
            : null;
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
    data['is_online'] = this.isOnline;
    data['date_of_birth'] = this.dateOfBirth;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['ps_latitude'] = this.psLatitude;
    data['ps_longitude'] = this.psLongitude;
    data['fcm_token'] = this.fcmToken;
    data['forget_pass_key'] = this.forgetPassKey;
    data['module_lock'] = this.moduleLock;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['last_online_at'] = this.lastOnlineAt;
    data['last_message'] = this.lastMessage;
    data['last_message_time'] = this.lastMessageTime;
    data['unread_count'] = this.unreadCount;
    if (this.business != null) {
      data['business'] = this.business!.toJson();
    }
    return data;
  }
}

class Address {
  String? address;
  String? city;
  String? country;
  String? zipCode;

  Address({this.address, this.city, this.country, this.zipCode});

  Address.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    city = json['city'];
    country = json['country'];
    zipCode = json['zip_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    return data;
  }
}

class Business {
  int? id;
  int? userId;
  int? subId;
  String? stripeSubscriptionId;
  String? logo;
  String? businessName;
  String? about;
  String? description;
  String? industry;
  String? openingHours;
  String? website;
  int? categoryId;
  int? subCategoryId;
  var tags;
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
  int? isStripeConnected;
  var stripeAccessToken;
  String? onboardedAt;
  int? loyaltyOrderThreshold;
  String? loyaltyDiscountPercentage;
  int? serviceStatus;
  int? productStatus;
  int? chatStatus;
  String? createdAt;
  String? updatedAt;

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
    this.isStripeConnected,
    this.stripeAccessToken,
    this.onboardedAt,
    this.loyaltyOrderThreshold,
    this.loyaltyDiscountPercentage,
    this.serviceStatus,
    this.productStatus,
    this.chatStatus,
    this.createdAt,
    this.updatedAt,
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
    isStripeConnected = json['is_stripe_connected'];
    stripeAccessToken = json['stripe_access_token'];
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    data['is_stripe_connected'] = this.isStripeConnected;
    data['stripe_access_token'] = this.stripeAccessToken;
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

class Concierges {
  int? id;
  String? userId;
  int? buildingId;
  int? gateId;
  String? email;
  String? firstName;
  String? lastName;
  String? gender;
  String? dateOfBirth;
  String? phoneNumber;
  String? conciergeImage;
  var address;
  var city;
  var state;
  var country;
  var zipCode;
  var shiftStart;
  var shiftEnd;
  String? conStartTime;
  var conEndTime;
  String? livestatus;
  String? createdAt;
  String? updatedAt;
  var lastMessage;
  var lastMessageTime;
  int? unreadCount;

  Concierges({
    this.id,
    this.userId,
    this.buildingId,
    this.gateId,
    this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.phoneNumber,
    this.conciergeImage,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.shiftStart,
    this.shiftEnd,
    this.conStartTime,
    this.conEndTime,
    this.livestatus,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount,
  });

  Concierges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingId = json['building_id'];
    gateId = json['gate_id'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    phoneNumber = json['phone_number'];
    conciergeImage = json['concierge_image'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    zipCode = json['zip_code'];
    shiftStart = json['shift_start'];
    shiftEnd = json['shift_end'];
    conStartTime = json['con_start_time'];
    conEndTime = json['con_end_time'];
    livestatus = json['livestatus'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    lastMessage = json['last_message'];
    lastMessageTime = json['last_message_time'];
    unreadCount = json['unread_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['building_id'] = this.buildingId;
    data['gate_id'] = this.gateId;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    data['phone_number'] = this.phoneNumber;
    data['concierge_image'] = this.conciergeImage;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    data['shift_start'] = this.shiftStart;
    data['shift_end'] = this.shiftEnd;
    data['con_start_time'] = this.conStartTime;
    data['con_end_time'] = this.conEndTime;
    data['livestatus'] = this.livestatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['last_message'] = this.lastMessage;
    data['last_message_time'] = this.lastMessageTime;
    data['unread_count'] = this.unreadCount;
    return data;
  }
}
