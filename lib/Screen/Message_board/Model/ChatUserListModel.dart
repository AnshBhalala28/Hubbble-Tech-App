class ChatUserListModel {
  int? status;
  String? message;
  List<Data>? data;

  ChatUserListModel({this.status, this.message, this.data});

  ChatUserListModel.fromJson(Map<String, dynamic> json) {
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
  int? createId;
  int? unitsId;
  String? residentType;
  String? createdAt;
  String? updatedAt;
  List<String>? requestStatuses;
  User? user;

  Data(
      {this.id,
      this.userId,
      this.createId,
      this.unitsId,
      this.residentType,
      this.createdAt,
      this.updatedAt,
      this.requestStatuses,
      this.user});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    createId = json['create_id'];
    unitsId = json['units_id'];
    residentType = json['resident_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    requestStatuses = json['request_statuses'].cast<String>();
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['create_id'] = this.createId;
    data['units_id'] = this.unitsId;
    data['resident_type'] = this.residentType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['request_statuses'] = this.requestStatuses;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  int? role;
  String? email;
  String? emailVerifiedAt;
  String? dPassword;
  int? mobileNo;
  String? gender;
  String? dateOfBirth;
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
  String? city;
  String? country;
  String? zipCode;

  User(
      {this.id,
      this.role,
      this.email,
      this.emailVerifiedAt,
      this.dPassword,
      this.mobileNo,
      this.gender,
      this.dateOfBirth,
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
      this.city,
      this.country,
      this.zipCode});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
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
    city = json['city'];
    country = json['country'];
    zipCode = json['zip_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['d_password'] = this.dPassword;
    data['mobile_no'] = this.mobileNo;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
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
    data['city'] = this.city;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    return data;
  }
}
