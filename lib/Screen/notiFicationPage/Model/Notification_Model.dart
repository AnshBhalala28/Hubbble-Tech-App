class NotificationModell {
  int? status;
  String? message;
  Data? data;

  NotificationModell({this.status, this.message, this.data});

  NotificationModell.fromJson(Map<String, dynamic> json) {
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
  List<Notifications>? notifications;
  int? totalCount;

  Data({this.notifications, this.totalCount});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      json['notifications'].forEach((v) {
        notifications!.add(new Notifications.fromJson(v));
      });
    }
    totalCount = json['total_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.notifications != null) {
      data['notifications'] =
          this.notifications!.map((v) => v.toJson()).toList();
    }
    data['total_count'] = this.totalCount;
    return data;
  }
}

class Notifications {
  int? id;
  int? bulidingId;
  String? appUserId;
  int? chatCreateId;
  String? data;
  String? type;
  String? msgTo;
  String? readAt;
  String? notificationDate;
  String? createdAt;
  String? updatedAt;
  ConciergeProfile? conciergeProfile;
  BusinessProfile? businessProfile;

  Notifications({
    this.id,
    this.bulidingId,
    this.appUserId,
    this.chatCreateId,
    this.data,
    this.type,
    this.msgTo,
    this.readAt,
    this.notificationDate,
    this.createdAt,
    this.updatedAt,
    this.conciergeProfile,
    this.businessProfile,
  });

  Notifications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bulidingId = json['buliding_id'];
    appUserId = json['app_user_id'];
    chatCreateId = json['chat_create_id'];
    data = json['data'];
    type = json['type'];
    msgTo = json['msg_to'];
    readAt = json['read_at'];
    notificationDate = json['notification_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    conciergeProfile =
    json['concierge_profile'] != null
        ? new ConciergeProfile.fromJson(json['concierge_profile'])
        : null;
    businessProfile =
    json['business_profile'] != null
        ? new BusinessProfile.fromJson(json['business_profile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['buliding_id'] = this.bulidingId;
    data['app_user_id'] = this.appUserId;
    data['chat_create_id'] = this.chatCreateId;
    data['data'] = this.data;
    data['type'] = this.type;
    data['msg_to'] = this.msgTo;
    data['read_at'] = this.readAt;
    data['notification_date'] = this.notificationDate;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.conciergeProfile != null) {
      data['concierge_profile'] = this.conciergeProfile!.toJson();
    }
    if (this.businessProfile != null) {
      data['business_profile'] = this.businessProfile!.toJson();
    }
    return data;
  }
}

class ConciergeProfile {
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
  List<String>? conciergeImage;
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

  ConciergeProfile({
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
  });

  ConciergeProfile.fromJson(Map<String, dynamic> json) {
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
    conciergeImage = json['concierge_image'].cast<String>();
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
    return data;
  }
}

class BusinessProfile {
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

  BusinessProfile({
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

  BusinessProfile.fromJson(Map<String, dynamic> json) {
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
