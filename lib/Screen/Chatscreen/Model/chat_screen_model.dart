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
  String? emailVerifiedAt;
  String? dPassword;
  int? mobileNo;
  String? gender;
  String? dateOfBirth;
  Address? address;
  String? fcmToken;
  String? forgetPassKey;
  String? moduleLock;
  String? status;
  String? profile;
  String? createdAt;
  String? updatedAt;
  String? lastMessage;
  String? lastMessageTime;
  int? unreadCount;
  Business? business;

  BusinessUsers(
      {this.id,
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
      this.lastMessage,
      this.lastMessageTime,
      this.unreadCount,
      this.business});

  BusinessUsers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
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
    business = json['business'] != null
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
    data['date_of_birth'] = this.dateOfBirth;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['fcm_token'] = this.fcmToken;
    data['forget_pass_key'] = this.forgetPassKey;
    data['module_lock'] = this.moduleLock;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
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
  int? categoryId;
  int? subCategoryId;
  String? tags;
  String? businessServices;
  String? experience;
  String? businessAddress;
  String? subStartDate;
  String? subEndDate;
  String? subStatus;
  String? latitude;
  String? longitude;
  String? media;
  String? creditBalance;
  String? createdAt;
  String? updatedAt;

  Business(
      {this.id,
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
      this.createdAt,
      this.updatedAt});

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
  String? address;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  String? shiftStart;
  String? shiftEnd;
  String? conStartTime;
  String? conEndTime;
  String? livestatus;
  String? createdAt;
  String? updatedAt;
  String? lastMessage;
  String? lastMessageTime;
  int? unreadCount;

  Concierges(
      {this.id,
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
      this.unreadCount});

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

