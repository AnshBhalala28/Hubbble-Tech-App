class StatusModal {
  int? status;
  String? message;
  List<Data>? data;

  StatusModal({this.status, this.message, this.data});

  StatusModal.fromJson(Map<String, dynamic> json) {
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
  String? startTime;
  String? endTime;
  String? bookingDate;
  String? isFirstSlot;

  Data({this.startTime, this.endTime, this.isFirstSlot, this.bookingDate});

  Data.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    bookingDate = json['booking_date'];
    isFirstSlot = json['is_first_slot'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['booking_date'] = this.bookingDate;
    data['is_first_slot'] = this.isFirstSlot;
    return data;
  }
}
