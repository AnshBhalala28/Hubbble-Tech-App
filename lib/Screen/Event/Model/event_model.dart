class EventlistModel {
  int? status;
  String? message;
  List<Data>? data;

  EventlistModel({this.status, this.message, this.data});

  EventlistModel.fromJson(Map<String, dynamic> json) {
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
  int? creatorId;
  String? title;
  String? description;
  String? apartmentNumber;
  String? attachment;
  String? eventDate;
  String? location;
  String? latitude;
  String? longitude;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? requestEvent;

  Data(
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
      this.requestEvent});

  Data.fromJson(Map<String, dynamic> json) {
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
    data['request_event'] = this.requestEvent;
    return data;
  }
}
