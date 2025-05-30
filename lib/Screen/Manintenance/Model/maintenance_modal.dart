class MaintenanceModel {
  int? status;
  String? message;
  List<Data>? data;

  MaintenanceModel({this.status, this.message, this.data});

  MaintenanceModel.fromJson(Map<String, dynamic> json) {
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
  String? buildingId;
  String? unitId;
  String? subject;
  String? date;
  String? note;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.userId,
      this.buildingId,
      this.unitId,
      this.subject,
      this.date,
      this.note,
      this.status,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingId = json['building_id'];
    unitId = json['unit_id'];
    subject = json['subject'];
    date = json['date'];
    note = json['note'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['building_id'] = this.buildingId;
    data['unit_id'] = this.unitId;
    data['subject'] = this.subject;
    data['date'] = this.date;
    data['note'] = this.note;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
