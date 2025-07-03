class AmenitiesModel {
  int? status;
  String? message;
  List<Data>? data;

  AmenitiesModel({this.status, this.message, this.data});

  AmenitiesModel.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? name;
  String? description;
  List<String>? imageUrl;
  String? rulesNotice;
  OperatingHours? operatingHours;
  String? bookingLimitDuration;
  List<String>? durationOptions;
  int? capacity;
  int? maxBookingPerDay;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? totalBookingSlots;
  int? bookedSlots;
  int? availableSlots;

  Data({
    this.id,
    this.userId,
    this.name,
    this.description,
    this.imageUrl,
    this.rulesNotice,
    this.operatingHours,
    this.bookingLimitDuration,
    this.durationOptions,
    this.capacity,
    this.maxBookingPerDay,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.totalBookingSlots,
    this.bookedSlots,
    this.availableSlots,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    description = json['description'];
    imageUrl = (json['image_url'] as List?)?.map((e) => e.toString()).toList();
    rulesNotice = json['rules_notice'];
    operatingHours = (json['operating_hours'] is Map)
        ? OperatingHours.fromJson(json['operating_hours'])
        : null;

    bookingLimitDuration = json['booking_limit_duration'];
    durationOptions = (json['duration_options'] as List?)
        ?.map((e) => e.toString())
        .toList();
    capacity = json['capacity'];
    maxBookingPerDay = json['max_booking_per_day'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalBookingSlots = json['total_booking_slots'];
    bookedSlots = json['booked_slots'];
    availableSlots = json['available_slots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['description'] = description;
    data['image_url'] = imageUrl;
    data['rules_notice'] = rulesNotice;
    if (operatingHours != null) {
      data['operating_hours'] = operatingHours!.toJson();
    }
    data['booking_limit_duration'] = bookingLimitDuration;
    data['duration_options'] = durationOptions;
    data['capacity'] = capacity;
    data['max_booking_per_day'] = maxBookingPerDay;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['total_booking_slots'] = totalBookingSlots;
    data['booked_slots'] = bookedSlots;
    data['available_slots'] = availableSlots;
    return data;
  }
}

class OperatingHours {
  Monday? monday;
  Monday? tuesday;
  Monday? wednesday;
  Monday? thursday;
  Monday? friday;
  Monday? saturday;
  Monday? sunday;

  OperatingHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  OperatingHours.fromJson(Map<String, dynamic> json) {
    monday = json['monday'] != null ? Monday.fromJson(json['monday']) : null;
    tuesday = json['tuesday'] != null ? Monday.fromJson(json['tuesday']) : null;
    wednesday =
    json['wednesday'] != null ? Monday.fromJson(json['wednesday']) : null;
    thursday =
    json['thursday'] != null ? Monday.fromJson(json['thursday']) : null;
    friday = json['friday'] != null ? Monday.fromJson(json['friday']) : null;
    saturday =
    json['saturday'] != null ? Monday.fromJson(json['saturday']) : null;
    sunday = json['sunday'] != null ? Monday.fromJson(json['sunday']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (monday != null) data['monday'] = monday!.toJson();
    if (tuesday != null) data['tuesday'] = tuesday!.toJson();
    if (wednesday != null) data['wednesday'] = wednesday!.toJson();
    if (thursday != null) data['thursday'] = thursday!.toJson();
    if (friday != null) data['friday'] = friday!.toJson();
    if (saturday != null) data['saturday'] = saturday!.toJson();
    if (sunday != null) data['sunday'] = sunday!.toJson();
    return data;
  }
}

class Monday {
  String? open;
  String? close;

  Monday({this.open, this.close});

  Monday.fromJson(Map<String, dynamic> json) {
    open = json['open'];
    close = json['close'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['open'] = open;
    data['close'] = close;
    return data;
  }
}