// class ChatModel {
//   int? status;
//   String? message;
//   Data? data;
//
//   ChatModel({this.status, this.message, this.data});
//
//   ChatModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   List<BusinessUsers>? businessUsers;
//   List<Concierges>? concierges;
//
//   Data({this.businessUsers, this.concierges});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     if (json['business_users'] != null) {
//       businessUsers = <BusinessUsers>[];
//       json['business_users'].forEach((v) {
//         businessUsers!.add(new BusinessUsers.fromJson(v));
//       });
//     }
//     if (json['concierges'] != null) {
//       concierges = <Concierges>[];
//       json['concierges'].forEach((v) {
//         concierges!.add(new Concierges.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.businessUsers != null) {
//       data['business_users'] =
//           this.businessUsers!.map((v) => v.toJson()).toList();
//     }
//     if (this.concierges != null) {
//       data['concierges'] = this.concierges!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class BusinessUsers {
//   int? id;
//   int? role;
//   String? name;
//   String? email;
//   String? emailVerifiedAt;
//   String? dPassword;
//   int? mobileNo;
//   String? gender;
//   Address? address;
//   String? fcmToken;
//   String? forgetPassKey;
//   String? moduleLock;
//   String? status;
//   String? profile;
//   String? createdAt;
//   String? updatedAt;
//   String? lastMessage;
//   String? lastMessageTime;
//   int? unreadCount;
//   Business? business;
//
//   BusinessUsers(
//       {this.id,
//       this.role,
//       this.name,
//       this.email,
//       this.emailVerifiedAt,
//       this.dPassword,
//       this.mobileNo,
//       this.gender,
//       this.address,
//       this.fcmToken,
//       this.forgetPassKey,
//       this.moduleLock,
//       this.status,
//       this.profile,
//       this.createdAt,
//       this.updatedAt,
//       this.lastMessage,
//       this.lastMessageTime,
//       this.unreadCount,
//       this.business});
//
//   BusinessUsers.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     role = json['role'];
//     name = json['name'];
//     email = json['email'];
//     emailVerifiedAt = json['email_verified_at'];
//     dPassword = json['d_password'];
//     mobileNo = json['mobile_no'];
//     gender = json['gender'];
//     address =
//         json['address'] != null ? new Address.fromJson(json['address']) : null;
//     fcmToken = json['fcm_token'];
//     forgetPassKey = json['forget_pass_key'];
//     moduleLock = json['module_lock'];
//     status = json['status'];
//     profile = json['profile'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     lastMessage = json['last_message'];
//     lastMessageTime = json['last_message_time'];
//     unreadCount = json['unread_count'];
//     business = json['business'] != null
//         ? new Business.fromJson(json['business'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['role'] = this.role;
//     data['name'] = this.name;
//     data['email'] = this.email;
//     data['email_verified_at'] = this.emailVerifiedAt;
//     data['d_password'] = this.dPassword;
//     data['mobile_no'] = this.mobileNo;
//     data['gender'] = this.gender;
//     if (this.address != null) {
//       data['address'] = this.address!.toJson();
//     }
//     data['fcm_token'] = this.fcmToken;
//     data['forget_pass_key'] = this.forgetPassKey;
//     data['module_lock'] = this.moduleLock;
//     data['status'] = this.status;
//     data['profile'] = this.profile;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['last_message'] = this.lastMessage;
//     data['last_message_time'] = this.lastMessageTime;
//     data['unread_count'] = this.unreadCount;
//     if (this.business != null) {
//       data['business'] = this.business!.toJson();
//     }
//     return data;
//   }
// }
//
// class Address {
//   String? address;
//   String? city;
//   String? country;
//   var zipCode;
//
//   Address({this.address, this.city, this.country, this.zipCode});
//
//   Address.fromJson(Map<String, dynamic> json) {
//     address = json['address'];
//     city = json['city'];
//     country = json['country'];
//     zipCode = json['zip_code'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['address'] = this.address;
//     data['city'] = this.city;
//     data['country'] = this.country;
//     data['zip_code'] = this.zipCode;
//     return data;
//   }
// }
//
// class Business {
//   int? id;
//   int? userId;
//   int? subId;
//   int? stripeSubscriptionId;
//   String? logo;
//   String? businessName;
//   String? about;
//   String? description;
//   String? industry;
//   String? businessServices;
//   String? experience;
//   String? businessAddress;
//   String? subStartDate;
//   String? subEndDate;
//   String? subStatus;
//   String? latitude;
//   String? longitude;
//   String? media;
//   String? creditBalance;
//   String? createdAt;
//   String? updatedAt;
//
//   Business(
//       {this.id,
//       this.userId,
//       this.subId,
//       this.stripeSubscriptionId,
//       this.logo,
//       this.businessName,
//       this.about,
//       this.description,
//       this.industry,
//       this.businessServices,
//       this.experience,
//       this.businessAddress,
//       this.subStartDate,
//       this.subEndDate,
//       this.subStatus,
//       this.latitude,
//       this.longitude,
//       this.media,
//       this.creditBalance,
//       this.createdAt,
//       this.updatedAt});
//
//   Business.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     subId = json['sub_id'];
//     stripeSubscriptionId = json['stripe_subscription_id'];
//     logo = json['logo'];
//     businessName = json['business_name'];
//     about = json['about'];
//     description = json['description'];
//     industry = json['industry'];
//     businessServices = json['business_services'];
//     experience = json['experience'];
//     businessAddress = json['business_address'];
//     subStartDate = json['sub_start_date'];
//     subEndDate = json['sub_end_date'];
//     subStatus = json['sub_status'];
//     latitude = json['latitude'];
//     longitude = json['longitude'];
//     media = json['media'];
//     creditBalance = json['credit_balance'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['sub_id'] = this.subId;
//     data['stripe_subscription_id'] = this.stripeSubscriptionId;
//     data['logo'] = this.logo;
//     data['business_name'] = this.businessName;
//     data['about'] = this.about;
//     data['description'] = this.description;
//     data['industry'] = this.industry;
//     data['business_services'] = this.businessServices;
//     data['experience'] = this.experience;
//     data['business_address'] = this.businessAddress;
//     data['sub_start_date'] = this.subStartDate;
//     data['sub_end_date'] = this.subEndDate;
//     data['sub_status'] = this.subStatus;
//     data['latitude'] = this.latitude;
//     data['longitude'] = this.longitude;
//     data['media'] = this.media;
//     data['credit_balance'] = this.creditBalance;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class Concierges {
//   int? id;
//   String? userId;
//   int? buildingId;
//   int? gateId;
//   String? email;
//   String? firstName;
//   String? lastName;
//   String? gender;
//   String? dateOfBirth;
//   String? phoneNumber;
//   String? conciergeImage;
//   String? address;
//   String? city;
//   String? state;
//   String? country;
//   String? zipCode;
//   String? shiftStart;
//   String? shiftEnd;
//   String? conStartTime;
//   String? conEndTime;
//   String? livestatus;
//   String? createdAt;
//   String? updatedAt;
//   String? lastMessage;
//   String? lastMessageTime;
//   int? unreadCount;
//
//   Concierges(
//       {this.id,
//       this.userId,
//       this.buildingId,
//       this.gateId,
//       this.email,
//       this.firstName,
//       this.lastName,
//       this.gender,
//       this.dateOfBirth,
//       this.phoneNumber,
//       this.conciergeImage,
//       this.address,
//       this.city,
//       this.state,
//       this.country,
//       this.zipCode,
//       this.shiftStart,
//       this.shiftEnd,
//       this.conStartTime,
//       this.conEndTime,
//       this.livestatus,
//       this.createdAt,
//       this.updatedAt,
//       this.lastMessage,
//       this.lastMessageTime,
//       this.unreadCount});
//
//   Concierges.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     buildingId = json['building_id'];
//     gateId = json['gate_id'];
//     email = json['email'];
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//     gender = json['gender'];
//     dateOfBirth = json['date_of_birth'];
//     phoneNumber = json['phone_number'];
//     conciergeImage = json['concierge_image'];
//     address = json['address'];
//     city = json['city'];
//     state = json['state'];
//     country = json['country'];
//     zipCode = json['zip_code'];
//     shiftStart = json['shift_start'];
//     shiftEnd = json['shift_end'];
//     conStartTime = json['con_start_time'];
//     conEndTime = json['con_end_time'];
//     livestatus = json['livestatus'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     lastMessage = json['last_message'];
//     lastMessageTime = json['last_message_time'];
//     unreadCount = json['unread_count'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['building_id'] = this.buildingId;
//     data['gate_id'] = this.gateId;
//     data['email'] = this.email;
//     data['first_name'] = this.firstName;
//     data['last_name'] = this.lastName;
//     data['gender'] = this.gender;
//     data['date_of_birth'] = this.dateOfBirth;
//     data['phone_number'] = this.phoneNumber;
//     data['concierge_image'] = this.conciergeImage;
//     data['address'] = this.address;
//     data['city'] = this.city;
//     data['state'] = this.state;
//     data['country'] = this.country;
//     data['zip_code'] = this.zipCode;
//     data['shift_start'] = this.shiftStart;
//     data['shift_end'] = this.shiftEnd;
//     data['con_start_time'] = this.conStartTime;
//     data['con_end_time'] = this.conEndTime;
//     data['livestatus'] = this.livestatus;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['last_message'] = this.lastMessage;
//     data['last_message_time'] = this.lastMessageTime;
//     data['unread_count'] = this.unreadCount;
//     return data;
//   }
// }
