class MyGroupRequestModel {
  int? status;
  String? message;
  List<Data>? data;

  MyGroupRequestModel({this.status, this.message, this.data});

  MyGroupRequestModel.fromJson(Map<String, dynamic> json) {
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
  int? groupId;
  int? userId;
  String? status;
  String? createdAt;
  String? updatedAt;
  Group? group;

  Data({
    this.id,
    this.groupId,
    this.userId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.group,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupId = json['group_id'];
    userId = json['user_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    group = json['group'] != null ? new Group.fromJson(json['group']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['group_id'] = this.groupId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.group != null) {
      data['group'] = this.group!.toJson();
    }
    return data;
  }
}

class Group {
  int? id;
  int? createdBy;
  String? name;
  String? details;
  String? images;
  String? createdAt;
  String? updatedAt;

  Group({
    this.id,
    this.createdBy,
    this.name,
    this.details,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdBy = json['created_by'];
    name = json['name'];
    details = json['details'];
    images = json['images'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_by'] = this.createdBy;
    data['name'] = this.name;
    data['details'] = this.details;
    data['images'] = this.images;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
