class StroyModel {
  int? status;
  String? message;
  Data? data;

  StroyModel({this.status, this.message, this.data});

  StroyModel.fromJson(Map<String, dynamic> json) {
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
  Owner? owner;
  List<FeaturedPosts>? featuredPosts;

  Data({this.owner, this.featuredPosts});

  Data.fromJson(Map<String, dynamic> json) {
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
    if (json['featured_posts'] != null) {
      featuredPosts = <FeaturedPosts>[];
      json['featured_posts'].forEach((v) {
        featuredPosts!.add(new FeaturedPosts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    if (this.featuredPosts != null) {
      data['featured_posts'] =
          this.featuredPosts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Owner {
  int? userId;
  String? name;
  String? logo;

  Owner({this.userId, this.name, this.logo});

  Owner.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    logo = json['logo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['logo'] = this.logo;
    return data;
  }
}

class FeaturedPosts {
  int? id;
  String? type;
  String? file;
  String? status;
  String? createdAt;

  FeaturedPosts({this.id, this.type, this.file, this.status, this.createdAt});

  FeaturedPosts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    file = json['file'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['file'] = this.file;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}
