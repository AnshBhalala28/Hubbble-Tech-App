//
// class LatestVisitorModal {
//   int? status;
//   String? message;
//   Data? data;
//
//   LatestVisitorModal({this.status, this.message, this.data});
//
//   LatestVisitorModal.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
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
//   int? currentPage;
//   List<Data1>? data;
//   String? firstPageUrl;
//   int? from;
//   int? lastPage;
//   String? lastPageUrl;
//   List<Links>? links;
//   var nextPageUrl;
//   String? path;
//   int? perPage;
//   var prevPageUrl;
//   int? to;
//   int? total;
//   int? totalPages;
//
//   Data({
//     this.currentPage,
//     this.data,
//     this.firstPageUrl,
//     this.from,
//     this.lastPage,
//     this.lastPageUrl,
//     this.links,
//     this.nextPageUrl,
//     this.path,
//     this.perPage,
//     this.prevPageUrl,
//     this.to,
//     this.total,
//     this.totalPages,
//   });
//
//   Data.fromJson(Map<String, dynamic> json) {
//     currentPage = json['current_page'];
//     if (json['data'] != null) {
//       data = <Data1>[];
//       json['data'].forEach((v) {
//         data!.add(Data1.fromJson(v));
//       });
//     }
//     firstPageUrl = json['first_page_url'];
//     from = json['from'];
//     lastPage = json['last_page'];
//     lastPageUrl = json['last_page_url'];
//     if (json['links'] != null) {
//       links = <Links>[];
//       json['links'].forEach((v) {
//         links!.add(Links.fromJson(v));
//       });
//     }
//     nextPageUrl = json['next_page_url'];
//     path = json['path'];
//     perPage = json['per_page'];
//     prevPageUrl = json['prev_page_url'];
//     to = json['to'];
//     total = json['total'];
//     totalPages = json['total_pages'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['current_page'] = this.currentPage;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     data['first_page_url'] = this.firstPageUrl;
//     data['from'] = this.from;
//     data['last_page'] = this.lastPage;
//     data['last_page_url'] = this.lastPageUrl;
//     if (this.links != null) {
//       data['links'] = this.links!.map((v) => v.toJson()).toList();
//     }
//     data['next_page_url'] = this.nextPageUrl;
//     data['path'] = this.path;
//     data['per_page'] = this.perPage;
//     data['prev_page_url'] = this.prevPageUrl;
//     data['to'] = this.to;
//     data['total'] = this.total;
//     data['total_pages'] = this.totalPages;
//     return data;
//   }
// }
//
// class Data1 {
//   int? id;
//   int? userId;
//   Null gateId;
//   int? reasonId;
//   int? unitId;
//   String? concigereId;
//   String? visitorName;
//   String? visitorPhone;
//   String? checkInDate;
//   String? checkInTime;
//   String? checkOutDate;
//   String? checkOutTime;
//   var inNote;
//   var outNote;
//   String? keyLog;
//   var isContractors;
//   var deletedAt;
//   String? createdAt;
//   String? updatedAt;
//   User? user;
//   Reason? reason;
//
//   Data1({
//     this.id,
//     this.userId,
//     this.gateId,
//     this.reasonId,
//     this.unitId,
//     this.concigereId,
//     this.visitorName,
//     this.visitorPhone,
//     this.checkInDate,
//     this.checkInTime,
//     this.checkOutDate,
//     this.checkOutTime,
//     this.inNote,
//     this.outNote,
//     this.keyLog,
//     this.isContractors,
//     this.deletedAt,
//     this.createdAt,
//     this.updatedAt,
//     this.user,
//     this.reason,
//   });
//
//   Data1.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     gateId = json['gate_id'];
//     reasonId = json['reason_id'];
//     unitId = json['unit_id'];
//     concigereId = json['concigere_id'];
//     visitorName = json['visitor_name'];
//     visitorPhone = json['visitor_phone'];
//     checkInDate = json['check_in_date'];
//     checkInTime = json['check_in_time'];
//     checkOutDate = json['check_out_date'];
//     checkOutTime = json['check_out_time'];
//     inNote = json['in_note'];
//     outNote = json['out_note'];
//     keyLog = json['key_log'];
//     isContractors = json['is_contractors'];
//     deletedAt = json['deleted_at'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     user = json['user'] != null ? User.fromJson(json['user']) : null;
//     reason = json['reason'] != null ? Reason.fromJson(json['reason']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['gate_id'] = this.gateId;
//     data['reason_id'] = this.reasonId;
//     data['unit_id'] = this.unitId;
//     data['concigere_id'] = this.concigereId;
//     data['visitor_name'] = this.visitorName;
//     data['visitor_phone'] = this.visitorPhone;
//     data['check_in_date'] = this.checkInDate;
//     data['check_in_time'] = this.checkInTime;
//     data['check_out_date'] = this.checkOutDate;
//     data['check_out_time'] = this.checkOutTime;
//     data['in_note'] = this.inNote;
//     data['out_note'] = this.outNote;
//     data['key_log'] = this.keyLog;
//     data['is_contractors'] = this.isContractors;
//     data['deleted_at'] = this.deletedAt;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.user != null) {
//       data['user'] = this.user!.toJson();
//     }
//     if (this.reason != null) {
//       data['reason'] = this.reason!.toJson();
//     }
//     return data;
//   }
// }
//
// class User {
//   int? id;
//   int? role;
//   String? name;
//   String? email;
//   var emailVerifiedAt;
//   String? dPassword;
//   var mobileNo;
//   String? gender;
//   var dateOfBirth;
//   String? address;
//   var psLatitude;
//   var psLongitude;
//   var fcmToken;
//   var forgetPassKey;
//   String? moduleLock;
//   String? isOnline;
//   var lastOnlineAt;
//   String? status;
//   String? profile;
//   int? isDeleted;
//   var deletedAt;
//   String? createdAt;
//   String? updatedAt;
//   Addressh? addressh;
//   List<String>? profilepath;
//
//   User({
//     this.id,
//     this.role,
//     this.name,
//     this.email,
//     this.emailVerifiedAt,
//     this.dPassword,
//     this.mobileNo,
//     this.gender,
//     this.dateOfBirth,
//     this.address,
//     this.psLatitude,
//     this.psLongitude,
//     this.fcmToken,
//     this.forgetPassKey,
//     this.moduleLock,
//     this.isOnline,
//     this.lastOnlineAt,
//     this.status,
//     this.profile,
//     this.isDeleted,
//     this.deletedAt,
//     this.createdAt,
//     this.updatedAt,
//     this.addressh,
//     this.profilepath,
//   });
//
//   User.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     role = json['role'];
//     name = json['name'];
//     email = json['email'];
//     emailVerifiedAt = json['email_verified_at'];
//     dPassword = json['d_password'];
//     mobileNo = json['mobile_no'];
//     gender = json['gender'];
//     dateOfBirth = json['date_of_birth'];
//     address = json['address'];
//     psLatitude = json['ps_latitude'];
//     psLongitude = json['ps_longitude'];
//     fcmToken = json['fcm_token'];
//     forgetPassKey = json['forget_pass_key'];
//     moduleLock = json['module_lock'];
//     isOnline = json['is_online'];
//     lastOnlineAt = json['last_online_at'];
//     status = json['status'];
//     profile = json['profile'];
//     isDeleted = json['is_deleted'];
//     deletedAt = json['deleted_at'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     addressh =
//         json['addressh'] != null ? Addressh.fromJson(json['addressh']) : null;
//     profilepath = json['profilepath'].cast<String>();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['role'] = this.role;
//     data['name'] = this.name;
//     data['email'] = this.email;
//     data['email_verified_at'] = this.emailVerifiedAt;
//     data['d_password'] = this.dPassword;
//     data['mobile_no'] = this.mobileNo;
//     data['gender'] = this.gender;
//     data['date_of_birth'] = this.dateOfBirth;
//     data['address'] = this.address;
//     data['ps_latitude'] = this.psLatitude;
//     data['ps_longitude'] = this.psLongitude;
//     data['fcm_token'] = this.fcmToken;
//     data['forget_pass_key'] = this.forgetPassKey;
//     data['module_lock'] = this.moduleLock;
//     data['is_online'] = this.isOnline;
//     data['last_online_at'] = this.lastOnlineAt;
//     data['status'] = this.status;
//     data['profile'] = this.profile;
//     data['is_deleted'] = this.isDeleted;
//     data['deleted_at'] = this.deletedAt;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.addressh != null) {
//       data['addressh'] = this.addressh!.toJson();
//     }
//     data['profilepath'] = this.profilepath;
//     return data;
//   }
// }
//
// class Addressh {
//   String? street;
//   String? city;
//   String? state;
//   String? country;
//
//   Addressh({this.street, this.city, this.state, this.country});
//
//   Addressh.fromJson(Map<String, dynamic> json) {
//     street = json['street'];
//     city = json['city'];
//     state = json['state'];
//     country = json['country'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['street'] = this.street;
//     data['city'] = this.city;
//     data['state'] = this.state;
//     data['country'] = this.country;
//     return data;
//   }
// }
//
// class Reason {
//   int? id;
//   int? userId;
//   String? reason;
//   String? createdAt;
//   String? updatedAt;
//
//   Reason({this.id, this.userId, this.reason, this.createdAt, this.updatedAt});
//
//   Reason.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     reason = json['reason'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['reason'] = this.reason;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class Links {
//   String? url;
//   String? label;
//   bool? active;
//
//   Links({this.url, this.label, this.active});
//
//   Links.fromJson(Map<String, dynamic> json) {
//     url = json['url'];
//     label = json['label'];
//     active = json['active'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['url'] = this.url;
//     data['label'] = this.label;
//     data['active'] = this.active;
//     return data;
//   }
// }
class LatestVisitorModal {
  int? status;
  String? message;
  Data? data;

