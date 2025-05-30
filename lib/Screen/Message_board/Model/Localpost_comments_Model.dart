class Localpost_comments_Model {
  int? status;
  String? message;
  List<Data>? data;

  Localpost_comments_Model({this.status, this.message, this.data});

  Localpost_comments_Model.fromJson(Map<String, dynamic> json) {
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