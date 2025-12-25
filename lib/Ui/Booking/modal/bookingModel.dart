// ================= Existing Booking =================
class ExistingBooking {
  String? startTime;
  String? endTime;

  ExistingBooking({this.startTime, this.endTime});

  ExistingBooking.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time']?.toString();
    endTime = json['end_time']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

// ================= AmenitiesModel =================
class AmenitiesModel {
  int? status;
  String? message;
  Data? data;

  AmenitiesModel({this.status, this.message, this.data});

  AmenitiesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] is Map<String, dynamic>
        ? Data.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

// ================= Data (Pagination) =================
class Data {
  int? currentPage;
  List<Data1>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;
  int? totalPages;

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];

    if (json['data'] is List) {
      data = (json['data'] as List)
          .map((e) => Data1.fromJson(e))
          .toList();
    } else {
      data = [];
    }

    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];

    if (json['links'] is List) {
      links =
          (json['links'] as List).map((e) => Links.fromJson(e)).toList();
    }

    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data?.map((e) => e.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links?.map((e) => e.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
      'total_pages': totalPages,
    };
  }
}

// ================= Data1 (Amenity) =================
class Data1 {
  int? id;
  int? userId;
  String? name;
  String? description;
  List<String> imageUrl = [];
  String? rulesNotice;
  OperatingHours? operatingHours;
  String? bookingLimitDuration;
  List<String> durationOptions = [];
  int? capacity;
  int? maxBookingPerDay;
  String? status;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  int? totalBookingSlots;
  int? bookedSlots;
  int? availableSlots;

  List<ExistingBooking> existingBookings = [];

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    description = json['description'];

    imageUrl =
    json['image_url'] is List ? List<String>.from(json['image_url']) : [];

    rulesNotice = json['rules_notice'];

    /// ✅ FIXED operating_hours (NO CRASH)
    final oh = json['operating_hours'];
    if (oh != null && oh is Map<String, dynamic>) {
      operatingHours = OperatingHours.fromJson(oh);
    } else {
      operatingHours = null;
    }

    bookingLimitDuration = json['booking_limit_duration'];

    durationOptions = json['duration_options'] is List
        ? List<String>.from(json['duration_options'])
        : [];

    capacity = json['capacity'];
    maxBookingPerDay = json['max_booking_per_day'];
    status = json['status'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalBookingSlots = json['total_booking_slots'];
    bookedSlots = json['booked_slots'];
    availableSlots = json['available_slots'];

    /// ✅ FIXED existing_bookings
    if (json['existing_bookings'] is List) {
      existingBookings = (json['existing_bookings'] as List)
          .map((e) => ExistingBooking.fromJson(e))
          .toList();
    } else {
      existingBookings = [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'rules_notice': rulesNotice,
      'operating_hours': operatingHours?.toJson(),
      'booking_limit_duration': bookingLimitDuration,
      'duration_options': durationOptions,
      'capacity': capacity,
      'max_booking_per_day': maxBookingPerDay,
      'status': status,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'total_booking_slots': totalBookingSlots,
      'booked_slots': bookedSlots,
      'available_slots': availableSlots,
      'existing_bookings':
      existingBookings.map((e) => e.toJson()).toList(),
    };
  }
}

class TimeSlot {
  String? open;
  String? close;

  TimeSlot({this.open, this.close});

  TimeSlot.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toString();
    close = json['close']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
    };
  }
}

class OperatingHours {
  List<TimeSlot>? monday;
  List<TimeSlot>? tuesday;
  List<TimeSlot>? wednesday;
  List<TimeSlot>? thursday;
  List<TimeSlot>? friday;
  List<TimeSlot>? saturday;
  List<TimeSlot>? sunday;

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
    monday = _parseTimeSlots(json['monday']);
    tuesday = _parseTimeSlots(json['tuesday']);
    wednesday = _parseTimeSlots(json['wednesday']);
    thursday = _parseTimeSlots(json['thursday']);
    friday = _parseTimeSlots(json['friday']);
    saturday = _parseTimeSlots(json['saturday']);
    sunday = _parseTimeSlots(json['sunday']);
  }

  List<TimeSlot>? _parseTimeSlots(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map<TimeSlot>((item) => TimeSlot.fromJson(item)).toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday?.map((e) => e.toJson()).toList(),
      'tuesday': tuesday?.map((e) => e.toJson()).toList(),
      'wednesday': wednesday?.map((e) => e.toJson()).toList(),
      'thursday': thursday?.map((e) => e.toJson()).toList(),
      'friday': friday?.map((e) => e.toJson()).toList(),
      'saturday': saturday?.map((e) => e.toJson()).toList(),
      'sunday': sunday?.map((e) => e.toJson()).toList(),
    };
  }
}

// Remove the Monday class since we're using TimeSlot now
// ================= Monday =================

// ================= Links =================
class Links {
  String? url;
  String? label;
  bool? active;

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}
