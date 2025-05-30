class RequestModal {
  int? status;
  String? message;
  Data? data;

  RequestModal({this.status, this.message, this.data});

  RequestModal.fromJson(Map<String, dynamic> json) {
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
  String? userId;
  String? serviceId;
  String? businessId;
  String? requestedDate;
  String? status;
  String? additionalNotes;
  String? updatedAt;
  String? createdAt;
  int? id;

  Data(
      {this.userId,
      this.serviceId,
      this.businessId,
      this.requestedDate,
      this.status,
      this.additionalNotes,
      this.updatedAt,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    serviceId = json['service_id'];
    businessId = json['business_id'];
    requestedDate = json['requested_date'];
    status = json['status'];
    additionalNotes = json['additional_notes'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['service_id'] = this.serviceId;
    data['business_id'] = this.businessId;
    data['requested_date'] = this.requestedDate;
    data['status'] = this.status;
    data['additional_notes'] = this.additionalNotes;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}
