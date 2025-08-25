class SendPostCommentsModel {
  int? status;
  String? message;
  Data? data;

  SendPostCommentsModel({this.status, this.message, this.data});

  SendPostCommentsModel.fromJson(Map<String, dynamic> json) {
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
  String? userId;
  String? postId;
  String? likes;
  String? comments;
  String? report;
  String? reportComment;
  String? share;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data({
    this.userId,
    this.postId,
    this.likes,
    this.comments,
    this.report,
    this.reportComment,
    this.share,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    postId = json['post_id'];
    likes = json['likes'];
    comments = json['comments'];
    report = json['report'];
    reportComment = json['report_comment'];
    share = json['share'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['post_id'] = this.postId;
    data['likes'] = this.likes;
    data['comments'] = this.comments;
    data['report'] = this.report;
    data['report_comment'] = this.reportComment;
    data['share'] = this.share;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