  LatestVisitorModal({this.status, this.message, this.data});

  LatestVisitorModal.fromJson(Map<String, dynamic> json) {
    status = _safeInt(json['status']);
    message = json['message']?.toString();
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  dynamic currentPage;
  List<Data1>? data;
  dynamic firstPageUrl;
  dynamic from;
  dynamic lastPage;
  dynamic lastPageUrl;
  List<Links>? links;
  dynamic nextPageUrl;
  dynamic path;
  dynamic perPage;
  dynamic prevPageUrl;
  dynamic to;
  dynamic total;
  dynamic totalPages;

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    data = _safeList<Data1>(json['data'], (v) => Data1.fromJson(v));
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    links = _safeList<Links>(json['links'], (v) => Links.fromJson(v));
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
    totalPages = json['total_pages'];
  }
}

class Data1 {
  dynamic id;
  dynamic userId;
  dynamic gateId;
  dynamic reasonId;
  dynamic unitId;
  dynamic concigereId;
  dynamic visitorName;
  dynamic visitorPhone;
  dynamic checkInDate;
  dynamic checkInTime;
  dynamic checkOutDate;
  dynamic checkOutTime;
  dynamic inNote;
  dynamic outNote;
  dynamic keyLog;
  dynamic isContractors;
  dynamic deletedAt;
  dynamic createdAt;
  dynamic updatedAt;
  User? user;
  Reason? reason;

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    gateId = json['gate_id'];
    reasonId = json['reason_id'];
    unitId = json['unit_id'];
    concigereId = json['concigere_id'];
    visitorName = json['visitor_name'];
    visitorPhone = json['visitor_phone'];
    checkInDate = json['check_in_date'];
    checkInTime = json['check_in_time'];
    checkOutDate = json['check_out_date'];
    checkOutTime = json['check_out_time'];
    inNote = json['in_note'];
    outNote = json['out_note'];
    keyLog = json['key_log'];
    isContractors = json['is_contractors'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    user = json['user'] is Map ? User.fromJson(json['user']) : null;
    reason = json['reason'] is Map ? Reason.fromJson(json['reason']) : null;
  }
}

