class CreateGroupModel {
  int? status;
  String? message;
  Data? data;

  CreateGroupModel({this.status, this.message, this.data});

  CreateGroupModel.fromJson(Map<String, dynamic> json) {
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
  String? createdBy;
  String? name;
  String? details;
  String? images;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data({
    this.createdBy,
    this.name,
    this.details,
    this.images,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  Data.fromJson(Map<String, dynamic> json) {
    createdBy = json['created_by'];
    name = json['name'];
    details = json['details'];
    images = json['images'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_by'] = this.createdBy;
    data['name'] = this.name;
    data['details'] = this.details;
    data['images'] = this.images;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
