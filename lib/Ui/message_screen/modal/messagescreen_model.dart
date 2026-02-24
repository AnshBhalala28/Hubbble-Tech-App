// class MessageModel {
//   int? status;
//   String? message;
//   List<Data>? data;
//
//   MessageModel({this.status, this.message, this.data});
//
//   MessageModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(Data.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Data {
//   int? id;
//   String? messageType;
//   String? message;
//   String? file;
//   String? type;
//   String? createdAt;
//   String? updatedAt;
//   Sender? sender;
//   Receiver? receiver;
//
//   Data({
//     this.id,
//     this.messageType,
//     this.message,
//     this.file,
//     this.type,
//     this.createdAt,
//     this.updatedAt,
//     this.sender,
//     this.receiver,
//   });
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//
//     messageType = json['message_type']?.toString();
//     message = json['message'];
//
//     if (json['file'] is List) {
//       file =
//           (json['file'] as List).isNotEmpty ? json['file'][0].toString() : '';
//     } else {
//       file = json['file']?.toString();
//     }
//
//     type = json['type']?.toString();
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
//     receiver =
//         json['receiver'] != null ? Receiver.fromJson(json['receiver']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['message_type'] = this.messageType;
//     data['message'] = this.message;
//     data['file'] = this.file;
//     data['type'] = this.type;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.sender != null) {
//       data['sender'] = this.sender!.toJson();
//     }
//     if (this.receiver != null) {
//       data['receiver'] = this.receiver!.toJson();
//     }
//     return data;
//   }
// }
//
// class Sender {
//   int? id;
//   String? firstName;
//   String? lastName;
//   String? email;
//   String? profile;
//
//   Sender({this.id, this.firstName, this.lastName, this.email, this.profile});
//
//   Sender.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//     email = json['email'];
//     profile = json['profile'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['first_name'] = this.firstName;
//     data['last_name'] = this.lastName;
//     data['email'] = this.email;
//     data['profile'] = this.profile;
//     return data;
//   }
// }
//
// class Receiver {
//   int? id;
//   String? firstName;
//   String? lastName;
//   String? email;
//   String? profile;
//
//   Receiver({this.id, this.firstName, this.lastName, this.email, this.profile});
//
//   Receiver.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//     email = json['email'];
//     profile = json['profile'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['first_name'] = this.firstName;
//     data['last_name'] = this.lastName;
//     data['email'] = this.email;
//     data['profile'] = this.profile;
//     return data;
//   }
// }
class MessageModel {
  int? status;
  String? message;
  List<MessageData>? data;

  MessageModel({this.status, this.message, this.data});

  MessageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MessageData>[];
      json['data'].forEach((v) {
        data!.add(new MessageData.fromJson(v));
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

class MessageData {
  int? id;
  String? messageType;
  String? message;
  String? file;
  String? type;
  ParcelInfo? parcelInfo;
  VisitorInfo? visitorInfo;
  String? createdAt;
  String? updatedAt;
  Sender? sender;
  Receiver? receiver;
  int? replyToId; // Add this field
  MessageData? replyTo; // Add this field for storing replied message data

  MessageData({
    this.id,
    this.messageType,
    this.message,
    this.file,
    this.type,
    this.parcelInfo,
    this.visitorInfo,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.receiver,
    this.replyToId,
    this.replyTo,
  });

  MessageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageType = json['message_type'];
    message = json['message'];
    file = json['file'];
    type = json['type'];
    replyToId = json['reply_to_id']; // Parse reply_to_id

    if (json['reply_to'] != null) {
      replyTo = MessageData.fromJson(json['reply_to']); // Parse replied message
    }

    parcelInfo = json['parcel_info'] != null
        ? ParcelInfo.fromJson(json['parcel_info'])
        : null;
    visitorInfo = json['visitor_info'] != null
        ? VisitorInfo.fromJson(json['visitor_info'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    receiver = json['receiver'] != null ? Receiver.fromJson(json['receiver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['message_type'] = messageType;
    data['message'] = message;
    data['file'] = file;
    data['type'] = type;
    data['reply_to_id'] = replyToId;
    if (parcelInfo != null) {
      data['parcel_info'] = parcelInfo!.toJson();
    }
    if (visitorInfo != null) {
      data['visitor_info'] = visitorInfo!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    if (receiver != null) {
      data['receiver'] = receiver!.toJson();
    }
    return data;
  }
}

class ParcelInfo {
  int? id;
  Null? trackingNumber;
  String? description;

  ParcelInfo({this.id, this.trackingNumber, this.description});

  ParcelInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    trackingNumber = json['tracking_number'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tracking_number'] = this.trackingNumber;
    data['description'] = this.description;
    return data;
  }
}

class VisitorInfo {
  int? id;
  String? name;
  String? purpose;
  String? description;

  VisitorInfo({this.id, this.name, this.purpose, this.description});

  VisitorInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    purpose = json['purpose'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['purpose'] = this.purpose;
    data['description'] = this.description;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['profile'] = this.profile;
    return data;
  }
}

class Receiver {
  int? id;
  String? firstName;
  String? lastName;
  Null? email;
  Null? profile;

  Receiver({this.id, this.firstName, this.lastName, this.email, this.profile});

  Receiver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    profile = json['profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['profile'] = this.profile;
    return data;
  }
}
