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
    return {'start_time': startTime, 'end_time': endTime};
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
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

// ================= Data (Pagination FULL) =================
class Data {
  int? currentPage;
  List<Data1> data = [];
  String? firstPageUrl;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? prevPageUrl;
  int? total;
  int? perPage;
  int? totalPages;
  List<Links> links = [];

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];

    if (json['data'] is List) {
      data = (json['data'] as List)
          .where((e) => e != null)
          .map((e) => Data1.fromJson(e))
          .toList();
    }

    firstPageUrl = json['first_page_url'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url']?.toString();
    prevPageUrl = json['prev_page_url']?.toString();
    total = json['total'];
    perPage = json['per_page'];
    totalPages = json['total_pages'];

    if (json['links'] is List) {
      links = (json['links'] as List)
          .where((e) => e != null)
          .map((e) => Links.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((e) => e.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
      'total': total,
      'per_page': perPage,
      'total_pages': totalPages,
      'links': links.map((e) => e.toJson()).toList(),
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
  var capacity;
  var maxBookingPerDay;
  var status;
  var createdAt;
  var updatedAt;
  var totalBookingSlots;
  var bookedSlots;
  var availableSlots;
  var maxBookingPerMonth;
  String? isAllDayBooking;
  var maintenanceDuration;
  List<ExistingBooking> existingBookings = [];

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    description = json['description'];

    imageUrl = _parseStringList(json['image_url']);
    durationOptions = _parseStringList(json['duration_options']);

    rulesNotice = json['rules_notice'];
    bookingLimitDuration = json['booking_limit_duration'];

    capacity = json['capacity'];
    maxBookingPerMonth = json['max_booking_per_month'];
    maxBookingPerDay = json['max_booking_per_day'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    totalBookingSlots = json['total_booking_slots'];
    bookedSlots = json['booked_slots'];
    availableSlots = json['available_slots'];

    isAllDayBooking = json['is_all_day_booking'];
    maintenanceDuration = json['maintenance_duration'];

    final oh = json['remaining_slots'];
    if (oh is Map<String, dynamic>) {
      operatingHours = OperatingHours.fromJson(oh);
    }

    if (json['existing_bookings'] is List) {
      existingBookings = (json['existing_bookings'] as List)
          .where((e) => e != null)
          .map((e) => ExistingBooking.fromJson(e))
          .toList();
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
      'remaining_slots': operatingHours?.toJson(),
      'booking_limit_duration': bookingLimitDuration,
      'duration_options': durationOptions,
      'capacity': capacity,
      'max_booking_per_month': maxBookingPerMonth,
      'max_booking_per_day': maxBookingPerDay,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'total_booking_slots': totalBookingSlots,
      'maintenance_duration': maintenanceDuration,
      'booked_slots': bookedSlots,
      'is_all_day_booking': isAllDayBooking,
      'available_slots': availableSlots,
      'existing_bookings': existingBookings.map((e) => e.toJson()).toList(),
    };
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) return [value];
    return [];
  }
}

// ================= TimeSlot =================
class TimeSlot {
  String? open;
  String? close;

  TimeSlot({this.open, this.close});

  TimeSlot.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toString();
    close = json['close']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {'open': open, 'close': close};
  }
}

// ================= Operating Hours =================
class OperatingHours {
  List<TimeSlot>? monday;
  List<TimeSlot>? tuesday;
  List<TimeSlot>? wednesday;
  List<TimeSlot>? thursday;
  List<TimeSlot>? friday;
  List<TimeSlot>? saturday;
  List<TimeSlot>? sunday;

  OperatingHours.fromJson(Map<String, dynamic> json) {
    monday = _parse(json['monday']);
    tuesday = _parse(json['tuesday']);
    wednesday = _parse(json['wednesday']);
    thursday = _parse(json['thursday']);
    friday = _parse(json['friday']);
    saturday = _parse(json['saturday']);
    sunday = _parse(json['sunday']);
  }

  List<TimeSlot>? _parse(dynamic data) {
    if (data is List) {
      return data.map((e) => TimeSlot.fromJson(e)).toList();
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

// ================= Links =================
class Links {
  String? url;
  String? label;
  bool? active;

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    label = json['label']?.toString();
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'label': label, 'active': active};
  }
}
