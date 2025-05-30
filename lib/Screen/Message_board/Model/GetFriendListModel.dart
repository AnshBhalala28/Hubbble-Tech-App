class GetFriendListModel {
  int? status;
  String? message;
  List<Data>? data;

  GetFriendListModel({this.status, this.message, this.data});

  GetFriendListModel.fromJson(Map<String, dynamic> json) {
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
  int? senderId;
  int? receiverId;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? senderName;
  String? senderImage;
  String? receiverName;
  String? receiverImage;
  int? unreadCount;
  String? lastMessage;

  Data(
      {this.id,
      this.senderId,
      this.receiverId,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.senderName,
      this.senderImage,
      this.receiverName,
      this.receiverImage,
      this.unreadCount,
      this.lastMessage});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    senderName = json['sender_name'];
    senderImage = json['sender_image'];
    receiverName = json['receiver_name'];
    receiverImage = json['receiver_image'];
    unreadCount = json['unread_count'];
    lastMessage = json['last_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sender_id'] = this.senderId;
    data['receiver_id'] = this.receiverId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['sender_name'] = this.senderName;
    data['sender_image'] = this.senderImage;
    data['receiver_name'] = this.receiverName;
    data['receiver_image'] = this.receiverImage;
    data['unread_count'] = this.unreadCount;
    data['last_message'] = this.lastMessage;
    return data;
  }
}
