// class VisitorModel {
//   int? status;
//   String? message;
//   Data? data;
//
//   VisitorModel({this.status, this.message, this.data});
//
//   VisitorModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   String? userId;
//   String? visitorName;
//   String? visitorPhone;
//   String? checkInDate;
//   String? checkInTime;
//   String? reasonId;
//   String? unitId;
//   String? keyLog;
//   String? isContractors;
//   String? updatedAt;
//   String? createdAt;
//   int? id;
//
//   Data(
//       {this.userId,
//       this.visitorName,
//       this.visitorPhone,
//       this.checkInDate,
//       this.checkInTime,
//       this.reasonId,
//       this.unitId,
//       this.keyLog,
//       this.isContractors,
//       this.updatedAt,
//       this.createdAt,
//       this.id});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     userId = json['user_id'];
//     visitorName = json['visitor_name'];
//     visitorPhone = json['visitor_phone'];
//     checkInDate = json['check_in_date'];
//     checkInTime = json['check_in_time'];
//     reasonId = json['reason_id'];
//     unitId = json['unit_id'];
//     keyLog = json['key_log'];
//     isContractors = json['is_contractors'];
//     updatedAt = json['updated_at'];
//     createdAt = json['created_at'];
//     id = json['id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['user_id'] = this.userId;
//     data['visitor_name'] = this.visitorName;
//     data['visitor_phone'] = this.visitorPhone;
//     data['check_in_date'] = this.checkInDate;
//     data['check_in_time'] = this.checkInTime;
//     data['reason_id'] = this.reasonId;
//     data['unit_id'] = this.unitId;
//     data['key_log'] = this.keyLog;
//     data['is_contractors'] = this.isContractors;
//     data['updated_at'] = this.updatedAt;
//     data['created_at'] = this.createdAt;
//     data['id'] = this.id;
//     return data;
//   }
// }
