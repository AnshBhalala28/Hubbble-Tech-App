class EventDetailModel {
  int? status;
  String? message;
  List<Data>? data;

  EventDetailModel({this.status, this.message, this.data});

  EventDetailModel.fromJson(Map<String, dynamic> json) {
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
  int? requestId;
  int? eventId;
  String? eventName;
  String? eventDate;
  String? eventLocation;
  String? status;
  String? rsvp;
  int? isAttended;

  Data(
      {this.requestId,
      this.eventId,
      this.eventName,
      this.eventDate,
      this.eventLocation,
      this.status,
      this.rsvp,
      this.isAttended});

  Data.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id'];
    eventId = json['event_id'];
    eventName = json['event_name'];
    eventDate = json['event_date'];
    eventLocation = json['event_location'];
    status = json['status'];
    rsvp = json['rsvp'];
    isAttended = json['is_attended'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = this.requestId;
    data['event_id'] = this.eventId;
    data['event_name'] = this.eventName;
    data['event_date'] = this.eventDate;
    data['event_location'] = this.eventLocation;
    data['status'] = this.status;
    data['rsvp'] = this.rsvp;
    data['is_attended'] = this.isAttended;
    return data;
  }
}
