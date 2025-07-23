class MaintenanceDetailModel {
  int? status;
  String? message;
  MaintenanceDetailData? data;

  MaintenanceDetailModel({this.status, this.message, this.data});

  MaintenanceDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null
            ? MaintenanceDetailData.fromJson(json['data'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['status'] = status;
    result['message'] = message;
    if (data != null) {
      result['data'] = data!.toJson();
    }
    return result;
  }
}

class MaintenanceDetailData {
  int? id;
  int? userId;
  dynamic buildingId;
  dynamic unitId;
  String? subject;
  dynamic date;
  String? note;
  String? status;
  String? createdAt;
  String? updatedAt;

  MaintenanceDetailData({
    this.id,
    this.userId,
    this.buildingId,
    this.unitId,
    this.subject,
    this.date,
    this.note,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory MaintenanceDetailData.fromJson(Map<String, dynamic> json) {
    return MaintenanceDetailData(
      id: json['id'],
      userId: json['user_id'],
      buildingId: json['building_id'],
      unitId: json['unit_id'],
      subject: json['subject'],
      date: json['date'],
      note: json['note'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'building_id': buildingId,
      'unit_id': unitId,
      'subject': subject,
      'date': date,
      'note': note,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
