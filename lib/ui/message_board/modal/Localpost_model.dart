class Localpost_model {
  int? status;
  String? message;
  Data? data;

  Localpost_model({this.status, this.message, this.data});

  Localpost_model.fromJson(Map<String, dynamic> json) {
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
  int? currentPage;
  List<Data1>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  var prevPageUrl;
  int? to;
  int? total;
  int? totalPages;

  Data({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
    this.totalPages,
  });

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data1>[];
      json['data'].forEach((v) {
        data!.add(Data1.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total_pages'] = this.totalPages;

    data['total'] = this.total;
    return data;
  }
}

class Data1 {
  int? id;
  int? userId;
  var buildingId;
  String? residentType;
  String? title;
  var coreOpt;
  var boostLevelId;
  var type;
  String? storyPost;
  var views;
  String? text;
  List<String>? file;
  var status;
  var deletedAt;
  String? createdAt;
  String? updatedAt;
  int? totalLikes;
  int? totalComments;
  int? totalReport;
  int? totalShare;
  List<Users>? users;

  Data1({
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
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.totalLikes,
    this.totalComments,
    this.totalReport,
    this.totalShare,
    this.users,
  });

  Data1.fromJson(Map<String, dynamic> json) {
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
    file = json['file'].cast<String>();
    status = json['status'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalLikes = json['total_likes'];
    totalComments = json['total_comments'];
    totalReport = json['total_report'];
    totalShare = json['total_share'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['building_id'] = this.buildingId;
    data['residentType'] = this.residentType;
    data['title'] = this.title;
    data['coreOpt'] = this.coreOpt;
    data['boost_level_id'] = this.boostLevelId;
    data['type'] = this.type;
    data['story_post'] = this.storyPost;
    data['views'] = this.views;
    data['text'] = this.text;
    data['file'] = this.file;
    data['status'] = this.status;
    data['deleted_at'] = this.deletedAt;
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
  var emailVerifiedAt;
  String? dPassword;
  var mobileNo;
  String? gender;
  var dateOfBirth;
  dynamic address; // <-- CHANGE HERE
  var psLatitude;
  var psLongitude;
  String? fcmToken;
  var forgetPassKey;
  var moduleLock;
  String? isOnline;
  var lastOnlineAt;
  String? status;
  String? profile;
  var deletedAt;
  String? createdAt;
  String? updatedAt;
  String? profiles;
  String? buildingName;
  String? areaName;

  Users({
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
    this.isOnline,
    this.lastOnlineAt,
    this.status,
    this.profile,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.profiles,
    this.buildingName,
    this.areaName,
  });

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

    // ✅ Custom logic for dynamic address
    if (json['address'] is String) {
      address = json['address'];
    } else if (json['address'] is Map<String, dynamic>) {
      address = Address.fromJson(json['address']);
    }

    psLatitude = json['ps_latitude'];
    psLongitude = json['ps_longitude'];
    fcmToken = json['fcm_token'];
    forgetPassKey = json['forget_pass_key'];
    moduleLock = json['module_lock'];
    isOnline = json['is_online'];
    lastOnlineAt = json['last_online_at'];
    status = json['status'];
    profile = json['profile'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    profiles = json['profiles'];
    buildingName = json['building_name'];
    areaName = json['area_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['role'] = this.role;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['d_password'] = this.dPassword;
    data['mobile_no'] = this.mobileNo;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;

    // ✅ Custom logic for dynamic address in toJson
    if (address is String) {
      data['address'] = address;
    } else if (address is Address) {
      data['address'] = (address as Address).toJson();
    }

    data['ps_latitude'] = this.psLatitude;
    data['ps_longitude'] = this.psLongitude;
    data['fcm_token'] = this.fcmToken;
    data['forget_pass_key'] = this.forgetPassKey;
    data['module_lock'] = this.moduleLock;
    data['is_online'] = this.isOnline;
    data['last_online_at'] = this.lastOnlineAt;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['profiles'] = this.profiles;
    data['building_name'] = this.buildingName;
    data['area_name'] = this.areaName;
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
    final Map<String, dynamic> data = {};
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
