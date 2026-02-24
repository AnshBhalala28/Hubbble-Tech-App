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
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['status'] = status;
    result['message'] = message;
    if (data != null) {
      result['data'] = data!.map((v) => v.toJson()).toList();
    }
    return result;
  }
}

class Data {
  int? id;
  int? userId;
  int? buildingId;
  String? residentType;
  String? title;
  int? nocomment;
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
  User? user;
  int? totalLikes;
  int? totalComments;
  int? totalReport;
  int? totalShare;
  List<PostEngagement>? postEngagement;

  Data({
    this.id,
    this.userId,
    this.buildingId,
    this.residentType,
    this.title,
    this.coreOpt,
    this.boostLevelId,
    this.type,
    this.storyPost,
    this.views,
    this.text,
    this.file,
    this.status,
    this.createdAt,
    this.nocomment,
    this.updatedAt,
    this.user,
    this.totalLikes,
    this.totalComments,
    this.totalReport,
    this.totalShare,
    this.postEngagement,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingId = json['building_id'];
    residentType = json['residentType'];
    title = json['title'];
    coreOpt = json['coreOpt'];
    boostLevelId = json['boost_level_id'];
    type = json['type'];
    storyPost = json['story_post'];
    views = json['views'];
    text = json['text'];
    nocomment = json['nocomment'];
    file = json['file'] != null ? List<String>.from(json['file']) : null;
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    totalLikes = json['total_likes'];
    totalComments = json['total_comments'];
    totalReport = json['total_report'];
    totalShare = json['total_share'];
    if (json['post_engagement'] != null) {
      postEngagement = <PostEngagement>[];
      json['post_engagement'].forEach((v) {
        postEngagement!.add(PostEngagement.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['id'] = id;
    result['user_id'] = userId;
    result['building_id'] = buildingId;
    result['title'] = title;
    result['residentType'] = residentType;
    result['coreOpt'] = coreOpt;
    result['boost_level_id'] = boostLevelId;
    result['type'] = type;
    result['story_post'] = storyPost;
    result['views'] = views;
    result['text'] = text;
    result['file'] = file;
    result['nocomment'] = nocomment;
    result['status'] = status;
    result['created_at'] = createdAt;
    result['updated_at'] = updatedAt;
    if (user != null) {
      result['user'] = user!.toJson();
    }
    result['total_likes'] = totalLikes;
    result['total_comments'] = totalComments;
    result['total_report'] = totalReport;
    result['total_share'] = totalShare;
    if (postEngagement != null) {
      result['post_engagement'] =
          postEngagement!.map((v) => v.toJson()).toList();
    }
    return result;
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

  User({
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
    final Map<String, dynamic> result = {};
    result['id'] = id;
    result['user_id'] = userId;
    result['building_id'] = buildingId;
    result['gate_id'] = gateId;
    result['email'] = email;
    result['first_name'] = firstName;
    result['last_name'] = lastName;
    result['gender'] = gender;
    result['date_of_birth'] = dateOfBirth;
    result['phone_number'] = phoneNumber;
    result['concierge_image'] = conciergeImage;
    result['address'] = address;
    result['city'] = city;
    result['state'] = state;
    result['country'] = country;
    result['zip_code'] = zipCode;
    result['shift_start'] = shiftStart;
    result['shift_end'] = shiftEnd;
    result['con_start_time'] = conStartTime;
    result['con_end_time'] = conEndTime;
    result['livestatus'] = livestatus;
    result['created_at'] = createdAt;
    result['updated_at'] = updatedAt;
    return result;
  }
}

class PostEngagement {
  int? id;
  int? userId;
  int? postId;
  String? userType;
  String? likes;
  String? comments;
  String? report;
  String? reportComment;
  String? share;
  String? createdAt;
  String? updatedAt;

  PostEngagement({
    this.id,
    this.userId,
    this.postId,
    this.userType,
    this.likes,
    this.comments,
    this.report,
    this.reportComment,
    this.share,
    this.createdAt,
    this.updatedAt,
  });

  PostEngagement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    postId = json['post_id'];
    userType = json['user_type'];
    likes = json['likes'];
    comments = json['comments'];
    report = json['report'];
    reportComment = json['report_comment'];
    share = json['share'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['id'] = id;
    result['user_id'] = userId;
    result['post_id'] = postId;
    result['user_type'] = userType;
    result['likes'] = likes;
    result['comments'] = comments;
    result['report'] = report;
    result['report_comment'] = reportComment;
    result['share'] = share;
    result['created_at'] = createdAt;
    result['updated_at'] = updatedAt;
    return result;
  }
}
