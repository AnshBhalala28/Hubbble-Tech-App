// class AmenitiesModel {
//   int? status;
//   String? message;
//   List<Data>? data;

//   AmenitiesModel({this.status, this.message, this.data});

//   AmenitiesModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(Data.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['status'] = status;
//     data['message'] = message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Data {
//   int? id;
//   int? userId;
//   String? name;
//   String? description;
//   List<String>? imageUrl;
//   String? rulesNotice;
//   OperatingHours? operatingHours;
//   String? bookingLimitDuration;
//   List<String>? durationOptions;
//   int? capacity;
//   int? maxBookingPerDay;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//   int? totalBookingSlots;
//   int? bookedSlots;
//   int? availableSlots;

//   Data({
//     this.id,
//     this.userId,
//     this.name,
//     this.description,
//     this.imageUrl,
//     this.rulesNotice,
//     this.operatingHours,
//     this.bookingLimitDuration,
//     this.durationOptions,
//     this.capacity,
//     this.maxBookingPerDay,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.totalBookingSlots,
//     this.bookedSlots,
//     this.availableSlots,
//   });

//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     name = json['name'];
//     description = json['description'];
//     imageUrl = (json['image_url'] as List?)?.map((e) => e.toString()).toList();
//     rulesNotice = json['rules_notice'];
//     operatingHours = (json['operating_hours'] is Map)
//         ? OperatingHours.fromJson(json['operating_hours'])
//         : null;

//     bookingLimitDuration = json['booking_limit_duration'];
//     durationOptions = (json['duration_options'] as List?)
//         ?.map((e) => e.toString())
//         .toList();
//     capacity = json['capacity'];
//     maxBookingPerDay = json['max_booking_per_day'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     totalBookingSlots = json['total_booking_slots'];
//     bookedSlots = json['booked_slots'];
//     availableSlots = json['available_slots'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['id'] = id;
//     data['user_id'] = userId;
//     data['name'] = name;
//     data['description'] = description;
//     data['image_url'] = imageUrl;
//     data['rules_notice'] = rulesNotice;
//     if (operatingHours != null) {
//       data['operating_hours'] = operatingHours!.toJson();
//     }
//     data['booking_limit_duration'] = bookingLimitDuration;
//     data['duration_options'] = durationOptions;
//     data['capacity'] = capacity;
//     data['max_booking_per_day'] = maxBookingPerDay;
//     data['status'] = status;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     data['total_booking_slots'] = totalBookingSlots;
//     data['booked_slots'] = bookedSlots;
//     data['available_slots'] = availableSlots;
//     return data;
//   }
// }
//
// class OperatingHours {
//   Monday? monday;
//   Monday? tuesday;
//   Monday? wednesday;
//   Monday? thursday;
//   Monday? friday;
//   Monday? saturday;
//   Monday? sunday;
//
//   OperatingHours({
//     this.monday,
//     this.tuesday,
//     this.wednesday,
//     this.thursday,
//     this.friday,
//     this.saturday,
//     this.sunday,
//   });
//
//   OperatingHours.fromJson(Map<String, dynamic> json) {
//     monday = json['monday'] != null ? Monday.fromJson(json['monday']) : null;
//     tuesday = json['tuesday'] != null ? Monday.fromJson(json['tuesday']) : null;
//     wednesday =
//     json['wednesday'] != null ? Monday.fromJson(json['wednesday']) : null;
//     thursday =
//     json['thursday'] != null ? Monday.fromJson(json['thursday']) : null;
//     friday = json['friday'] != null ? Monday.fromJson(json['friday']) : null;
//     saturday =
//     json['saturday'] != null ? Monday.fromJson(json['saturday']) : null;
//     sunday = json['sunday'] != null ? Monday.fromJson(json['sunday']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     if (monday != null) data['monday'] = monday!.toJson();
//     if (tuesday != null) data['tuesday'] = tuesday!.toJson();
//     if (wednesday != null) data['wednesday'] = wednesday!.toJson();
//     if (thursday != null) data['thursday'] = thursday!.toJson();
//     if (friday != null) data['friday'] = friday!.toJson();
//     if (saturday != null) data['saturday'] = saturday!.toJson();
//     if (sunday != null) data['sunday'] = sunday!.toJson();
//     return data;
//   }
// }
//
// class Monday {
//   String? open;
//   String? close;
//
//   Monday({this.open, this.close});
//
//   Monday.fromJson(Map<String, dynamic> json) {
//     open = json['open'];
//     close = json['close'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['open'] = open;
//     data['close'] = close;
//     return data;
//   }
// }
class AmenitiesModel {
  int? status;
  String? message;
  Data? data;

  AmenitiesModel({this.status, this.message, this.data});

  AmenitiesModel.fromJson(Map<String, dynamic> json) {
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
  Null? deletedAt;
  String? createdAt;
  String? updatedAt;
  int? totalBookingSlots;
  int? bookedSlots;
  int? availableSlots;

  Data1(
      {this.id,
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
        this.deletedAt,
        this.createdAt,
        this.updatedAt,
        this.totalBookingSlots,
        this.bookedSlots,
        this.availableSlots});

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['image_url'].cast<String>();
    rulesNotice = json['rules_notice'];
    operatingHours = (json['operating_hours'] is Map)
        ? OperatingHours.fromJson(json['operating_hours'])
        : null;
    bookingLimitDuration = json['booking_limit_duration'];
    durationOptions = json['duration_options'].cast<String>();
    capacity = json['capacity'];
    maxBookingPerDay = json['max_booking_per_day'];
    status = json['status'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalBookingSlots = json['total_booking_slots'];
    bookedSlots = json['booked_slots'];
    availableSlots = json['available_slots'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image_url'] = this.imageUrl;
    data['rules_notice'] = this.rulesNotice;
    if (operatingHours != null) {
      data['operating_hours'] = operatingHours!.toJson();
    }
    data['booking_limit_duration'] = this.bookingLimitDuration;
    data['duration_options'] = this.durationOptions;
    data['capacity'] = this.capacity;
    data['max_booking_per_day'] = this.maxBookingPerDay;
    data['status'] = this.status;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['total_booking_slots'] = this.totalBookingSlots;
    data['booked_slots'] = this.bookedSlots;
    data['available_slots'] = this.availableSlots;
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
