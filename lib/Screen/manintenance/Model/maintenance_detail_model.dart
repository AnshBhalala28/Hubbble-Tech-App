class MaintenanceDetailModel {
  int? status;
  String? message;
  Data? data;

  MaintenanceDetailModel({this.status, this.message, this.data});

  MaintenanceDetailModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? userId;
  int? buildingId;
  int? unitId;
  String? subject;
  String? date;
  String? note;
  String? file;
  String? status;
  String? notiRead;
  var deletedAt;
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
        this.file,
        this.status,
        this.notiRead,
        this.deletedAt,
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
    file = json['file'];
    status = json['status'];
    notiRead = json['noti_read'];
    deletedAt = json['deleted_at'];
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
    data['file'] = this.file;
    data['status'] = this.status;
    data['noti_read'] = this.notiRead;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
