class BusnessSearchModal {
  int? status;
  String? message;
  List<Data>? data;

  BusnessSearchModal({this.status, this.message, this.data});

  BusnessSearchModal.fromJson(Map<String, dynamic> json) {
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
  int? subId;
  int? stripeSubscriptionId;
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
  User? user;

  Data({
    this.id,
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
    this.updatedAt,
    this.user,
  });

  Data.fromJson(Map<String, dynamic> json) {
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
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
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
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  int? role;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? dPassword;
  int? mobileNo;
  String? gender;
  String? dateOfBirth;
  String? address;
  String? psLatitude;
  String? psLongitude;
  String? fcmToken;
  String? forgetPassKey;
  String? moduleLock;
  String? status;
  String? profile;
  String? createdAt;
  String? updatedAt;

  User({
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
    this.status,
    this.profile,
    this.createdAt,
    this.updatedAt,
  });

  User.fromJson(Map<String, dynamic> json) {
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
    status = json['status'];
    profile = json['profile'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    data['ps_latitude'] = this.psLatitude;
    data['ps_longitude'] = this.psLongitude;
    data['fcm_token'] = this.fcmToken;
    data['forget_pass_key'] = this.forgetPassKey;
    data['module_lock'] = this.moduleLock;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
