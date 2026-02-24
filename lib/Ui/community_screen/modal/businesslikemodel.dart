class BussinessLikeModel {
  int? status;
  String? message;
  Data? data;

  BussinessLikeModel({this.status, this.message, this.data});

  BussinessLikeModel.fromJson(Map<String, dynamic> json) {
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
  var appUserId;
  var businessId;
  var isLike;
  String? createdAt;
  String? updatedAt;

  Data({
    this.appUserId,
    this.businessId,
    this.isLike,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    appUserId = json['app_user_id'];
    businessId = json['business_id'];
    isLike = json['is_like'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['app_user_id'] = this.appUserId;
    data['business_id'] = this.businessId;
    data['is_like'] = this.isLike;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
