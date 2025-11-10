class Add_Post_Model {
  int? status;
  String? message;
  Data? data;

  Add_Post_Model({this.status, this.message, this.data});

  Add_Post_Model.fromJson(Map<String, dynamic> json) {
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
  String? text;
  String? userId;
  String? storyPost;
  List<String>? file;
  String? residentType;
  String? updatedAt;
  String? createdAt;
  int? id;
  int? totalLikes;
  int? totalComments;
  int? totalReport;
  int? totalShare;

  Data({
    this.text,
    this.userId,
    this.storyPost,
    this.file,
    this.residentType,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.totalLikes,
    this.totalComments,
    this.totalReport,
    this.totalShare,
  });

  Data.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    userId = json['user_id'];
    storyPost = json['story_post'];
    file = json['file'] != null ? List<String>.from(json['file']) : null;
    residentType = json['residentType'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    totalLikes = json['total_likes'];
    totalComments = json['total_comments'];
    totalReport = json['total_report'];
    totalShare = json['total_share'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['text'] = text;
    data['user_id'] = userId;
    data['story_post'] = storyPost;
    if (file != null) {
      data['file'] = file;
    }
    data['residentType'] = residentType;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['total_likes'] = totalLikes;
    data['total_comments'] = totalComments;
    data['total_report'] = totalReport;
    data['total_share'] = totalShare;
    return data;
  }
}