class User {
  dynamic id;
  dynamic role;
  dynamic name;
  dynamic email;
  dynamic emailVerifiedAt;
  dynamic dPassword;
  dynamic mobileNo;
  dynamic gender;
  dynamic dateOfBirth;
  dynamic address;
  dynamic psLatitude;
  dynamic psLongitude;
  dynamic fcmToken;
  dynamic forgetPassKey;
  dynamic moduleLock;
  dynamic isOnline;
  dynamic lastOnlineAt;
  dynamic status;
  dynamic profile;
  dynamic isDeleted;
  dynamic deletedAt;
  dynamic createdAt;
  dynamic updatedAt;
  Addressh? addressh;
  List<String>? profilepath;

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
    isOnline = json['is_online'];
    lastOnlineAt = json['last_online_at'];
    status = json['status'];
    profile = json['profile'];
    isDeleted = json['is_deleted'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    addressh =
        json['addressh'] is Map ? Addressh.fromJson(json['addressh']) : null;

    profilepath = _safeStringList(json['profilepath']);
  }
}

class Addressh {
  dynamic street;
  dynamic city;
  dynamic state;
  dynamic country;

  Addressh.fromJson(Map<String, dynamic> json) {
    street = json['street'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
  }
}

class Reason {
  dynamic id;
  dynamic userId;
  dynamic reason;
  dynamic createdAt;
  dynamic updatedAt;

  Reason.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    reason = json['reason'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class Links {
  dynamic url;
  dynamic label;
  dynamic active;

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }
}

/// ---------- SAFETY HELPERS ----------

int? _safeInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

List<T>? _safeList<T>(dynamic value, T Function(dynamic) builder) {
  if (value is List) return value.map((e) => builder(e)).toList();
  return null;
}

List<String>? _safeStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String && value.contains(",")) {
    return value.split(",").map((e) => e.trim()).toList();
  }
  return [value.toString()];
}
