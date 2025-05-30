class ParcelViewModal {
  int? status;
  String? message;
  List<Data3>? data;

  ParcelViewModal({this.status, this.message, this.data});

  ParcelViewModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data3>[];
      json['data'].forEach((v) {
        data!.add(new Data3.fromJson(v));
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

class Data3 {
  int? id;
  String? userId;
  int? requestId;
  int? receiverId;
  String? apartmentNo;
  int? noOfParcel;
  var collectedBy;
  var amount;
  String? comment;
  var trackingNumber;
  var courierService;
  String? deliveryStatus;
  String? createdAt;
  String? updatedAt;
  Requester? requester;

  Data3(
      {this.id,
      this.userId,
      this.requestId,
      this.receiverId,
      this.apartmentNo,
      this.noOfParcel,
      this.collectedBy,
      this.amount,
      this.comment,
      this.trackingNumber,
      this.courierService,
      this.deliveryStatus,
      this.createdAt,
      this.updatedAt,
      this.requester});

  Data3.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    requestId = json['request_id'];
    receiverId = json['receiver_id'];
    apartmentNo = json['apartment_no'];
    noOfParcel = json['no_of_parcel'];
    collectedBy = json['collected_by'];
    amount = json['amount'];
    comment = json['comment'];
    trackingNumber = json['tracking_number'];
    courierService = json['courier_service'];
    deliveryStatus = json['delivery_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    requester = json['requester'] != null
        ? new Requester.fromJson(json['requester'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['request_id'] = this.requestId;
    data['receiver_id'] = this.receiverId;
    data['apartment_no'] = this.apartmentNo;
    data['no_of_parcel'] = this.noOfParcel;
    data['collected_by'] = this.collectedBy;
    data['amount'] = this.amount;
    data['comment'] = this.comment;
    data['tracking_number'] = this.trackingNumber;
    data['courier_service'] = this.courierService;
    data['delivery_status'] = this.deliveryStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.requester != null) {
      data['requester'] = this.requester!.toJson();
    }
    return data;
  }
}

class Requester {
  int? id;
  int? role;
  String? name;
  String? email;
  Null? emailVerifiedAt;
  String? dPassword;
  int? mobileNo;
  String? gender;
  String? address;
  Null? fcmToken;
  String? forgetPassKey;
  Null? moduleLock;
  String? status;
  String? profile;
  String? createdAt;
  String? updatedAt;

  Requester(
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

  Requester.fromJson(Map<String, dynamic> json) {
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
