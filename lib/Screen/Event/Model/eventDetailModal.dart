class EventDetailModal {
  int? status;
  String? message;
  Data? data;

  EventDetailModal({this.status, this.message, this.data});

  EventDetailModal.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? creatorId;
  String? title;
  var description;
  var apartmentNumber;
  String? attachment;
  String? eventDate;
  String? location;
  var latitude;
  var longitude;
  String? status;
  int? isDeleted;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? bio;
  String? eventTime;
  String? startTime;
  String? endTime;

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
        this.isDeleted,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.bio,
        this.eventTime,
        this.startTime,
        this.endTime});

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
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    bio = json['bio'];
    eventTime = json['event_time'];
    startTime = json['start_time'];
    endTime = json['end_time'];
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
    data['is_deleted'] = this.isDeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['bio'] = this.bio;
    data['event_time'] = this.eventTime;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    return data;
  }
}
