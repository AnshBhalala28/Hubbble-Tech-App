// class EventlistModel {
//   int? status;
//   String? message;
//   List<Data>? data;

//   EventlistModel({this.status, this.message, this.data});

//   EventlistModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Data {
//   int? id;
//   int? creatorId;
//   String? title;
//   String? description;
//   String? apartmentNumber;
//   String? attachment;
//   String? eventDate;
//   String? location;
//   String? latitude;
//   String? longitude;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//   String? requestEvent;

//   Data(
//       {this.id,
//       this.creatorId,
//       this.title,
//       this.description,
//       this.apartmentNumber,
//       this.attachment,
//       this.eventDate,
//       this.location,
//       this.latitude,
//       this.longitude,
//       this.status,
//       this.createdAt,
//       this.updatedAt,
//       this.requestEvent});

//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     creatorId = json['creator_id'];
//     title = json['title'];
//     description = json['description'];
//     apartmentNumber = json['apartment_number'];
//     attachment = json['attachment'];
//     eventDate = json['event_date'];
//     location = json['location'];
//     latitude = json['latitude'];
//     longitude = json['longitude'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     requestEvent = json['request_event'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['creator_id'] = this.creatorId;
//     data['title'] = this.title;
//     data['description'] = this.description;
//     data['apartment_number'] = this.apartmentNumber;
//     data['attachment'] = this.attachment;
//     data['event_date'] = this.eventDate;
//     data['location'] = this.location;
//     data['latitude'] = this.latitude;
//     data['longitude'] = this.longitude;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['request_event'] = this.requestEvent;
//     return data;
//   }
// }
class EventlistModel {
  int? status;
  String? message;
  Data? data;

  EventlistModel({this.status, this.message, this.data});

  EventlistModel.fromJson(Map<String, dynamic> json) {
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
  int? currentPage;
  List<Data1>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  Null? nextPageUrl;
  String? path;
  int? perPage;
  Null? prevPageUrl;
  int? to;
  int? total;

  Data(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data1>[];
      json['data'].forEach((v) {
        data!.add(new Data1.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class Data1 {
  int? id;
  int? creatorId;
  String? title;
  Null? description;
  Null? apartmentNumber;
  String? attachment;
  String? eventDate;
  String? location;
  Null? latitude;
  Null? longitude;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? bio;
  String? eventTime;
  String? startTime;
  String? endTime;
  String? requestEvent;

  Data1(
      {this.id,
        this.creatorId,
        this.title,
        this.description,
        this.apartmentNumber,
        this.attachment,
        this.eventDate,
        this.location,
        this.latitude,
        this.longitude,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.bio,
        this.eventTime,
        this.startTime,
        this.endTime,
        this.requestEvent});

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    creatorId = json['creator_id'];
    title = json['title'];
    description = json['description'];
    apartmentNumber = json['apartment_number'];
    attachment = json['attachment'];
    eventDate = json['event_date'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bio = json['bio'];
    eventTime = json['event_time'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    requestEvent = json['request_event'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['creator_id'] = this.creatorId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['apartment_number'] = this.apartmentNumber;
    data['attachment'] = this.attachment;
    data['event_date'] = this.eventDate;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['bio'] = this.bio;
    data['event_time'] = this.eventTime;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['request_event'] = this.requestEvent;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}

