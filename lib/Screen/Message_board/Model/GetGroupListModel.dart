class GetGroupListModel {
  int? status;
  String? message;
  List<Data>? data;

  GetGroupListModel({this.status, this.message, this.data});

  GetGroupListModel.fromJson(Map<String, dynamic> json) {
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
  int? createdBy;
  String? name;
  var details;
  var images;
  String? createdAt;
  String? updatedAt;
  int? unreadCount;
  Lastmessage? lastmessage;

  Data(
      {this.id,
      this.createdBy,
      this.name,
      this.details,
      this.images,
      this.createdAt,
      this.updatedAt,
      this.unreadCount,
      this.lastmessage});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdBy = json['created_by'];
    name = json['name'];
    details = json['details'];
    images = json['images'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    unreadCount = json['unread_count'];
    lastmessage = json['lastmessage'] != null
        ? new Lastmessage.fromJson(json['lastmessage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_by'] = this.createdBy;
    data['name'] = this.name;
    data['details'] = this.details;
    data['images'] = this.images;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['unread_count'] = this.unreadCount;
    if (this.lastmessage != null) {
      data['lastmessage'] = this.lastmessage!.toJson();
    }
    return data;
  }
}

class Lastmessage {
  int? id;
  int? senderId;
  int? receiverId;
  int? groupId;
  String? type;
  String? msgTo;
  String? messageType;
  String? message;
  List<String>? file;
  String? isRead;
  String? createdAt;
  String? updatedAt;
  String? firstName;
  String? lastName;
  String? profileImage;
  Users? users;

  Lastmessage(
      {this.id,
      this.senderId,
      this.receiverId,
      this.groupId,
      this.type,
      this.msgTo,
      this.messageType,
      this.message,
      this.file,
      this.isRead,
      this.createdAt,
      this.updatedAt,
      this.firstName,
      this.lastName,
      this.profileImage,
      this.users});

  Lastmessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    groupId = json['group_id'];
    type = json['type'];
    msgTo = json['msg_to'];
    messageType = json['message_type'];
    message = json['message'];
    file = json['file'] != null ? List<String>.from(json['file']) : [];
    isRead = json['is_read'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    profileImage = json['profile_image'];
    users = json['users'] != null ? new Users.fromJson(json['users']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['sender_id'] = this.senderId;
    data['receiver_id'] = this.receiverId;
    data['group_id'] = this.groupId;
    data['type'] = this.type;
    data['msg_to'] = this.msgTo;
    data['message_type'] = this.messageType;
    data['message'] = this.message;
    data['file'] = this.file;
    data['is_read'] = this.isRead;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['profile_image'] = this.profileImage;
    if (this.users != null) {
      data['users'] = this.users!.toJson();
    }
    return data;
  }
}

class Users {
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

  Users(
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
      this.psLatitude,
      this.psLongitude,
      this.fcmToken,
      this.forgetPassKey,
      this.moduleLock,
      this.status,
      this.profile,
      this.createdAt,
      this.updatedAt});

  Users.fromJson(Map<String, dynamic> json) {
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
