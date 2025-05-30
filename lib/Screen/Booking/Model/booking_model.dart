// class AmenitiesModel {
//   int? status;
//   String? message;
//   List<Data>? data;
//
//   AmenitiesModel({this.status, this.message, this.data});
//
//   AmenitiesModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }
//
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
//
// class Data {
//   int? id;
//   int? userId;
//   String? name;
//   String? description;
//   List<String>? imageUrl;
//   String? rulesNotice;
//   // OperatingHours? operatingHours;z
//   List<String>? durationOptions;
//   int? capacity;
//   int? maxBookingPerDay;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//
//   Data(
//       {this.id,
//         this.userId,
//         this.name,
//         this.description,
//         this.imageUrl,
//         this.rulesNotice,
//         // this.operatingHours,
//         this.durationOptions,
//         this.capacity,
//         this.maxBookingPerDay,
//         this.status,
//         this.createdAt,
//         this.updatedAt});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     name = json['name'];
//     description = json['description'];
//     imageUrl = json['image_url'].cast<String>();
//     rulesNotice = json['rules_notice'];
//     // operatingHours = json['operating_hours'] != null
//     //     ? new OperatingHours.fromJson(json['operating_hours'])
//     //     : null;
//     durationOptions = json['duration_options'].cast<String>();
//     capacity = json['capacity'];
//     maxBookingPerDay = json['max_booking_per_day'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['name'] = this.name;
//     data['description'] = this.description;
//     data['image_url'] = this.imageUrl;
//     data['rules_notice'] = this.rulesNotice;
//     // if (this.operatingHours != null) {
//     //   data['operating_hours'] = this.operatingHours!.toJson();
//     // }
//     data['duration_options'] = this.durationOptions;
//     data['capacity'] = this.capacity;
//     data['max_booking_per_day'] = this.maxBookingPerDay;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class OperatingHours {
//   Monday? monday;
//   Monday? wednesday;
//   Monday? friday;
//   Monday? sunday;
//   Monday? saturday;
//   Monday? tuesday;
//
//   OperatingHours(
//       {this.monday,
//         this.wednesday,
//         this.friday,
//         this.sunday,
//         this.saturday,
//         this.tuesday});
//
//   OperatingHours.fromJson(Map<String, dynamic> json) {
//     monday =
//     json['monday'] != null ? new Monday.fromJson(json['monday']) : null;
//     wednesday = json['wednesday'] != null
//         ? new Monday.fromJson(json['wednesday'])
//         : null;
//     friday =
//     json['friday'] != null ? new Monday.fromJson(json['friday']) : null;
//     sunday =
//     json['sunday'] != null ? new Monday.fromJson(json['sunday']) : null;
//     saturday =
//     json['saturday'] != null ? new Monday.fromJson(json['saturday']) : null;
//     tuesday =
//     json['tuesday'] != null ? new Monday.fromJson(json['tuesday']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.monday != null) {
//       data['monday'] = this.monday!.toJson();
//     }
//     if (this.wednesday != null) {
//       data['wednesday'] = this.wednesday!.toJson();
//     }
//     if (this.friday != null) {
//       data['friday'] = this.friday!.toJson();
//     }
//     if (this.sunday != null) {
//       data['sunday'] = this.sunday!.toJson();
//     }
//     if (this.saturday != null) {
//       data['saturday'] = this.saturday!.toJson();
//     }
//     if (this.tuesday != null) {
//       data['tuesday'] = this.tuesday!.toJson();
//     }
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
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['open'] = this.open;
//     data['close'] = this.close;
//     return data;
//   }
// }
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
  int? userId;
  String? name;
  String? description;
  List<String>? imageUrl;
  String? rulesNotice;

  // OperatingHours? operatingHours;
  var bookingLimitDuration;
  List<String>? durationOptions;
  int? capacity;
  int? maxBookingPerDay;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? totalBookingSlots;
  int? bookedSlots;
  int? availableSlots;

  Data(
      {this.id,
      this.userId,
      this.name,
      this.description,
      this.imageUrl,
      this.rulesNotice,
      // this.operatingHours,
      this.bookingLimitDuration,
      this.durationOptions,
      this.capacity,
      this.maxBookingPerDay,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.totalBookingSlots,
      this.bookedSlots,
      this.availableSlots});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['image_url'].cast<String>();
    rulesNotice = json['rules_notice'];
    // operatingHours = json['operating_hours'] != null
    //     ? new OperatingHours.fromJson(json['operating_hours'])
    //     : null;
    bookingLimitDuration = json['booking_limit_duration'];
    durationOptions = json['duration_options'].cast<String>();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image_url'] = this.imageUrl;
    data['rules_notice'] = this.rulesNotice;
    // if (this.operatingHours != null) {
    //   data['operating_hours'] = this.operatingHours!.toJson();
    // }
    data['booking_limit_duration'] = this.bookingLimitDuration;
    data['duration_options'] = this.durationOptions;
    data['capacity'] = this.capacity;
    data['max_booking_per_day'] = this.maxBookingPerDay;
    data['status'] = this.status;
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
  Monday? wednesday;
  Monday? friday;
  Monday? sunday;

  OperatingHours({this.monday, this.wednesday, this.friday, this.sunday});

  OperatingHours.fromJson(Map<String, dynamic> json) {
    monday =
        json['monday'] != null ? new Monday.fromJson(json['monday']) : null;
    wednesday = json['wednesday'] != null
        ? new Monday.fromJson(json['wednesday'])
        : null;
    friday =
        json['friday'] != null ? new Monday.fromJson(json['friday']) : null;
    sunday =
        json['sunday'] != null ? new Monday.fromJson(json['sunday']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.monday != null) {
      data['monday'] = this.monday!.toJson();
    }
    if (this.wednesday != null) {
      data['wednesday'] = this.wednesday!.toJson();
    }
    if (this.friday != null) {
      data['friday'] = this.friday!.toJson();
    }
    if (this.sunday != null) {
      data['sunday'] = this.sunday!.toJson();
    }
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['open'] = this.open;
    data['close'] = this.close;
    return data;
  }
}
