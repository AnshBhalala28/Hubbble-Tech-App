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
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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

    if (json['user'] is Map<String, dynamic>) {
      user = User.fromJson(json['user']);
    } else {
      user = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = this.name;
    data['profile'] = this.profile;
    return data;
  }
}
