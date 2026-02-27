class GetMsgModel {
  int? status;
  String? message;
  List<Data>? data;

  GetMsgModel({this.status, this.message, this.data});

  GetMsgModel.fromJson(Map<String, dynamic> json) {
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
  String? messageType;
  String? message;
  String? file;
  String? type;
  String? createdAt;
  String? updatedAt;
  Sender? sender;
  Sender? receiver;

  Data({
    this.id,
    this.messageType,
    this.message,
    this.file,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.receiver,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageType = json['message_type'];
    message = json['message'];
    file = json['file'];
    type = json['type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    receiver =
        json['receiver'] != null ? Sender.fromJson(json['receiver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['message_type'] = this.messageType;
    data['message'] = this.message;
    data['file'] = this.file;
    data['type'] = this.type;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.sender != null) {
      data['sender'] = this.sender!.toJson();
    }
    if (this.receiver != null) {
      data['receiver'] = this.receiver!.toJson();
    }
    return data;
  }
}

class Sender {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? profile;

  Sender({this.id, this.firstName, this.lastName, this.email, this.profile});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    profile = json['profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['profile'] = this.profile;
    return data;
  }
}
