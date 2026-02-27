class GetRequestModel {
  int? status;
  String? message;
  Data? data;

  GetRequestModel({this.status, this.message, this.data});

  GetRequestModel.fromJson(Map<String, dynamic> json) {
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
  List<Requests>? requests;

  Data({this.requests});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['requests'] != null) {
      requests = <Requests>[];
      json['requests'].forEach((v) {
        requests!.add(Requests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.requests != null) {
      data['requests'] = this.requests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Requests {
  int? id;
  int? senderId;
  int? receiverId;
  String? status;
  String? createdAt;
  String? updatedAt;
  AppUserName? appUserName;

  Requests({
    this.id,
    this.senderId,
    this.receiverId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.appUserName,
  });

  Requests.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    appUserName =
        json['app_user_name'] != null
            ? AppUserName.fromJson(json['app_user_name'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['sender_id'] = this.senderId;
    data['receiver_id'] = this.receiverId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.appUserName != null) {
      data['app_user_name'] = this.appUserName!.toJson();
    }
    return data;
  }
}

class AppUserName {
  int? id;
  int? role;
  String? email;
  String? emailVerifiedAt;
  String? dPassword;
  var mobileNo;
  String? gender;
  String? dateOfBirth;
  Address? address;
  String? psLatitude;
  String? psLongitude;
  String? fcmToken;
  String? forgetPassKey;
  String? moduleLock;
  String? status;
  String? profile;
  String? createdAt;
  String? updatedAt;
  String? firstName;
  String? lastName;

  AppUserName({
    this.id,
    this.role,
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
    this.firstName,
    this.lastName,
  });

  AppUserName.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    psLatitude = json['ps_latitude'];
    psLongitude = json['ps_longitude'];
    fcmToken = json['fcm_token'];
    forgetPassKey = json['forget_pass_key'];
    moduleLock = json['module_lock'];
    status = json['status'];
    profile = json['profile'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['role'] = this.role;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['d_password'] = this.dPassword;
    data['mobile_no'] = this.mobileNo;
    data['gender'] = this.gender;
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
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    return data;
  }
}
