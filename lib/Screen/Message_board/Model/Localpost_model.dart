class Localpost_model {
  int? status;
  String? message;
  List<Data>? data;

  Localpost_model({this.status, this.message, this.data});

  Localpost_model.fromJson(Map<String, dynamic> json) {
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
  String? buildingId;
  String? residentType;
  String? title;
  String? coreOpt;
  String? boostLevelId;
  String? type;
  String? storyPost;
  String? views;
  String? text;
  List<String>? file;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? totalLikes;
  int? totalComments;
  int? totalReport;
  int? totalShare;
  List<Users>? users;

  Data(
      {this.id,
      this.userId,
      this.buildingId,
      this.title,
      this.residentType,
      this.coreOpt,
      this.boostLevelId,
      this.type,
      this.storyPost,
      this.views,
      this.text,
      this.file,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.totalLikes,
      this.totalComments,
      this.totalReport,
      this.totalShare,
      this.users});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingId = json['building_id'];
    residentType = json['residentType'];
    coreOpt = json['coreOpt'];
    boostLevelId = json['boost_level_id'];
    type = json['type'];
    storyPost = json['story_post'];
    views = json['views'];
    text = json['text'];
    title = json['title'];
    file = json['file'].cast<String>();
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalLikes = json['total_likes'];
    totalComments = json['total_comments'];
    totalReport = json['total_report'];
    totalShare = json['total_share'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['building_id'] = this.buildingId;
    data['residentType'] = this.residentType;
    data['coreOpt'] = this.coreOpt;
    data['boost_level_id'] = this.boostLevelId;
    data['type'] = this.type;
    data['title'] = this.title;
    data['story_post'] = this.storyPost;
    data['views'] = this.views;
    data['text'] = this.text;
    data['file'] = this.file;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['total_likes'] = this.totalLikes;
    data['total_comments'] = this.totalComments;
    data['total_report'] = this.totalReport;
    data['total_share'] = this.totalShare;
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
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
  String? profiles;

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
      this.updatedAt,
      this.profiles});

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
    profiles = json['profiles'];
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
    data['profiles'] = this.profiles;
    return data;
  }
}
