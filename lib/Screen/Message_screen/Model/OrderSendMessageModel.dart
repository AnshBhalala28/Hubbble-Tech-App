class OrdersendMessageModel {
  int? status;
  String? message;
  Data? data;

  OrdersendMessageModel({this.status, this.message, this.data});

  OrdersendMessageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    var messageField = json['message'];
    if (messageField is String) {
      message = messageField;
    } else if (messageField is Map<String, dynamic>) {
      message = messageField.toString();
    } else {
      message = null;
    }

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
  String? orderProductId;
  String? businessId;
  String? userId;
  String? message;
  String? file;
  int? messageType;
  bool? isRead;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.orderProductId,
      this.businessId,
      this.userId,
      this.message,
      this.file,
      this.messageType,
      this.isRead,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    orderProductId = json['order_product_id'];
    businessId = json['business_id'];
    userId = json['user_id'];
    message = json['message'];
    file = json['file'];
    messageType = json['message_type'];
    isRead = json['is_read'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_product_id'] = this.orderProductId;
    data['business_id'] = this.businessId;
    data['user_id'] = this.userId;
    data['message'] = this.message;
    data['file'] = this.file;
    data['message_type'] = this.messageType;
    data['is_read'] = this.isRead;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
