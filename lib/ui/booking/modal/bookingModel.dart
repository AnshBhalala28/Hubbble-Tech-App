// ---------- Helpers ----------
int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
String? _toStr(dynamic v) => v?.toString();

List<String> _toStrList(dynamic v) {
  if (v == null) return [];
  if (v is List) return v.map((e) => e.toString()).toList();
  return [v.toString()];
}

// ---------- Root ----------
class AmenitiesModel {
  int? status;
  String? message;
  Data? data;

  AmenitiesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    status = _toInt(json['status']);
    message = _toStr(json['message']);
    data = json['data'] is Map ? Data.fromJson(json['data']) : null;
  }
}

// ---------- Pagination ----------
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

  Data.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;

    currentPage = _toInt(json['current_page']);
    firstPageUrl = _toStr(json['first_page_url']);
    lastPage = _toInt(json['last_page']);
    lastPageUrl = _toStr(json['last_page_url']);
    nextPageUrl = _toStr(json['next_page_url']);
    prevPageUrl = _toStr(json['prev_page_url']);
    total = _toInt(json['total']);
    perPage = _toInt(json['per_page']);
    totalPages = _toInt(json['total_pages']);

    if (json['data'] is List) {
      data = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Data1.fromJson(e))
          .toList();
    }

    if (json['links'] is List) {
      links = (json['links'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Links.fromJson(e))
          .toList();
    }
  }
}

// ---------- Amenity ----------
class Data1 {
  int? id;
  int? userId;
  int? conciergeId;

  String? name;
  String? description;
  List<String> imageUrl = [];
  String? rulesNotice;

  OperatingHours? operatingHours;
  OperatingHours? remainingSlots;

  String? bookingLimitDuration;
  List<String> durationOptions = [];

  int? capacity;
  int? totalBookingSlots;
  int? bookedSlots;
  int? availableSlots;

  String? maxBookingPerDay;
  String? maxBookingsPerSession;
  String? maxBookingPerMonth;

  String? isAllDayBooking;
  String? maintenanceDuration;

  String? status;
  int? residentId;
  int? residentUnitId;
  int? requireConfirmation;

  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  List<ExistingBooking> existingBookings = [];

  Data1.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;

    id = _toInt(json['id']);
    userId = _toInt(json['user_id']);
    conciergeId = _toInt(json['concierge_id']);

    name = _toStr(json['name']);
    description = _toStr(json['description']);

    imageUrl = _toStrList(json['image_url']);
    rulesNotice = _toStr(json['rules_notice']);

    bookingLimitDuration = _toStr(json['booking_limit_duration']);
    durationOptions = _toStrList(json['duration_options']);

    capacity = _toInt(json['capacity']);
    totalBookingSlots = _toInt(json['total_booking_slots']);
    bookedSlots = _toInt(json['booked_slots']);
    availableSlots = _toInt(json['available_slots']);

    maxBookingPerDay = _toStr(json['max_booking_per_day']);
    maxBookingsPerSession = _toStr(json['max_bookings_per_session']);
    maxBookingPerMonth = _toStr(json['max_booking_per_month']);

    isAllDayBooking = _toStr(json['is_all_day_booking']);
    maintenanceDuration = _toStr(json['maintenance_duration']);

    status = _toStr(json['status']);
    residentId = _toInt(json['resident_id']);
    residentUnitId = _toInt(json['resident_unit_id']);
    requireConfirmation = _toInt(json['require_confirmation']);

    deletedAt = _toStr(json['deleted_at']);
    createdAt = _toStr(json['created_at']);
    updatedAt = _toStr(json['updated_at']);

    if (json['operating_hours'] is Map) {
      operatingHours = OperatingHours.fromJson(json['operating_hours']);
    }

    if (json['remaining_slots'] is Map) {
      remainingSlots = OperatingHours.fromJson(json['remaining_slots']);
    }

    if (json['existing_bookings'] is List) {
      existingBookings = (json['existing_bookings'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ExistingBooking.fromJson(e))
          .toList();
    }
  }
}

// ---------- Existing Booking ----------
class ExistingBooking {
  String? startTime;
  String? endTime;

  ExistingBooking.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    startTime = _toStr(json['start_time']);
    endTime = _toStr(json['end_time']);
  }
}

// ---------- Operating Hours ----------
// class OperatingHours {
//   Map<String, List<TimeSlot>> days = {};
//
//   OperatingHours.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return;
//
//     json.forEach((key, value) {
//       if (value is List) {
//         days[key] = value
//             .whereType<Map<String, dynamic>>()
//             .map((e) => TimeSlot.fromJson(e))
//             .toList();
//       }
//     });
//   }
// }
// ---------- Operating Hours ----------
class OperatingHours {
  List<TimeSlot>? monday;
  List<TimeSlot>? tuesday;
  List<TimeSlot>? wednesday;
  List<TimeSlot>? thursday;
  List<TimeSlot>? friday;
  List<TimeSlot>? saturday;
  List<TimeSlot>? sunday;

  OperatingHours.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;

    monday = _parseTimeSlots(json['monday']);
    tuesday = _parseTimeSlots(json['tuesday']);
    wednesday = _parseTimeSlots(json['wednesday']);
    thursday = _parseTimeSlots(json['thursday']);
    friday = _parseTimeSlots(json['friday']);
    saturday = _parseTimeSlots(json['saturday']);
    sunday = _parseTimeSlots(json['sunday']);
  }

  List<TimeSlot>? _parseTimeSlots(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((e) => TimeSlot.fromJson(e))
          .toList();
    }
    return null;
  }

  // Helper method to get slots for a specific day
  List<TimeSlot>? getSlotsForDay(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return monday;
      case 'tuesday':
        return tuesday;
      case 'wednesday':
        return wednesday;
      case 'thursday':
        return thursday;
      case 'friday':
        return friday;
      case 'saturday':
        return saturday;
      case 'sunday':
        return sunday;
      default:
        return null;
    }
  }
}
// ---------- Time Slot ----------
class TimeSlot {
  String? open;
  String? close;

  TimeSlot.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    open = _toStr(json['open']);
    close = _toStr(json['close']);
  }
}

// ---------- Links ----------
class Links {
  String? url;
  String? label;
  bool? active;

  Links.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    url = _toStr(json['url']);
    label = _toStr(json['label']);
    active = json['active'];
  }
}