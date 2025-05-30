class MessageBoardModal {
  int? status;
  String? message;
  List<Data>? data;

  MessageBoardModal({this.status, this.message, this.data});

  MessageBoardModal.fromJson(Map<String, dynamic> json) {
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
  int? buildingId;
  String? residentType;
  String? coreOpt;
  Null? boostLevelId;
  Null? type;
  String? storyPost;
  Null? views;
  String? text;
  List<String>? file;
  Null? status;
  String? createdAt;
  String? updatedAt;
  User? user;
  int? totalLikes;
  int? totalComments;
  int? totalReport;
  int? totalShare;
  List<PostEngagement>? postEngagement;

  Data(
      {this.id,
      this.userId,
      this.buildingId,
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
      this.user,
      this.totalLikes,
      this.totalComments,
      this.totalReport,
      this.totalShare,
      this.postEngagement});

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
    file = json['file'].cast<String>();
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    totalLikes = json['total_likes'];
    totalComments = json['total_comments'];
    totalReport = json['total_report'];
    totalShare = json['total_share'];
    if (json['post_engagement'] != null) {
      postEngagement = <PostEngagement>[];
      json['post_engagement'].forEach((v) {
        postEngagement!.add(new PostEngagement.fromJson(v));
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
    data['story_post'] = this.storyPost;
    data['views'] = this.views;
    data['text'] = this.text;
    data['file'] = this.file;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['total_likes'] = this.totalLikes;
    data['total_comments'] = this.totalComments;
    data['total_report'] = this.totalReport;
    data['total_share'] = this.totalShare;
    if (this.postEngagement != null) {
      data['post_engagement'] =
          this.postEngagement!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
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
  Null? address;
  Null? city;
  Null? state;
  Null? country;
  Null? zipCode;
  Null? shiftStart;
  Null? shiftEnd;
  String? conStartTime;
  String? conEndTime;
  String? livestatus;
  String? createdAt;
  String? updatedAt;

  User(
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
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
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

class PostEngagement {
  int? id;
  int? userId;
  int? postId;
  Null? likes;
  String? comments;
  Null? report;
  Null? reportComment;
  Null? share;
  String? createdAt;
  String? updatedAt;

  PostEngagement(
      {this.id,
      this.userId,
      this.postId,
      this.likes,
      this.comments,
      this.report,
      this.reportComment,
      this.share,
      this.createdAt,
      this.updatedAt});

  PostEngagement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    postId = json['post_id'];
    likes = json['likes'];
    comments = json['comments'];
    report = json['report'];
    reportComment = json['report_comment'];
    share = json['share'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['post_id'] = this.postId;
    data['likes'] = this.likes;
    data['comments'] = this.comments;
    data['report'] = this.report;
    data['report_comment'] = this.reportComment;
    data['share'] = this.share;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
