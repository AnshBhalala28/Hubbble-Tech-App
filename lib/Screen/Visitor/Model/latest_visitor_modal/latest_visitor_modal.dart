// class LatestVisitorModal {
//   int? status;
//   String? message;
//   List<Data>? data;
//
//   LatestVisitorModal({this.status, this.message, this.data});
//
//   LatestVisitorModal.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   int? id;
//   int? userId;
//   var gateId;
//   int? reasonId;
//   int? unitId;
//   String? visitorName;
//   String? visitorPhone;
//   String? checkInDate;
//   String? checkInTime;
//   String? checkOutDate;
//   String? checkOutTime;
//   var inNote;
//   var outNote;
//   String? keyLog;
//   String? isContractors;
//   String? createdAt;
//   String? updatedAt;
//
//   Data(
//       {this.id,
//       this.userId,
//       this.gateId,
//       this.reasonId,
//       this.unitId,
//       this.visitorName,
//       this.visitorPhone,
//       this.checkInDate,
//       this.checkInTime,
//       this.checkOutDate,
//       this.checkOutTime,
//       this.inNote,
//       this.outNote,
//       this.keyLog,
//       this.isContractors,
//       this.createdAt,
//       this.updatedAt});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     gateId = json['gate_id'];
//     reasonId = json['reason_id'];
//     unitId = json['unit_id'];
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
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['gate_id'] = this.gateId;
//     data['reason_id'] = this.reasonId;
//     data['unit_id'] = this.unitId;
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
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
class LatestVisitorModal {
  int? status;
  String? message;
  List<Data>? data;

  LatestVisitorModal({this.status, this.message, this.data});

  LatestVisitorModal.fromJson(Map<String, dynamic> json) {
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
  String? gateId;
  int? reasonId;
  int? unitId;
  String? concigereId;
  String? visitorName;
  String? visitorPhone;
  String? checkInDate;
  String? checkInTime;
  String? checkOutDate;
  String? checkOutTime;
  String? inNote;
  String? outNote;
  String? keyLog;
  String? isContractors;
  String? createdAt;
  String? updatedAt;
  User? user;
  Reason? reason;

  Data(
      {this.id,
      this.userId,
      this.gateId,
      this.reasonId,
      this.unitId,
      this.concigereId,
      this.visitorName,
      this.visitorPhone,
      this.checkInDate,
      this.checkInTime,
      this.checkOutDate,
      this.checkOutTime,
      this.inNote,
      this.outNote,
      this.keyLog,
      this.isContractors,
      this.createdAt,
      this.updatedAt,
      this.user,
      this.reason});

  Data.fromJson(Map<String, dynamic> json) {
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    reason =
        json['reason'] != null ? new Reason.fromJson(json['reason']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['gate_id'] = this.gateId;
    data['reason_id'] = this.reasonId;
    data['unit_id'] = this.unitId;
    data['concigere_id'] = this.concigereId;
    data['visitor_name'] = this.visitorName;
    data['visitor_phone'] = this.visitorPhone;
    data['check_in_date'] = this.checkInDate;
    data['check_in_time'] = this.checkInTime;
    data['check_out_date'] = this.checkOutDate;
    data['check_out_time'] = this.checkOutTime;
    data['in_note'] = this.inNote;
    data['out_note'] = this.outNote;
    data['key_log'] = this.keyLog;
    data['is_contractors'] = this.isContractors;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.reason != null) {
      data['reason'] = this.reason!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  int? role;
  String? name;
  String? email;
  var emailVerifiedAt;
  var dPassword;
  int? mobileNo;
  String? gender;
  String? address;
  var fcmToken;
  var forgetPassKey;
  String? moduleLock;
  String? status;
  var profile;
  var createdAt;
  String? updatedAt;

  User(
      {this.id,
      this.role,
      this.name,
      this.email,
      this.emailVerifiedAt,
      this.dPassword,
      this.mobileNo,
      this.gender,
      this.address,
      this.fcmToken,
      this.forgetPassKey,
      this.moduleLock,
      this.status,
      this.profile,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];
    address = json['address'];
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
    data['address'] = this.address;
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

class Reason {
  int? id;
  int? userId;
  String? reason;
  String? createdAt;
  String? updatedAt;

  Reason({this.id, this.userId, this.reason, this.createdAt, this.updatedAt});

  Reason.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    reason = json['reason'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['reason'] = this.reason;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
