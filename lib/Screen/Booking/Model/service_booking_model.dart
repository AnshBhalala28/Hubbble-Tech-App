class ServiceBookingModel {
  String? status;
  List<Data>? data;

  ServiceBookingModel({this.status, this.data});

  ServiceBookingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? serviceId;
  String? title;
  String? description;
  String? price;
  String? totalPrice;
  String? bookingDatetime;
  String? status;
  List<String>? images;

  Data(
      {this.serviceId,
      this.title,
      this.description,
      this.price,
      this.totalPrice,
      this.bookingDatetime,
      this.status,
      this.images});

  Data.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    title = json['title'];
    description = json['description'];
    price = json['price'];
    totalPrice = json['total_price'];
    bookingDatetime = json['booking_datetime'];
    status = json['status'];
    images = (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service_id'] = this.serviceId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['price'] = this.price;
    data['total_price'] = this.totalPrice;
    data['booking_datetime'] = this.bookingDatetime;
    data['status'] = this.status;
    data['images'] = this.images;
    return data;
  }
}
