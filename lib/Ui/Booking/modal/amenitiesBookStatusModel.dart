class BookAmenitiesStatusModel {
  int? status;
  String? message;
  Data? data;

  BookAmenitiesStatusModel({this.status, this.message, this.data});

  BookAmenitiesStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<December>? december;
  List<November>? november;
  List<October>? october;
  List<September>? september;
  List<August>? august;
  List<July>? july;
  List<June>? june;
  List<May>? may;
  List<April>? april;
  List<March>? march;
  List<February>? february;
  List<January>? january;

  Data({
    this.december,
    this.november,
    this.october,
    this.september,
    this.august,
    this.july,
    this.june,
    this.may,
    this.april,
    this.march,
    this.february,
    this.january,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['december'] != null) {
      december = <December>[];
      json['december'].forEach((v) {
        december!.add(December.fromJson(v));
      });
    }
    if (json['november'] != null) {
      november = <November>[];
      json['november'].forEach((v) {
        november!.add(November.fromJson(v));
      });
    }
    if (json['october'] != null) {
      october = <October>[];
      json['october'].forEach((v) {
        october!.add(October.fromJson(v));
      });
    }
    if (json['september'] != null) {
      september = <September>[];
      json['september'].forEach((v) {
        september!.add(September.fromJson(v));
      });
    }
    if (json['august'] != null) {
      august = <August>[];
      json['august'].forEach((v) {
        august!.add(August.fromJson(v));
      });
    }
    if (json['july'] != null) {
      july = <July>[];
      json['july'].forEach((v) {
        july!.add(July.fromJson(v));
      });
    }
    if (json['june'] != null) {
      june = <June>[];
      json['june'].forEach((v) {
        june!.add(June.fromJson(v));
      });
    }
    if (json['may'] != null) {
      may = <May>[];
      json['may'].forEach((v) {
        may!.add(May.fromJson(v));
      });
    }
    if (json['april'] != null) {
      april = <April>[];
      json['april'].forEach((v) {
        april!.add(April.fromJson(v));
      });
    }
    if (json['march'] != null) {
      march = <March>[];
      json['march'].forEach((v) {
        march!.add(March.fromJson(v));
      });
    }
    if (json['february'] != null) {
      february = <February>[];
      json['february'].forEach((v) {
        february!.add(February.fromJson(v));
      });
    }
    if (json['january'] != null) {
      january = <January>[];
      json['january'].forEach((v) {
        january!.add(January.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.december != null) {
      data['december'] = this.december!.map((v) => v.toJson()).toList();
    }
    if (this.november != null) {
      data['november'] = this.november!.map((v) => v.toJson()).toList();
    }
    if (this.october != null) {
      data['october'] = this.october!.map((v) => v.toJson()).toList();
    }
    if (this.september != null) {
      data['september'] = this.september!.map((v) => v.toJson()).toList();
    }
    if (this.august != null) {
      data['august'] = this.august!.map((v) => v.toJson()).toList();
    }
    if (this.july != null) {
      data['july'] = this.july!.map((v) => v.toJson()).toList();
    }
    if (this.june != null) {
      data['june'] = this.june!.map((v) => v.toJson()).toList();
    }
    if (this.may != null) {
      data['may'] = this.may!.map((v) => v.toJson()).toList();
    }
    if (this.april != null) {
      data['april'] = this.april!.map((v) => v.toJson()).toList();
    }
    if (this.march != null) {
      data['march'] = this.march!.map((v) => v.toJson()).toList();
    }
    if (this.february != null) {
      data['february'] = this.february!.map((v) => v.toJson()).toList();
    }
    if (this.january != null) {
      data['january'] = this.january!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class December {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  var rsvp;
  var attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  December({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  December.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class Amenity {
  int? id;
  int? userId;
  String? name;
  String? description;
  List<String>? imageUrl;
  String? rulesNotice;
  OperatingHours? operatingHours;
  List<String>? durationOptions;
  int? capacity;
  int? maxBookingPerDay;
  String? status;
  String? createdAt;
  String? updatedAt;

  Amenity({
    this.id,
    this.userId,
    this.name,
    this.description,
    this.imageUrl,
    this.rulesNotice,
    this.operatingHours,
    this.durationOptions,
    this.capacity,
    this.maxBookingPerDay,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Amenity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['image_url'].cast<String>();
    rulesNotice = json['rules_notice'];
    operatingHours =
        json['operating_hours'] != null
            ? OperatingHours.fromJson(json['operating_hours'])
            : null;
    durationOptions = json['duration_options'].cast<String>();
    capacity = json['capacity'];
    maxBookingPerDay = json['max_booking_per_day'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image_url'] = this.imageUrl;
    data['rules_notice'] = this.rulesNotice;
    if (this.operatingHours != null) {
      data['operating_hours'] = this.operatingHours!.toJson();
    }
    data['duration_options'] = this.durationOptions;
    data['capacity'] = this.capacity;
    data['max_booking_per_day'] = this.maxBookingPerDay;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class OperatingHours {
  List<Monday> monday = [];
  List<Monday> tuesday = [];
  List<Monday> wednesday = [];
  List<Monday> thursday = [];
  List<Monday> friday = [];
  List<Monday> saturday = [];
  List<Monday> sunday = [];

  OperatingHours.fromJson(Map<String, dynamic> json) {
    monday = _parseDay(json['monday']);
    tuesday = _parseDay(json['tuesday']);
    wednesday = _parseDay(json['wednesday']);
    thursday = _parseDay(json['thursday']);
    friday = _parseDay(json['friday']);
    saturday = _parseDay(json['saturday']);
    sunday = _parseDay(json['sunday']);
  }

  static List<Monday> _parseDay(dynamic dayData) {
    if (dayData is List) {
      return dayData
          .map((e) => Monday.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday.map((e) => e.toJson()).toList(),
      'tuesday': tuesday.map((e) => e.toJson()).toList(),
      'wednesday': wednesday.map((e) => e.toJson()).toList(),
      'thursday': thursday.map((e) => e.toJson()).toList(),
      'friday': friday.map((e) => e.toJson()).toList(),
      'saturday': saturday.map((e) => e.toJson()).toList(),
      'sunday': sunday.map((e) => e.toJson()).toList(),
    };
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['open'] = this.open;
    data['close'] = this.close;
    return data;
  }
}

class June {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  June({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  June.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class November {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  November({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  November.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class October {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  October({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  October.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class September {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  September({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  September.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class August {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  August({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  August.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class July {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  July({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  July.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class May {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  May({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  May.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class April {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  April({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  April.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class March {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  String? startTime;
  String? endTime;
  Amenity? amenity;

  March({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  March.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class February {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  String? startTime;
  String? endTime;
  Amenity? amenity;

  February({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  February.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}

class January {
  int? bookingId;
  int? userId;
  String? status;
  String? requestedAt;
  String? rsvp;
  String? attended;
  Amenity? amenity;
  String? startTime;
  String? endTime;

  January({
    this.bookingId,
    this.userId,
    this.status,
    this.requestedAt,
    this.rsvp,
    this.attended,
    this.amenity,
    this.startTime,
    this.endTime,
  });

  January.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    userId = json['user_id'];
    status = json['status'];
    requestedAt = json['requested_at'];
    rsvp = json['rsvp'];
    attended = json['attended'];
    endTime = json['end_time'];
    startTime = json['start_time'];
    amenity =
        json['amenity'] != null ? Amenity.fromJson(json['amenity']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = this.bookingId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['requested_at'] = this.requestedAt;
    data['rsvp'] = this.rsvp;
    data['attended'] = this.attended;
    data['end_time'] = this.endTime;
    data['start_time'] = this.startTime;
    if (this.amenity != null) {
      data['amenity'] = this.amenity!.toJson();
    }
    return data;
  }
}
