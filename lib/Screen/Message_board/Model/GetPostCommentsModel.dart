// class GetPostCommentsModel {
//   int? status;
//   String? message;
//   List<Data>? data;
//
//   GetPostCommentsModel({this.status, this.message, this.data});
//
//   GetPostCommentsModel.fromJson(Map<String, dynamic> json) {
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
//   int? postId;
//   String? likes;
//   String? comments;
//   String? report;
//   String? reportComment;
//   String? share;
//   String? createdAt;
//   String? updatedAt;
//
//   Data(
//       {this.id,
//       this.userId,
//       this.postId,
//       this.likes,
//       this.comments,
//       this.report,
//       this.reportComment,
//       this.share,
//       this.createdAt,
//       this.updatedAt});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     postId = json['post_id'];
//     likes = json['likes'];
//     comments = json['comments'];
//     report = json['report'];
//     reportComment = json['report_comment'];
//     share = json['share'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['post_id'] = this.postId;
//     data['likes'] = this.likes;
//     data['comments'] = this.comments;
//     data['report'] = this.report;
//     data['report_comment'] = this.reportComment;
//     data['share'] = this.share;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }

class GetPostCommentsModel {
  int? status;
  String? message;
  List<Data>? data;

  GetPostCommentsModel({this.status, this.message, this.data});

  GetPostCommentsModel.fromJson(Map<String, dynamic> json) {
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
  String? comment;
  User? user;

  Data({this.id, this.comment, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];

    //user = json['user'] != null ? new User.fromJson(json['user']) : null;


    // FIX: Only parse user if it's a Map, not a List
    if (json['user'] is Map<String, dynamic>) {
      user = User.fromJson(json['user']);
    } else {
      user = null;
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? name;
  String? profile;

  User({this.name, this.profile});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    profile = json['profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['profile'] = this.profile;
    return data;
  }
}
