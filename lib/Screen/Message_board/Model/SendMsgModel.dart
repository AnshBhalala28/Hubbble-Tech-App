class SendMsgModel {
  int? status;
  String? message;
  Data? data;

  SendMsgModel({this.status, this.message, this.data});

  SendMsgModel.fromJson(Map<String, dynamic> json) {
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
  String? senderId;
  int? messageType;
  String? message;
  int? isRead;
  List<String>? file;
  String? type;
  String? msgTo;
  String? receiverId;
  String? groupId;
  String? updatedAt;
  String? createdAt;
  int? id;
  String? files;

  Data(
      {this.senderId,
      this.messageType,
      this.message,
      this.isRead,
      this.file,
      this.type,
      this.msgTo,
      this.receiverId,
      this.groupId,
      this.updatedAt,
      this.createdAt,
      this.id,
      this.files});

  Data.fromJson(Map<String, dynamic> json) {
    senderId = json['sender_id'];
    messageType = json['message_type'];
    message = json['message'];
    isRead = json['is_read'];
    // if (json['file'] != null) {
    //   file = <Null>[];
    //   json['file'].forEach((v) {
    //     file!.add(new Null.fromJson(v));
    //   });
    // }
    file = json['file'] != null ? List<String>.from(json['file']) : null;
    type = json['type'];
    msgTo = json['msg_to'];
    receiverId = json['receiver_id'];
    groupId = json['group_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    files = json['files'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sender_id'] = this.senderId;
    data['message_type'] = this.messageType;
    data['message'] = this.message;
    data['is_read'] = this.isRead;
    if (file != null) {
      data['file'] = file;
    }
    // if (this.file != null) {
    //   data['file'] = this.file!.map((v) => v.toJson()).toList();
    // }
    data['type'] = this.type;
    data['msg_to'] = this.msgTo;
    data['receiver_id'] = this.receiverId;
    data['group_id'] = this.groupId;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['files'] = this.files;
    return data;
  }
}
